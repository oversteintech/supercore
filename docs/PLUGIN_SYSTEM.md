# After Plugin System

Every AfterArtificial Super App supports **plugins**. Plugins add pages,
dashboard widgets, AI skills, reports, forms, APIs, navigation items, and
business modules **without modifying the core application**.

Layout of which plugins are installed is owned by **JSON** (bundled asset)
and/or **Remote Config**.

## Packages

| Piece | Package | API |
|-------|---------|-----|
| Manifests, registry, host | `after_core` | `AfterPluginManifest`, `AfterPluginCatalog`, `AfterPluginRegistry`, `hydrateAfterPlugins`, `AfterPluginHost`, `AfterPlugin` |
| Dashboard bridge | `after_core` | `applyPluginDashboardWidgets` |
| Providers | `after_core` | `afterPluginRegistryProvider`, `afterPluginNavigationItemsProvider`, `afterPluginPagesProvider`, `afterPluginAiSkillsProvider` |

Remote Config key (default): `after.plugins.catalog`

AI-specific capability packs (`AfterAiPluginDescriptor`) remain in
`after_ai` and can be mirrored from `aiSkill` contributions.

## Contribution kinds

| Kind | Adds |
|------|------|
| `page` | New screen / route |
| `dashboardWidget` | Home tile (merges into Dashboard Engine) |
| `aiSkill` | AfterAI skill / tool |
| `report` | Report definition |
| `form` | Declarative form schema |
| `api` | API endpoint descriptor |
| `navigationItem` | Shell nav entry (tab / more / drawer) |
| `businessModule` | Vertical feature pack |

## How dynamic loading works

1. **Catalog** — `assets/plugins/catalog.json` lists plugin manifests.
2. **Hydrate** — `hydrateAfterPlugins(registry, defaultJson:, remoteConfig:)`
   at bootstrap. Remote Config wins, so ops can enable packs without a store
   release.
3. **Shell reads contributions** — navigation, pages, AI skills, etc. come
   from `registry.contributions(kind)` / Riverpod helpers. The shell does
   **not** hard-code plugin routes.
4. **Optional runtime handlers** — a Dart `AfterPlugin` package calls
   `registry.install(plugin)` to bind page/form/API handlers on
   `AfterPluginHost` without editing app shell source.
5. **Dashboard merge** — `applyPluginDashboardWidgets(engine, registry)`.

True binary hot-load of arbitrary Dart is out of scope on Flutter mobile;
“dynamic” here means **catalog-driven composition** + optional deferred
plugin packages referenced by `entryPoint`.

## JSON shape

```json
{
  "version": 1,
  "plugins": [
    {
      "id": "vin_decoder",
      "name": "VIN Decoder",
      "version": "1.0.0",
      "entryPoint": "package:after_plugin_vin/after_plugin_vin.dart",
      "contributions": [
        {
          "id": "vin_page",
          "kind": "page",
          "titleKey": "plugin.vin.page",
          "route": "/plugins/vin",
          "order": 10
        },
        {
          "id": "vin_widget",
          "kind": "dashboardWidget",
          "titleKey": "plugin.vin.widget",
          "data": { "widgetKind": "quickActions" }
        }
      ]
    }
  ]
}
```

## Examples

- [`examples/plugins/supergarage_plugins.json`](../examples/plugins/supergarage_plugins.json)
- [`examples/plugins/superhospital_plugins.json`](../examples/plugins/superhospital_plugins.json)

## App wiring

```dart
final registry = ref.read(afterPluginRegistryProvider);
final json = await rootBundle.loadString('assets/plugins/catalog.json');
hydrateAfterPlugins(
  registry,
  defaultJson: json,
  remoteConfig: ref.read(afterRemoteConfigProvider),
);

applyPluginDashboardWidgets(
  ref.read(afterDashboardEngineProvider),
  registry,
  context: ref.read(afterPluginContextProvider),
);

// Shell
final nav = ref.watch(afterPluginNavigationItemsProvider);
final pages = ref.watch(afterPluginPagesProvider);
```

## Rules

1. Do not fork the app shell for each extension — contribute via plugins.
2. Gate contributions with `requiredPermission` / `productLines` as needed.
3. Core modules (auth, shell, engines) stay in `supercore`; plugins stay
   vertical / optional.
4. Prefer declarative contributions; use `AfterPlugin.install` only when
   executable handlers are required.

See also [DASHBOARD_ENGINE.md](DASHBOARD_ENGINE.md),
[AFTER_AI_PLATFORM.md](AFTER_AI_PLATFORM.md),
[WORKFLOW_ENGINE.md](WORKFLOW_ENGINE.md).
