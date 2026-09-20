import 'dart:async';
import 'dart:convert';

import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Status for the shared Super App cloud-backup controller.
enum AfterCloudBackupStatus { idle, syncing, exporting, restoring, error }

/// Observable state for backup / restore / export.
class AfterCloudBackupState {
  const AfterCloudBackupState({
    this.status = AfterCloudBackupStatus.idle,
    this.lastSyncedMillis,
    this.errorCode,
    this.lastExportJson,
  });

  final AfterCloudBackupStatus status;
  final int? lastSyncedMillis;
  final String? errorCode;

  /// Last successful [exportSnapshot] JSON string (UTF-8).
  final String? lastExportJson;

  AfterCloudBackupState copyWith({
    AfterCloudBackupStatus? status,
    int? lastSyncedMillis,
    String? errorCode,
    String? lastExportJson,
    bool clearError = false,
    bool clearExport = false,
  }) {
    return AfterCloudBackupState(
      status: status ?? this.status,
      lastSyncedMillis: lastSyncedMillis ?? this.lastSyncedMillis,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      lastExportJson:
          clearExport ? null : (lastExportJson ?? this.lastExportJson),
    );
  }
}

/// Builds / applies product payload for cloud backup.
///
/// SuperGarage supplies vehicle stores; scaffolds supply family prefs stores.
class AfterCloudBackupCodec {
  const AfterCloudBackupCodec({
    required this.collect,
    required this.apply,
  });

  final Map<String, dynamic> Function() collect;
  final Future<void> Function(Map<String, dynamic> payload) apply;
}

/// Optional override — products set this at composition root.
final afterCloudBackupCodecProvider = Provider<AfterCloudBackupCodec?>((ref) {
  return null;
});

final afterCloudBackupProvider =
    NotifierProvider<AfterCloudBackupController, AfterCloudBackupState>(
  AfterCloudBackupController.new,
);

/// Shared cloud backup: Firestore blob + optional Storage manifest.
///
/// Complements [FamilyCloudSyncController] (family prefs) with a product-
/// agnostic push/pull/export API every Super App can wire once.
class AfterCloudBackupController extends Notifier<AfterCloudBackupState> {
  static const _stampKey = 'after_cloud_backup_last_synced_millis';
  static const _payloadKey = 'after_cloud_backup_local_payload';

  @override
  AfterCloudBackupState build() {
    final prefs = ref.watch(afterSharedPreferencesProvider);
    return AfterCloudBackupState(
      lastSyncedMillis: prefs.getInt(_stampKey),
    );
  }

  SharedPreferences get _prefs => ref.read(afterSharedPreferencesProvider);

  AfterUserBlobSyncPort get _blob => ref.read(afterUserBlobSyncPortProvider);

  AfterUserMediaSyncPort get _media => ref.read(afterUserMediaSyncPortProvider);

  Future<String?> _resolveUserId() async {
    final session =
        await ref.read(afterAuthRepositoryProvider).getCurrentSession();
    final uid = session.user?.uid;
    if (!afterHasCloudBackupIdentity(
      isAuthenticated: session.isAuthenticated,
      isAnonymous: session.user?.isAnonymous ?? true,
      uid: uid,
    )) {
      return null;
    }
    return uid;
  }

  String get _appId {
    try {
      return PlatformConfig.current.appId;
    } on Object {
      return 'unknown';
    }
  }

  AfterCloudBackupCodec get _codec {
    final codec = ref.read(afterCloudBackupCodecProvider);
    if (codec != null) return codec;
    return AfterCloudBackupCodec(
      collect: _defaultCollect,
      apply: _defaultApply,
    );
  }

  Map<String, dynamic> _defaultCollect() {
    final stores = <String, dynamic>{};
    for (final key in _prefs.getKeys()) {
      if (key.startsWith('family_') ||
          key.contains('_crud_') ||
          key.startsWith('after_settings') ||
          key.startsWith('after_cloud_backup')) {
        final value = _prefs.get(key);
        if (value != null) stores[key] = value;
      }
    }
    return {
      'stores': stores,
      'locale': _prefs.getString(AfterSettingsKeys.locale) ??
          _prefs.getString('locale') ??
          'en',
    };
  }

  Future<void> _defaultApply(Map<String, dynamic> payload) async {
    final stores = payload['stores'];
    if (stores is! Map) return;
    for (final entry in stores.entries) {
      final key = '${entry.key}';
      final value = entry.value;
      if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value != null) {
        await _prefs.setString(key, jsonEncode(value));
      }
    }
  }

  List<AfterStorageManifestEntry> _manifestFromPayload(
    Map<String, dynamic> payload,
  ) {
    final raw = payload['mediaManifest'] ?? payload['storageManifest'];
    if (raw is! List) return const [];
    final out = <AfterStorageManifestEntry>[];
    for (final item in raw) {
      if (item is Map) {
        out.add(
          AfterStorageManifestEntry.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }
    return out;
  }

  /// Push local payload when newer than remote (or remote missing).
  Future<void> syncNow() async {
    final userId = await _resolveUserId();
    if (userId == null) {
      state = state.copyWith(
        status: AfterCloudBackupStatus.error,
        errorCode: 'unauthenticated',
      );
      return;
    }
    if (!_blob.isAvailable) {
      state = state.copyWith(
        status: AfterCloudBackupStatus.error,
        errorCode: 'sync/unavailable',
      );
      return;
    }

    state = state.copyWith(
      status: AfterCloudBackupStatus.syncing,
      clearError: true,
    );

    try {
      final localMillis = _prefs.getInt(_stampKey) ?? 0;
      final localPayload = _readCachedPayload() ?? _codec.collect();
      final remote = await _blob.pull(appId: _appId, userId: userId);

      if (remote != null && remote.updatedAtMillis > localMillis) {
        await _applySnapshot(
          AfterCloudBackupSnapshot.fromBlob(
            remote,
            mediaManifest: _manifestFromPayload(remote.payload),
          ),
        );
        state = state.copyWith(
          status: AfterCloudBackupStatus.idle,
          lastSyncedMillis: remote.updatedAtMillis,
          clearError: true,
        );
        return;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final media = _manifestFromPayload(localPayload);
      final snapshot = AfterCloudBackupSnapshot(
        appId: _appId,
        userId: userId,
        updatedAtMillis: now,
        payload: localPayload,
        mediaManifest: media,
      );
      await _blob.push(snapshot.toBlob());
      await _prefs.setInt(_stampKey, now);
      await _prefs.setString(_payloadKey, jsonEncode(localPayload));
      state = state.copyWith(
        status: AfterCloudBackupStatus.idle,
        lastSyncedMillis: now,
        clearError: true,
      );
    } on AfterSyncException catch (e) {
      state = state.copyWith(
        status: AfterCloudBackupStatus.error,
        errorCode: e.code ?? 'sync/error',
      );
    } on Object {
      state = state.copyWith(
        status: AfterCloudBackupStatus.error,
        errorCode: 'sync/error',
      );
    }
  }

  /// Pull remote when local cache looks empty (post-login).
  Future<void> restoreFromCloudIfEmpty() async {
    final userId = await _resolveUserId();
    if (userId == null || !_blob.isAvailable) return;
    final local = _readCachedPayload() ?? _codec.collect();
    final stores = local['stores'];
    final hasLocal = stores is Map && stores.isNotEmpty;
    if (hasLocal) return;

    state = state.copyWith(
      status: AfterCloudBackupStatus.restoring,
      clearError: true,
    );
    try {
      final remote = await _blob.pull(appId: _appId, userId: userId);
      if (remote != null) {
        await _applySnapshot(
          AfterCloudBackupSnapshot.fromBlob(
            remote,
            mediaManifest: _manifestFromPayload(remote.payload),
          ),
        );
        state = state.copyWith(
          status: AfterCloudBackupStatus.idle,
          lastSyncedMillis: remote.updatedAtMillis,
          clearError: true,
        );
        return;
      }
      state = state.copyWith(status: AfterCloudBackupStatus.idle);
    } on Object {
      state = state.copyWith(
        status: AfterCloudBackupStatus.error,
        errorCode: 'sync/error',
      );
    }
  }

  /// Force-apply remote over local (user-initiated restore).
  Future<void> restoreFromCloud() async {
    final userId = await _resolveUserId();
    if (userId == null) {
      state = state.copyWith(
        status: AfterCloudBackupStatus.error,
        errorCode: 'unauthenticated',
      );
      return;
    }
    if (!_blob.isAvailable) {
      state = state.copyWith(
        status: AfterCloudBackupStatus.error,
        errorCode: 'sync/unavailable',
      );
      return;
    }
    state = state.copyWith(
      status: AfterCloudBackupStatus.restoring,
      clearError: true,
    );
    try {
      final remote = await _blob.pull(appId: _appId, userId: userId);
      if (remote == null) {
        state = state.copyWith(
          status: AfterCloudBackupStatus.error,
          errorCode: 'backup/empty',
        );
        return;
      }
      await _applySnapshot(
        AfterCloudBackupSnapshot.fromBlob(
          remote,
          mediaManifest: _manifestFromPayload(remote.payload),
        ),
      );
      state = state.copyWith(
        status: AfterCloudBackupStatus.idle,
        lastSyncedMillis: remote.updatedAtMillis,
        clearError: true,
      );
    } on AfterSyncException catch (e) {
      state = state.copyWith(
        status: AfterCloudBackupStatus.error,
        errorCode: e.code ?? 'sync/error',
      );
    } on Object {
      state = state.copyWith(
        status: AfterCloudBackupStatus.error,
        errorCode: 'sync/error',
      );
    }
  }

  /// Build a portable JSON export (share / file save).
  Future<String?> exportSnapshot() async {
    final userId = await _resolveUserId() ?? 'local';
    state = state.copyWith(
      status: AfterCloudBackupStatus.exporting,
      clearError: true,
      clearExport: true,
    );
    try {
      final payload = _codec.collect();
      final snapshot = AfterCloudBackupSnapshot(
        appId: _appId,
        userId: userId,
        updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
        payload: payload,
        mediaManifest: _manifestFromPayload(payload),
      );
      final encoded = const JsonEncoder.withIndent('  ').convert(
        snapshot.toExportJson(),
      );
      state = state.copyWith(
        status: AfterCloudBackupStatus.idle,
        lastExportJson: encoded,
        clearError: true,
      );
      return encoded;
    } on Object {
      state = state.copyWith(
        status: AfterCloudBackupStatus.error,
        errorCode: 'export/error',
      );
      return null;
    }
  }

  /// Import from [AfterCloudBackupSnapshot.toExportJson] and optionally push.
  Future<void> importSnapshot(
    Map<String, dynamic> json, {
    bool pushToCloud = false,
  }) async {
    state = state.copyWith(
      status: AfterCloudBackupStatus.restoring,
      clearError: true,
    );
    try {
      final snapshot = AfterCloudBackupSnapshot.fromExportJson(json);
      await _applySnapshot(snapshot);
      if (pushToCloud) {
        await syncNow();
        return;
      }
      state = state.copyWith(
        status: AfterCloudBackupStatus.idle,
        lastSyncedMillis: snapshot.updatedAtMillis,
        clearError: true,
      );
    } on Object {
      state = state.copyWith(
        status: AfterCloudBackupStatus.error,
        errorCode: 'import/error',
      );
    }
  }

  /// Upload one media object via the shared Storage port.
  Future<void> uploadMedia({
    required String storagePath,
    required AfterUserMediaBytes data,
  }) async {
    if (!_media.isAvailable) {
      throw const AfterSyncException(
        'Media sync unavailable',
        code: 'sync/unavailable',
      );
    }
    await _media.upload(storagePath: storagePath, data: data);
  }

  Future<AfterUserMediaBytes?> downloadMedia({
    required String storagePath,
  }) {
    return _media.download(storagePath: storagePath);
  }

  Future<void> deleteMedia({required String storagePath}) {
    return _media.delete(storagePath: storagePath);
  }

  Future<void> markLocalDirty() async {
    final payload = _codec.collect();
    await _prefs.setString(_payloadKey, jsonEncode(payload));
  }

  Future<void> clearLocalCache() async {
    await _prefs.remove(_stampKey);
    await _prefs.remove(_payloadKey);
    state = const AfterCloudBackupState();
  }

  Map<String, dynamic>? _readCachedPayload() {
    final raw = _prefs.getString(_payloadKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is Map) return Map<String, dynamic>.from(map);
    } on Object {
      return null;
    }
    return null;
  }

  Future<void> _applySnapshot(AfterCloudBackupSnapshot snapshot) async {
    await _codec.apply(snapshot.payload);
    await _prefs.setString(_payloadKey, jsonEncode(snapshot.payload));
    await _prefs.setInt(_stampKey, snapshot.updatedAtMillis);
  }
}

void scheduleAfterCloudBackup(WidgetRef ref) {
  unawaited(ref.read(afterCloudBackupProvider.notifier).syncNow());
}
