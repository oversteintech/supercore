# Consumer Framework

The consumer product line (`AfterProductLine.consumer`) is the family of
B2C AfterArtificial Super Apps. **SuperGarage is the reference.**

## Stack

```
Product (lib/features/<vertical>/)
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
4. Shell uses the `ConsumerCoreFeatureId` tabs — Home, Explore,
   Assistant, Search, Profile.
5. Vertical features drop into `lib/features/<vertical>/` and register
   with the product's own feature catalog.

See `templates/super_app_consumer/` in this repo.
