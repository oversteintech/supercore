import 'dart:convert';

import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../scope/enterprise_scope.dart';

/// Remote Config / asset key for the workflow definition catalog JSON.
const afterWorkflowCatalogRemoteConfigKey = 'after.workflow.catalog';

/// Optional rich state metadata (labels, terminal flags).
@immutable
class WorkflowStateDef {
  const WorkflowStateDef({
    required this.id,
    this.labelKey,
    this.terminal = false,
    this.metadata = const <String, Object?>{},
  });

  final String id;
  final String? labelKey;
  final bool terminal;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() => {
        'id': id,
        if (labelKey != null) 'labelKey': labelKey,
        if (terminal) 'terminal': terminal,
        if (metadata.isNotEmpty) 'metadata': metadata,
      };

  factory WorkflowStateDef.fromJson(Map<String, Object?> json) {
    return WorkflowStateDef(
      id: '${json['id'] ?? ''}',
      labelKey: json['labelKey'] as String? ?? json['label'] as String?,
      terminal: json['terminal'] as bool? ?? false,
      metadata: _asStringKeyedMap(json['metadata']),
    );
  }
}

/// Edge in a workflow state machine.
@immutable
class WorkflowTransition {
  const WorkflowTransition({
    required this.from,
    required this.to,
    required this.event,
    this.labelKey,
    this.requiredPermission,
    this.requiredRole,
    this.createsTask = false,
    this.taskTitleKey,
    this.metadata = const <String, Object?>{},
  });

  final String from;
  final String to;
  final String event;
  final String? labelKey;
  final String? requiredPermission;
  final String? requiredRole;
  final bool createsTask;
  final String? taskTitleKey;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() => {
        'from': from,
        'to': to,
        'event': event,
        if (labelKey != null) 'labelKey': labelKey,
        if (requiredPermission != null)
          'requiredPermission': requiredPermission,
        if (requiredRole != null) 'requiredRole': requiredRole,
        if (createsTask) 'createsTask': createsTask,
        if (taskTitleKey != null) 'taskTitleKey': taskTitleKey,
        if (metadata.isNotEmpty) 'metadata': metadata,
      };

  factory WorkflowTransition.fromJson(Map<String, Object?> json) {
    return WorkflowTransition(
      from: '${json['from'] ?? ''}',
      to: '${json['to'] ?? ''}',
      event: '${json['event'] ?? json['action'] ?? ''}',
      labelKey: json['labelKey'] as String? ?? json['label'] as String?,
      requiredPermission: json['requiredPermission'] as String? ??
          json['permission'] as String?,
      requiredRole: json['requiredRole'] as String? ?? json['role'] as String?,
      createsTask: json['createsTask'] as bool? ?? false,
      taskTitleKey: json['taskTitleKey'] as String?,
      metadata: _asStringKeyedMap(json['metadata']),
    );
  }
}

/// Static description of a state machine that governs a business process.
///
/// Definitions are loaded from JSON / Remote Config — products do **not**
/// ship new Dart classes for each hospital admission, flight prep, etc.
@immutable
class WorkflowDefinition {
  const WorkflowDefinition({
    required this.id,
    required this.name,
    required this.states,
    required this.transitions,
    required this.initialState,
    this.nameKey,
    this.descriptionKey,
    this.domain,
    this.subjectType,
    this.version = 1,
    this.enabled = true,
    this.organizationIds,
    this.stateDefs = const <WorkflowStateDef>[],
    this.terminalStates = const <String>{},
    this.metadata = const <String, Object?>{},
  });

  final String id;

  /// Display name (or fallback when [nameKey] is unset).
  final String name;
  final String? nameKey;
  final String? descriptionKey;

  /// Vertical domain tag: `hospital`, `airport`, `maritime`, `factory`, …
  final String? domain;

  /// Subject entity type: `patient`, `flight`, `ship`, `machine`, …
  final String? subjectType;

  final int version;
  final bool enabled;

  /// When non-null, only these tenants may use the definition.
  final Set<String>? organizationIds;

  final Set<String> states;
  final List<WorkflowStateDef> stateDefs;
  final List<WorkflowTransition> transitions;
  final String initialState;
  final Set<String> terminalStates;
  final Map<String, Object?> metadata;

  bool hasState(String state) => states.contains(state);

  bool isTerminal(String state) {
    if (terminalStates.contains(state)) return true;
    for (final def in stateDefs) {
      if (def.id == state && def.terminal) return true;
    }
    return false;
  }

  List<WorkflowTransition> transitionsFrom(String state) =>
      transitions.where((t) => t.from == state).toList(growable: false);

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        if (nameKey != null) 'nameKey': nameKey,
        if (descriptionKey != null) 'descriptionKey': descriptionKey,
        if (domain != null) 'domain': domain,
        if (subjectType != null) 'subjectType': subjectType,
        'version': version,
        'enabled': enabled,
        if (organizationIds != null)
          'organizationIds': organizationIds!.toList(),
        'states': states.toList(),
        if (stateDefs.isNotEmpty)
          'stateDefs': [for (final s in stateDefs) s.toJson()],
        'initialState': initialState,
        if (terminalStates.isNotEmpty)
          'terminalStates': terminalStates.toList(),
        'transitions': [for (final t in transitions) t.toJson()],
        if (metadata.isNotEmpty) 'metadata': metadata,
      };

  factory WorkflowDefinition.fromJson(Map<String, Object?> json) {
    final stateDefsRaw = json['stateDefs'] ?? json['state_defs'];
    final stateDefs = <WorkflowStateDef>[];
    if (stateDefsRaw is List) {
      for (final item in stateDefsRaw) {
        if (item is Map) {
          stateDefs.add(
            WorkflowStateDef.fromJson(
              item.map((k, v) => MapEntry('$k', v as Object?)),
            ),
          );
        }
      }
    }

    final statesRaw = json['states'];
    final states = <String>{};
    if (statesRaw is List) {
      for (final s in statesRaw) {
        if (s is String) {
          states.add(s);
        } else if (s is Map) {
          final def = WorkflowStateDef.fromJson(
            s.map((k, v) => MapEntry('$k', v as Object?)),
          );
          states.add(def.id);
          if (!stateDefs.any((d) => d.id == def.id)) {
            stateDefs.add(def);
          }
        }
      }
    }
    for (final def in stateDefs) {
      states.add(def.id);
    }

    final transitionsRaw = json['transitions'];
    final transitions = <WorkflowTransition>[];
    if (transitionsRaw is List) {
      for (final item in transitionsRaw) {
        if (item is Map) {
          transitions.add(
            WorkflowTransition.fromJson(
              item.map((k, v) => MapEntry('$k', v as Object?)),
            ),
          );
        }
      }
    }

    final terminalRaw = json['terminalStates'] ?? json['terminal'];
    final terminalStates = <String>{};
    if (terminalRaw is List) {
      terminalStates.addAll(terminalRaw.map((e) => '$e'));
    }
    for (final def in stateDefs) {
      if (def.terminal) terminalStates.add(def.id);
    }

    final orgRaw = json['organizationIds'];
    Set<String>? organizationIds;
    if (orgRaw is List) {
      organizationIds = orgRaw.map((e) => '$e').toSet();
    }

    final name = '${json['name'] ?? json['nameKey'] ?? json['id'] ?? ''}';

    return WorkflowDefinition(
      id: '${json['id'] ?? ''}',
      name: name,
      nameKey: json['nameKey'] as String?,
      descriptionKey: json['descriptionKey'] as String?,
      domain: json['domain'] as String? ?? json['vertical'] as String?,
      subjectType: json['subjectType'] as String? ?? json['subject'] as String?,
      version: (json['version'] as num?)?.toInt() ?? 1,
      enabled: json['enabled'] as bool? ?? true,
      organizationIds: organizationIds,
      states: states,
      stateDefs: List.unmodifiable(stateDefs),
      transitions: List.unmodifiable(transitions),
      initialState: '${json['initialState'] ?? json['initial'] ?? ''}',
      terminalStates: terminalStates,
      metadata: _asStringKeyedMap(json['metadata']),
    );
  }

  WorkflowDefinition copyWith({
    String? id,
    String? name,
    String? nameKey,
    String? descriptionKey,
    String? domain,
    String? subjectType,
    int? version,
    bool? enabled,
    Set<String>? organizationIds,
    Set<String>? states,
    List<WorkflowStateDef>? stateDefs,
    List<WorkflowTransition>? transitions,
    String? initialState,
    Set<String>? terminalStates,
    Map<String, Object?>? metadata,
  }) {
    return WorkflowDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      nameKey: nameKey ?? this.nameKey,
      descriptionKey: descriptionKey ?? this.descriptionKey,
      domain: domain ?? this.domain,
      subjectType: subjectType ?? this.subjectType,
      version: version ?? this.version,
      enabled: enabled ?? this.enabled,
      organizationIds: organizationIds ?? this.organizationIds,
      states: states ?? this.states,
      stateDefs: stateDefs ?? this.stateDefs,
      transitions: transitions ?? this.transitions,
      initialState: initialState ?? this.initialState,
      terminalStates: terminalStates ?? this.terminalStates,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Full catalog document (JSON / Remote Config payload).
@immutable
class WorkflowCatalog {
  const WorkflowCatalog({
    required this.version,
    required this.workflows,
    this.id = 'default',
    this.domain,
    this.updatedAt,
  });

  final int version;
  final String id;

  /// Optional catalog-level domain filter hint.
  final String? domain;
  final List<WorkflowDefinition> workflows;
  final DateTime? updatedAt;

  Map<String, Object?> toJson() => {
        'version': version,
        'id': id,
        if (domain != null) 'domain': domain,
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
        'workflows': [for (final w in workflows) w.toJson()],
      };

  factory WorkflowCatalog.fromJson(Map<String, Object?> json) {
    final raw = json['workflows'] ?? json['definitions'];
    final workflows = <WorkflowDefinition>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          workflows.add(
            WorkflowDefinition.fromJson(
              item.map((k, v) => MapEntry('$k', v as Object?)),
            ),
          );
        }
      }
    }
    return WorkflowCatalog(
      version: (json['version'] as num?)?.toInt() ?? 1,
      id: '${json['id'] ?? 'default'}',
      domain: json['domain'] as String?,
      updatedAt: DateTime.tryParse('${json['updatedAt'] ?? ''}'),
      workflows: List.unmodifiable(workflows),
    );
  }

  static WorkflowCatalog? tryParse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return WorkflowCatalog.fromJson(
          decoded.map((k, v) => MapEntry(k, v as Object?)),
        );
      }
      if (decoded is List) {
        return WorkflowCatalog(
          version: 1,
          workflows: [
            for (final item in decoded)
              if (item is Map)
                WorkflowDefinition.fromJson(
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

/// Actor context for permission / role gated transitions.
@immutable
class WorkflowActorContext {
  const WorkflowActorContext({
    this.actorId,
    this.permissions = const <String>{},
    this.roles = const <String>{},
    this.organizationId,
  });

  final String? actorId;
  final Set<String> permissions;
  final Set<String> roles;
  final String? organizationId;

  bool allows(WorkflowTransition transition) {
    final permission = transition.requiredPermission;
    if (permission != null &&
        permission.isNotEmpty &&
        !permissions.contains(permission)) {
      return false;
    }
    final role = transition.requiredRole;
    if (role != null && role.isNotEmpty && !roles.contains(role)) {
      return false;
    }
    return true;
  }

  bool canUseDefinition(WorkflowDefinition definition) {
    if (!definition.enabled) return false;
    final orgs = definition.organizationIds;
    if (orgs != null &&
        organizationId != null &&
        !orgs.contains(organizationId)) {
      return false;
    }
    return true;
  }
}

/// A live instance of a [WorkflowDefinition] attached to a domain object.
@immutable
class WorkflowInstance {
  const WorkflowInstance({
    required this.id,
    required this.definitionId,
    required this.subjectId,
    required this.currentState,
    required this.history,
    required this.createdAt,
    required this.updatedAt,
    this.organizationId,
    this.metadata = const <String, Object?>{},
  });

  final String id;
  final String definitionId;
  final String subjectId;
  final String currentState;
  final List<WorkflowEvent> history;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? organizationId;
  final Map<String, Object?> metadata;

  WorkflowInstance withTransition({
    required String newState,
    required WorkflowEvent event,
    required DateTime at,
  }) {
    return WorkflowInstance(
      id: id,
      definitionId: definitionId,
      subjectId: subjectId,
      currentState: newState,
      history: List.unmodifiable([...history, event]),
      createdAt: createdAt,
      updatedAt: at,
      organizationId: organizationId,
      metadata: metadata,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'definitionId': definitionId,
        'subjectId': subjectId,
        'currentState': currentState,
        'history': [for (final e in history) e.toJson()],
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        if (organizationId != null) 'organizationId': organizationId,
        if (metadata.isNotEmpty) 'metadata': metadata,
      };

  factory WorkflowInstance.fromJson(Map<String, Object?> json) {
    final historyRaw = json['history'];
    final history = <WorkflowEvent>[];
    if (historyRaw is List) {
      for (final item in historyRaw) {
        if (item is Map) {
          history.add(
            WorkflowEvent.fromJson(
              item.map((k, v) => MapEntry('$k', v as Object?)),
            ),
          );
        }
      }
    }
    return WorkflowInstance(
      id: '${json['id'] ?? ''}',
      definitionId: '${json['definitionId'] ?? ''}',
      subjectId: '${json['subjectId'] ?? ''}',
      currentState: '${json['currentState'] ?? ''}',
      history: List.unmodifiable(history),
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt: DateTime.tryParse('${json['updatedAt'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      organizationId: json['organizationId'] as String?,
      metadata: _asStringKeyedMap(json['metadata']),
    );
  }
}

@immutable
class WorkflowEvent {
  const WorkflowEvent({
    required this.event,
    required this.from,
    required this.to,
    required this.at,
    this.actorId,
    this.note,
    this.metadata = const <String, Object?>{},
  });

  final String event;
  final String from;
  final String to;
  final DateTime at;
  final String? actorId;
  final String? note;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() => {
        'event': event,
        'from': from,
        'to': to,
        'at': at.toIso8601String(),
        if (actorId != null) 'actorId': actorId,
        if (note != null) 'note': note,
        if (metadata.isNotEmpty) 'metadata': metadata,
      };

  factory WorkflowEvent.fromJson(Map<String, Object?> json) {
    return WorkflowEvent(
      event: '${json['event'] ?? ''}',
      from: '${json['from'] ?? ''}',
      to: '${json['to'] ?? ''}',
      at: DateTime.tryParse('${json['at'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      actorId: json['actorId'] as String?,
      note: json['note'] as String?,
      metadata: _asStringKeyedMap(json['metadata']),
    );
  }
}

class WorkflowException implements Exception {
  WorkflowException(this.message);
  final String message;
  @override
  String toString() => 'WorkflowException: $message';
}

/// Pure state-machine engine — definitions come from the catalog / repository.
class WorkflowEngine {
  /// Transitions allowed from the instance's current state for [actor].
  List<WorkflowTransition> availableTransitions({
    required WorkflowDefinition definition,
    required WorkflowInstance instance,
    WorkflowActorContext actor = const WorkflowActorContext(),
  }) {
    if (definition.id != instance.definitionId) {
      throw WorkflowException(
        'Definition ${definition.id} does not match instance ${instance.id}',
      );
    }
    if (!actor.canUseDefinition(definition)) return const [];
    if (definition.isTerminal(instance.currentState)) return const [];
    return definition
        .transitionsFrom(instance.currentState)
        .where(actor.allows)
        .toList(growable: false);
  }

  bool canTransition({
    required WorkflowDefinition definition,
    required WorkflowInstance instance,
    required String event,
    WorkflowActorContext actor = const WorkflowActorContext(),
  }) {
    return availableTransitions(
      definition: definition,
      instance: instance,
      actor: actor,
    ).any((t) => t.event == event);
  }

  WorkflowInstance transition({
    required WorkflowDefinition definition,
    required WorkflowInstance instance,
    required String event,
    String? actorId,
    DateTime? at,
    WorkflowActorContext? actor,
    String? note,
    Map<String, Object?> metadata = const {},
  }) {
    if (definition.id != instance.definitionId) {
      throw WorkflowException(
        'Definition ${definition.id} does not match instance ${instance.id}',
      );
    }
    final ctx = actor ??
        WorkflowActorContext(actorId: actorId);
    if (!ctx.canUseDefinition(definition)) {
      throw WorkflowException(
        'Definition "${definition.id}" is disabled or not available '
        'for this organization',
      );
    }
    if (definition.isTerminal(instance.currentState)) {
      throw WorkflowException(
        'Instance ${instance.id} is in terminal state '
        '"${instance.currentState}"',
      );
    }

    final candidates = definition.transitions.where(
      (t) => t.from == instance.currentState && t.event == event,
    );
    if (candidates.isEmpty) {
      throw WorkflowException(
        'No transition for event "$event" from state '
        '"${instance.currentState}"',
      );
    }
    final match = candidates.first;
    if (!ctx.allows(match)) {
      throw WorkflowException(
        'Actor lacks permission/role for event "$event"',
      );
    }

    final now = at ?? DateTime.now().toUtc();
    return instance.withTransition(
      newState: match.to,
      event: WorkflowEvent(
        event: event,
        from: match.from,
        to: match.to,
        at: now,
        actorId: actorId ?? ctx.actorId,
        note: note,
        metadata: metadata,
      ),
      at: now,
    );
  }
}

/// In-memory registry of unlimited workflow definitions (JSON/RC owned).
abstract class WorkflowDefinitionRegistry {
  void register(WorkflowDefinition definition);

  void registerAll(Iterable<WorkflowDefinition> definitions);

  void unregister(String id);

  void applyCatalog(WorkflowCatalog catalog);

  bool applyJson(String raw);

  bool applyRemoteConfig(
    AfterRemoteConfig config, {
    String key = afterWorkflowCatalogRemoteConfigKey,
  });

  WorkflowDefinition? get(String id);

  List<WorkflowDefinition> get all;

  List<WorkflowDefinition> byDomain(String domain);

  WorkflowCatalog? get currentCatalog;
}

class InMemoryWorkflowDefinitionRegistry implements WorkflowDefinitionRegistry {
  InMemoryWorkflowDefinitionRegistry({
    Iterable<WorkflowDefinition>? seed,
  }) {
    if (seed != null) registerAll(seed);
  }

  final Map<String, WorkflowDefinition> _definitions =
      <String, WorkflowDefinition>{};
  WorkflowCatalog? _catalog;

  @override
  WorkflowCatalog? get currentCatalog => _catalog;

  @override
  void register(WorkflowDefinition definition) {
    _definitions[definition.id] = definition;
  }

  @override
  void registerAll(Iterable<WorkflowDefinition> definitions) {
    for (final d in definitions) {
      _definitions[d.id] = d;
    }
  }

  @override
  void unregister(String id) {
    _definitions.remove(id);
  }

  @override
  void applyCatalog(WorkflowCatalog catalog) {
    _catalog = catalog;
    _definitions
      ..clear()
      ..addEntries(catalog.workflows.map((w) => MapEntry(w.id, w)));
  }

  @override
  bool applyJson(String raw) {
    final catalog = WorkflowCatalog.tryParse(raw);
    if (catalog == null) return false;
    applyCatalog(catalog);
    return true;
  }

  @override
  bool applyRemoteConfig(
    AfterRemoteConfig config, {
    String key = afterWorkflowCatalogRemoteConfigKey,
  }) {
    final raw = config.getString(key);
    if (raw.isEmpty) return false;
    return applyJson(raw);
  }

  @override
  WorkflowDefinition? get(String id) => _definitions[id];

  @override
  List<WorkflowDefinition> get all =>
      List<WorkflowDefinition>.unmodifiable(_definitions.values);

  @override
  List<WorkflowDefinition> byDomain(String domain) {
    final normalized = domain.trim().toLowerCase();
    return all
        .where(
          (w) =>
              w.enabled &&
              (w.domain?.toLowerCase() == normalized),
        )
        .toList(growable: false);
  }
}

/// Seed from bundled asset JSON, then overlay Remote Config when present.
///
/// Remote Config wins so ops can add/reshape workflows without an app update.
bool hydrateWorkflowCatalog(
  WorkflowDefinitionRegistry registry, {
  String? defaultJson,
  AfterRemoteConfig? remoteConfig,
  String remoteKey = afterWorkflowCatalogRemoteConfigKey,
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

/// Port for workflow definitions and running instances.
abstract class WorkflowRepository {
  /// Fail-closed: [organizationId] is required (ADR-002).
  Future<List<WorkflowDefinition>> listDefinitions({
    required String organizationId,
    String? domain,
  });

  Future<WorkflowDefinition?> getDefinition(String id);

  Future<WorkflowDefinition> upsertDefinition(WorkflowDefinition definition);

  /// Fail-closed: [organizationId] is required (ADR-002).
  Future<List<WorkflowInstance>> listInstances({
    required String organizationId,
    String? definitionId,
    String? subjectId,
  });

  Future<WorkflowInstance?> getInstance(String id);

  Future<WorkflowInstance> startInstance({
    required WorkflowDefinition definition,
    required String subjectId,
    required String organizationId,
    Map<String, Object?> metadata = const {},
  });

  Future<WorkflowInstance> saveInstance(WorkflowInstance instance);

  /// Convenience: load definition, apply transition, persist.
  Future<WorkflowInstance> applyTransition({
    required String instanceId,
    required String event,
    WorkflowActorContext actor = const WorkflowActorContext(),
    String? note,
    Map<String, Object?> metadata = const {},
    DateTime? at,
  });
}

class InMemoryWorkflowRepository implements WorkflowRepository {
  InMemoryWorkflowRepository({
    List<WorkflowDefinition>? seed,
    WorkflowDefinitionRegistry? registry,
    WorkflowEngine? engine,
  })  : _registry = registry ??
            InMemoryWorkflowDefinitionRegistry(seed: seed),
        _engine = engine ?? WorkflowEngine() {
    if (seed != null && registry == null) {
      _registry.registerAll(seed);
    }
  }

  final WorkflowDefinitionRegistry _registry;
  final WorkflowEngine _engine;
  final Map<String, WorkflowInstance> _instances = {};
  var _nextId = 1;

  WorkflowDefinitionRegistry get registry => _registry;

  WorkflowEngine get engine => _engine;

  @override
  Future<List<WorkflowDefinition>> listDefinitions({
    required String organizationId,
    String? domain,
  }) async {
    final org = EnterpriseScope.requireOrganizationId(organizationId);
    final Iterable<WorkflowDefinition> defs = domain == null || domain.isEmpty
        ? _registry.all.where((w) => w.enabled)
        : _registry.byDomain(domain);
    return defs.where((w) {
      final orgs = w.organizationIds;
      return orgs == null || orgs.contains(org);
    }).toList(growable: false);
  }

  @override
  Future<WorkflowDefinition?> getDefinition(String id) async =>
      _registry.get(id);

  @override
  Future<WorkflowDefinition> upsertDefinition(
    WorkflowDefinition definition,
  ) async {
    _registry.register(definition);
    return definition;
  }

  @override
  Future<List<WorkflowInstance>> listInstances({
    required String organizationId,
    String? definitionId,
    String? subjectId,
  }) async {
    final org = EnterpriseScope.requireOrganizationId(organizationId);
    return _instances.values
        .where(
          (i) =>
              i.organizationId == org &&
              (definitionId == null || i.definitionId == definitionId) &&
              (subjectId == null || i.subjectId == subjectId),
        )
        .toList(growable: false);
  }

  @override
  Future<WorkflowInstance?> getInstance(String id) async => _instances[id];

  @override
  Future<WorkflowInstance> startInstance({
    required WorkflowDefinition definition,
    required String subjectId,
    required String organizationId,
    Map<String, Object?> metadata = const {},
  }) async {
    final org = EnterpriseScope.requireOrganizationId(organizationId);
    if (!definition.enabled) {
      throw WorkflowException('Definition "${definition.id}" is disabled');
    }
    if (!definition.hasState(definition.initialState)) {
      throw WorkflowException(
        'Initial state "${definition.initialState}" missing from definition '
        '"${definition.id}"',
      );
    }
    final now = DateTime.now().toUtc();
    final id = 'wfi_${_nextId++}';
    final instance = WorkflowInstance(
      id: id,
      definitionId: definition.id,
      subjectId: subjectId,
      currentState: definition.initialState,
      history: const [],
      createdAt: now,
      updatedAt: now,
      organizationId: org,
      metadata: metadata,
    );
    _instances[id] = instance;
    return instance;
  }

  @override
  Future<WorkflowInstance> saveInstance(WorkflowInstance instance) async {
    _instances[instance.id] = instance;
    return instance;
  }

  @override
  Future<WorkflowInstance> applyTransition({
    required String instanceId,
    required String event,
    WorkflowActorContext actor = const WorkflowActorContext(),
    String? note,
    Map<String, Object?> metadata = const {},
    DateTime? at,
  }) async {
    final instance = _instances[instanceId];
    if (instance == null) {
      throw WorkflowException('Instance "$instanceId" not found');
    }
    final definition = _registry.get(instance.definitionId);
    if (definition == null) {
      throw WorkflowException(
        'Definition "${instance.definitionId}" not found',
      );
    }
    final next = _engine.transition(
      definition: definition,
      instance: instance,
      event: event,
      actor: actor,
      actorId: actor.actorId,
      note: note,
      metadata: metadata,
      at: at,
    );
    _instances[next.id] = next;
    return next;
  }
}

Map<String, Object?> _asStringKeyedMap(Object? raw) {
  if (raw is Map<String, Object?>) return Map<String, Object?>.from(raw);
  if (raw is Map) {
    return raw.map((k, v) => MapEntry('$k', v as Object?));
  }
  return const {};
}

/// App-wide definition registry. Seed from assets/JSON or Remote Config.
final workflowDefinitionRegistryProvider =
    Provider<WorkflowDefinitionRegistry>((ref) {
  return InMemoryWorkflowDefinitionRegistry();
});
