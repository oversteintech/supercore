import 'package:meta/meta.dart';

enum SyncOperationKind { create, update, delete }

enum SyncStatus { pending, sending, done, failed }

@immutable
class SyncOperation {
  const SyncOperation({
    required this.id,
    required this.entity,
    required this.entityId,
    required this.kind,
    required this.payload,
    this.status = SyncStatus.pending,
    this.attempts = 0,
    this.lastError,
    this.enqueuedAt,
    this.completedAt,
  });

  final String id;
  final String entity;
  final String entityId;
  final SyncOperationKind kind;
  final Map<String, Object?> payload;
  final SyncStatus status;
  final int attempts;
  final String? lastError;
  final DateTime? enqueuedAt;
  final DateTime? completedAt;

  SyncOperation copyWith({
    SyncStatus? status,
    int? attempts,
    String? lastError,
    DateTime? completedAt,
  }) {
    return SyncOperation(
      id: id,
      entity: entity,
      entityId: entityId,
      kind: kind,
      payload: payload,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastError: lastError,
      enqueuedAt: enqueuedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Port for the sync queue that enterprise apps use to ship offline edits.
abstract class OfflineSyncQueue {
  Future<SyncOperation> enqueue(SyncOperation operation);
  Future<List<SyncOperation>> pending({int limit = 50});
  Future<void> markSending(String id);
  Future<void> markDone(String id);
  Future<void> markFailed(String id, {required String error});
}

class InMemoryOfflineSyncQueue implements OfflineSyncQueue {
  final Map<String, SyncOperation> _ops = {};
  var _nextId = 1;

  @override
  Future<SyncOperation> enqueue(SyncOperation operation) async {
    final id = operation.id.isEmpty ? 'sync_${_nextId++}' : operation.id;
    final stored = SyncOperation(
      id: id,
      entity: operation.entity,
      entityId: operation.entityId,
      kind: operation.kind,
      payload: operation.payload,
      status: SyncStatus.pending,
      attempts: 0,
      enqueuedAt: operation.enqueuedAt ?? DateTime.now().toUtc(),
    );
    _ops[id] = stored;
    return stored;
  }

  @override
  Future<List<SyncOperation>> pending({int limit = 50}) async {
    final list = _ops.values
        .where((o) => o.status == SyncStatus.pending)
        .take(limit)
        .toList(growable: false);
    return list;
  }

  @override
  Future<void> markSending(String id) async {
    final current = _ops[id];
    if (current == null) return;
    _ops[id] = current.copyWith(
      status: SyncStatus.sending,
      attempts: current.attempts + 1,
    );
  }

  @override
  Future<void> markDone(String id) async {
    final current = _ops[id];
    if (current == null) return;
    _ops[id] = current.copyWith(
      status: SyncStatus.done,
      completedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<void> markFailed(String id, {required String error}) async {
    final current = _ops[id];
    if (current == null) return;
    _ops[id] = current.copyWith(
      status: SyncStatus.failed,
      lastError: error,
    );
  }
}
