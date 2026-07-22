# Enterprise template — generation contract

This document lists every file
[`scripts/generate_product.ps1`](../../scripts/generate_product.ps1) writes
into a fresh sibling repo when it instantiates the enterprise template
from a `product.spec.yaml`.

## Inputs the generator reads

- `metadata.name` — human-readable app name (`SuperAirport`).
- `metadata.package` — Flutter pubspec `name` (`super_airport`).
- `metadata.bundle` — Android application id / iOS bundle id
  (`com.overstein.superairport`).
- `metadata.productLine` — must equal `enterprise`.
- `spec.domain` — 1-line domain description.
- `spec.reference` — reference app (`SuperHospital`).
- `spec.features[]` — vertical features (id + i18n keys + optional
  `requiredPermission`).
- `spec.navigation.tabs[]` — shell tabs. Each tab is either an inherited
  OS module (`module: tasks|calendar|documents|assistant|dashboard|
  search|more`) or a vertical feature (`feature: <id>`).
- `spec.permissions[]` — RBAC permission strings this vertical enforces.
- `spec.dashboard.widgets[]` — DashboardWidgetSpec list. `type: module`
  widgets bind to inherited OS modules; `type: metric` / `chart` widgets
  bind to `source:` dotted paths into vertical providers.
- `spec.ai.skills[]` — enterprise AI skills catalog with tool bindings.
- `spec.branding.accent` — hex accent color.
- `spec.branding.monogram` — 2–3 char OVERSTEIN splash monogram.
- `spec.locales[]` — BCP-47 locales the scaffold ships.

## Files the generator writes

| Path | Purpose |
|------|---------|
| `pubspec.yaml` | Depends on `after_core`, `after_enterprise`, `after_design_system` via `path:` back to `supercore/packages/*`. |
| `README.md` | Product identity, stack diagram, references. Regenerated only if missing. |
| `docs/PRODUCT.md` | Domain brief + vertical feature list. Existing versions are preserved on re-run (industry modules survive re-generation). |
| `lib/app/platform/manifest.dart` | `AppPlatformManifest` with `AfterProductLine.enterprise`. |
| `lib/app/platform/after_framework.dart` | `ensureConfigured` stub calling `AfterStandardOverrides.create` + `enterpriseRepositoryProvider` override. |
| `lib/features/feature_catalog.dart` | Product-owned vertical feature catalog. |
| `lib/features/shell/main_shell.dart` | Skeleton `MainShell` deriving tabs from `spec.navigation.tabs`. |
| `lib/features/rbac/permissions.dart` | Const list of the permission strings declared in `spec.permissions`. |
| `lib/features/dashboard/dashboard_widgets.dart` | Registers `DashboardWidgetSpec` list from `spec.dashboard.widgets`. |
| `lib/features/ai/skills.dart` | Registers vertical AI skills from `spec.ai.skills`. |
| `assets/l10n/en.json`, `assets/l10n/tr.json`, … | l10n stub with every referenced i18n key. |
| `.github/workflows/ci.yml` | Standard analyze + test workflow with sibling `supercore` checkout. |

## What the generator does NOT write

- Firebase / Supabase / HL7 / EDI / MES vendor SDK wiring — real
  backends bind at composition root when the product graduates to
  shipping.
- App store metadata.
- Custom design tokens (family palette is fixed by `after_design_system`).
- Any existing `docs/PRODUCT.md` industry-module list — the generator
  preserves what is already there and only adds a marker footer.

## Post-generation checklist

1. `flutter create .` inside the new sibling directory (adds
   `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`).
2. `flutter pub get`.
3. `flutter analyze` — MUST be clean before wiring vertical features.
4. Optionally seed `MockEnterpriseRepository` fixtures for demos.
5. Bind real backend adapters at composition root when the product
   graduates from mock to shipping.
