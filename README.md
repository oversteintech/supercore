# SuperCore — After Framework packages

Canonical home of **After Framework** Flutter packages for AfterArtificial Super Apps.

| Package | Role |
|---------|------|
| [`packages/after_core`](packages/after_core) | Auth, Dio, storage, DI, AI BYOK, premium, flags, notifications, deep links, `AppPlatformManifest` |
| [`packages/after_design_system`](packages/after_design_system) | Ice-on-graphite tokens + shared UI |

Docs: [afterframework.com](https://www.afterframework.com) · Standard: [afterframework.com/standard](https://www.afterframework.com/standard)

## Consume from a Super App

**Sibling checkout (local, recommended):**

```text
HANTURAI/
  supercore/
  supergarage/
  superhealth/
```

```yaml
dependencies:
  after_core:
    path: ../supercore/packages/after_core
  after_design_system:
    path: ../supercore/packages/after_design_system
```

**Git dependency:**

```yaml
dependencies:
  after_core:
    git:
      url: https://github.com/oversteintech/supercore.git
      path: packages/after_core
      ref: main
  after_design_system:
    git:
      url: https://github.com/oversteintech/supercore.git
      path: packages/after_design_system
      ref: main
```

## New Super App checklist

See [`SUPER_APP_CHECKLIST.md`](SUPER_APP_CHECKLIST.md) and the template under [`templates/super_app/`](templates/super_app/).

## Develop packages

```bash
cd packages/after_core && flutter pub get && flutter test
cd packages/after_design_system && flutter pub get && flutter test
```

## Ecosystem

```
AfterArtificial → Super* Apps
  └── After Framework (afterframework.com)
        └── packages → this repo
              └── Built by Overstein Labs
```
