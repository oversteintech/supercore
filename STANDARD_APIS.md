# After Framework — standard APIs (all Super Apps)

Single shared surface. Super Apps **must not** fork these modules.

Canonical packages: [`packages/after_core`](packages/after_core) · [`packages/after_design_system`](packages/after_design_system)  
Public docs: [afterframework.com](https://www.afterframework.com)

## Composition (required)

| API | Package | Purpose |
|-----|---------|---------|
| `AppPlatformManifest` / `PlatformConfig` | after_core | Product identity (appId, package, widgets) |
| `AfterStandardOverrides.create(...)` | after_core | Baseline Riverpod overrides for every Super App |
| Product `AfterFramework.create*Overrides` | app | Manifest + standard overrides + product adapters |

## Ports (override with store adapters)

| Provider / type | Default | Product overrides with |
|-----------------|---------|------------------------|
| `afterAuthRepositoryProvider` | No-op | Firebase / Supabase auth |
| `afterAnalyticsProvider` | No-op | Firebase Analytics, etc. |
| `afterRemotePushProvider` | No-op | FCM / Huawei push |
| `afterEntitlementProvider` | Free matrix | Store + server entitlements |
| `afterHttpPolicyProvider` | HTTPS policy | Product UA + blocklists |
| `afterDioProvider` / `afterApiClientProvider` | Hardened Dio | Same client for all APIs |
| `afterFeatureFlagsProvider` | Prefs | Remote + local flags |
| `afterRemoteConfigProvider` | Cached prefs | Remote Config |
| `afterAiCredentialVaultProvider` | Secure storage | BYOK keys |
| `afterLocalNotificationsProvider` | Flutter local | Product channels |
| `afterDeepLinkServiceProvider` | — | app_links |

## Design system

| API | Purpose |
|-----|---------|
| `AfterThemeData.light/dark` | Theme base |
| `AfterTheme` extension | Tokens |
| `After*` widgets | Buttons, cards, inputs, nav, dialogs, charts, empty/loading |

## Super App family (active scaffolds)

| App | Repo | Status |
|-----|------|--------|
| SuperGarage | supergarage | Flagship / reference |
| SuperHealth | superhealth | Scaffold |
| SuperNews | supernews | Scaffold |
| SuperSports | supersports | Scaffold |

## Rule

Vertical code lives only under each app’s `lib/features/`. Shared behavior lands in SuperCore, never copied between apps.
