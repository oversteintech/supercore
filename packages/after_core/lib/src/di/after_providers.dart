import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/after_analytics.dart';
import '../api/after_api_client.dart';
import '../auth/after_auth.dart';
import '../deep_links/after_deep_links.dart';
import '../feature_flags/after_feature_flags.dart';
import '../logging/after_logger.dart';
import '../network/after_http_client.dart';
import '../notifications/after_notifications.dart';
import '../premium/after_premium.dart';
import '../remote_config/after_remote_config.dart';
import '../storage/secure_storage.dart';
import '../ai/after_ai_sdk.dart';

/// Overrides these at bootstrap — same pattern as Super Garage cold start.
final afterSharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'Override afterSharedPreferencesProvider in ProviderScope',
  );
});

final afterLoggerProvider = Provider<AfterLogger>((ref) {
  return const ConsoleAfterLogger();
});

final afterSecureStorageProvider = Provider<AfterSecureStorage>((ref) {
  return FlutterSecureAfterStorage();
});

final afterPreferencesProvider = Provider<AfterPreferences>((ref) {
  return SharedPreferencesAfterStore(ref.watch(afterSharedPreferencesProvider));
});

final afterInstallationIdStoreProvider =
    Provider<AfterInstallationIdStore>((ref) {
  return AfterInstallationIdStore(ref.watch(afterSecureStorageProvider));
});

final afterHttpPolicyProvider = Provider<AfterHttpPolicy>((ref) {
  return const AfterHttpPolicy();
});

final afterDioProvider = Provider<Dio>((ref) {
  return AfterHttpClientFactory(
    policy: ref.watch(afterHttpPolicyProvider),
    logger: ref.watch(afterLoggerProvider),
  ).create();
});

final afterApiClientProvider = Provider<AfterApiClient>((ref) {
  return AfterApiClient(ref.watch(afterDioProvider));
});

final afterAuthRepositoryProvider = Provider<AfterAuthRepository>((ref) {
  return NoOpAfterAuthRepository();
});

final afterAnalyticsProvider = Provider<AfterAnalytics>((ref) {
  return const NoOpAfterAnalytics();
});

final afterFeatureFlagsProvider = Provider<AfterFeatureFlags>((ref) {
  return PrefsAfterFeatureFlags(ref.watch(afterPreferencesProvider));
});

final afterRemoteConfigProvider = Provider<AfterRemoteConfig>((ref) {
  return CachedAfterRemoteConfig(ref.watch(afterPreferencesProvider));
});

final afterLocalNotificationsProvider =
    Provider<AfterLocalNotifications>((ref) {
  return FlutterAfterLocalNotifications();
});

final afterRemotePushProvider = Provider<AfterRemotePush>((ref) {
  return const NoOpAfterRemotePush();
});

final afterDeepLinkServiceProvider = Provider<AfterDeepLinkService>((ref) {
  return AppLinksAfterDeepLinkService();
});

final afterAiCredentialVaultProvider = Provider<AfterAiCredentialVault>((ref) {
  return AfterAiCredentialVault(ref.watch(afterSecureStorageProvider));
});

final afterSubscriptionVerifierProvider =
    Provider<AfterSubscriptionVerifier>((ref) {
  return const NoOpAfterSubscriptionVerifier();
});

final afterEntitlementProvider = Provider<AfterEntitlement>((ref) {
  return const AfterEntitlement(
    effectivePlan: AfterUserPlan.free,
    storedPlan: AfterUserPlan.free,
  );
});

/// Convenience: resolve installation id once.
final afterInstallationIdProvider = FutureProvider<String>((ref) async {
  return ref.watch(afterInstallationIdStoreProvider).getOrCreate();
});
