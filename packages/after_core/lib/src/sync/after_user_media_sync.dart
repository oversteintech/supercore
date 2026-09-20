import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../errors/after_exception.dart';
import 'after_user_blob_sync.dart';

/// Manifest row for a single cloud media object (Firebase Storage / GCS).
///
/// Product-independent — SuperGarage vehicle photos and SuperPet pet images
/// both use the same shape; only [kind] / path conventions differ per app.
@immutable
class AfterStorageManifestEntry {
  const AfterStorageManifestEntry({
    required this.kind,
    required this.storagePath,
    required this.localId,
    this.localFileName,
    this.mimeType,
    this.sizeBytes,
    this.contentSha256,
  });

  factory AfterStorageManifestEntry.fromJson(Map<String, dynamic> json) {
    return AfterStorageManifestEntry(
      kind: json['kind'] as String? ?? '',
      storagePath: json['storagePath'] as String? ?? '',
      localId: json['localId'] as String? ?? '',
      localFileName: json['localFileName'] as String?,
      mimeType: json['mimeType'] as String?,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      contentSha256: json['contentSha256'] as String?,
    );
  }

  final String kind;
  final String storagePath;
  final String localId;
  final String? localFileName;
  final String? mimeType;
  final int? sizeBytes;
  final String? contentSha256;

  Map<String, Object?> toJson() => {
        'kind': kind,
        'storagePath': storagePath,
        'localId': localId,
        if (localFileName != null) 'localFileName': localFileName,
        if (mimeType != null) 'mimeType': mimeType,
        if (sizeBytes != null) 'sizeBytes': sizeBytes,
        if (contentSha256 != null) 'contentSha256': contentSha256,
      };

  AfterStorageManifestEntry copyWith({
    String? kind,
    String? storagePath,
    String? localId,
    String? localFileName,
    String? mimeType,
    int? sizeBytes,
    String? contentSha256,
  }) {
    return AfterStorageManifestEntry(
      kind: kind ?? this.kind,
      storagePath: storagePath ?? this.storagePath,
      localId: localId ?? this.localId,
      localFileName: localFileName ?? this.localFileName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      contentSha256: contentSha256 ?? this.contentSha256,
    );
  }
}

/// Bytes + optional content type for a Storage put/get.
@immutable
class AfterUserMediaBytes {
  const AfterUserMediaBytes({
    required this.bytes,
    this.contentType,
  });

  final Uint8List bytes;
  final String? contentType;
}

/// Port — Firebase Storage / GCS media sync for Super Apps.
///
/// Domain layers never import `firebase_storage`. Composition roots bind
/// [FirebaseAfterUserMediaSync] from `after_firebase`.
abstract class AfterUserMediaSyncPort {
  bool get isAvailable;

  Future<void> upload({
    required String storagePath,
    required AfterUserMediaBytes data,
  });

  Future<AfterUserMediaBytes?> download({required String storagePath});

  Future<void> delete({required String storagePath});
}

/// No-op / in-memory media sync for scaffolds and tests.
class InMemoryAfterUserMediaSync implements AfterUserMediaSyncPort {
  InMemoryAfterUserMediaSync({this.available = true});

  bool available;
  final Map<String, AfterUserMediaBytes> _store = {};

  @override
  bool get isAvailable => available;

  @override
  Future<void> upload({
    required String storagePath,
    required AfterUserMediaBytes data,
  }) async {
    if (!isAvailable) {
      throw const AfterSyncException(
        'Media sync unavailable',
        code: 'sync/unavailable',
      );
    }
    _store[storagePath] = data;
  }

  @override
  Future<AfterUserMediaBytes?> download({required String storagePath}) async {
    if (!isAvailable) {
      throw const AfterSyncException(
        'Media sync unavailable',
        code: 'sync/unavailable',
      );
    }
    return _store[storagePath];
  }

  @override
  Future<void> delete({required String storagePath}) async {
    _store.remove(storagePath);
  }
}

final afterUserMediaSyncPortProvider = Provider<AfterUserMediaSyncPort>((ref) {
  return InMemoryAfterUserMediaSync();
});

/// Opaque cloud backup snapshot — blob payload (+ optional media manifest).
///
/// Product codecs own [payload] contents (vehicles, pets, trips, …).
@immutable
class AfterCloudBackupSnapshot {
  const AfterCloudBackupSnapshot({
    required this.appId,
    required this.userId,
    required this.updatedAtMillis,
    required this.payload,
    this.mediaManifest = const [],
  });

  factory AfterCloudBackupSnapshot.fromBlob(
    AfterUserBlob blob, {
    List<AfterStorageManifestEntry> mediaManifest = const [],
  }) {
    return AfterCloudBackupSnapshot(
      appId: blob.appId,
      userId: blob.userId,
      updatedAtMillis: blob.updatedAtMillis,
      payload: blob.payload,
      mediaManifest: mediaManifest,
    );
  }

  final String appId;
  final String userId;
  final int updatedAtMillis;
  final Map<String, dynamic> payload;
  final List<AfterStorageManifestEntry> mediaManifest;

  AfterUserBlob toBlob() => AfterUserBlob(
        appId: appId,
        userId: userId,
        updatedAtMillis: updatedAtMillis,
        payload: {
          ...payload,
          if (mediaManifest.isNotEmpty)
            'mediaManifest': mediaManifest.map((e) => e.toJson()).toList(),
        },
      );

  Map<String, dynamic> toExportJson() => {
        'format': 'after.cloud_backup.v1',
        'appId': appId,
        'userId': userId,
        'updatedAtMillis': updatedAtMillis,
        'payload': payload,
        'mediaManifest': mediaManifest.map((e) => e.toJson()).toList(),
      };

  factory AfterCloudBackupSnapshot.fromExportJson(Map<String, dynamic> json) {
    final mediaRaw = json['mediaManifest'];
    final media = <AfterStorageManifestEntry>[];
    if (mediaRaw is List) {
      for (final item in mediaRaw) {
        if (item is Map) {
          media.add(
            AfterStorageManifestEntry.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }
    final payload = json['payload'];
    return AfterCloudBackupSnapshot(
      appId: json['appId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      updatedAtMillis: (json['updatedAtMillis'] as num?)?.toInt() ?? 0,
      payload: payload is Map
          ? Map<String, dynamic>.from(payload)
          : <String, dynamic>{},
      mediaManifest: media,
    );
  }
}

/// True when the session may use cloud backup (signed-in, non-guest uid).
bool afterHasCloudBackupIdentity({
  required bool isAuthenticated,
  required bool isAnonymous,
  String? uid,
}) {
  if (!isAuthenticated || isAnonymous) return false;
  final id = uid?.trim() ?? '';
  return id.isNotEmpty;
}
