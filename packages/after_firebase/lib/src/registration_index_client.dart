import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'after_firebase_cloud_availability.dart';

/// Shared uniqueness-index reads for every Super App signup flow.
///
/// Pre-auth clients often cannot read locked collections. Methods return
/// `null` on permission-denied / timeout so callers stay optimistic and never
/// trap the UI on "checking" or crash account creation.
class RegistrationIndexClient {
  RegistrationIndexClient({
    FirebaseFirestore? firestore,
    this.timeout = const Duration(seconds: 3),
  }) : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;
  final Duration timeout;

  FirebaseFirestore? get _db {
    if (_firestoreOverride != null) return _firestoreOverride;
    if (!AfterFirebaseCloudAvailability.canUseCloud) return null;
    try {
      return FirebaseFirestore.instance;
    } on Object {
      return null;
    }
  }

  static String normalizeUsername(String raw) {
    return raw
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^a-z0-9._]'), '')
        .replaceAll(RegExp(r'\.{2,}'), '.')
        .replaceAll(RegExp(r'^\.+|\.+$'), '');
  }

  static String normalizeEmail(String raw) => raw.trim().toLowerCase();

  static final RegExp usernamePattern = RegExp(r'^[a-z0-9._]{3,30}$');

  /// `true` free, `false` taken, `null` unknown (cannot read).
  Future<bool?> tryIsUsernameAvailable(
    String username, {
    String? excludeUid,
  }) {
    final normalized = normalizeUsername(username);
    if (normalized.isEmpty || !usernamePattern.hasMatch(normalized)) {
      return Future<bool?>.value(false);
    }
    return tryIsIndexFree(
      collection: 'usernames',
      docId: normalized,
      excludeUid: excludeUid,
    );
  }

  Future<bool?> tryIsEmailAvailable(
    String email, {
    String? excludeUid,
  }) {
    final normalized = normalizeEmail(email);
    if (normalized.isEmpty || !normalized.contains('@')) {
      return Future<bool?>.value(false);
    }
    return tryIsIndexFree(
      collection: 'emails',
      docId: normalized,
      excludeUid: excludeUid,
    );
  }

  Future<bool?> tryIsPhoneAvailable(
    String e164, {
    String? excludeUid,
  }) {
    if (e164.trim().isEmpty) return Future<bool?>.value(true);
    return tryIsIndexFree(
      collection: 'phoneNumbers',
      docId: e164.trim(),
      excludeUid: excludeUid,
    );
  }

  Future<bool?> tryIsGarageIdAvailable(
    String garageId, {
    String? excludeUid,
  }) {
    if (garageId.trim().isEmpty) return Future<bool?>.value(true);
    return tryIsIndexFree(
      collection: 'garageIds',
      docId: garageId.trim(),
      excludeUid: excludeUid,
    );
  }

  /// Optimistic helper — treats unknown as available.
  Future<bool> isUsernameAvailable(String username, {String? excludeUid}) async {
    return (await tryIsUsernameAvailable(username, excludeUid: excludeUid)) ??
        true;
  }

  Future<bool> isGarageIdAvailable(String garageId, {String? excludeUid}) async {
    return (await tryIsGarageIdAvailable(garageId, excludeUid: excludeUid)) ??
        true;
  }

  Future<bool?> tryIsIndexFree({
    required String collection,
    required String docId,
    String? excludeUid,
  }) async {
    final db = _db;
    if (db == null || docId.isEmpty) return true;
    try {
      final doc = await db
          .collection(collection)
          .doc(docId)
          .get()
          .timeout(timeout);
      if (!doc.exists) return true;
      final owner = doc.data()?['uid']?.toString();
      return owner == null || owner == excludeUid;
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') return null;
      debugPrint('RegistrationIndexClient($collection): ${error.code}');
      return null;
    } on TimeoutException {
      return null;
    } on Object catch (error) {
      debugPrint('RegistrationIndexClient($collection) failed: $error');
      return null;
    }
  }

  /// Best-effort claim after auth. Never throws — uniqueness is re-checked
  /// server-side when Cloud Functions / transactions are available.
  Future<bool> claimUsername({
    required String uid,
    required String username,
  }) async {
    final db = _db;
    final normalized = normalizeUsername(username);
    if (db == null || uid.isEmpty || normalized.isEmpty) return false;
    try {
      await db.collection('usernames').doc(normalized).set({
        'uid': uid,
        'usernameLower': normalized,
        'updatedAtMillis': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));
      return true;
    } on Object catch (error) {
      debugPrint('claimUsername failed: $error');
      return false;
    }
  }
}
