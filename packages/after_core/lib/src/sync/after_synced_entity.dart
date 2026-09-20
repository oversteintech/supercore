import 'package:meta/meta.dart';

/// Shared last-write-wins entity document for Super App cloud sync.
@immutable
class AfterSyncedEntity {
  const AfterSyncedEntity({
    required this.id,
    required this.uid,
    required this.containerId,
    required this.collection,
    required this.updatedAtMillis,
    required this.version,
    required this.data,
    this.deletedAtMillis,
    this.deviceId,
    this.serverUpdatedAtMillis,
  });

  factory AfterSyncedEntity.fromFirestoreMap({
    required String collection,
    required Map<String, dynamic> map,
    int? serverUpdatedAtMillis,
  }) {
    final nested = map['data'];
    final data = nested is Map
        ? Map<String, dynamic>.from(nested)
        : Map<String, dynamic>.from(map)
      ..removeWhere(
        (key, _) => const {
          'id',
          'uid',
          'containerId',
          'garageId',
          'collection',
          'updatedAtMillis',
          'version',
          'deletedAtMillis',
          'deviceId',
          'serverUpdatedAt',
          'serverUpdatedAtMillis',
          'ownerUid',
          'data',
        }.contains(key),
      );
    return AfterSyncedEntity(
      id: map['id']?.toString() ?? '',
      uid: map['uid']?.toString() ?? map['ownerUid']?.toString() ?? '',
      containerId: map['containerId']?.toString() ??
          map['garageId']?.toString() ??
          '',
      collection: collection,
      updatedAtMillis: (map['updatedAtMillis'] as num?)?.toInt() ?? 0,
      version: (map['version'] as num?)?.toInt() ?? 1,
      data: data,
      deletedAtMillis: (map['deletedAtMillis'] as num?)?.toInt(),
      deviceId: map['deviceId']?.toString(),
      serverUpdatedAtMillis: serverUpdatedAtMillis ??
          (map['serverUpdatedAtMillis'] as num?)?.toInt(),
    );
  }

  final String id;
  final String uid;
  final String containerId;
  final String collection;
  final int updatedAtMillis;
  final int version;
  final Map<String, dynamic> data;
  final int? deletedAtMillis;
  final String? deviceId;
  final int? serverUpdatedAtMillis;

  bool get isDeleted => deletedAtMillis != null;

  Map<String, dynamic> toFirestoreMap() => {
        'id': id,
        'uid': uid,
        'ownerUid': uid,
        'containerId': containerId,
        'garageId': containerId,
        'collection': collection,
        'updatedAtMillis': updatedAtMillis,
        'version': version,
        'data': data,
        if (deletedAtMillis != null) 'deletedAtMillis': deletedAtMillis,
        if (deviceId != null) 'deviceId': deviceId,
        if (serverUpdatedAtMillis != null)
          'serverUpdatedAtMillis': serverUpdatedAtMillis,
      };

  /// Last-write-wins: higher [version] wins; equal version uses timestamp.
  static AfterSyncedEntity pickWinner(
    AfterSyncedEntity a,
    AfterSyncedEntity b,
  ) {
    if (a.id != b.id) return b;
    if (b.version != a.version) {
      return b.version > a.version ? b : a;
    }
    if (b.updatedAtMillis != a.updatedAtMillis) {
      return b.updatedAtMillis > a.updatedAtMillis ? b : a;
    }
    return b;
  }
}

abstract final class AfterEntityMetaIds {
  static const settings = 'settings';
  static const profile = 'profile';
  static const migration = 'migration';
}
