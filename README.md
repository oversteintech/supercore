# SuperCore

**Status:** Scaffold · reserved for the shared Super App core extracted from SuperGarage.

## Intent

`supercore` is the long-term home for **After Framework** Flutter packages (today living inside [`oversteintech/supergarage`](https://github.com/oversteintech/supergarage) as path packages):

| Package | Role |
|---------|------|
| `after_core` | Auth, Dio, storage, DI, AI BYOK, premium, flags, notifications, deep links |
| `after_design_system` | Ice-on-graphite tokens + shared UI components |

Public docs: [afterframework.com](https://www.afterframework.com)

## Until extract

1. Develop packages in SuperGarage `packages/after_core` and `packages/after_design_system`.
2. New Super Apps (e.g. SuperHealth) depend via `path:` or git submodule until this repo is populated.
3. Follow [Platform Standard](https://www.afterframework.com/standard) and SuperGarage composition root as reference.

## Ecosystem

```
AfterArtificial (products) → Super* Apps
  └── Powered by After Framework (afterframework.com)
        └── Packages → this repo (target)
              └── Built by Overstein Labs (overstein.com)
```

## Next steps

- [ ] Copy `after_core` + `after_design_system` from SuperGarage
- [ ] Add CI (format / analyze / test)
- [ ] Publish versioning policy (path → git tags → pub.dev optional)
- [ ] Wire SuperGarage + SuperHealth to consume this repo
