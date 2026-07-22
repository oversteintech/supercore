import 'dart:io';

import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryRemoteConfig implements AfterRemoteConfig {
  _MemoryRemoteConfig(this._values);

  final Map<String, Object?> _values;

  @override
  Future<void> fetchAndActivate({
    Duration minimumFetchInterval = const Duration(hours: 1),
  }) async {}

  @override
  String getString(String key, {String defaultValue = ''}) {
    final v = _values[key];
    if (v is String) return v;
    if (v != null) return '$v';
    return defaultValue;
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) => defaultValue;

  @override
  int getInt(String key, {int defaultValue = 0}) => defaultValue;

  @override
  double getDouble(String key, {double defaultValue = 0}) => defaultValue;

  @override
  Map<String, Object?> getAll() => Map.unmodifiable(_values);

  @override
  Stream<void> get onConfigUpdated => const Stream.empty();
}

class _VinPlugin implements AfterPlugin {
  var installed = false;

  @override
  AfterPluginManifest get manifest => const AfterPluginManifest(
        id: 'vin_runtime',
        name: 'VIN Runtime',
        version: '1.0.0',
        contributions: [
          AfterPluginContribution(
            id: 'vin_page',
            kind: AfterPluginContributionKind.page,
            titleKey: 'vin.page',
            route: '/vin',
          ),
        ],
      );

  @override
  Future<void> install(AfterPluginHost host) async {
    installed = true;
    host.registerPageBuilder('vin_page', (_) => 'VinPage');
  }

  @override
  Future<void> uninstall(AfterPluginHost host) async {
    installed = false;
    host.unregisterContribution('vin_page');
  }
}

void main() {
  group('AfterPluginContributionKindX.tryParse', () {
    test('parses wire names and aliases', () {
      expect(
        AfterPluginContributionKindX.tryParse('dashboardWidget'),
        AfterPluginContributionKind.dashboardWidget,
      );
      expect(
        AfterPluginContributionKindX.tryParse('nav'),
        AfterPluginContributionKind.navigationItem,
      );
      expect(
        AfterPluginContributionKindX.tryParse('ai_skill'),
        AfterPluginContributionKind.aiSkill,
      );
      expect(AfterPluginContributionKindX.tryParse('nope'), isNull);
    });
  });

  group('InMemoryAfterPluginRegistry', () {
    test('loads catalog and exposes contributions by kind', () {
      final registry = InMemoryAfterPluginRegistry();
      final ok = registry.applyJson('''
      {
        "version": 1,
        "plugins": [
          {
            "id": "pack",
            "name": "Pack",
            "version": "1.0.0",
            "contributions": [
              {"id":"p1","kind":"page","titleKey":"t.page","route":"/p","order":1},
              {"id":"n1","kind":"navigationItem","titleKey":"t.nav","route":"/p","order":2},
              {"id":"a1","kind":"aiSkill","titleKey":"t.ai","order":3,
               "data":{"skillId":"s1"}},
              {"id":"r1","kind":"report","titleKey":"t.report","order":4},
              {"id":"f1","kind":"form","titleKey":"t.form","order":5},
              {"id":"api1","kind":"api","titleKey":"t.api","order":6},
              {"id":"m1","kind":"businessModule","titleKey":"t.mod","order":7},
              {"id":"w1","kind":"dashboardWidget","titleKey":"t.w","order":8,
               "data":{"widgetKind":"statistics","source":"x"}}
            ]
          }
        ]
      }
      ''');
      expect(ok, isTrue);
      expect(registry.all, hasLength(1));
      expect(
        registry.contributions(AfterPluginContributionKind.page),
        hasLength(1),
      );
      expect(
        registry.contributions(AfterPluginContributionKind.navigationItem),
        hasLength(1),
      );
      expect(
        registry.contributions(AfterPluginContributionKind.aiSkill),
        hasLength(1),
      );
      expect(
        registry.contributions(AfterPluginContributionKind.report),
        hasLength(1),
      );
      expect(
        registry.contributions(AfterPluginContributionKind.form),
        hasLength(1),
      );
      expect(
        registry.contributions(AfterPluginContributionKind.api),
        hasLength(1),
      );
      expect(
        registry.contributions(AfterPluginContributionKind.businessModule),
        hasLength(1),
      );
      expect(registry.dashboardWidgets().single.kind, DashboardWidgetKind.statistics);
    });

    test('filters by permission and product line', () {
      final registry = InMemoryAfterPluginRegistry(
        seed: const [
          AfterPluginManifest(
            id: 'ent',
            name: 'Enterprise Pack',
            version: '1.0.0',
            productLines: {'enterprise'},
            contributions: [
              AfterPluginContribution(
                id: 'secure',
                kind: AfterPluginContributionKind.page,
                titleKey: 'secure',
                requiredPermission: 'fhir.read',
              ),
              AfterPluginContribution(
                id: 'open',
                kind: AfterPluginContributionKind.page,
                titleKey: 'open',
              ),
            ],
          ),
        ],
      );

      final pages = registry.contributions(
        AfterPluginContributionKind.page,
        context: const AfterPluginContext(
          productLine: 'enterprise',
          permissions: {'fhir.read'},
        ),
      );
      expect(pages.map((p) => p.id), ['secure', 'open']);

      final consumer = registry.enabledPlugins(
        const AfterPluginContext(productLine: 'consumer'),
      );
      expect(consumer, isEmpty);
    });

    test('hydrateAfterPlugins prefers Remote Config', () {
      final registry = InMemoryAfterPluginRegistry();
      final rc = _MemoryRemoteConfig({
        afterPluginCatalogRemoteConfigKey: '''
        {"version":9,"plugins":[
          {"id":"rc","name":"RC","version":"1","contributions":[]}
        ]}
        ''',
      });
      final applied = hydrateAfterPlugins(
        registry,
        defaultJson: '''
        {"version":1,"plugins":[
          {"id":"asset","name":"Asset","version":"1","contributions":[]}
        ]}
        ''',
        remoteConfig: rc,
      );
      expect(applied, isTrue);
      expect(registry.all.single.id, 'rc');
      expect(registry.currentCatalog?.version, 9);
    });

    test('install binds runtime handlers without core changes', () async {
      final registry = InMemoryAfterPluginRegistry();
      final plugin = _VinPlugin();
      await registry.install(plugin);
      expect(plugin.installed, isTrue);
      expect(registry.host.pageBuilder('vin_page')!(
        registry.contributions(AfterPluginContributionKind.page).single,
      ), 'VinPage');
      await registry.uninstall('vin_runtime');
      expect(plugin.installed, isFalse);
      expect(registry.get('vin_runtime'), isNull);
    });

    test('applyPluginDashboardWidgets registers into engine', () {
      final registry = InMemoryAfterPluginRegistry();
      registry.applyJson('''
      {"plugins":[{"id":"p","name":"P","version":"1","contributions":[
        {"id":"w","kind":"dashboardWidget","titleKey":"t",
         "data":{"widgetKind":"news"}}
      ]}]}
      ''');
      final engine = InMemoryDashboardEngine();
      applyPluginDashboardWidgets(engine, registry);
      expect(engine.all.single.kind, DashboardWidgetKind.news);
    });

    test('setEnabled hides contributions without unregistering', () {
      final registry = InMemoryAfterPluginRegistry(
        seed: const [
          AfterPluginManifest(
            id: 'x',
            name: 'X',
            version: '1',
            contributions: [
              AfterPluginContribution(
                id: 'n',
                kind: AfterPluginContributionKind.navigationItem,
                titleKey: 'n',
              ),
            ],
          ),
        ],
      );
      expect(
        registry.contributions(AfterPluginContributionKind.navigationItem),
        hasLength(1),
      );
      registry.setEnabled('x', enabled: false);
      expect(
        registry.contributions(AfterPluginContributionKind.navigationItem),
        isEmpty,
      );
    });
  });

  group('example catalogs', () {
    test('supergarage + superhospital catalogs parse', () {
      for (final name in [
        'supergarage_plugins.json',
        'superhospital_plugins.json',
      ]) {
        final catalog = AfterPluginCatalog.tryParse(
          File(_examplePath(name)).readAsStringSync(),
        );
        expect(catalog, isNotNull, reason: name);
        expect(catalog!.plugins, isNotEmpty, reason: name);
        final kinds = catalog.plugins
            .expand((p) => p.contributions)
            .map((c) => c.kind)
            .toSet();
        expect(kinds, contains(AfterPluginContributionKind.page));
        expect(kinds, contains(AfterPluginContributionKind.navigationItem));
      }
    });
  });
}

String _examplePath(String fileName) {
  final packageRoot = Directory.current.path;
  final candidates = [
    '$packageRoot/../../examples/plugins/$fileName',
    '$packageRoot/../../../examples/plugins/$fileName',
  ];
  for (final c in candidates) {
    final f = File(c);
    if (f.existsSync()) return f.path;
  }
  return candidates.first;
}
