import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'after_sync_operation.dart';

/// Optional cloud mirror so a reinstall can recover pending outbox rows.
abstract class AfterSyncOutboxCloudMirror {
  bool get isAvailable;

  Future<void> upsertOperation({
    required String uid,
    required AfterSyncOperation operation,
  });

  Future<void> deleteOperation({
    required String uid,
    required String operationId,
  });

  Future<List<AfterSyncOperation>> fetchPending({required String uid});
}

/// Prefs-backed durable outbox with optional cloud mirror.
class AfterDurableSyncOutbox {
  AfterDurableSyncOutbox(
    this.preferences, {
    this.scope,
    this.cloudMirror,
    this.uidProvider,
    this.baseKey = 'after_sync_outbox_v1',
  });

  final SharedPreferences preferences;
  final String? scope;
  final AfterSyncOutboxCloudMirror? cloudMirror;
  final String? Function()? uidProvider;
  final String baseKey;

  static const _uuid = Uuid();

  String get _storageKey {
    final scoped = scope?.trim();
    if (scoped == null || scoped.isEmpty) return baseKey;
    return '$baseKey|$scoped';
  }

  List<AfterSyncOperation> _load() {
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map(
            (item) => AfterSyncOperation.fromJson(
              Map<String, Object?>.from(item),
            ),
          )
          .toList();
    } on Object {
      return const [];
    }
  }

  Future<void> _save(List<AfterSyncOperation> operations) {
    final encoded = jsonEncode(
      operations.map((op) => op.toJson()).toList(growable: false),
    );
    return preferences.setString(_storageKey, encoded);
  }

  List<AfterSyncOperation> pendingOperations() {
    return _load()
        .where((op) => op.status != AfterSyncOperationStatus.completed)
        .toList(growable: false);
  }

  int get pendingCount => pendingOperations().length;

  Future<AfterSyncOperation> enqueuePayload({
    required String entityType,
    required String entityId,
    required AfterSyncOperationType operationType,
    required Map<String, dynamic> payload,
  }) async {
    final operations = _load()
        .where((op) => op.status != AfterSyncOperationStatus.completed)
        .toList();
    final op = AfterSyncOperation(
      operationId: _uuid.v4(),
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      payload: payload,
      createdAt: DateTime.now().toUtc(),
    );
    operations.add(op);
    await _save(operations);
    await _mirrorUpsert(op);
    return op;
  }

  Future<void> markCompleted(String operationId) async {
    final operations = _load();
    final next = operations
        .where((op) => op.operationId != operationId)
        .toList(growable: false);
    await _save(next);
    await _mirrorDelete(operationId);
  }

  Future<void> markFailed(String operationId, String error) async {
    final operations = _load();
    final next = [
      for (final op in operations)
        if (op.operationId == operationId)
          op.copyWith(
            status: AfterSyncOperationStatus.failed,
            attempts: op.attempts + 1,
            lastError: error,
          )
        else
          op,
    ];
    await _save(next);
    final updated = next.where((op) => op.operationId == operationId);
    if (updated.isNotEmpty) {
      await _mirrorUpsert(updated.first);
    }
  }

  Future<void> recoverFromCloudMirror() async {
    final mirror = cloudMirror;
    final uid = uidProvider?.call()?.trim();
    if (mirror == null || !mirror.isAvailable || uid == null || uid.isEmpty) {
      return;
    }
    final remote = await mirror.fetchPending(uid: uid);
    if (remote.isEmpty) return;
    final local = {
      for (final op in _load()) op.operationId: op,
    };
    for (final op in remote) {
      local.putIfAbsent(op.operationId, () => op);
    }
    await _save(local.values.toList(growable: false));
  }

  Future<void> _mirrorUpsert(AfterSyncOperation operation) async {
    final mirror = cloudMirror;
    final uid = uidProvider?.call()?.trim();
    if (mirror == null || !mirror.isAvailable || uid == null || uid.isEmpty) {
      return;
    }
    try {
      await mirror.upsertOperation(uid: uid, operation: operation);
    } on Object {
      // Local persistence is the source of truth; mirror is best-effort.
    }
  }

  Future<void> _mirrorDelete(String operationId) async {
    final mirror = cloudMirror;
    final uid = uidProvider?.call()?.trim();
    if (mirror == null || !mirror.isAvailable || uid == null || uid.isEmpty) {
      return;
    }
    try {
      await mirror.deleteOperation(uid: uid, operationId: operationId);
    } on Object {
      // ignore
    }
  }
}
