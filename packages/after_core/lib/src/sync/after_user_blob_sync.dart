import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../errors/after_exception.dart';

/// User-scoped JSON blob for Super App cloud sync (Garage-style).
@immutable
class AfterUserBlob {
  const AfterUserBlob({
    required this.appId,
    required this.userId,
    required this.updatedAtMillis,
    required this.payload,
  });

  final String appId;
  final String userId;
  final int updatedAtMillis;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() => {
        'appId': appId,
        'userId': userId,
        'updatedAtMillis': updatedAtMillis,
        'payload': payload,
      };

  factory AfterUserBlob.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['payload'];
    return AfterUserBlob(
      appId: '${json['appId']}',
      userId: '${json['userId']}',
      updatedAtMillis: (json['updatedAtMillis'] as num?)?.toInt() ?? 0,
      payload: rawPayload is Map
          ? Map<String, dynamic>.from(rawPayload)
          : <String, dynamic>{},
    );
  }

  AfterUserBlob copyWith({
    int? updatedAtMillis,
    Map<String, dynamic>? payload,
  }) {
    return AfterUserBlob(
      appId: appId,
      userId: userId,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      payload: payload ?? this.payload,
    );
  }
}

/// Vendor-agnostic cloud blob port — Firebase/Supabase bind at composition root.
abstract class AfterUserBlobSyncPort {
  bool get isAvailable;

  Future<AfterUserBlob?> pull({
    required String appId,
    required String userId,
  });

  Future<void> push(AfterUserBlob blob);
}

/// In-memory sync for tests and offline scaffolds.
class InMemoryAfterUserBlobSync implements AfterUserBlobSyncPort {
  InMemoryAfterUserBlobSync({this.available = true});

  final bool available;
  final Map<String, AfterUserBlob> _store = {};

  String _key(String appId, String userId) => '$appId::$userId';

  @override
  bool get isAvailable => available;

  @override
  Future<AfterUserBlob?> pull({
    required String appId,
    required String userId,
  }) async {
    if (!available) {
      throw const AfterSyncException(
        'Sync unavailable',
        code: 'sync/unavailable',
      );
    }
    return _store[_key(appId, userId)];
  }

  @override
  Future<void> push(AfterUserBlob blob) async {
    if (!available) {
      throw const AfterSyncException(
        'Sync unavailable',
        code: 'sync/unavailable',
      );
    }
    _store[_key(blob.appId, blob.userId)] = blob;
  }

  void clear() => _store.clear();
}

/// Prefs-backed remote mirror — works without Firebase at skeleton stage.
/// Production apps override with a Firestore adapter at composition root.
class PrefsAfterUserBlobSync implements AfterUserBlobSyncPort {
  PrefsAfterUserBlobSync(this._prefs, {this.available = true});

  final SharedPreferences _prefs;
  final bool available;

  String _prefsKey(String appId, String userId) =>
      'after_cloud_blob_${appId}_$userId';

  @override
  bool get isAvailable => available;

  @override
  Future<AfterUserBlob?> pull({
    required String appId,
    required String userId,
  }) async {
    if (!available) {
      throw const AfterSyncException(
        'Sync unavailable',
        code: 'sync/unavailable',
      );
    }
    final raw = _prefs.getString(_prefsKey(appId, userId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is! Map) return null;
      return AfterUserBlob.fromJson(Map<String, dynamic>.from(map));
    } on Object {
      return null;
    }
  }

  @override
  Future<void> push(AfterUserBlob blob) async {
    if (!available) {
      throw const AfterSyncException(
        'Sync unavailable',
        code: 'sync/unavailable',
      );
    }
    await _prefs.setString(
      _prefsKey(blob.appId, blob.userId),
      jsonEncode(blob.toJson()),
    );
  }
}

/// Riverpod hook — override at bootstrap with Prefs or Firestore adapter.
final afterUserBlobSyncPortProvider = Provider<AfterUserBlobSyncPort>((ref) {
  return InMemoryAfterUserBlobSync();
});
