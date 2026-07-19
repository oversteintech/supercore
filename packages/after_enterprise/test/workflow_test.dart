import 'package:after_enterprise/after_enterprise.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
