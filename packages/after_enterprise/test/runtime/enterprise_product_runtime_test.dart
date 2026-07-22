import 'package:after_core/after_core.dart';
import 'package:after_enterprise/after_enterprise.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('EnterpriseProductRuntime hydrates dashboard + workflows + plugins',
      () async {
    const runtime = EnterpriseProductRuntime(
      manifest: AppPlatformManifest(
        appName: 'SuperTest',
        appId: 'super_test',
        packageName: 'com.overstein.supertest',
        androidWidgetProvider: 'com.overstein.supertest.WidgetProvider',
        iosAppGroupId: 'group.com.overstein.supertest',
        productLine: AfterProductLine.enterprise,
      ),
      domain: 'Test domain',
      features: [
        EnterpriseIndustryFeature(
          id: 'alpha',
          titleKey: 'features.alpha',
          subtitleKey: 'features.alpha_sub',
        ),
      ],
    );

    final dashboard = InMemoryDashboardEngine();
    final workflows = InMemoryWorkflowDefinitionRegistry();
    final plugins = InMemoryAfterPluginRegistry();

    await runtime.hydratePlatformEngines(
      dashboard: dashboard,
      workflows: workflows,
      plugins: plugins,
      loadAsset: (path) async {
        if (path.contains('dashboard')) {
          return '{"version":1,"widgets":[{"id":"k","kind":"kpi","titleKey":"t","order":1}]}';
        }
        if (path.contains('workflows')) {
          return '{"version":1,"workflows":[{"id":"w","name":"W","initialState":"a","states":["a","b"],"transitions":[{"from":"a","to":"b","event":"go"}]}]}';
        }
        if (path.contains('plugins')) {
          return '{"version":1,"plugins":[{"id":"p","name":"P","version":"1","contributions":[{"id":"n","kind":"navigationItem","titleKey":"n"}]}]}';
        }
        throw StateError(path);
      },
    );

    expect(dashboard.all, isNotEmpty);
    expect(workflows.all.single.id, 'w');
    expect(plugins.all.single.id, 'p');
  });

  test('enterpriseProductRuntimeProvider requires override', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(
      () => container.read(enterpriseProductRuntimeProvider),
      throwsA(
        predicate(
          (Object? e) =>
              e is UnimplementedError ||
              '$e'.contains('UnimplementedError'),
        ),
      ),
    );
  });
}
