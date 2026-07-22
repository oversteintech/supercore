import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../dashboard/after_dashboard.dart';
import '../remote_config/after_remote_config.dart';

/// Remote Config / asset key for the plugin catalog JSON.
const afterPluginCatalogRemoteConfigKey = 'after.plugins.catalog';

/// What a plugin may contribute into a Super App shell.
enum AfterPluginContributionKind {
  /// Full screen / route (`route`, optional `pageBuilder` handler).
  page,

  /// Home dashboard tile — merges into [DashboardEngine].
  dashboardWidget,

  /// AfterAI skill / tool descriptor.
  aiSkill,

  /// Report definition for reporting hosts.
  report,

  /// Declarative form schema (+ optional handler).
  form,

  /// API route / client endpoint descriptor (+ optional handler).
  api,

  /// Shell navigation entry (tab, drawer, more menu).
  navigationItem,

  /// Vertical business module (feature pack) entry.
  businessModule,
}

extension AfterPluginContributionKindX on AfterPluginContributionKind {
  String get wireName => name;

  static AfterPluginContributionKind? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final normalized = raw.trim();
    for (final kind in AfterPluginContributionKind.values) {
      if (kind.name == normalized) return kind;
    }
    return switch (normalized) {
      'pages' || 'screen' || 'screens' => AfterPluginContributionKind.page,
      'dashboard' ||
      'dashboard_widget' ||
      'widget' ||
      'widgets' =>
        AfterPluginContributionKind.dashboardWidget,
      'ai' ||
      'skill' ||
      'skills' ||
      'ai_skill' ||
      'aiSkills' =>
        AfterPluginContributionKind.aiSkill,
      'reports' => AfterPluginContributionKind.report,
      'forms' => AfterPluginContributionKind.form,
      'apis' || 'endpoint' || 'endpoints' => AfterPluginContributionKind.api,
      'nav' ||
      'navigation' ||
      'nav_item' ||
      'navItem' =>
        AfterPluginContributionKind.navigationItem,
      'module' ||
      'modules' ||
      'business_module' ||
      'businessModule' =>
        AfterPluginContributionKind.businessModule,
      _ => null,
    };
  }
}

/// Single contribution declared by a plugin (data-only, JSON-serializable).
@immutable
class AfterPluginContribution {
  const AfterPluginContribution({
    required this.id,
    required this.kind,
    required this.titleKey,
    this.subtitleKey,
    this.route,
    this.iconKey,
    this.order = 100,
    this.enabled = true,
    this.requiredPermission,
    this.productLines,
    this.data = const <String, Object?>{},
  });

  final String id;
  final AfterPluginContributionKind kind;
  final String titleKey;
  final String? subtitleKey;

  /// Deep link / named route for pages and navigation items.
  final String? route;
  final String? iconKey;
  final int order;
  final bool enabled;
  final String? requiredPermission;
  final Set<String>? productLines;

  /// Kind-specific payload (form schema, API method/path, report columns, …).
  final Map<String, Object?> data;

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind.wireName,
        'titleKey': titleKey,
        if (subtitleKey != null) 'subtitleKey': subtitleKey,
        if (route != null) 'route': route,
        if (iconKey != null) 'iconKey': iconKey,
        'order': order,
        'enabled': enabled,
        if (requiredPermission != null)
          'requiredPermission': requiredPermission,
        if (productLines != null) 'productLines': productLines!.toList(),
        if (data.isNotEmpty) 'data': data,
      };

  factory AfterPluginContribution.fromJson(Map<String, Object?> json) {
    final kindRaw = '${json['kind'] ?? ''}';
    final kind = AfterPluginContributionKindX.tryParse(kindRaw) ??
        AfterPluginContributionKind.businessModule;
    final lines = json['productLines'];
    return AfterPluginContribution(
      id: '${json['id'] ?? ''}',
      kind: kind,
      titleKey: '${json['titleKey'] ?? json['title'] ?? ''}',
      subtitleKey:
          json['subtitleKey'] as String? ?? json['subtitle'] as String?,
      route: json['route'] as String? ?? json['path'] as String?,
      iconKey: json['iconKey'] as String? ?? json['icon'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 100,
      enabled: json['enabled'] as bool? ?? true,
      requiredPermission: json['requiredPermission'] as String? ??
          json['permission'] as String?,
      productLines:
          lines is List ? lines.map((e) => '$e').toSet() : null,
      data: _asStringKeyedMap(json['data'] ?? json['config']),
    );
  }

  /// Build a [DashboardWidgetSpec] when [kind] is [dashboardWidget].
  DashboardWidgetSpec? toDashboardWidgetSpec({String? pluginId}) {
    if (kind != AfterPluginContributionKind.dashboardWidget) return null;
    final kindRaw = '${data['widgetKind'] ?? data['kind'] ?? 'custom'}';
    final widgetKind = DashboardWidgetKindX.tryParse(kindRaw) ??
        DashboardWidgetKind.custom;
    return DashboardWidgetSpec(
      id: pluginId == null ? id : '${pluginId}_$id',
      kind: widgetKind,
      titleKey: titleKey,
      subtitleKey: subtitleKey,
      module: data['module'] as String?,
      source: data['source'] as String?,
      limit: (data['limit'] as num?)?.toInt(),
      order: order,
      span: (data['span'] as num?)?.toInt() ?? 1,
      visible: enabled,
      requiredPermission: requiredPermission,
      productLines: productLines,
      data: data,
    );
  }
}

/// Installable plugin descriptor — loaded from JSON / Remote Config.
@immutable
class AfterPluginManifest {
  const AfterPluginManifest({
    required this.id,
    required this.name,
    required this.version,
    required this.contributions,
    this.nameKey,
    this.descriptionKey,
    this.enabled = true,
    this.minAppVersion,
    this.productLines,
    this.organizationIds,
    this.dependencies = const <String>[],
    this.entryPoint,
    this.metadata = const <String, Object?>{},
  });

  final String id;
  final String name;
  final String? nameKey;
  final String? descriptionKey;
  final String version;
  final bool enabled;
  final String? minAppVersion;
  final Set<String>? productLines;
  final Set<String>? organizationIds;

  /// Other plugin ids that must be enabled first.
  final List<String> dependencies;

  /// Optional Dart package / deferred library id for runtime handlers.
  final String? entryPoint;

  final List<AfterPluginContribution> contributions;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        if (nameKey != null) 'nameKey': nameKey,
        if (descriptionKey != null) 'descriptionKey': descriptionKey,
        'version': version,
        'enabled': enabled,
        if (minAppVersion != null) 'minAppVersion': minAppVersion,
        if (productLines != null) 'productLines': productLines!.toList(),
        if (organizationIds != null)
          'organizationIds': organizationIds!.toList(),
        if (dependencies.isNotEmpty) 'dependencies': dependencies,
        if (entryPoint != null) 'entryPoint': entryPoint,
        'contributions': [for (final c in contributions) c.toJson()],
        if (metadata.isNotEmpty) 'metadata': metadata,
      };

  factory AfterPluginManifest.fromJson(Map<String, Object?> json) {
    final contribRaw = json['contributions'] ?? json['provides'];
    final contributions = <AfterPluginContribution>[];
    if (contribRaw is List) {
      for (final item in contribRaw) {
        if (item is Map) {
          contributions.add(
            AfterPluginContribution.fromJson(
              item.map((k, v) => MapEntry('$k', v as Object?)),
            ),
          );
        }
      }
    }

    final lines = json['productLines'];
    final orgs = json['organizationIds'];
    final deps = json['dependencies'];

    return AfterPluginManifest(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? json['nameKey'] ?? json['id'] ?? ''}',
      nameKey: json['nameKey'] as String?,
      descriptionKey: json['descriptionKey'] as String?,
      version: '${json['version'] ?? '1.0.0'}',
      enabled: json['enabled'] as bool? ?? true,
      minAppVersion: json['minAppVersion'] as String?,
      productLines:
          lines is List ? lines.map((e) => '$e').toSet() : null,
      organizationIds:
          orgs is List ? orgs.map((e) => '$e').toSet() : null,
      dependencies: deps is List
          ? deps.map((e) => '$e').toList(growable: false)
          : const <String>[],
      entryPoint: json['entryPoint'] as String? ?? json['package'] as String?,
      contributions: List.unmodifiable(contributions),
      metadata: _asStringKeyedMap(json['metadata']),
    );
  }
}

/// Catalog document of plugins (asset / Remote Config payload).
@immutable
class AfterPluginCatalog {
  const AfterPluginCatalog({
    required this.version,
    required this.plugins,
    this.id = 'default',
    this.updatedAt,
  });

  final int version;
  final String id;
  final List<AfterPluginManifest> plugins;
  final DateTime? updatedAt;

  Map<String, Object?> toJson() => {
        'version': version,
        'id': id,
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
        'plugins': [for (final p in plugins) p.toJson()],
      };

  factory AfterPluginCatalog.fromJson(Map<String, Object?> json) {
    final raw = json['plugins'] ?? json['extensions'];
    final plugins = <AfterPluginManifest>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          plugins.add(
            AfterPluginManifest.fromJson(
              item.map((k, v) => MapEntry('$k', v as Object?)),
            ),
          );
        }
      }
    }
    return AfterPluginCatalog(
      version: (json['version'] as num?)?.toInt() ?? 1,
      id: '${json['id'] ?? 'default'}',
      updatedAt: DateTime.tryParse('${json['updatedAt'] ?? ''}'),
      plugins: List.unmodifiable(plugins),
    );
  }

  static AfterPluginCatalog? tryParse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AfterPluginCatalog.fromJson(
          decoded.map((k, v) => MapEntry(k, v as Object?)),
        );
      }
      if (decoded is List) {
        return AfterPluginCatalog(
          version: 1,
          plugins: [
            for (final item in decoded)
              if (item is Map)
                AfterPluginManifest.fromJson(
                  item.map((k, v) => MapEntry('$k', v as Object?)),
                ),
          ],
        );
      }
    } on Object {
      return null;
    }
    return null;
  }
}

/// Filter context for which plugin contributions are visible.
@immutable
class AfterPluginContext {
  const AfterPluginContext({
    this.productLine,
    this.organizationId,
    this.permissions = const <String>{},
    this.appVersion,
  });

  final String? productLine;
  final String? organizationId;
  final Set<String> permissions;
  final String? appVersion;

  bool allowsManifest(AfterPluginManifest manifest) {
    if (!manifest.enabled) return false;
    if (manifest.productLines != null &&
        productLine != null &&
        !manifest.productLines!.contains(productLine)) {
      return false;
    }
    if (manifest.organizationIds != null &&
        organizationId != null &&
        !manifest.organizationIds!.contains(organizationId)) {
      return false;
    }
    return true;
  }

  bool allowsContribution(AfterPluginContribution contribution) {
    if (!contribution.enabled) return false;
    if (contribution.productLines != null &&
        productLine != null &&
        !contribution.productLines!.contains(productLine)) {
      return false;
    }
    final permission = contribution.requiredPermission;
    if (permission != null &&
        permission.isNotEmpty &&
        !permissions.contains(permission)) {
      return false;
    }
    return true;
  }
}

typedef AfterPluginPageBuilder = Object Function(
  AfterPluginContribution contribution,
);

typedef AfterPluginFormHandler = Future<Object?> Function(
  AfterPluginContribution contribution,
  Map<String, Object?> values,
);

typedef AfterPluginApiHandler = Future<Object?> Function(
  AfterPluginContribution contribution,
  Map<String, Object?> args,
);

/// Runtime host where executable plugins bind handlers without editing the app.
class AfterPluginHost {
  final Map<String, AfterPluginPageBuilder> _pageBuilders = {};
  final Map<String, AfterPluginFormHandler> _formHandlers = {};
  final Map<String, AfterPluginApiHandler> _apiHandlers = {};

  void registerPageBuilder(String contributionId, AfterPluginPageBuilder builder) {
    _pageBuilders[contributionId] = builder;
  }

  void registerFormHandler(String contributionId, AfterPluginFormHandler handler) {
    _formHandlers[contributionId] = handler;
  }

  void registerApiHandler(String contributionId, AfterPluginApiHandler handler) {
    _apiHandlers[contributionId] = handler;
  }

  void unregisterContribution(String contributionId) {
    _pageBuilders.remove(contributionId);
    _formHandlers.remove(contributionId);
    _apiHandlers.remove(contributionId);
  }

  AfterPluginPageBuilder? pageBuilder(String contributionId) =>
      _pageBuilders[contributionId];

  AfterPluginFormHandler? formHandler(String contributionId) =>
      _formHandlers[contributionId];

  AfterPluginApiHandler? apiHandler(String contributionId) =>
      _apiHandlers[contributionId];
}

/// Optional runtime package that installs handlers for its manifest.
abstract class AfterPlugin {
  AfterPluginManifest get manifest;

  Future<void> install(AfterPluginHost host);

  Future<void> uninstall(AfterPluginHost host) async {
    for (final c in manifest.contributions) {
      host.unregisterContribution(c.id);
      host.unregisterContribution('${manifest.id}.${c.id}');
    }
  }
}

class AfterPluginException implements Exception {
  AfterPluginException(this.message);
  final String message;
  @override
  String toString() => 'AfterPluginException: $message';
}

/// Loads and queries plugins dynamically — core shell stays unchanged.
abstract class AfterPluginRegistry {
  void registerManifest(AfterPluginManifest manifest);

  void registerAll(Iterable<AfterPluginManifest> manifests);

  void unregister(String pluginId);

  void setEnabled(String pluginId, {required bool enabled});

  void applyCatalog(AfterPluginCatalog catalog);

  bool applyJson(String raw);

  bool applyRemoteConfig(
    AfterRemoteConfig config, {
    String key = afterPluginCatalogRemoteConfigKey,
  });

  /// Install a runtime [AfterPlugin] (manifest + handlers).
  Future<void> install(AfterPlugin plugin);

  Future<void> uninstall(String pluginId);

  AfterPluginManifest? get(String id);

  List<AfterPluginManifest> get all;

  List<AfterPluginManifest> enabledPlugins(AfterPluginContext context);

  List<AfterPluginContribution> contributions(
    AfterPluginContributionKind kind, {
    AfterPluginContext context = const AfterPluginContext(),
  });

  List<DashboardWidgetSpec> dashboardWidgets({
    AfterPluginContext context = const AfterPluginContext(),
  });

  AfterPluginCatalog? get currentCatalog;

  AfterPluginHost get host;

  Stream<void> get onChanged;
}

class InMemoryAfterPluginRegistry implements AfterPluginRegistry {
  InMemoryAfterPluginRegistry({
    Iterable<AfterPluginManifest>? seed,
    AfterPluginHost? host,
  }) : _host = host ?? AfterPluginHost() {
    if (seed != null) registerAll(seed);
  }

  final Map<String, AfterPluginManifest> _plugins =
      <String, AfterPluginManifest>{};
  final Map<String, AfterPlugin> _runtime = <String, AfterPlugin>{};
  final Set<String> _disabled = <String>{};
  final AfterPluginHost _host;
  final StreamController<void> _controller =
      StreamController<void>.broadcast();
  AfterPluginCatalog? _catalog;

  void _emit() {
    if (!_controller.isClosed) _controller.add(null);
  }

  @override
  AfterPluginHost get host => _host;

  @override
  AfterPluginCatalog? get currentCatalog => _catalog;

  @override
  Stream<void> get onChanged => _controller.stream;

  @override
  void registerManifest(AfterPluginManifest manifest) {
    _plugins[manifest.id] = manifest;
    _emit();
  }

  @override
  void registerAll(Iterable<AfterPluginManifest> manifests) {
    for (final m in manifests) {
      _plugins[m.id] = m;
    }
    _emit();
  }

  @override
  void unregister(String pluginId) {
    _plugins.remove(pluginId);
    _disabled.remove(pluginId);
    _runtime.remove(pluginId);
    _emit();
  }

  @override
  void setEnabled(String pluginId, {required bool enabled}) {
    if (enabled) {
      _disabled.remove(pluginId);
    } else {
      _disabled.add(pluginId);
    }
    _emit();
  }

  @override
  void applyCatalog(AfterPluginCatalog catalog) {
    _catalog = catalog;
    _plugins
      ..clear()
      ..addEntries(catalog.plugins.map((p) => MapEntry(p.id, p)));
    _emit();
  }

  @override
  bool applyJson(String raw) {
    final catalog = AfterPluginCatalog.tryParse(raw);
    if (catalog == null) return false;
    applyCatalog(catalog);
    return true;
  }

  @override
  bool applyRemoteConfig(
    AfterRemoteConfig config, {
    String key = afterPluginCatalogRemoteConfigKey,
  }) {
    final raw = config.getString(key);
    if (raw.isEmpty) return false;
    return applyJson(raw);
  }

  @override
  Future<void> install(AfterPlugin plugin) async {
    final missing = plugin.manifest.dependencies
        .where((d) => !_plugins.containsKey(d) || _disabled.contains(d))
        .toList();
    if (missing.isNotEmpty) {
      throw AfterPluginException(
        'Plugin "${plugin.manifest.id}" missing dependencies: $missing',
      );
    }
    await plugin.install(_host);
    _runtime[plugin.manifest.id] = plugin;
    registerManifest(plugin.manifest);
  }

  @override
  Future<void> uninstall(String pluginId) async {
    final runtime = _runtime.remove(pluginId);
    if (runtime != null) {
      await runtime.uninstall(_host);
    }
    unregister(pluginId);
  }

  @override
  AfterPluginManifest? get(String id) => _plugins[id];

  @override
  List<AfterPluginManifest> get all =>
      List<AfterPluginManifest>.unmodifiable(_plugins.values);

  bool _isActive(AfterPluginManifest manifest, AfterPluginContext context) {
    if (_disabled.contains(manifest.id)) return false;
    return context.allowsManifest(manifest);
  }

  @override
  List<AfterPluginManifest> enabledPlugins(AfterPluginContext context) {
    return all.where((p) => _isActive(p, context)).toList(growable: false);
  }

  @override
  List<AfterPluginContribution> contributions(
    AfterPluginContributionKind kind, {
    AfterPluginContext context = const AfterPluginContext(),
  }) {
    final out = <AfterPluginContribution>[];
    for (final plugin in enabledPlugins(context)) {
      for (final c in plugin.contributions) {
        if (c.kind != kind) continue;
        if (!context.allowsContribution(c)) continue;
        out.add(c);
      }
    }
    out.sort((a, b) => a.order.compareTo(b.order));
    return List.unmodifiable(out);
  }

  @override
  List<DashboardWidgetSpec> dashboardWidgets({
    AfterPluginContext context = const AfterPluginContext(),
  }) {
    final out = <DashboardWidgetSpec>[];
    for (final plugin in enabledPlugins(context)) {
      for (final c in plugin.contributions) {
        if (c.kind != AfterPluginContributionKind.dashboardWidget) continue;
        if (!context.allowsContribution(c)) continue;
        final spec = c.toDashboardWidgetSpec(pluginId: plugin.id);
        if (spec != null) out.add(spec);
      }
    }
    out.sort((a, b) => a.order.compareTo(b.order));
    return List.unmodifiable(out);
  }

  Future<void> dispose() async {
    if (!_controller.isClosed) await _controller.close();
  }
}

/// Seed from bundled asset JSON, then overlay Remote Config when present.
bool hydrateAfterPlugins(
  AfterPluginRegistry registry, {
  String? defaultJson,
  AfterRemoteConfig? remoteConfig,
  String remoteKey = afterPluginCatalogRemoteConfigKey,
}) {
  var applied = false;
  if (defaultJson != null && defaultJson.trim().isNotEmpty) {
    if (registry.applyJson(defaultJson)) applied = true;
  }
  if (remoteConfig != null) {
    if (registry.applyRemoteConfig(remoteConfig, key: remoteKey)) {
      applied = true;
    }
  }
  return applied;
}

/// Merge plugin dashboard widgets into a [DashboardEngine] (idempotent by id).
void applyPluginDashboardWidgets(
  DashboardEngine engine,
  AfterPluginRegistry plugins, {
  AfterPluginContext context = const AfterPluginContext(),
}) {
  engine.registerAll(plugins.dashboardWidgets(context: context));
}

Map<String, Object?> _asStringKeyedMap(Object? raw) {
  if (raw is Map<String, Object?>) return Map<String, Object?>.from(raw);
  if (raw is Map) {
    return raw.map((k, v) => MapEntry('$k', v as Object?));
  }
  return const {};
}

/// App-wide plugin registry. Seed from assets/JSON or Remote Config at boot.
final afterPluginRegistryProvider = Provider<AfterPluginRegistry>((ref) {
  final registry = InMemoryAfterPluginRegistry();
  ref.onDispose(() {
    final r = registry;
    unawaited(r.dispose());
  });
  return registry;
});

final afterPluginContextProvider = Provider<AfterPluginContext>((ref) {
  return const AfterPluginContext();
});

/// Convenience providers for shell composition.
final afterPluginNavigationItemsProvider =
    Provider<List<AfterPluginContribution>>((ref) {
  final registry = ref.watch(afterPluginRegistryProvider);
  final context = ref.watch(afterPluginContextProvider);
  final sub = registry.onChanged.listen((_) => ref.invalidateSelf());
  ref.onDispose(sub.cancel);
  return registry.contributions(
    AfterPluginContributionKind.navigationItem,
    context: context,
  );
});

final afterPluginPagesProvider =
    Provider<List<AfterPluginContribution>>((ref) {
  final registry = ref.watch(afterPluginRegistryProvider);
  final context = ref.watch(afterPluginContextProvider);
  final sub = registry.onChanged.listen((_) => ref.invalidateSelf());
  ref.onDispose(sub.cancel);
  return registry.contributions(
    AfterPluginContributionKind.page,
    context: context,
  );
});

final afterPluginAiSkillsProvider =
    Provider<List<AfterPluginContribution>>((ref) {
  final registry = ref.watch(afterPluginRegistryProvider);
  final context = ref.watch(afterPluginContextProvider);
  final sub = registry.onChanged.listen((_) => ref.invalidateSelf());
  ref.onDispose(sub.cancel);
  return registry.contributions(
    AfterPluginContributionKind.aiSkill,
    context: context,
  );
});
