import 'after_durable_sync_outbox.dart';
import 'after_sync_operation.dart';

export 'after_community_sync_outbox.dart';
export 'after_durable_sync_outbox.dart';
export 'after_entity_cloud_remote.dart';
export 'after_entity_conflict_resolver.dart';
export 'after_sync_logger.dart';
export 'after_sync_operation.dart';
export 'after_synced_entity.dart';
export 'after_user_blob_sync.dart';
export 'after_user_media_sync.dart';

/// In-memory [AfterSyncOutboxCloudMirror] for tests and emulator harnesses.
class InMemoryAfterSyncOutboxCloudMirror implements AfterSyncOutboxCloudMirror {
  InMemoryAfterSyncOutboxCloudMirror({this.available = true});

  bool available;
  final Map<String, AfterSyncOperation> _ops = {};

  @override
  bool get isAvailable => available;

  @override
  Future<void> upsertOperation({
    required String uid,
    required AfterSyncOperation operation,
  }) async {
    _ops['$uid|${operation.operationId}'] = operation;
  }

  @override
  Future<void> deleteOperation({
    required String uid,
    required String operationId,
  }) async {
    _ops.remove('$uid|$operationId');
  }

  @override
  Future<List<AfterSyncOperation>> fetchPending({required String uid}) async {
    final prefix = '$uid|';
    return _ops.entries
        .where((entry) => entry.key.startsWith(prefix))
        .map((entry) => entry.value)
        .toList(growable: false);
  }
}
