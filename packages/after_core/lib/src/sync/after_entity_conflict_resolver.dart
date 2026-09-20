import 'after_synced_entity.dart';

/// Last-write-wins conflict resolver used by Super App entity sync.
class AfterEntityConflictResolver {
  const AfterEntityConflictResolver();

  AfterSyncedEntity resolve(AfterSyncedEntity local, AfterSyncedEntity remote) {
    return AfterSyncedEntity.pickWinner(local, remote);
  }

  Map<String, AfterSyncedEntity> mergeMaps({
    required Map<String, AfterSyncedEntity> local,
    required Map<String, AfterSyncedEntity> remote,
  }) {
    final merged = <String, AfterSyncedEntity>{...remote};
    for (final entry in local.entries) {
      final existing = merged[entry.key];
      merged[entry.key] =
          existing == null ? entry.value : resolve(entry.value, existing);
    }
    return merged;
  }
}
