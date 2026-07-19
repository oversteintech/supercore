import 'package:meta/meta.dart';

/// Static description of a state machine that governs a business process,
/// e.g. patient discharge, purchase approval, hospital admission.
@immutable
class WorkflowDefinition {
  const WorkflowDefinition({
    required this.id,
    required this.name,
    required this.states,
    required this.transitions,
    required this.initialState,
  });

  final String id;
  final String name;
  final Set<String> states;
  final List<WorkflowTransition> transitions;
  final String initialState;

  bool hasState(String state) => states.contains(state);
}

@immutable
class WorkflowTransition {
  const WorkflowTransition({
    required this.from,
    required this.to,
    required this.event,
    this.requiredPermission,
  });

  final String from;
  final String to;
  final String event;
  final String? requiredPermission;
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
  });

  final String id;
  final String definitionId;
  final String subjectId;
  final String currentState;
  final List<WorkflowEvent> history;
  final DateTime createdAt;
  final DateTime updatedAt;

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
  });

  final String event;
  final String from;
  final String to;
  final DateTime at;
  final String? actorId;
}

class WorkflowException implements Exception {
  WorkflowException(this.message);
  final String message;
  @override
  String toString() => 'WorkflowException: $message';
}

/// Pure state-machine transition; delegates persistence to [WorkflowRepository].
class WorkflowEngine {
  WorkflowInstance transition({
    required WorkflowDefinition definition,
    required WorkflowInstance instance,
    required String event,
    String? actorId,
    DateTime? at,
  }) {
    if (definition.id != instance.definitionId) {
      throw WorkflowException(
        'Definition ${definition.id} does not match instance ${instance.id}',
      );
    }
    final match = definition.transitions.firstWhere(
      (t) => t.from == instance.currentState && t.event == event,
      orElse: () => throw WorkflowException(
        'No transition for event "$event" from state '
        '"${instance.currentState}"',
      ),
    );
    final now = at ?? DateTime.now().toUtc();
    return instance.withTransition(
      newState: match.to,
      event: WorkflowEvent(
        event: event,
        from: match.from,
        to: match.to,
        at: now,
        actorId: actorId,
      ),
      at: now,
    );
  }
}

/// Port for workflow definitions and running instances.
abstract class WorkflowRepository {
  Future<List<WorkflowDefinition>> listDefinitions();
  Future<WorkflowDefinition?> getDefinition(String id);
  Future<WorkflowDefinition> upsertDefinition(WorkflowDefinition definition);

  Future<List<WorkflowInstance>> listInstances({String? definitionId});
  Future<WorkflowInstance?> getInstance(String id);
  Future<WorkflowInstance> startInstance({
    required WorkflowDefinition definition,
    required String subjectId,
  });
  Future<WorkflowInstance> saveInstance(WorkflowInstance instance);
}

class InMemoryWorkflowRepository implements WorkflowRepository {
  InMemoryWorkflowRepository({List<WorkflowDefinition>? seed})
      : _definitions = {
          for (final d in seed ?? const <WorkflowDefinition>[]) d.id: d,
        };

  final Map<String, WorkflowDefinition> _definitions;
  final Map<String, WorkflowInstance> _instances = {};
  var _nextId = 1;

  @override
  Future<List<WorkflowDefinition>> listDefinitions() async =>
      List.unmodifiable(_definitions.values);

  @override
  Future<WorkflowDefinition?> getDefinition(String id) async =>
      _definitions[id];

  @override
  Future<WorkflowDefinition> upsertDefinition(
    WorkflowDefinition definition,
  ) async {
    _definitions[definition.id] = definition;
    return definition;
  }

  @override
  Future<List<WorkflowInstance>> listInstances({String? definitionId}) async {
    return _instances.values
        .where((i) => definitionId == null || i.definitionId == definitionId)
        .toList(growable: false);
  }

  @override
  Future<WorkflowInstance?> getInstance(String id) async => _instances[id];

  @override
  Future<WorkflowInstance> startInstance({
    required WorkflowDefinition definition,
    required String subjectId,
  }) async {
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
    );
    _instances[id] = instance;
    return instance;
  }

  @override
  Future<WorkflowInstance> saveInstance(WorkflowInstance instance) async {
    _instances[instance.id] = instance;
    return instance;
  }
}
