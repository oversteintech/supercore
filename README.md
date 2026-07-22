# SuperCore — AfterArtificial AI Product Platform

> **AfterArtificial is an AI Product Platform that generates consumer and
> enterprise software from a unified architecture.**

Not an app company. Products are **Life Domain / Industry Domain modules
of one ecosystem** — one identity, one AI, one cloud, one subscription.
SuperCore is the factory + OS packages behind that platform.

**Master Vision v2.0:** [`docs/AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md`](docs/AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md)  
**Manifest (v2.0):** [`docs/AFTER_ECOSYSTEM_MANIFEST.md`](docs/AFTER_ECOSYSTEM_MANIFEST.md)  
**Life Domains:** [`docs/LIFE_DOMAINS.md`](docs/LIFE_DOMAINS.md) ·
[`docs/LIFE_DOMAIN_ROADMAP.md`](docs/LIFE_DOMAIN_ROADMAP.md) (≥100 apps)  
**Alignment:** [`docs/MASTER_VISION_ALIGNMENT_2026.md`](docs/MASTER_VISION_ALIGNMENT_2026.md)  
**Doctrine:** [`docs/PLATFORM_DOCTRINE.md`](docs/PLATFORM_DOCTRINE.md) *(platform-first)*  
**Architecture review + ADRs:** [`docs/ARCHITECTURE_REVIEW_2026.md`](docs/ARCHITECTURE_REVIEW_2026.md) · [`docs/adr/`](docs/adr/)  
**Locales (≥20):** [`docs/LOCALES.md`](docs/LOCALES.md) · `AfterSupportedLocales`

- **Consumer Life Domains** — reference: `SuperGarage` (+ Health, Kids, Finance, Home, Travel, Pet, Sports, News, Games, Find, Documents, AI, …).
- **Enterprise Industry Domains** — reference: `SuperHospital` (+ Education, Farm, Airport, …).

Both lines share `after_core` + `after_design_system` + **`after_ai`** +
**`after_ecosystem`** (After ID, After+, events, shared calendar /
notifications / search / documents, cross-product APIs). Product lines
layer on `after_consumer` **or** `after_enterprise`.

- Ecosystem: [`docs/AFTER_ECOSYSTEM_PLATFORM.md`](docs/AFTER_ECOSYSTEM_PLATFORM.md)
- AI: [`docs/AFTER_AI_PLATFORM.md`](docs/AFTER_AI_PLATFORM.md)

## One-command generation

From this repo root:

```powershell
powershell -File scripts\generate_product.ps1 -SpecPath factory\specs\examples\super_airport.product.spec.yaml
```

or, with only a name (for a quick starter):

```powershell
powershell -File scripts\generate_product.ps1 -Name SuperAirport -Reference SuperHospital
```

Validate a spec before generating:

```powershell
powershell -File scripts\validate_product_spec.ps1 -SpecPath factory\specs\examples\super_airport.product.spec.yaml
```

Master handbook: [`docs/PRODUCT_FACTORY.md`](docs/PRODUCT_FACTORY.md).
Every shared module a product inherits: [`docs/MODULE_REGISTRY.md`](docs/MODULE_REGISTRY.md).

## The factory in one picture

```
product.spec.yaml   →   generate_product.ps1   →   sibling Super App repo
   ├─ metadata               ├─ pubspec.yaml           depending only on
   ├─ features               ├─ manifest.dart          after_core +
   ├─ navigation.tabs        ├─ after_framework.dart   after_design_system +
   ├─ permissions            ├─ feature_catalog.dart   after_consumer /
   ├─ dashboard.widgets      ├─ shell/main_shell.dart  after_enterprise
   ├─ ai.skills              ├─ dashboard_widgets      via path: deps.
   ├─ branding               ├─ ai skills
   └─ locales                ├─ l10n/*.json
                             ├─ .github/workflows/ci.yml
                             └─ docs/PRODUCT.md (merge-safe)
```

Everything not listed in the `product.spec.yaml` — auth, membership /
org, RBAC engine, calendar, tasks, notifications, documents, analytics,
workflow, design system, API, offline sync, splash, CI, settings,
search, dashboard engine — is **inherited** from the platform.

## Factory layout

| Path | Purpose |
|------|---------|
| [`factory/README.md`](factory/README.md) | Factory entry point. |
| [`factory/schema/product.spec.schema.json`](factory/schema/product.spec.schema.json) | JSON Schema for `product.spec.yaml`. |
| [`factory/specs/examples/`](factory/specs/examples/) | Example `product.spec.yaml` files (hospital, garage, airport). |
| [`factory/modules/registry.yaml`](factory/modules/registry.yaml) | Machine-readable shared-module registry. |
| [`factory/templates/README.md`](factory/templates/README.md) | Pointers to `templates/super_app_*`. |
| [`scripts/generate_product.ps1`](scripts/generate_product.ps1) | The generator. |
| [`scripts/validate_product_spec.ps1`](scripts/validate_product_spec.ps1) | Fast, no-Flutter validator. |

## Packages

| Package | Role |
|---------|------|
| [`packages/after_core`](packages/after_core) | Shared kernel: auth, Dio, storage, DI, AI BYOK, premium, flags, notifications, deep links, dashboard / plugin / search / settings engines. |
| [`packages/after_ecosystem`](packages/after_ecosystem) | **Ecosystem fabric** — After ID, After+, event bus, product APIs, shared calendar / notifications / search / wallet / family / marketplace / documents / analytics / settings / personalization, ecosystem AI context. |
| [`packages/after_ai`](packages/after_ai) | **AfterAI Platform** — modular AI capabilities; products enable/disable only. |
| [`packages/after_design_system`](packages/after_design_system) | Shared visual language. Identical across consumer + enterprise. |
| [`packages/after_consumer`](packages/after_consumer) | Consumer OS layer — membership, catalog, personal vault. |
| [`packages/after_enterprise`](packages/after_enterprise) | Enterprise OS layer — org, RBAC, workflow, tasks, calendar, documents, runtime shell host. |

## Templates

- [`templates/super_app_consumer/`](templates/super_app_consumer/) — consumer scaffold blueprint (SuperGarage sibling). Ships `product.spec.example.yaml` + `GENERATION.md`.
- [`templates/super_app_enterprise/`](templates/super_app_enterprise/) — enterprise scaffold blueprint (SuperHospital sibling). Ships `product.spec.example.yaml` + `GENERATION.md`.

## Product catalog

Machine-readable registry: [`catalog/products.yaml`](catalog/products.yaml).
Human-readable table: [`docs/PRODUCT_CATALOG.md`](docs/PRODUCT_CATALOG.md).

## Documentation

- [`docs/AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md`](docs/AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md) — **Master Vision v2.0** (superseding).
- [`docs/AFTER_ECOSYSTEM_MANIFEST.md`](docs/AFTER_ECOSYSTEM_MANIFEST.md) — **Manifest v2.0** (binding engineering law).
- [`docs/MASTER_VISION_ALIGNMENT_2026.md`](docs/MASTER_VISION_ALIGNMENT_2026.md) — gaps + decade roadmap.
- [`docs/LIFE_DOMAINS.md`](docs/LIFE_DOMAINS.md) — Life / Industry Domain ownership model.
- [`docs/LIFE_DOMAIN_ROADMAP.md`](docs/LIFE_DOMAIN_ROADMAP.md) — add domains to 100+ without architecture changes.
- [`docs/PLATFORM_DOCTRINE.md`](docs/PLATFORM_DOCTRINE.md) — ≥90% reuse; platform-first rule.
- [`docs/AFTER_ECOSYSTEM_PLATFORM.md`](docs/AFTER_ECOSYSTEM_PLATFORM.md) — fabric architecture (After ID, events, services).
- [`docs/PRODUCT_FACTORY.md`](docs/PRODUCT_FACTORY.md) — factory handbook.
- [`docs/MODULE_REGISTRY.md`](docs/MODULE_REGISTRY.md) — inherited modules.
- [`docs/PLUGIN_SYSTEM.md`](docs/PLUGIN_SYSTEM.md) · [`DASHBOARD_ENGINE.md`](docs/DASHBOARD_ENGINE.md) · [`WORKFLOW_ENGINE.md`](docs/WORKFLOW_ENGINE.md).
- [`docs/AFTER_OS_ARCHITECTURE.md`](docs/AFTER_OS_ARCHITECTURE.md) — package map.
- Reuse check: `scripts/check_reuse_contract.ps1 -AppRoot ..\<product>`
- [`docs/CONSUMER_FRAMEWORK.md`](docs/CONSUMER_FRAMEWORK.md) — B2C product-line framework.
- [`docs/ENTERPRISE_FRAMEWORK.md`](docs/ENTERPRISE_FRAMEWORK.md) — B2B / vertical product-line framework.
- [`docs/SUPER_HOSPITAL_STANDARD.md`](docs/SUPER_HOSPITAL_STANDARD.md) — enterprise reference checklist.
- [`STANDARD_APIS.md`](STANDARD_APIS.md) — `after_core` ports and providers.
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
  → AfterArtificial — AI Product Platform
    (generates consumer + enterprise software from one architecture)
      → Life Domains: SuperGarage (ref) · Health · Kids · Finance · …
      → Industry Domains: SuperHospital (ref) · Airport · Factory · …
        └── After OS / After Framework / AfterAI
              └── SuperCore (this repo) — factory + packages
                    └── Built by Overstein Labs
```
