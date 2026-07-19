# Module Registry — what every Super App inherits

Machine-readable source of truth:
[`factory/modules/registry.yaml`](../factory/modules/registry.yaml).
This doc is the human-readable companion.

Every module below is **shipped by the platform** and inherited by
every Super App generated from the factory. A `product.spec.yaml`
does not re-declare any of them; it only supplies the vertical bits
(features, permissions, dashboard widgets, AI skills, branding,
**and After Hub contributions** via `spec.hub` — see
[`AFTER_HUB.md`](AFTER_HUB.md) · ADR-019).

Life Domains / Industry Domains organize *which* product owns which
vertical surface — they do **not** fork this registry. See
[`LIFE_DOMAINS.md`](LIFE_DOMAINS.md) and
[`LIFE_DOMAIN_ROADMAP.md`](LIFE_DOMAIN_ROADMAP.md).

**After Hub** is the consumer OS shell (`role: os_shell`) — not a Life
Domain product. It **mounts** the modules below; Super Apps contribute
Hub widgets. SuperAI is Hub AI branding, not a peer entry app.

## Reading the tables

| Column | Meaning |
|--------|---------|
| Module | Human-readable capability name. |
| Package | Dart package that ships the port(s). |
| Ports / classes | The main symbols verticals import. |
| Line | `consumer` · `enterprise` · `shared` (both lines). |
| Status | `shipping` · `expand` (docs/blueprints being expanded). |

## Shared kernel (both lines)

| Module | Package | Ports / classes | Status |
|--------|---------|-----------------|--------|
| Shared Core | `after_core` | `AfterAuthRepository`, `AfterAiCredentialVault`, `AfterAnalytics`, `AfterApiClient`, `AfterDeepLinkService`, `AfterFeatureFlags`, `AfterLogger`, `AfterLocalNotifications`, `AfterRemotePush`, `AfterPreferences`, `AfterSecureStorage`, `AfterSubscriptionVerifier`, `AppPlatformManifest` | shipping |
| Shared Design System | `after_design_system` | tokens + `AfterTheme`, `AfterScaffold`, `AfterCard`, `AfterAppBar`, `AfterNavigation` | shipping |
| Shared Authentication | `after_core` | `AfterAuthRepository`, `PrefsGoogleAuthRepository`, `AfterSuperAdmin` | shipping |
| Shared Dashboard Engine | `after_core` + `after_design_system` | `DashboardEngine`, `DashboardLayout`, `hydrateDashboardEngine`, `AfterDashboard` — see [DASHBOARD_ENGINE.md](DASHBOARD_ENGINE.md) | shipping |
| Shared Plugin System | `after_core` | `AfterPluginRegistry`, `AfterPluginCatalog`, `hydrateAfterPlugins`, `AfterPluginHost` — see [PLUGIN_SYSTEM.md](PLUGIN_SYSTEM.md) | shipping |
| **After Ecosystem Manifest** | — | Binding law — [AFTER_ECOSYSTEM_MANIFEST.md](AFTER_ECOSYSTEM_MANIFEST.md) (v1.0) | shipping |
| **Life Domains vision** | — | Organizing principle — [LIFE_DOMAINS.md](LIFE_DOMAINS.md) · [LIFE_DOMAIN_ROADMAP.md](LIFE_DOMAIN_ROADMAP.md) | shipping |
| **Architecture Review 2026** | — | Binding ADRs — [ARCHITECTURE_REVIEW_2026.md](ARCHITECTURE_REVIEW_2026.md) + [adr/](adr/) | shipping |
| **After Ecosystem Platform** | `after_ecosystem` | `AfterEcosystemFabric`, After ID, After+, event bus, product APIs, shared services, AI context — see [AFTER_ECOSYSTEM_PLATFORM.md](AFTER_ECOSYSTEM_PLATFORM.md) | shipping |
| Enterprise Product Runtime | `after_enterprise` | `EnterpriseProductRuntime`, `AfterEnterpriseAuthGate`, `AfterEnterpriseMainShell` — thin products mount these; see [PLATFORM_DOCTRINE.md](PLATFORM_DOCTRINE.md) | shipping |
| Shared Search Engine | `after_core` | `AfterSearchPort`, `SearchQuery`, `SearchHit`, `SearchIndex`, `InMemoryAfterSearch`, `InMemorySearchIndex`, `afterSearchPortProvider` | shipping |
| Shared Settings Engine | `after_core` | `AfterSettingsStore`, `AfterSettingsKeys`, `AfterThemeModeValue`, `PrefsAfterSettingsStore`, `afterSettingsStoreProvider` | shipping |
| Shared Notification Engine | `after_core` + `after_enterprise` | `AfterLocalNotifications`, `AfterRemotePush`, `EnterpriseNotificationDispatcher` | shipping |
| Shared Analytics | `after_core` + `after_enterprise` | `AfterAnalytics`, `EnterpriseAnalytics` | shipping |
| Shared AI Modules | `after_core` + `after_enterprise` | `AfterAiCredentialVault`, `SimpleAfterAiOrchestrator`, `EnterpriseAiAssistant` | shipping |
| Shared API Layer | `after_core` + `after_enterprise` | `AfterApiClient`, `EnterpriseApiClient`, `EnterpriseApiHeaders` | shipping |

## Consumer line (SuperGarage reference)

| Module | Package | Ports / classes | Status |
|--------|---------|-----------------|--------|
| **After Hub (OS shell)** | `after_hub` (product) + fabric | Home / Calendar / Apps / AI / More; federated Hub widgets — [AFTER_HUB.md](AFTER_HUB.md) · ADR-019 | expand |
| Consumer Shell + Catalog | `after_consumer` | `ConsumerCoreFeatureId`, `ConsumerVerticalFeature` | shipping |
| Shared Membership | `after_consumer` (+ `after_core` premium) | `ConsumerMembership`, `AfterEntitlement`, `AfterUserPlan` | shipping |
| Personal Vault | `after_consumer` | `PersonalVaultItem`, `PersonalVaultRepository` | shipping |
| Consumer App Template | `templates/super_app_consumer/` | scaffold blueprint + `spec.hub` | expand |

## Enterprise line (SuperHospital reference)

| Module | Package | Ports / classes | Status |
|--------|---------|-----------------|--------|
| Shared Organization | `after_enterprise` | `OrganizationRepository` | shipping |
| Shared Role Management | `after_enterprise` | `RbacRepository`, `Role`, `PermissionSet` | shipping |
| Shared Workflow Engine | `after_enterprise` | `WorkflowCatalog`, `WorkflowDefinitionRegistry`, `hydrateWorkflowCatalog`, `WorkflowEngine`, `WorkflowRepository` — see [WORKFLOW_ENGINE.md](WORKFLOW_ENGINE.md) | shipping |
| Shared Task Engine | `after_enterprise` | `EnterpriseTask`, `TaskRepository`, `InMemoryTaskRepository` | shipping |
| Shared Calendar | `after_enterprise` | `CalendarEvent`, `CalendarRepository` | shipping |
| Shared Document Management | `after_enterprise` | `EnterpriseDocument`, `DocumentRepository` | shipping |
| Shared Messaging | `after_enterprise` | `MessagingChannel`, `MessagingMessage`, `MessagingRepository` | shipping |
| Shared Reporting | `after_enterprise` | `ReportDefinition`, `ReportResult`, `ReportingRepository` | shipping |
| Shared Audit Log | `after_enterprise` | `AuditLogRepository`, `AuditLogEntry` (append-only) | shipping |
| Shared Offline Sync | `after_enterprise` | `OfflineSyncQueue` | shipping |
| Enterprise App Template | `templates/super_app_enterprise/` | scaffold blueprint | expand |

## Inheritance rules

- **A capability listed here is NEVER re-implemented per product.**
  If SuperAirport needs "just a bit more" tasks logic, it either
  reuses `TaskRepository` as-is or upgrades the port upstream for the
  entire enterprise line.
- **Products depend on ports, not on backends.** Real backends bind at
  the product's composition root by overriding the relevant provider
  (e.g. `enterpriseRepositoryProvider.overrideWithValue(FirestoreEnterpriseRepository(...))`).
- **The design system is immutable per product.** Accent color and
  monogram are the only visual knobs a `product.spec.yaml` exposes.
- **Mock-first.** Every port ships with an `InMemory*` or mock default,
  so a freshly generated scaffold runs green without any backend.

## Adding a new module

See section 8 ("How to add a new shared module to the factory") in
[`PRODUCT_FACTORY.md`](PRODUCT_FACTORY.md).
