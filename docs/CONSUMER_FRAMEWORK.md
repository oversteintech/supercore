# Consumer Framework

The consumer product line (`AfterProductLine.consumer`) is the family of
B2C **Life Domain** modules. **SuperGarage is the reference.**

Organizing principle: [`LIFE_DOMAINS.md`](LIFE_DOMAINS.md) ·
Roadmap: [`LIFE_DOMAIN_ROADMAP.md`](LIFE_DOMAIN_ROADMAP.md).

Each consumer Super App **owns one Life Domain** (mobility, health, kids,
finance, …) but mounts the same shell, identity, AI, and ecosystem fabric.
Domains communicate only via `after_ecosystem` events and secure APIs.

## Stack

```
Life Domain product (lib/features/<domain>/)
        ↓
after_ecosystem + after_ai
        ↓
after_consumer   (this OS layer)
        ↓
after_core + after_design_system
```

## What lives in `after_consumer`

- `ConsumerMembership` bridge over the shared `after_core`
  `AfterEntitlement` — verticals never talk to raw plan enums.
- `ConsumerCoreFeatureId` — the family shell tabs used by every consumer
  Super App: `home`, `explore`, `assistant`, `search`, `profile`.
- `PersonalVaultItem` / `PersonalVaultRepository` — thin family / household
  sharing primitive for products that let a user store personal data
  (SuperDocuments, SuperFinance receipts, SuperHealth records, …).

Deliberately thin — most consumer plumbing (auth, BYOK AI, analytics,
premium) is already in `after_core`.

## What DOES NOT live in `after_consumer`

- **Vertical logic** (garage / health / finance / …). That lives in the
  product repo under `lib/features/<vertical>/`.
- **UI components.** All widgets come from `after_design_system`.
- **Network / auth.** That lives in `after_core`.

## Composition contract (consumer Super App)

1. `main.dart` runs `runZonedGuarded` + splash-first cold start
   (SuperGarage / SuperSports pattern).
2. `AppPlatformManifest` has `productLine: AfterProductLine.consumer`
   (default — you may omit it for backward-compat manifests).
3. `ProviderScope.overrides` includes
   `AfterStandardOverrides.create(preferences, userAgent)` from
   `after_core` + any product-specific adapters.
4. Mount `after_ecosystem` (After ID, After+, event bus, shared services)
   and pass ecosystem AI context into After AI.
5. Shell uses the `ConsumerCoreFeatureId` tabs — Home, Explore,
   Assistant, Search, Profile. Domain-specific destinations are feature
   modules, not a private navigation stack.
6. Vertical features drop into `lib/features/<domain>/` and register
   with the product's own feature catalog.

## Navigation structure (shared)

| Layer | Owned by | Contents |
|-------|----------|----------|
| Shell chrome | Platform | 5-tab MainShell, AuthGate, splash, settings, search |
| Domain tabs / grids | Product | Feature catalog entries for that Life Domain only |
| Cross-domain jumps | Ecosystem | Deep links + events — never sibling package imports |

See `templates/super_app_consumer/` in this repo.
