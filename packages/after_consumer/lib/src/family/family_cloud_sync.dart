import 'dart:async';
import 'dart:convert';

import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FamilyCloudSyncStatus { idle, syncing, error }

class FamilyCloudSyncState {
  const FamilyCloudSyncState({
    this.status = FamilyCloudSyncStatus.idle,
    this.lastSyncedMillis,
    this.errorCode,
  });

  final FamilyCloudSyncStatus status;
  final int? lastSyncedMillis;
  final String? errorCode;

  FamilyCloudSyncState copyWith({
    FamilyCloudSyncStatus? status,
    int? lastSyncedMillis,
    String? errorCode,
    bool clearError = false,
  }) {
    return FamilyCloudSyncState(
      status: status ?? this.status,
      lastSyncedMillis: lastSyncedMillis ?? this.lastSyncedMillis,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
    );
  }
}

final familyCloudSyncProvider =
    NotifierProvider<FamilyCloudSyncController, FamilyCloudSyncState>(
  FamilyCloudSyncController.new,
);

/// Garage-style blob sync for Family CRUD + prefs payload.
class FamilyCloudSyncController extends Notifier<FamilyCloudSyncState> {
  static const _localStampKey = 'family_cloud_last_synced_millis';
  static const _localPayloadKey = 'family_cloud_local_payload';

  Timer? _debounce;

  @override
  FamilyCloudSyncState build() {
    ref.onDispose(() => _debounce?.cancel());
    final prefs = ref.watch(afterSharedPreferencesProvider);
    return FamilyCloudSyncState(
      lastSyncedMillis: prefs.getInt(_localStampKey),
    );
  }

  SharedPreferences get _prefs => ref.read(afterSharedPreferencesProvider);

  AfterUserBlobSyncPort get _port => ref.read(afterUserBlobSyncPortProvider);

  Future<String?> _resolveUserId() async {
    final session =
        await ref.read(afterAuthRepositoryProvider).getCurrentSession();
    final uid = session.user?.uid;
    if (uid == null || uid.isEmpty) return null;
    return uid;
  }

  String get _appId {
    try {
      return PlatformConfig.current.appId;
    } on Object {
      return 'unknown';
    }
  }

  /// Debounced sync after CRUD mutations (2s, Garage pattern).
  void scheduleSync() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      unawaited(syncNow());
    });
  }

  Future<void> syncNow() async {
    final userId = await _resolveUserId();
    if (userId == null || userId.isEmpty) {
      state = state.copyWith(
        status: FamilyCloudSyncStatus.error,
        errorCode: 'unauthenticated',
      );
      return;
    }
    if (!_port.isAvailable) {
      state = state.copyWith(
        status: FamilyCloudSyncStatus.error,
        errorCode: 'sync/unavailable',
      );
      return;
    }

    state = state.copyWith(
      status: FamilyCloudSyncStatus.syncing,
      clearError: true,
    );

    try {
      final localMillis = _prefs.getInt(_localStampKey) ?? 0;
      final localPayload = _readLocalPayload();
      final remote = await _port.pull(appId: _appId, userId: userId);

      if (remote != null && remote.updatedAtMillis > localMillis) {
        await _applyRemote(remote);
        state = state.copyWith(
          status: FamilyCloudSyncStatus.idle,
          lastSyncedMillis: remote.updatedAtMillis,
          clearError: true,
        );
        return;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final blob = AfterUserBlob(
        appId: _appId,
        userId: userId,
        updatedAtMillis: now,
        payload: localPayload,
      );
      await _port.push(blob);
      await _prefs.setInt(_localStampKey, now);
      state = state.copyWith(
        status: FamilyCloudSyncStatus.idle,
        lastSyncedMillis: now,
        clearError: true,
      );
    } on AfterSyncException catch (e) {
      state = state.copyWith(
        status: FamilyCloudSyncStatus.error,
        errorCode: e.code ?? 'sync/error',
      );
    } on Object {
      state = state.copyWith(
        status: FamilyCloudSyncStatus.error,
        errorCode: 'sync/error',
      );
    }
  }

  /// Pull remote when local stores look empty (post-login restore).
  Future<void> restoreFromCloudIfEmpty() async {
    final userId = await _resolveUserId();
    if (userId == null || !_port.isAvailable) return;
    final local = _readLocalPayload();
    final stores = local['stores'];
    final hasLocal = stores is Map && stores.isNotEmpty;
    if (hasLocal) return;
    try {
      final remote = await _port.pull(appId: _appId, userId: userId);
      if (remote != null) {
        await _applyRemote(remote);
        state = state.copyWith(
          lastSyncedMillis: remote.updatedAtMillis,
          status: FamilyCloudSyncStatus.idle,
          clearError: true,
        );
      }
    } on Object {
      // Non-fatal on login path.
    }
  }

  Map<String, dynamic> _readLocalPayload() {
    final raw = _prefs.getString(_localPayloadKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final map = jsonDecode(raw);
        if (map is Map) return Map<String, dynamic>.from(map);
      } on Object {
        // fall through
      }
    }
    return _collectPrefsSnapshot();
  }

  Map<String, dynamic> _collectPrefsSnapshot() {
    final stores = <String, dynamic>{};
    for (final key in _prefs.getKeys()) {
      if (key.startsWith('family_') ||
          key.contains('_crud_') ||
          key.startsWith('after_settings')) {
        final value = _prefs.get(key);
        if (value != null) stores[key] = value;
      }
    }
    return {
      'stores': stores,
      'locale': _prefs.getString('locale') ??
          _prefs.getString('app.locale') ??
          'en',
    };
  }

  Future<void> _applyRemote(AfterUserBlob remote) async {
    final stores = remote.payload['stores'];
    if (stores is Map) {
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
    await _prefs.setString(_localPayloadKey, jsonEncode(remote.payload));
    await _prefs.setInt(_localStampKey, remote.updatedAtMillis);
  }

  /// Call after local mutation so next push includes fresh data.
  Future<void> markLocalDirty() async {
    final payload = _collectPrefsSnapshot();
    await _prefs.setString(_localPayloadKey, jsonEncode(payload));
    scheduleSync();
  }
}

void scheduleFamilyCloudSync(WidgetRef ref) {
  ref.read(familyCloudSyncProvider.notifier).scheduleSync();
}
