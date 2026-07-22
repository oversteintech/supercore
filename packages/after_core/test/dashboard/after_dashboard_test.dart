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

void main() {
  group('DashboardWidgetKindX.tryParse', () {
    test('parses wire names and aliases', () {
      expect(
        DashboardWidgetKindX.tryParse('statistics'),
        DashboardWidgetKind.statistics,
      );
      expect(
        DashboardWidgetKindX.tryParse('aiCard'),
        DashboardWidgetKind.aiCard,
      );
      expect(
        DashboardWidgetKindX.tryParse('quick_actions'),
        DashboardWidgetKind.quickActions,
      );
      expect(
        DashboardWidgetKindX.tryParse('vehicle'),
        DashboardWidgetKind.vehicleCard,
      );
      expect(
        DashboardWidgetKindX.tryParse('patients'),
        DashboardWidgetKind.patientCard,
      );
      expect(DashboardWidgetKindX.tryParse('nope'), isNull);
    });
  });

  group('DashboardLayout', () {
    test('fromJson / toJson round-trip', () {
      const layout = DashboardLayout(
        version: 2,
        id: 'home',
        widgets: [
          DashboardWidgetSpec(
            id: 'stats',
            kind: DashboardWidgetKind.statistics,
            titleKey: 'dash.stats',
            order: 10,
            span: 2,
          ),
          DashboardWidgetSpec(
            id: 'ai',
            kind: DashboardWidgetKind.aiCard,
            titleKey: 'dash.ai',
            order: 20,
          ),
        ],
      );
      final again = DashboardLayout.fromJson(layout.toJson());
      expect(again.version, 2);
      expect(again.widgets.map((w) => w.id), ['stats', 'ai']);
      expect(again.widgets.first.kind, DashboardWidgetKind.statistics);
      expect(again.widgets.first.span, 2);
    });

    test('tryParse accepts widget list-only JSON', () {
      final layout = DashboardLayout.tryParse('''
        [
          {"id":"t","kind":"tasks","titleKey":"dash.tasks","order":1},
          {"id":"n","kind":"news","titleKey":"dash.news","order":2}
        ]
      ''');
      expect(layout, isNotNull);
      expect(layout!.widgets.map((w) => w.kind), [
        DashboardWidgetKind.tasks,
        DashboardWidgetKind.news,
      ]);
    });

    test('tryParse returns null on garbage', () {
      expect(DashboardLayout.tryParse('{not json'), isNull);
      expect(DashboardLayout.tryParse(''), isNull);
    });
  });

  group('InMemoryDashboardEngine', () {
    test('registers and enumerates widgets', () {
      final engine = InMemoryDashboardEngine();
      engine.register(
        const DashboardWidgetSpec(
          id: 'active_flights',
          kind: DashboardWidgetKind.metric,
          titleKey: 'dash.active_flights',
          source: 'vertical.flights.activeCount',
          order: 10,
        ),
      );
      engine.registerAll(const [
        DashboardWidgetSpec(
          id: 'open_tasks',
          kind: DashboardWidgetKind.module,
          titleKey: 'dash.open_tasks',
          module: 'tasks',
          limit: 5,
          order: 20,
        ),
      ]);
      expect(
        engine.all.map((w) => w.id),
        containsAll(['active_flights', 'open_tasks']),
      );
    });

    test('visibleWidgets filters by product line, permission, visible', () {
      final engine = InMemoryDashboardEngine(
        seed: const [
          DashboardWidgetSpec(
            id: 'a',
            kind: DashboardWidgetKind.metric,
            titleKey: 'a',
            productLines: {'enterprise'},
            order: 30,
          ),
          DashboardWidgetSpec(
            id: 'b',
            kind: DashboardWidgetKind.metric,
            titleKey: 'b',
            productLines: {'consumer'},
            order: 20,
          ),
          DashboardWidgetSpec(
            id: 'c',
            kind: DashboardWidgetKind.metric,
            titleKey: 'c',
            requiredPermission: 'flights.read',
            order: 10,
          ),
          DashboardWidgetSpec(
            id: 'hidden',
            kind: DashboardWidgetKind.news,
            titleKey: 'h',
            visible: false,
            order: 5,
          ),
        ],
      );

      final visible = engine.visibleWidgets(
        const DashboardContext(
          productLine: 'enterprise',
          permissions: {'flights.read'},
        ),
      );
      expect(visible.map((w) => w.id), ['c', 'a']);
    });

    test('applyJson replaces layout without code changes', () {
      final engine = InMemoryDashboardEngine(
        seed: const [
          DashboardWidgetSpec(
            id: 'old',
            kind: DashboardWidgetKind.custom,
            titleKey: 'old',
          ),
        ],
      );
      final ok = engine.applyJson('''
      {
        "version": 1,
        "id": "home",
        "widgets": [
          {"id":"vehicles","kind":"vehicleCard","titleKey":"dash.vehicles","order":10},
          {"id":"qa","kind":"quickActions","titleKey":"dash.qa","order":20,
           "data":{"actions":[{"id":"add","label":"Add"}]}},
          {"id":"weather","kind":"weather","titleKey":"dash.weather","order":30,"visible":false}
        ]
      }
      ''');
      expect(ok, isTrue);
      expect(engine.currentLayout?.version, 1);
      expect(engine.all.map((w) => w.id), ['vehicles', 'qa', 'weather']);
      final visible = engine.visibleWidgets(const DashboardContext());
      expect(visible.map((w) => w.id), ['vehicles', 'qa']);
    });

    test('applyRemoteConfig uses after.dashboard.layout key', () {
      final engine = InMemoryDashboardEngine();
      final rc = _MemoryRemoteConfig({
        afterDashboardRemoteConfigKey: '''
        {"version":3,"widgets":[
          {"id":"kpi","kind":"kpi","titleKey":"dash.kpi","order":1},
          {"id":"patients","kind":"patient","titleKey":"dash.patients","order":2}
        ]}
        ''',
      });
      expect(engine.applyRemoteConfig(rc), isTrue);
      expect(engine.currentLayout?.version, 3);
      expect(engine.all.map((w) => w.kind), [
        DashboardWidgetKind.kpi,
        DashboardWidgetKind.patientCard,
      ]);
    });

    test('hydrateDashboardEngine prefers Remote Config over asset defaults', () {
      final engine = InMemoryDashboardEngine();
      final rc = _MemoryRemoteConfig({
        afterDashboardRemoteConfigKey:
            '{"version":9,"widgets":[{"id":"rc","kind":"news","titleKey":"n","order":1}]}',
      });
      final applied = hydrateDashboardEngine(
        engine,
        defaultJson:
            '{"version":1,"widgets":[{"id":"asset","kind":"tasks","titleKey":"t","order":1}]}',
        remoteConfig: rc,
      );
      expect(applied, isTrue);
      expect(engine.all.single.id, 'rc');
      expect(engine.currentLayout?.version, 9);
    });

    test('watchAll emits after register + unregister', () async {
      final engine = InMemoryDashboardEngine();
      final events = <List<DashboardWidgetSpec>>[];
      final sub = engine.watchAll().listen(events.add);
      engine.register(
        const DashboardWidgetSpec(
          id: 'x',
          kind: DashboardWidgetKind.metric,
          titleKey: 'x',
        ),
      );
      engine.unregister('x');
      await Future<void>.delayed(Duration.zero);
      expect(events.length, 2);
      expect(events.first.first.id, 'x');
      expect(events.last, isEmpty);
      await sub.cancel();
      await engine.dispose();
    });

    test('copyWith overrides selected fields', () {
      const spec = DashboardWidgetSpec(
        id: 'x',
        kind: DashboardWidgetKind.metric,
        titleKey: 'x',
      );
      final copy = spec.copyWith(order: 5, subtitleKey: 'sub');
      expect(copy.order, 5);
      expect(copy.subtitleKey, 'sub');
      expect(copy.id, 'x');
    });
  });
}
