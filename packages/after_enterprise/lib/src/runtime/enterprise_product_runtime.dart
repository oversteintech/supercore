import 'package:after_core/after_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../catalog/enterprise_feature_catalog.dart';
import '../workflow/workflow.dart';

/// Vertical AI skill declared in `product.spec.yaml` — not a new AI stack.
@immutable
class EnterpriseAiSkillSpec {
  const EnterpriseAiSkillSpec({
    required this.id,
    required this.description,
    this.tools = const <String>[],
  });

  final String id;
  final String description;
  final List<String> tools;

  factory EnterpriseAiSkillSpec.fromJson(Map<String, Object?> json) {
    final tools = json['tools'];
    return EnterpriseAiSkillSpec(
      id: '${json['id'] ?? ''}',
      description: '${json['description'] ?? ''}',
      tools: tools is List
          ? tools.map((e) => '$e').toList(growable: false)
          : const <String>[],
    );
  }
}

/// The ≤10% a product may configure. Architecture stays in the platform.
///
/// Generated from `product.spec.yaml`. Products must not invent parallel
/// shells, auth, or engines — they supply this config + vertical widgets.
@immutable
class EnterpriseProductRuntime {
  const EnterpriseProductRuntime({
    required this.manifest,
    required this.domain,
    required this.features,
    this.permissions = const <String>[],
    this.dashboardWidgets = const <DashboardWidgetSpec>[],
    this.aiSkills = const <EnterpriseAiSkillSpec>[],
    this.dashboardAsset = 'assets/dashboard/home.json',
    this.workflowAsset = 'assets/workflows/catalog.json',
    this.pluginAsset = 'assets/plugins/catalog.json',
    this.accentHex,
    this.monogram,
  });

  final AppPlatformManifest manifest;
  final String domain;
  final List<EnterpriseIndustryFeature> features;
  final List<String> permissions;
  final List<DashboardWidgetSpec> dashboardWidgets;
  final List<EnterpriseAiSkillSpec> aiSkills;

  /// Bundled JSON catalogs — layout/process/plugins without code changes.
  final String dashboardAsset;
  final String workflowAsset;
  final String pluginAsset;

  final String? accentHex;
  final String? monogram;

  /// Hydrate platform engines from product assets (call once at warm boot).
  Future<void> hydratePlatformEngines({
    required DashboardEngine dashboard,
    required WorkflowDefinitionRegistry workflows,
    required AfterPluginRegistry plugins,
    required Future<String> Function(String asset) loadAsset,
    AfterRemoteConfig? remoteConfig,
  }) async {
    try {
      final dashJson = await loadAsset(dashboardAsset);
      hydrateDashboardEngine(
        dashboard,
        defaultJson: dashJson,
        remoteConfig: remoteConfig,
      );
    } on Object {
      if (dashboardWidgets.isNotEmpty) {
        dashboard.registerAll(dashboardWidgets);
      }
    }
    try {
      final wfJson = await loadAsset(workflowAsset);
      hydrateWorkflowCatalog(
        workflows,
        defaultJson: wfJson,
        remoteConfig: remoteConfig,
      );
    } on Object {
      // Optional for thin scaffolds.
    }
    try {
      final pluginJson = await loadAsset(pluginAsset);
      hydrateAfterPlugins(
        plugins,
        defaultJson: pluginJson,
        remoteConfig: remoteConfig,
      );
      applyPluginDashboardWidgets(dashboard, plugins);
    } on Object {
      // Optional for thin scaffolds.
    }
  }
}

/// Composition root binding for the current enterprise product.
final enterpriseProductRuntimeProvider =
    Provider<EnterpriseProductRuntime>((ref) {
  throw UnimplementedError(
    'Override enterpriseProductRuntimeProvider with the product '
    'EnterpriseProductRuntime from product.spec.yaml. '
    'See docs/PLATFORM_DOCTRINE.md.',
  );
});

/// Builds a vertical feature page — the only UI products should supply.
typedef EnterpriseFeaturePageBuilder = Widget Function(
  BuildContext context,
  EnterpriseIndustryFeature feature,
);

/// Optional home header (org chip, offline banner). Body is Dashboard Engine.
typedef EnterpriseHomeHeaderBuilder = Widget Function(BuildContext context);
