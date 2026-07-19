# After Consumer

Shared **consumer OS layer** for AfterArtificial B2C Super Apps.

Sits directly on top of the `after_core` kernel. Deliberately thin —
consumer verticals stay lightweight; the important architectural weight
lives in `after_core` (auth, AI, premium, analytics) and in each product's
`lib/features/` folder.

Reference implementation: **SuperGarage**.

## Modules

| Module | API |
|--------|-----|
| Consumer membership | `ConsumerMembership` bridge over `AfterEntitlement` |
| Consumer feature catalog | `ConsumerCoreFeatureId`, `ConsumerVerticalFeature` |
| Personal vault | `PersonalVaultItem`, `PersonalVaultRepository` (in-memory mock) |
| DI | `consumerMembershipProvider`, `personalVaultRepositoryProvider` |

## Rules

1. **Do NOT** put vertical (garage / health / finance) logic here.
2. Consumer verticals compose `after_core` + `after_consumer` +
   `after_design_system` and drop their features into `lib/features/`.
3. Family shell tabs — `ConsumerCoreFeatureId.{home, explore, assistant,
   search, profile}` — mirror SuperGarage.

See `docs/CONSUMER_FRAMEWORK.md`.
