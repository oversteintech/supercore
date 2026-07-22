/// After Core — shared Super App foundation for AfterArtificial.
///
/// Ports + default implementations for auth, networking, storage, DI,
/// analytics, feature flags, remote config, AI, notifications, deep links,
/// and premium entitlements. Super Apps override Riverpod providers with
/// Firebase / Supabase / store-specific adapters.
library;

export 'src/ai/after_ai_context_block.dart';
export 'src/ai/after_ai_sdk.dart';
export 'src/ai/ui/after_ai_assistant_chrome.dart';
export 'src/ai/ui/after_ai_hub_icon.dart';
export 'src/analytics/after_analytics.dart';
export 'src/api/after_api_client.dart';
export 'src/auth/after_auth.dart';
export 'src/auth/after_super_admin.dart';
export 'src/auth/prefs_google_auth_repository.dart';
export 'src/bootstrap/after_bootstrap_mode.dart';
export 'src/bootstrap/after_standard_overrides.dart';
export 'src/query/page_query.dart';
export 'src/dashboard/after_dashboard.dart';
export 'src/deep_links/after_deep_links.dart';
export 'src/di/after_providers.dart';
export 'src/errors/after_exception.dart';
export 'src/feature_flags/after_feature_flags.dart';
export 'src/l10n/after_asset_string_catalog.dart';
export 'src/l10n/after_locale_prefs.dart';
export 'src/l10n/after_supported_locales.dart';
export 'src/logging/after_logger.dart';
export 'src/network/after_http_client.dart';
export 'src/notifications/after_notifications.dart';
export 'src/platform/app_platform_manifest.dart';
export 'src/plugins/after_plugins.dart';
export 'src/premium/after_premium.dart';
export 'src/remote_config/after_remote_config.dart';
export 'src/search/after_search.dart';
export 'src/settings/after_dynamic_app_icon_service.dart';
export 'src/settings/after_settings.dart';
export 'src/storage/secure_storage.dart';
export 'src/sync/after_user_blob_sync.dart';
export 'src/utils/after_utils.dart';
