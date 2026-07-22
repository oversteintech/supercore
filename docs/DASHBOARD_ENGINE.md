# Dashboard Engine

Every AfterArtificial Super App builds its **Home** screen from a
configurable list of dashboard widgets. Layout is owned by **JSON**
(bundled asset) and/or **Remote Config** — not by hard-coded Dart trees.

## Packages

| Piece | Package | API |
|-------|---------|-----|
| Specs, layout, engine | `after_core` | `DashboardWidgetKind`, `DashboardWidgetSpec`, `DashboardLayout`, `DashboardEngine`, `InMemoryDashboardEngine`, `hydrateDashboardEngine` |
| UI host | `after_design_system` | `AfterDashboard`, `AfterDashboardTile` |
| Providers | `after_core` | `afterDashboardEngineProvider`, `afterDashboardContextProvider`, `afterDashboardVisibleWidgetsProvider` |

Remote Config key (default): `after.dashboard.layout`

## Widget kinds

| Kind | Typical use |
|------|-------------|
| `statistics` / `metric` | Numeric tiles / strips |
| `tasks` | OS tasks preview |
| `calendar` | Schedule preview |
| `notifications` | Inbox preview |
| `aiCard` | AfterAI insight card |
| `quickActions` | Deep-link action chips (`data.actions`) |
| `recentItems` | Recently viewed entities |
| `favorites` | Pinned items |
| `chart` | Spark / bar / donut (`source`) |
| `documents` | Documents module preview |
| `activityTimeline` | Audit / activity feed |
| `kpi` | Business KPIs (enterprise) |
| `upcomingEvents` | Event list |
| `weather` | Weather card |
| `location` | Location / map snippet |
| `news` | Headlines |
| `vehicleCard` | SuperGarage vehicles |
| `healthCard` | SuperHealth |
| `financeCard` | SuperFinance |
| `propertyCard` | SuperHome |
| `flightCard` | SuperTravel / SuperAirport |
| `patientCard` | SuperHospital |
| `shipCard` | SuperMaritime |
| `module` | Generic OS module slot |
| `custom` | Vertical-supplied card (still layout-owned) |

Aliases (`quick_actions`, `vehicle`, `patients`, …) are accepted by
`DashboardWidgetKindX.tryParse`.

## JSON shape

```json
{
  "version": 1,
  "id": "home",
  "widgets": [
    {
      "id": "stats",
      "kind": "statistics",
      "titleKey": "dash.stats",
      "subtitleKey": "dash.stats_sub",
      "source": "garage.stats",
      "module": "tasks",
      "limit": 5,
      "order": 10,
      "span": 2,
      "visible": true,
      "requiredPermission": "dashboard.read",
      "productLines": ["consumer"],
      "data": {}
    }
  ]
}
```

A bare widget array is also accepted (version defaults to `1`).

Examples:

- [`examples/dashboard/supergarage_home.json`](../examples/dashboard/supergarage_home.json)
- [`examples/dashboard/superhospital_home.json`](../examples/dashboard/superhospital_home.json)

## App wiring (no layout in Dart)

```dart
// 1) Override engine + context at bootstrap
final engine = InMemoryDashboardEngine();
final asset = await rootBundle.loadString('assets/dashboard/home.json');
hydrateDashboardEngine(
  engine,
  defaultJson: asset,
  remoteConfig: ref.read(afterRemoteConfigProvider), // optional
);

// 2) Home screen
final widgets = ref.watch(afterDashboardVisibleWidgetsProvider);
return AfterDashboard(
  widgets: widgets,
  resolveLabel: (key) => ref.tr(key),
  resolveValue: (source) => lookupDomainValue(source),
  onAction: (spec) => navigateFor(spec),
);
```

Ops can push a new `after.dashboard.layout` string via Remote Config;
`hydrateDashboardEngine` / `applyRemoteConfig` replaces the layout without
an app store release.

## Filtering

`DashboardContext` filters by:

- `visible: false` → hidden
- `productLines` → must contain current product line
- `requiredPermission` → must be in session permissions

Widgets are sorted by `order` ascending.

## Product Factory

`product.spec` may declare `dashboard.widgets[]`; the factory copies them
into `assets/dashboard/home.json` and wires `hydrateDashboardEngine` in
bootstrap. See [PRODUCT_FACTORY.md](PRODUCT_FACTORY.md).
