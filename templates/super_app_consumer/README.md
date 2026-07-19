# Super App — Consumer template

Composition-root template for **B2C** AfterArtificial Super Apps.

Reference app: **SuperGarage**. Copy this template into a new Flutter app
as `lib/app/platform/`:

1. `manifest.dart` — product `AppPlatformManifest` (product line = consumer).
2. `after_framework.dart` — `ensureConfigured` + provider overrides.
3. Wire `main.dart` → `ProviderScope(overrides: [...])`.
4. Add `after_core` + `after_consumer` + `after_design_system` as
   `path:` dependencies pointing at `supercore/packages/*`.
5. Drop the vertical experience into `lib/features/<vertical>/`.

See `docs/CONSUMER_FRAMEWORK.md` in supercore.
