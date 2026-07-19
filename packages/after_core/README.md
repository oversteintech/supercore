# After Core

Shared Super App foundation for **AfterArtificial** (reference: Super Garage).

Every Super App depends on this package for cross-cutting platform services.
Product UI belongs in `after_design_system`; business screens stay in the app.

## Install

```yaml
dependencies:
  after_core:
    path: packages/after_core
  after_design_system:
    path: packages/after_design_system
```

## Modules

| Module | API |
|--------|-----|
| Errors | `AfterException` hierarchy |
| Logging | `AfterLogger`, `ConsoleAfterLogger` |
| Secure storage | `AfterSecureStorage`, `AfterInstallationIdStore` |
| Preferences | `AfterPreferences` |
| Networking | `AfterHttpClientFactory`, hardened Dio |
| API | `AfterApiClient`, `AfterAuthInterceptor` |
| Auth | `AfterAuthRepository`, `AfterAuthSession` |
| DI | Riverpod providers in `after_providers.dart` |
| Analytics | `AfterAnalytics` (+ product helpers) |
| Feature flags | `AfterFeatureFlags`, `PrefsAfterFeatureFlags` |
| Remote config | `AfterRemoteConfig`, `CachedAfterRemoteConfig` |
| AI SDK | BYOK vault, OpenAI-compatible client, orchestrator |
| Local notifications | `AfterLocalNotifications` |
| Remote push | `AfterRemotePush` port (inject FCM/Huawei) |
| Deep links | `AfterDeepLinkService` (`app_links`) |
| Premium | `AfterUserPlan`, `AfterEntitlementEngine`, features |
| Utils | `AfterUtils`, `AfterResult`, `AfterDebouncer` |

## Bootstrap pattern

```dart
import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        afterSharedPreferencesProvider.overrideWithValue(prefs),
        afterAuthRepositoryProvider.overrideWithValue(MyFirebaseAuthRepository()),
        afterAnalyticsProvider.overrideWithValue(MyFirebaseAnalytics()),
        // ... store-specific adapters
      ],
      child: const MySuperApp(),
    ),
  );
}
```

## Design rules

1. **Ports over SDKs** — feature code depends on After interfaces, never Firebase/Supabase directly.
2. **BYOK for AI** — never ship production LLM keys in the client.
3. **Server trust for premium** — use `AfterSubscriptionVerifier`; client merge via `AfterEntitlementEngine`.
4. **HTTPS + rate limits** — use `afterDioProvider` / `AfterHttpClientFactory`.
5. **Scrub secrets** — `AfterUtils.scrubExtras` before analytics/logging.

See `docs/AFTERARTIFICIAL_PLATFORM_STANDARD_v1.md`.
