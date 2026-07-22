import 'package:after_core/after_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:after_firebase/src/after_firebase_cloud_availability.dart';

/// Firestore blob sync — `users/{uid}/apps/{appId}/blob/data`.
///
/// Matches Garage durability goals with a family-wide path so every Super App
/// isolates payload by [AfterUserBlob.appId].
class FirestoreAfterUserBlobSync implements AfterUserBlobSyncPort {
  FirestoreAfterUserBlobSync({FirebaseFirestore? firestore})
      : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    if (!AfterFirebaseCloudAvailability.canUseCloud) return null;
    try {
      return FirebaseFirestore.instance;
    } on Object {
      return null;
    }
  }

  @override
  bool get isAvailable =>
      AfterFirebaseCloudAvailability.canUseCloud && _db != null;

  DocumentReference<Map<String, dynamic>>? _ref({
    required String appId,
    required String userId,
  }) {
    return _db
        ?.collection('users')
        .doc(userId)
        .collection('apps')
        .doc(appId)
        .collection('blob')
        .doc('data');
  }

  @override
  Future<AfterUserBlob?> pull({
    required String appId,
    required String userId,
  }) async {
    if (!isAvailable) {
      throw const AfterSyncException(
        'Firestore unavailable',
        code: 'sync/unavailable',
      );
    }
    final ref = _ref(appId: appId, userId: userId);
    if (ref == null) return null;
    final snap = await ref.get();
    if (!snap.exists) return null;
    final data = snap.data();
    if (data == null) return null;

    final payload = data['payload'];
    if (payload is! Map) return null;

    final updatedAt = data['updatedAt'];
    final millis = updatedAt is Timestamp
        ? updatedAt.millisecondsSinceEpoch
        : (data['updatedAtMillis'] as num?)?.toInt() ?? 0;

    return AfterUserBlob(
      appId: appId,
      userId: userId,
      updatedAtMillis: millis,
      payload: Map<String, dynamic>.from(payload),
    );
  }

  @override
  Future<void> push(AfterUserBlob blob) async {
    if (!isAvailable) {
      throw const AfterSyncException(
        'Firestore unavailable',
        code: 'sync/unavailable',
      );
    }
    final ref = _ref(appId: blob.appId, userId: blob.userId);
    if (ref == null) {
      throw const AfterSyncException(
        'Firestore unavailable',
        code: 'sync/unavailable',
      );
    }
    final now = DateTime.now().toUtc();
    await ref.set({
      'appId': blob.appId,
      'userId': blob.userId,
      'payload': blob.payload,
      'updatedAtMillis': blob.updatedAtMillis,
      'updatedAt': Timestamp.fromDate(now),
      'syncVersion': 1,
    }, SetOptions(merge: true));
  }
}
