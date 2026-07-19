# Super App checklist (After Framework)

Use before starting a new vertical (e.g. SuperHealth, SuperFinance).

## Must

- [ ] Depend on `after_core` + `after_design_system` from this repo
- [ ] Unique `AppPlatformManifest` (appId, packageName, widget provider, iOS app group)
- [ ] Composition root: `lib/app/platform/after_framework.dart` with `create*Overrides()`
- [ ] Set `PlatformConfig.current` before `runApp`
- [ ] Auth / analytics / push / entitlements behind After ports (adapters)
- [ ] HTTPS Dio policy (`requireHttps: true`)
- [ ] Theme from `AfterThemeData` / design system
- [ ] Vertical features only under `lib/features/`
- [ ] Smoke test: manifest + overrides non-empty
- [ ] CI: format, analyze, test

## Should

- [ ] Store flavors: `play` / `dev` / `huawei`
- [ ] `assets/l10n` + string catalog
- [ ] Entitlement matrix → `AfterUserPlan` / `AfterPlanFeature`
- [ ] Privacy / terms URLs on Overstein legal hub

## Reference

- Flagship: `oversteintech/supergarage`
- Docs: https://www.afterframework.com/start
