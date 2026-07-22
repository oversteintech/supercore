import 'package:after_core/after_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:after_firebase/src/after_firebase_cloud_availability.dart';
import 'package:after_firebase/src/firebase_after_auth_repository.dart';
import 'package:after_firebase/src/firestore_after_user_blob_sync.dart';

/// Initializes Firebase once and builds Riverpod overrides for auth + sync.
///
/// When [options] is null or init fails, falls back to
/// PrefsGoogleAuthRepository + PrefsAfterUserBlobSync (no crash).
abstract final class AfterFirebaseBootstrap {
  static var _initAttempted = false;
  static var _ready = false;

  static bool get isReady => _ready;

  @visibleForTesting
  static void resetForTests() {
    _initAttempted = false;
    _ready = false;
  }

  /// Call from cold start before [ProviderScope].
  static Future<bool> ensureInitialized({
    FirebaseOptions? options,
    bool preferLocalFallback = false,
  }) async {
    if (preferLocalFallback) {
      _initAttempted = true;
      _ready = false;
      return false;
    }
    if (_initAttempted) return _ready;
    _initAttempted = true;
    if (options == null) {
      _ready = false;
      return false;
    }
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: options);
      }
      _ready = AfterFirebaseCloudAvailability.canUseCloud;
    } on Object catch (e, st) {
      debugPrint('AfterFirebase init failed: $e\n$st');
      _ready = false;
    }
    return _ready;
  }

  /// Auth + blob sync overrides for a Super App composition root.
  static List<Override> overrides({
    required SharedPreferences preferences,
    required String appId,
    String? googleServerClientId,
    String? googleIosClientId,
    String? mockGoogleEmailForTests,
  }) {
    if (_ready) {
      return [
        afterAuthRepositoryProvider.overrideWithValue(
          FirebaseAfterAuthRepository(
            googleServerClientId: googleServerClientId,
            googleIosClientId: googleIosClientId,
            mockGoogleEmailForTests: mockGoogleEmailForTests,
          ),
        ),
        afterUserBlobSyncPortProvider.overrideWithValue(
          FirestoreAfterUserBlobSync(),
        ),
      ];
    }

    // Placeholder / init-failed path: one auth override only. Soft Google
    // avoids clientConfigurationError until real OAuth clients exist.
    return [
      afterAuthRepositoryProvider.overrideWithValue(
        PrefsGoogleAuthRepository(
          preferences,
          prefsKeyPrefix: appId,
          googleServerClientId: googleServerClientId,
          googleIosClientId: googleIosClientId,
          mockGoogleEmailForTests: mockGoogleEmailForTests,
          softGoogleFallbackOnMisconfig: true,
        ),
      ),
      afterUserBlobSyncPortProvider.overrideWithValue(
        PrefsAfterUserBlobSync(preferences),
      ),
    ];
  }
}
