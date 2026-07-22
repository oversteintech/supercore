# After OS — master architecture

> **AfterArtificial is an AI Product Platform that generates consumer and
> enterprise software from a unified architecture.**

**Manifest:** [`AFTER_ECOSYSTEM_MANIFEST.md`](AFTER_ECOSYSTEM_MANIFEST.md)
(v1.0). After OS is the shared runtime of that ecosystem. See
[`PLATFORM_DOCTRINE.md`](PLATFORM_DOCTRINE.md): **≥90% reuse**; only
business domain, feature modules, and AI change.

Organizing principle: **Life Domains** (consumer) and **Industry Domains**
(enterprise) — [`LIFE_DOMAINS.md`](LIFE_DOMAINS.md). Scale plan:
[`LIFE_DOMAIN_ROADMAP.md`](LIFE_DOMAIN_ROADMAP.md) (≥100 apps, zero
architecture forks).

All products share ONE kernel (`after_core`) plus ONE of TWO product-line
OS layers:

- `after_consumer` → B2C Life Domain modules (reference: **SuperGarage**).
- `after_enterprise` → B2B Industry Domain modules (reference: **SuperHospital**).

Both lines share:

- After Ecosystem fabric (`after_ecosystem`) — After ID, After+, events, interop.
- After Design System (`after_design_system`) — identical visual family.
- After Framework composition root — same bootstrap contract for every app.
- OVERSTEIN cold-start splash contract.
- Dashboard Engine · Plugin System · Search · Settings (`after_core`).
- Workflow Engine · Product runtime / shell host (`after_enterprise`).
- AfterAI Platform (`after_ai`) — enable/disable per product; one assistant.
- Riverpod DI, domain/data/features layering, l10n (≥20 locales), tests, CI.

≥100 Life/Industry Domain products are **assembled from standards**, not
architected from scratch.

## Package map

```
supercore/
  packages/
    after_core/            # SHARED kernel: auth, network, DI, engines
    after_ecosystem/       # UNIFIED fabric: After ID, events, shared services
    after_ai/              # SHARED AI capability platform
    after_design_system/   # SHARED visual language
    after_consumer/        # OS layer for B2C modules
    after_enterprise/      # OS layer for B2B modules
  templates/
    super_app_consumer/    # consumer scaffold blueprint
    super_app_enterprise/  # enterprise scaffold blueprint
  catalog/
    products.yaml          # machine-readable product registry
  docs/
    LIFE_DOMAINS.md
    LIFE_DOMAIN_ROADMAP.md
    AFTER_ECOSYSTEM_PLATFORM.md
    AFTER_OS_ARCHITECTURE.md
    PLATFORM_DOCTRINE.md
    PRODUCT_CATALOG.md
```

## Dependency diagram

```
Life Domains (Garage, Health, Kids, Sports, …)
Industry Domains (Hospital, Airport, Factory, …)
        ↓ events / secure APIs only
after_ecosystem + after_ai + (after_consumer | after_enterprise)
        ↓
after_core + after_design_system
```

Adding a domain adds a top-layer module only — this diagram does not change.

See [`ARCHITECTURE_REVIEW_2026.md`](ARCHITECTURE_REVIEW_2026.md) and [`adr/`](adr/).

## Product-line manifest

Every Super App declares its line in its `AppPlatformManifest`:

```dart
const superHospitalManifest = AppPlatformManifest(
  appName: 'SuperHospital',
  appId: 'super_hospital',
  packageName: 'com.overstein.superhospital',
  androidWidgetProvider: 'com.overstein.superhospital.WidgetProvider',
  iosAppGroupId: 'group.com.overstein.superhospital',
  productLine: AfterProductLine.enterprise,
);
```

`AfterProductLine` defaults to `consumer` for backward compatibility so
existing SuperGarage-family manifests continue to compile.

## Architecture principles (non-negotiable)

1. **SuperGarage** is the consumer reference; **SuperHospital** is the
   enterprise reference. Every new product looks like its reference.
2. **Industry / vertical modules** live ONLY in product repos under
   `lib/features/<vertical>/`. Never in shared packages.
3. **Shared OS modules** live ONLY in `after_consumer` /
   `after_enterprise` / `after_core`. Never duplicated per product.
4. **Generate**, don't greenfield. New products = template + catalog +
   branding. Never a new architecture.
5. **Ports over SDKs.** Verticals depend on interfaces from
   `after_core` / `after_enterprise`, never on Firebase/Supabase
   directly.
6. **Family feel wins.** UI chrome, motion, density, splash and shell
   patterns are identical across the entire OS. Verticals customize
   only their product accent, industry features, and copy.
7. **Modular, scalable, maintainable, production-ready.** The OS layer
   ships with mock implementations for every port so scaffolds run
   without any backend setup.

## Enterprise OS surface

`after_enterprise` ships these ports (all with in-memory / mock
implementations under `MockEnterpriseRepository`):

| # | Module | Port |
|---|--------|------|
| 1 | Organization / tenant | `OrganizationRepository` |
| 2 | RBAC | `RbacRepository`, `Role`, `PermissionSet` |
| 3 | Workflow engine | `WorkflowEngine`, `WorkflowRepository` |
| 4 | Tasks | `TaskRepository` |
| 5 | Calendar / scheduling | `CalendarRepository` |
| 6 | Documents | `DocumentRepository` |
| 7 | Enterprise AI | `EnterpriseAiAssistant` |
| 8 | Messaging | `MessagingRepository` |
| 9 | Notifications | `EnterpriseNotificationDispatcher` |
| 10 | Reporting | `ReportingRepository` |
| 11 | Analytics | `EnterpriseAnalytics` |
| 12 | Audit log | `AuditLogRepository` (append-only) |
| 13 | Offline sync | `OfflineSyncQueue` |
| 14 | API conventions | `EnterpriseApiClient`, `EnterpriseApiHeaders` |

## Consumer OS surface

`after_consumer` is intentionally thin — most consumer plumbing already
lives in `after_core` (auth, AI BYOK, premium, analytics). It provides:

| Module | API |
|--------|-----|
| Consumer membership bridge | `ConsumerMembership` on `AfterEntitlement` |
| Consumer feature catalog | `ConsumerCoreFeatureId`, `ConsumerVerticalFeature` |
| Personal vault | `PersonalVaultItem`, `PersonalVaultRepository` |

## New product recipe

1. Pick line (consumer or enterprise) + reference app.
2. Copy the matching template into a new sibling Flutter app.
3. Register the product in `catalog/products.yaml`.
4. Add vertical features under `lib/features/<vertical>/`.
5. Bind real backend adapters at composition root (Firestore, GraphQL,
   HL7, EDI, MES, whatever the industry demands).
6. Run `flutter analyze` + `flutter test --coverage`.

The scaffold MUST match SuperGarage / SuperHospital on every family
contract listed in `super-app-compliance-gate.mdc` — if the compliance
report shows deviations, fix them until it's 100% green.
