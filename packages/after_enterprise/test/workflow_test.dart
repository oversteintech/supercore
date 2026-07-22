import 'dart:io';

import 'package:after_core/after_core.dart';
import 'package:after_enterprise/after_enterprise.dart';
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
  const definition = WorkflowDefinition(
    id: 'admission',
    name: 'Patient Admission',
    states: {'draft', 'triaged', 'admitted', 'discharged'},
    initialState: 'draft',
    transitions: [
      WorkflowTransition(from: 'draft', to: 'triaged', event: 'triage'),
      WorkflowTransition(from: 'triaged', to: 'admitted', event: 'admit'),
      WorkflowTransition(
        from: 'admitted',
        to: 'discharged',
        event: 'discharge',
      ),
    ],
  );

  test('starts at initial state', () async {
    final repo = InMemoryWorkflowRepository(seed: const [definition]);
    final instance = await repo.startInstance(
      definition: definition,
      subjectId: 'patient_1',
      organizationId: 'org1',
    );
    expect(instance.currentState, 'draft');
    expect(instance.history, isEmpty);
  });

  test('valid transition advances state and appends history', () {
    final engine = WorkflowEngine();
    final start = WorkflowInstance(
      id: 'i1',
      definitionId: definition.id,
      subjectId: 'p1',
      currentState: 'draft',
      history: const [],
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final next = engine.transition(
      definition: definition,
      instance: start,
      event: 'triage',
      actorId: 'nurse_1',
      at: DateTime.utc(2026, 1, 2),
    );
    expect(next.currentState, 'triaged');
    expect(next.history, hasLength(1));
    expect(next.history.first.event, 'triage');
    expect(next.history.first.actorId, 'nurse_1');
  });

  test('invalid transition throws WorkflowException', () {
    final engine = WorkflowEngine();
    final start = WorkflowInstance(
      id: 'i2',
      definitionId: definition.id,
      subjectId: 'p2',
      currentState: 'draft',
      history: const [],
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    expect(
      () => engine.transition(
        definition: definition,
        instance: start,
        event: 'discharge',
      ),
      throwsA(isA<WorkflowException>()),
    );
  });

  test('availableTransitions respects permission and role', () {
    const gated = WorkflowDefinition(
      id: 'med',
      name: 'Medication Approval',
      states: {'pending', 'approved'},
      initialState: 'pending',
      transitions: [
        WorkflowTransition(
          from: 'pending',
          to: 'approved',
          event: 'approve',
          requiredPermission: 'pharmacy.approve',
          requiredRole: 'pharmacist',
        ),
      ],
    );
    final instance = WorkflowInstance(
      id: 'm1',
      definitionId: gated.id,
      subjectId: 'order_1',
      currentState: 'pending',
      history: const [],
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final engine = WorkflowEngine();
    expect(
      engine.availableTransitions(
        definition: gated,
        instance: instance,
        actor: const WorkflowActorContext(
          permissions: {'pharmacy.approve'},
        ),
      ),
      isEmpty,
    );
    expect(
      engine
          .availableTransitions(
            definition: gated,
            instance: instance,
            actor: const WorkflowActorContext(
              permissions: {'pharmacy.approve'},
              roles: {'pharmacist'},
            ),
          )
          .map((t) => t.event),
      ['approve'],
    );
  });

  test('applyJson loads unlimited definitions without code changes', () {
    final registry = InMemoryWorkflowDefinitionRegistry();
    final ok = registry.applyJson('''
    {
      "version": 2,
      "workflows": [
        {"id":"a","name":"A","domain":"hospital","initialState":"s1",
         "states":["s1","s2"],"transitions":[
           {"from":"s1","to":"s2","event":"go"}
         ]},
        {"id":"b","name":"B","domain":"airport","initialState":"x",
         "states":["x","y"],"transitions":[
           {"from":"x","to":"y","event":"fly"}
         ]}
      ]
    }
    ''');
    expect(ok, isTrue);
    expect(registry.all, hasLength(2));
    expect(registry.byDomain('hospital').single.id, 'a');
    expect(registry.currentCatalog?.version, 2);
  });

  test('hydrateWorkflowCatalog prefers Remote Config over assets', () {
    final registry = InMemoryWorkflowDefinitionRegistry();
    final rc = _MemoryRemoteConfig({
      afterWorkflowCatalogRemoteConfigKey: '''
      {"version":9,"workflows":[
        {"id":"rc","name":"RC","initialState":"a","states":["a","b"],
         "transitions":[{"from":"a","to":"b","event":"next"}]}
      ]}
      ''',
    });
    final applied = hydrateWorkflowCatalog(
      registry,
      defaultJson: '''
      {"version":1,"workflows":[
        {"id":"asset","name":"Asset","initialState":"a","states":["a"],
         "transitions":[]}
      ]}
      ''',
      remoteConfig: rc,
    );
    expect(applied, isTrue);
    expect(registry.all.single.id, 'rc');
    expect(registry.currentCatalog?.version, 9);
  });

  test('repository applyTransition persists engine result', () async {
    final repo = InMemoryWorkflowRepository(seed: const [definition]);
    final started = await repo.startInstance(
      definition: definition,
      subjectId: 'p9',
      organizationId: 'org1',
    );
    final next = await repo.applyTransition(
      instanceId: started.id,
      event: 'triage',
      actor: const WorkflowActorContext(actorId: 'nurse'),
    );
    expect(next.currentState, 'triaged');
    expect(await repo.getInstance(started.id), next);
  });

  test('example hospital catalog parses and runs admission', () async {
    final path = _examplePath('hospital_catalog.json');
    final raw = File(path).readAsStringSync();
    final catalog = WorkflowCatalog.tryParse(raw);
    expect(catalog, isNotNull);
    expect(catalog!.workflows.map((w) => w.id), containsAll([
      'patient_admission',
      'medication_approval',
      'discharge',
      'lab_request',
    ]));

    final repo = InMemoryWorkflowRepository(seed: catalog.workflows);
    final def = (await repo.getDefinition('patient_admission'))!;
    final instance = await repo.startInstance(
      definition: def,
      subjectId: 'patient_42',
      organizationId: 'org1',
    );
    final triaged = await repo.applyTransition(
      instanceId: instance.id,
      event: 'triage',
      actor: const WorkflowActorContext(
        actorId: 'nurse_1',
        permissions: {'patients.triage'},
      ),
    );
    expect(triaged.currentState, 'triaged');
  });

  test('example airport / maritime / factory catalogs parse', () {
    for (final name in [
      'airport_catalog.json',
      'maritime_catalog.json',
      'factory_catalog.json',
    ]) {
      final catalog = WorkflowCatalog.tryParse(
        File(_examplePath(name)).readAsStringSync(),
      );
      expect(catalog, isNotNull, reason: name);
      expect(catalog!.workflows, isNotEmpty, reason: name);
      for (final wf in catalog.workflows) {
        expect(wf.id, isNotEmpty);
        expect(wf.initialState, isNotEmpty);
        expect(wf.states.contains(wf.initialState), isTrue);
      }
    }
  });
}

String _examplePath(String fileName) {
  // test/ → package → packages → supercore
  final packageRoot = Directory.current.path;
  final candidates = [
    '$packageRoot/../../examples/workflows/$fileName',
    '$packageRoot/../../../examples/workflows/$fileName',
  ];
  for (final c in candidates) {
    final f = File(c);
    if (f.existsSync()) return f.path;
  }
  return candidates.first;
}
