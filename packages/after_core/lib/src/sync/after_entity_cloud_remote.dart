import 'dart:async';

import 'after_synced_entity.dart';

/// Vendor-agnostic entity collection port (Firebase / in-memory / tests).
abstract class AfterEntityCloudRemote {
  bool get isAvailable;

  List<String> get entityCollections;

  Future<bool> hasAnyEntities(String containerId);

  Future<List<AfterSyncedEntity>> fetchCollection({
    required String containerId,
    required String collection,
  });

  Future<Map<String, List<AfterSyncedEntity>>> fetchAllEntities(
    String containerId,
  );

  Future<void> upsertEntity(AfterSyncedEntity entity);

  Future<void> softDeleteEntity({
    required String containerId,
    required String collection,
    required String id,
    required String uid,
    required int version,
    required int deletedAtMillis,
    String? deviceId,
  });

  Future<Map<String, dynamic>?> fetchMetaDoc({
    required String containerId,
    required String docId,
  });

  Future<void> upsertMetaDoc({
    required String containerId,
    required String docId,
    required String uid,
    required Map<String, dynamic> data,
    required int updatedAtMillis,
    required int version,
    String? deviceId,
  });

  Stream<List<AfterSyncedEntity>> watchCollection({
    required String containerId,
    required String collection,
    String? ownerUid,
  });
}

/// In-memory remote for unit tests and offline scaffolds.
class InMemoryAfterEntityCloudRemote implements AfterEntityCloudRemote {
  InMemoryAfterEntityCloudRemote({
    this.available = true,
    List<String>? entityCollections,
  }) : entityCollections =
            entityCollections ?? const <String>['vehicles', 'meta'];

  bool available;
  bool pushShouldFail = false;
  int pushCount = 0;

  @override
  final List<String> entityCollections;

  final Map<String, AfterSyncedEntity> _entities = {};
  final Map<String, Map<String, dynamic>> _meta = {};
  final Map<String, StreamController<List<AfterSyncedEntity>>> _watchers = {};

  String _key(String containerId, String collection, String id) =>
      '$containerId|$collection|$id';

  String _watchKey(String containerId, String collection) =>
      '$containerId|$collection';

  List<AfterSyncedEntity> _snapshot(String containerId, String collection) {
    return _entities.values
        .where(
          (entity) =>
              entity.containerId == containerId &&
              entity.collection == collection,
        )
        .toList(growable: false);
  }

  void _notify(String containerId, String collection) {
    final controller = _watchers[_watchKey(containerId, collection)];
    if (controller != null && !controller.isClosed) {
      controller.add(_snapshot(containerId, collection));
    }
  }

  void seedEntity(AfterSyncedEntity entity) {
    _entities[_key(entity.containerId, entity.collection, entity.id)] = entity;
    _notify(entity.containerId, entity.collection);
  }

  @override
  bool get isAvailable => available;

  @override
  Future<bool> hasAnyEntities(String containerId) async {
    return _entities.values.any(
      (entity) => entity.containerId == containerId && !entity.isDeleted,
    );
  }

  @override
  Future<List<AfterSyncedEntity>> fetchCollection({
    required String containerId,
    required String collection,
  }) async {
    return _entities.values
        .where(
          (entity) =>
              entity.containerId == containerId &&
              entity.collection == collection,
        )
        .toList(growable: false);
  }

  @override
  Future<Map<String, List<AfterSyncedEntity>>> fetchAllEntities(
    String containerId,
  ) async {
    final results = <String, List<AfterSyncedEntity>>{};
    for (final name in entityCollections) {
      results[name] = await fetchCollection(
        containerId: containerId,
        collection: name,
      );
    }
    return results;
  }

  @override
  Future<void> upsertEntity(AfterSyncedEntity entity) async {
    if (!isAvailable) throw StateError('cloud_unavailable');
    if (pushShouldFail) throw StateError('push_failed');
    pushCount++;
    final key = _key(entity.containerId, entity.collection, entity.id);
    final existing = _entities[key];
    _entities[key] = existing == null
        ? entity
        : AfterSyncedEntity.pickWinner(existing, entity);
    _notify(entity.containerId, entity.collection);
  }

  @override
  Future<void> softDeleteEntity({
    required String containerId,
    required String collection,
    required String id,
    required String uid,
    required int version,
    required int deletedAtMillis,
    String? deviceId,
  }) {
    return upsertEntity(
      AfterSyncedEntity(
        id: id,
        uid: uid,
        containerId: containerId,
        collection: collection,
        updatedAtMillis: deletedAtMillis,
        version: version,
        data: const {},
        deletedAtMillis: deletedAtMillis,
        deviceId: deviceId,
      ),
    );
  }

  @override
  Future<Map<String, dynamic>?> fetchMetaDoc({
    required String containerId,
    required String docId,
  }) async {
    return _meta['$containerId|$docId'];
  }

  @override
  Future<void> upsertMetaDoc({
    required String containerId,
    required String docId,
    required String uid,
    required Map<String, dynamic> data,
    required int updatedAtMillis,
    required int version,
    String? deviceId,
  }) async {
    if (!isAvailable) throw StateError('cloud_unavailable');
    _meta['$containerId|$docId'] = {
      'uid': uid,
      'containerId': containerId,
      'updatedAtMillis': updatedAtMillis,
      'version': version,
      if (deviceId != null) 'deviceId': deviceId,
      'data': data,
    };
  }

  @override
  Stream<List<AfterSyncedEntity>> watchCollection({
    required String containerId,
    required String collection,
    String? ownerUid,
  }) {
    final key = _watchKey(containerId, collection);
    final controller = _watchers.putIfAbsent(
      key,
      () => StreamController<List<AfterSyncedEntity>>.broadcast(),
    );
    return Stream<List<AfterSyncedEntity>>.multi((listener) {
      listener.add(_snapshot(containerId, collection));
      final sub = controller.stream.listen(
        listener.add,
        onError: listener.addError,
        onDone: listener.close,
      );
      listener
        ..onPause = sub.pause
        ..onResume = sub.resume
        ..onCancel = sub.cancel;
    });
  }
}
