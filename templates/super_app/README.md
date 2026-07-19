# Super App composition-root template

Copy into a new Flutter app as `lib/app/platform/`:

1. `manifest.dart` — product `AppPlatformManifest`
2. `after_framework.dart` — `ensureConfigured` + provider overrides
3. Wire `main.dart` → `ProviderScope(overrides: [...])`

See SuperHealth (`oversteintech/superhealth`) for a minimal working app.
