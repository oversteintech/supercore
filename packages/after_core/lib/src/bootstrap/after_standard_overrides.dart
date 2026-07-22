import 'package:riverpod/src/internals.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import '../ai/after_ai_sdk.dart';
import '../di/after_providers.dart';
import '../feature_flags/after_feature_flags.dart';
import '../logging/after_logger.dart';
import '../network/after_http_client.dart';
import '../notifications/after_notifications.dart';
import '../remote_config/after_remote_config.dart';
import '../storage/secure_storage.dart';
import '../sync/after_user_blob_sync.dart';

/// Standard After Framework provider overrides shared by every Super App.
///
/// Product apps call this from their composition root, then append
/// product-specific adapters (auth, analytics, push, entitlements).
abstract final class AfterStandardOverrides {
  /// Baseline platform wiring: prefs, HTTPS Dio policy, flags, remote config,
  /// local notifications, AI credential vault, logger.
  ///
  /// Auth / analytics / remote push default to no-op After ports until the
  /// Super App overrides them with store adapters.
  static List<Override> create({
    required SharedPreferences preferences,
    required String userAgent,
    AfterHttpPolicy? httpPolicy,
    AfterLogger logger = const ConsoleAfterLogger(),
    // False when composition root also spreads AfterFirebaseBootstrap.overrides
    // (avoids double-override of afterUserBlobSyncPortProvider).
    bool includeUserBlobSync = true,
  }) {
    final policy = httpPolicy ??
        AfterHttpPolicy(
          requireHttps: true,
          userAgent: userAgent,
        );

    return [
      afterSharedPreferencesProvider.overrideWithValue(preferences),
      afterHttpPolicyProvider.overrideWithValue(policy),
      afterLoggerProvider.overrideWithValue(logger),
      afterFeatureFlagsProvider.overrideWith((ref) {
        return PrefsAfterFeatureFlags(
          SharedPreferencesAfterStore(preferences),
        );
      }),
      afterRemoteConfigProvider.overrideWith((ref) {
        return CachedAfterRemoteConfig(
          SharedPreferencesAfterStore(preferences),
        );
      }),
      afterLocalNotificationsProvider.overrideWith(
        (ref) => FlutterAfterLocalNotifications(),
      ),
      afterAiCredentialVaultProvider.overrideWith((ref) {
        return AfterAiCredentialVault(ref.watch(afterSecureStorageProvider));
      }),
      if (includeUserBlobSync)
        afterUserBlobSyncPortProvider.overrideWithValue(
          PrefsAfterUserBlobSync(preferences),
        ),
    ];
  }
}
