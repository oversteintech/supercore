import 'dart:typed_data';

import 'package:after_core/after_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:after_firebase/src/after_firebase_cloud_availability.dart';

/// Firebase Storage adapter for [AfterUserMediaSyncPort].
///
/// Object paths stay product-owned (`users/{uid}/…`). This class only speaks
/// putBytes / getData / delete — no Garage vehicle layout knowledge.
class FirebaseAfterUserMediaSync implements AfterUserMediaSyncPort {
  FirebaseAfterUserMediaSync({FirebaseStorage? storage}) : _storage = storage;

  final FirebaseStorage? _storage;

  FirebaseStorage? get _bucket {
    if (_storage != null) return _storage;
    if (!AfterFirebaseCloudAvailability.canUseCloud) return null;
    try {
      return FirebaseStorage.instance;
    } on Object {
      return null;
    }
  }

  @override
  bool get isAvailable =>
      AfterFirebaseCloudAvailability.canUseCloud && _bucket != null;

  Reference? _ref(String storagePath) {
    final bucket = _bucket;
    if (bucket == null) return null;
    final path = storagePath.trim();
    if (path.isEmpty) return null;
    return bucket.ref(path);
  }

  @override
  Future<void> upload({
    required String storagePath,
    required AfterUserMediaBytes data,
  }) async {
    if (!isAvailable) {
      throw const AfterSyncException(
        'Storage unavailable',
        code: 'sync/unavailable',
      );
    }
    final ref = _ref(storagePath);
    if (ref == null) {
      throw const AfterSyncException(
        'Storage unavailable',
        code: 'sync/unavailable',
      );
    }
    final meta = data.contentType == null
        ? null
        : SettableMetadata(contentType: data.contentType);
    await ref.putData(data.bytes, meta);
  }

  @override
  Future<AfterUserMediaBytes?> download({required String storagePath}) async {
    if (!isAvailable) {
      throw const AfterSyncException(
        'Storage unavailable',
        code: 'sync/unavailable',
      );
    }
    final ref = _ref(storagePath);
    if (ref == null) return null;
    try {
      final bytes = await ref.getData();
      if (bytes == null || bytes.isEmpty) return null;
      String? contentType;
      try {
        contentType = (await ref.getMetadata()).contentType;
      } on Object {
        contentType = null;
      }
      return AfterUserMediaBytes(
        bytes: Uint8List.fromList(bytes),
        contentType: contentType,
      );
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return null;
      rethrow;
    }
  }

  @override
  Future<void> delete({required String storagePath}) async {
    if (!isAvailable) {
      throw const AfterSyncException(
        'Storage unavailable',
        code: 'sync/unavailable',
      );
    }
    final ref = _ref(storagePath);
    if (ref == null) return;
    try {
      await ref.delete();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return;
      rethrow;
    }
  }
}
