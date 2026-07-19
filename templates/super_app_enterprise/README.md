# Super App — Enterprise template

Composition-root template for **B2B / vertical** AfterArtificial Super
Apps.

Reference app: **SuperHospital**. Copy this template into a new Flutter
app as `lib/app/platform/`:

1. `manifest.dart` — product `AppPlatformManifest` (product line =
   enterprise).
2. `after_framework.dart` — `ensureConfigured` + `enterpriseRepositoryProvider`
   override (default: `MockEnterpriseRepository`).
3. Wire `main.dart` → `ProviderScope(overrides: [...])`.
4. Add `after_core` + `after_enterprise` + `after_design_system` as
   `path:` dependencies pointing at `supercore/packages/*`.
5. Enterprise shell — Home, Tasks, Calendar, Documents, AI, More — sits
   in `lib/features/shell/`.
6. Industry / vertical modules go under `lib/features/<vertical>/`
   (Patients / Wards / Pharmacy for hospitals; Berths / Manifests for
   maritime; Runways / Gates for airport; …).

See `docs/ENTERPRISE_FRAMEWORK.md` and
`docs/SUPER_HOSPITAL_STANDARD.md` in supercore.
