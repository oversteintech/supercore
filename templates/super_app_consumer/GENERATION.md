# Consumer template — generation contract

This document lists every file
[`scripts/generate_product.ps1`](../../scripts/generate_product.ps1) writes
into a fresh sibling repo when it instantiates the consumer template
from a `product.spec.yaml`.

## Inputs the generator reads

- `metadata.name` — human-readable app name (`SuperExample`).
- `metadata.package` — Flutter pubspec `name` (`super_example`).
- `metadata.bundle` — Android application id / iOS bundle id
  (`com.overstein.superexample`).
- `metadata.productLine` — must equal `consumer`.
- `spec.domain` — 1-line domain description.
- `spec.reference` — reference app (`SuperGarage`).
- `spec.features[]` — vertical features (id + i18n keys).
- `spec.navigation.tabs[]` — shell tabs. Each tab is either an inherited
  OS module (`module:`) or a vertical feature (`feature:`).
- `spec.permissions[]` — RBAC keys (usually empty for consumer apps).
- `spec.dashboard.widgets[]` — DashboardWidgetSpec list.
- `spec.ai.skills[]` — vertical AI skills catalog.
- `spec.branding.accent` — hex accent color.
- `spec.branding.monogram` — 2–3 char OVERSTEIN splash monogram.
- `spec.locales[]` — BCP-47 locales the scaffold ships.

## Files the generator writes

| Path | Purpose |
|------|---------|
| `pubspec.yaml` | Depends on `after_core`, `after_consumer`, `after_design_system` via `path:` back to `supercore/packages/*`. |
| `README.md` | Product identity, stack diagram, references. Regenerated only if missing. |
| `docs/PRODUCT.md` | Domain brief + vertical feature list. Existing versions are preserved on re-run. |
| `lib/app/platform/manifest.dart` | `AppPlatformManifest` with `AfterProductLine.consumer`. |
| `lib/app/platform/after_framework.dart` | `ensureConfigured` stub calling `AfterStandardOverrides.create`. |
| `lib/features/feature_catalog.dart` | Product-owned vertical feature catalog derived from `spec.features`. |
| `lib/features/shell/main_shell.dart` | Skeleton `MainShell` deriving tab list from `spec.navigation.tabs`. |
| `assets/l10n/en.json`, `assets/l10n/tr.json`, … | l10n stub with every `titleKey` / `subtitleKey` / `labelKey` referenced from the spec. |
| `.github/workflows/ci.yml` | Standard analyze + test workflow with sibling `supercore` checkout. |

## What the generator does NOT write

- Firebase / Supabase / vendor SDK wiring.
- App store metadata.
- Custom design tokens (family palette is fixed by `after_design_system`).
- Any file already present when the generator re-runs (safe to invoke
  repeatedly).

## Post-generation checklist

1. `flutter create .` inside the new sibling directory to add the
   platform folders.
2. `flutter pub get` — verifies path deps to `supercore/packages/*`.
3. `flutter analyze` — MUST be clean.
4. Bind real backend adapters at composition root when the product
   graduates from mock to shipping.
