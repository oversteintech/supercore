# SuperCore — After OS packages

Canonical home of the **After OS** — AfterArtificial's dual-line AI
Operating System for building hundreds of Super Apps from ONE shared
kernel.

- **Consumer line** — reference: `SuperGarage`.
- **Enterprise line** — reference: `SuperHospital`.

Both lines share `after_core` + `after_design_system`. Product lines
layer on `after_consumer` **or** `after_enterprise`.

## Packages

| Package | Role |
|---------|------|
| [`packages/after_core`](packages/after_core) | Shared kernel: auth, Dio, storage, DI, AI BYOK, premium, flags, notifications, deep links, `AppPlatformManifest` (with `AfterProductLine`). |
| [`packages/after_design_system`](packages/after_design_system) | Ice-on-graphite tokens + shared UI. Identical across consumer + enterprise. |
| [`packages/after_consumer`](packages/after_consumer) | OS layer for B2C Super Apps — membership bridge, consumer feature catalog, personal vault. |
| [`packages/after_enterprise`](packages/after_enterprise) | OS layer for B2B / vertical Super Apps — organization, RBAC, workflow engine, tasks, calendar, documents, enterprise AI, messaging, notifications, reporting, analytics, audit log, offline sync, API conventions. |

## Templates

- [`templates/super_app_consumer/`](templates/super_app_consumer/) — consumer scaffold blueprint (SuperGarage sibling).
- [`templates/super_app_enterprise/`](templates/super_app_enterprise/) — enterprise scaffold blueprint (SuperHospital sibling).

## Product catalog

Machine-readable registry: [`catalog/products.yaml`](catalog/products.yaml).
Human-readable table: [`docs/PRODUCT_CATALOG.md`](docs/PRODUCT_CATALOG.md).

## Documentation

- [`docs/AFTER_OS_ARCHITECTURE.md`](docs/AFTER_OS_ARCHITECTURE.md) — master architecture.
- [`docs/CONSUMER_FRAMEWORK.md`](docs/CONSUMER_FRAMEWORK.md) — B2C product-line framework.
- [`docs/ENTERPRISE_FRAMEWORK.md`](docs/ENTERPRISE_FRAMEWORK.md) — B2B / vertical product-line framework.
- [`docs/SUPER_HOSPITAL_STANDARD.md`](docs/SUPER_HOSPITAL_STANDARD.md) — enterprise reference checklist.
- [`STANDARD_APIS.md`](STANDARD_APIS.md) — after_core ports and providers.
- [`SUPER_APP_CHECKLIST.md`](SUPER_APP_CHECKLIST.md) — new Super App checklist.

Docs site: [afterframework.com](https://www.afterframework.com) · Standard: [afterframework.com/standard](https://www.afterframework.com/standard).

## Consume from a Super App

**Sibling checkout (local, recommended):**

```text
HANTURAI/
  supercore/
  supergarage/         # consumer reference
  superhospital/       # enterprise reference
  superhealth/  superfinance/  superhome/  supertravel/  supersports/ …
```

### Consumer product

```yaml
dependencies:
  after_core:
    path: ../supercore/packages/after_core
  after_consumer:
    path: ../supercore/packages/after_consumer
  after_design_system:
    path: ../supercore/packages/after_design_system
```

### Enterprise product

```yaml
dependencies:
  after_core:
    path: ../supercore/packages/after_core
  after_enterprise:
    path: ../supercore/packages/after_enterprise
  after_design_system:
    path: ../supercore/packages/after_design_system
```

## Develop the packages

```bash
cd packages/after_core && flutter pub get && flutter test
cd packages/after_design_system && flutter pub get && flutter test
cd packages/after_consumer && flutter pub get && flutter test
cd packages/after_enterprise && flutter pub get && flutter test
```

## Ecosystem

```
Ayhan Uzundal
  → AfterArtificial (AI Operating System)
      → Consumer line: SuperGarage (flagship) + 11 siblings
      → Enterprise line: SuperHospital (flagship) + 15 verticals
        └── Powered by After Framework (afterframework.com)
              └── packages → this repo
                    └── Built by Overstein Labs
```
