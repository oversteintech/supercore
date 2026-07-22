import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../remote_config/after_remote_config.dart';

/// Canonical dashboard widget kinds for every AfterArtificial Super App.
///
/// Home screens are assembled from these kinds via JSON / Remote Config —
/// products do not hard-code layout in Dart.
enum DashboardWidgetKind {
  /// Numeric / labeled statistics strip or tiles.
  statistics,

  /// Alias of [statistics] kept for older specs (`metric`).
  metric,

  /// OS tasks module preview.
  tasks,

  /// OS calendar / upcoming schedule preview.
  calendar,

  /// Notification inbox preview.
  notifications,

  /// AI insight / Mate card.
  aiCard,

  /// Quick action buttons (deep links).
  quickActions,

  /// Recently viewed / edited entities.
  recentItems,

  /// User favorites / pinned items.
  favorites,

  /// Chart (spark / bar / donut) — data via [DashboardWidgetSpec.source].
  chart,

  /// Documents module preview.
  documents,

  /// Activity / audit timeline.
  activityTimeline,

  /// Business KPI tiles (enterprise).
  kpi,

  /// Upcoming events list.
  upcomingEvents,

  /// Weather card.
  weather,

  /// Location / map snippet.
  location,

  /// News headlines card.
  news,

  /// Domain cards — renderer resolved by kind; data from [source]/data].
  vehicleCard,
  healthCard,
  financeCard,
  propertyCard,
  flightCard,
  patientCard,
  shipCard,

  /// Generic OS-module list (`module` + module id) — legacy / flexible.
  module,

  /// Vertical-supplied custom card (still layout-owned by the engine).
  custom,
}

extension DashboardWidgetKindX on DashboardWidgetKind {
  /// Wire name used in JSON / Remote Config.
  String get wireName => name;

  static DashboardWidgetKind? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final normalized = raw.trim();
    for (final kind in DashboardWidgetKind.values) {
      if (kind.name == normalized) return kind;
    }
    // Friendly aliases from product specs / ops configs.
    return switch (normalized) {
      'stats' || 'Statistics' => DashboardWidgetKind.statistics,
      'ai' || 'ai_cards' || 'aiCards' => DashboardWidgetKind.aiCard,
      'quick_actions' => DashboardWidgetKind.quickActions,
      'recent' || 'recent_items' => DashboardWidgetKind.recentItems,
      'timeline' || 'activity' => DashboardWidgetKind.activityTimeline,
      'upcoming' || 'events' => DashboardWidgetKind.upcomingEvents,
      'vehicle' || 'vehicles' => DashboardWidgetKind.vehicleCard,
      'health' => DashboardWidgetKind.healthCard,
      'finance' => DashboardWidgetKind.financeCard,
      'property' || 'home' => DashboardWidgetKind.propertyCard,
      'flight' || 'flights' => DashboardWidgetKind.flightCard,
      'patient' || 'patients' => DashboardWidgetKind.patientCard,
      'ship' || 'ships' || 'maritime' => DashboardWidgetKind.shipCard,
      'kpis' || 'business_kpi' => DashboardWidgetKind.kpi,
      _ => null,
    };
  }
}

/// Declarative dashboard widget descriptor (data-only, JSON-serializable).
@immutable
class DashboardWidgetSpec {
  const DashboardWidgetSpec({
    required this.id,
    required this.kind,
    required this.titleKey,
    this.subtitleKey,
    this.module,
    this.source,
    this.limit,
    this.order = 100,
    this.span = 1,
    this.visible = true,
    this.requiredPermission,
    this.productLines,
    this.data = const <String, Object?>{},
  });

  final String id;
  final DashboardWidgetKind kind;
  final String titleKey;
  final String? subtitleKey;

  /// OS module id when [kind] is [DashboardWidgetKind.module] or a module-like
  /// kind (`tasks`, `calendar`, `notifications`, `documents`, …).
  final String? module;

  /// Dotted data path for metrics/charts/domain cards.
  final String? source;

  final int? limit;
  final int order;

  /// Grid span hint (1 = half/standard, 2 = full width).
  final int span;

  /// Soft hide without removing from config (Remote Config toggles).
  final bool visible;

  final String? requiredPermission;
  final Set<String>? productLines;
  final Map<String, Object?> data;

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind.wireName,
        'titleKey': titleKey,
        if (subtitleKey != null) 'subtitleKey': subtitleKey,
        if (module != null) 'module': module,
        if (source != null) 'source': source,
        if (limit != null) 'limit': limit,
        'order': order,
        'span': span,
        'visible': visible,
        if (requiredPermission != null)
          'requiredPermission': requiredPermission,
        if (productLines != null) 'productLines': productLines!.toList(),
        if (data.isNotEmpty) 'data': data,
      };

  factory DashboardWidgetSpec.fromJson(Map<String, Object?> json) {
    final kindRaw = '${json['kind'] ?? ''}';
    final kind = DashboardWidgetKindX.tryParse(kindRaw) ??
        DashboardWidgetKind.custom;
    final lines = json['productLines'];
    return DashboardWidgetSpec(
      id: '${json['id'] ?? ''}',
      kind: kind,
      titleKey: '${json['titleKey'] ?? json['title'] ?? ''}',
      subtitleKey: json['subtitleKey'] as String? ?? json['subtitle'] as String?,
      module: json['module'] as String?,
      source: json['source'] as String?,
      limit: (json['limit'] as num?)?.toInt(),
      order: (json['order'] as num?)?.toInt() ?? 100,
      span: (json['span'] as num?)?.toInt() ?? 1,
      visible: json['visible'] as bool? ?? true,
      requiredPermission: json['requiredPermission'] as String? ??
          json['permission'] as String?,
      productLines: lines is List
          ? lines.map((e) => '$e').toSet()
          : null,
      data: _asStringKeyedMap(json['data']),
    );
  }

  DashboardWidgetSpec copyWith({
    String? id,
    DashboardWidgetKind? kind,
    String? titleKey,
    String? subtitleKey,
    String? module,
    String? source,
    int? limit,
    int? order,
    int? span,
    bool? visible,
    String? requiredPermission,
    Set<String>? productLines,
    Map<String, Object?>? data,
  }) {
    return DashboardWidgetSpec(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      titleKey: titleKey ?? this.titleKey,
      subtitleKey: subtitleKey ?? this.subtitleKey,
      module: module ?? this.module,
      source: source ?? this.source,
      limit: limit ?? this.limit,
      order: order ?? this.order,
      span: span ?? this.span,
      visible: visible ?? this.visible,
      requiredPermission: requiredPermission ?? this.requiredPermission,
      productLines: productLines ?? this.productLines,
      data: data ?? this.data,
    );
  }
}

Map<String, Object?> _asStringKeyedMap(Object? raw) {
  if (raw is Map<String, Object?>) return Map<String, Object?>.from(raw);
  if (raw is Map) {
    return raw.map((k, v) => MapEntry('$k', v as Object?));
  }
  return const {};
}

/// Full dashboard layout document (JSON / Remote Config payload).
@immutable
class DashboardLayout {
  const DashboardLayout({
    required this.version,
    required this.widgets,
    this.id = 'home',
    this.updatedAt,
  });

  final int version;
  final String id;
  final List<DashboardWidgetSpec> widgets;
  final DateTime? updatedAt;

  Map<String, Object?> toJson() => {
        'version': version,
        'id': id,
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
        'widgets': [for (final w in widgets) w.toJson()],
      };

  factory DashboardLayout.fromJson(Map<String, Object?> json) {
    final rawWidgets = json['widgets'];
    final widgets = <DashboardWidgetSpec>[];
    if (rawWidgets is List) {
      for (final item in rawWidgets) {
        if (item is Map) {
          widgets.add(
            DashboardWidgetSpec.fromJson(
              item.map((k, v) => MapEntry('$k', v as Object?)),
            ),
          );
        }
      }
    }
    return DashboardLayout(
      version: (json['version'] as num?)?.toInt() ?? 1,
      id: '${json['id'] ?? 'home'}',
      updatedAt: DateTime.tryParse('${json['updatedAt'] ?? ''}'),
      widgets: widgets,
    );
  }

  static DashboardLayout? tryParse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return DashboardLayout.fromJson(
          decoded.map((k, v) => MapEntry(k, v as Object?)),
        );
      }
      if (decoded is List) {
        return DashboardLayout(
          version: 1,
          widgets: [
            for (final item in decoded)
              if (item is Map)
                DashboardWidgetSpec.fromJson(
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

/// Context for filtering widgets (product line + RBAC).
@immutable
class DashboardContext {
  const DashboardContext({
    this.productLine,
    this.permissions = const <String>{},
  });

  final String? productLine;
  final Set<String> permissions;

  bool matches(DashboardWidgetSpec spec) {
    if (!spec.visible) return false;
    if (spec.productLines != null &&
        productLine != null &&
        !spec.productLines!.contains(productLine)) {
      return false;
    }
    final permission = spec.requiredPermission;
    if (permission != null &&
        permission.isNotEmpty &&
        !permissions.contains(permission)) {
      return false;
    }
    return true;
  }
}

/// Remote Config / asset key used by default for dashboard JSON.
const afterDashboardRemoteConfigKey = 'after.dashboard.layout';

/// Dashboard engine — register, load from JSON/RC, filter, order.
abstract class DashboardEngine {
  void register(DashboardWidgetSpec spec);

  void registerAll(Iterable<DashboardWidgetSpec> specs);

  void unregister(String id);

  /// Replace the entire layout (used by JSON / Remote Config).
  void applyLayout(DashboardLayout layout);

  /// Parse JSON string and [applyLayout]. Returns false if parse fails.
  bool applyJson(String raw);

  /// Read [afterDashboardRemoteConfigKey] (or [key]) from remote config.
  bool applyRemoteConfig(
    AfterRemoteConfig config, {
    String key = afterDashboardRemoteConfigKey,
  });

  List<DashboardWidgetSpec> get all;

  List<DashboardWidgetSpec> visibleWidgets(DashboardContext context);

  Stream<List<DashboardWidgetSpec>> watchAll();

  DashboardLayout? get currentLayout;
}

/// In-memory engine — default for every Super App.
class InMemoryDashboardEngine implements DashboardEngine {
  InMemoryDashboardEngine({Iterable<DashboardWidgetSpec>? seed}) {
    if (seed != null) registerAll(seed);
  }

  final Map<String, DashboardWidgetSpec> _widgets =
      <String, DashboardWidgetSpec>{};
  final StreamController<List<DashboardWidgetSpec>> _controller =
      StreamController<List<DashboardWidgetSpec>>.broadcast();
  DashboardLayout? _layout;

  void _emit() {
    if (_controller.isClosed) return;
    _controller.add(all);
  }

  @override
  DashboardLayout? get currentLayout => _layout;

  @override
  void register(DashboardWidgetSpec spec) {
    _widgets[spec.id] = spec;
    _emit();
  }

  @override
  void registerAll(Iterable<DashboardWidgetSpec> specs) {
    for (final spec in specs) {
      _widgets[spec.id] = spec;
    }
    _emit();
  }

  @override
  void unregister(String id) {
    if (_widgets.remove(id) != null) _emit();
  }

  @override
  void applyLayout(DashboardLayout layout) {
    _layout = layout;
    _widgets
      ..clear()
      ..addEntries(layout.widgets.map((w) => MapEntry(w.id, w)));
    _emit();
  }

  @override
  bool applyJson(String raw) {
    final layout = DashboardLayout.tryParse(raw);
    if (layout == null) return false;
    applyLayout(layout);
    return true;
  }

  @override
  bool applyRemoteConfig(
    AfterRemoteConfig config, {
    String key = afterDashboardRemoteConfigKey,
  }) {
    final raw = config.getString(key);
    if (raw.isEmpty) return false;
    return applyJson(raw);
  }

  @override
  List<DashboardWidgetSpec> get all =>
      List<DashboardWidgetSpec>.unmodifiable(_widgets.values);

  @override
  List<DashboardWidgetSpec> visibleWidgets(DashboardContext context) {
    final matching = _widgets.values.where(context.matches).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return List<DashboardWidgetSpec>.unmodifiable(matching);
  }

  @override
  Stream<List<DashboardWidgetSpec>> watchAll() => _controller.stream;

  Future<void> dispose() async {
    if (!_controller.isClosed) await _controller.close();
  }
}

/// App-wide dashboard engine. Seed from assets/JSON or Remote Config at boot.
final afterDashboardEngineProvider = Provider<DashboardEngine>((ref) {
  return InMemoryDashboardEngine();
});

/// Shell builds this from manifest + session + RBAC.
final afterDashboardContextProvider = Provider<DashboardContext>((ref) {
  return const DashboardContext();
});

/// Visible widgets for the current context — rebuilds on engine mutations.
final afterDashboardVisibleWidgetsProvider =
    Provider<List<DashboardWidgetSpec>>((ref) {
  final engine = ref.watch(afterDashboardEngineProvider);
  final context = ref.watch(afterDashboardContextProvider);
  // Subscribe so JSON / Remote Config hydrate triggers Home rebuilds.
  final sub = engine.watchAll().listen((_) {
    ref.invalidateSelf();
  });
  ref.onDispose(sub.cancel);
  return engine.visibleWidgets(context);
});

/// Seed from bundled asset JSON, then overlay Remote Config when present.
///
/// Remote Config wins so ops can reshape Home without shipping an app update.
/// Returns `true` if at least one source applied successfully.
bool hydrateDashboardEngine(
  DashboardEngine engine, {
  String? defaultJson,
  AfterRemoteConfig? remoteConfig,
  String remoteKey = afterDashboardRemoteConfigKey,
}) {
  var applied = false;
  if (defaultJson != null && defaultJson.trim().isNotEmpty) {
    if (engine.applyJson(defaultJson)) applied = true;
  }
  if (remoteConfig != null) {
    if (engine.applyRemoteConfig(remoteConfig, key: remoteKey)) {
      applied = true;
    }
  }
  return applied;
}
