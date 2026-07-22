import 'package:after_core/after_core.dart';
import 'package:after_enterprise/after_enterprise.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('listTasks without org throws fail-closed', () async {
    final tasks = InMemoryTaskRepository(
      seed: const [
        EnterpriseTask(id: 't1', organizationId: 'org1', title: 'A'),
        EnterpriseTask(id: 't2', organizationId: 'org2', title: 'B'),
      ],
    );
    expect(
      () => tasks.listTasks(organizationId: ''),
      throwsStateError,
    );
  });

  test('listTasks filters to one tenant only', () async {
    final tasks = InMemoryTaskRepository(
      seed: const [
        EnterpriseTask(id: 't1', organizationId: 'org1', title: 'A'),
        EnterpriseTask(id: 't2', organizationId: 'org2', title: 'B'),
      ],
    );
    final org1 = await tasks.listTasks(organizationId: 'org1');
    expect(org1.map((t) => t.id), ['t1']);
  });

  test('pageTasks uses PageQuery', () async {
    final tasks = InMemoryTaskRepository(
      seed: [
        for (var i = 0; i < 5; i++)
          EnterpriseTask(
            id: 't$i',
            organizationId: 'org1',
            title: 'T$i',
          ),
      ],
    );
    final page = await tasks.pageTasks(
      organizationId: 'org1',
      query: const PageQuery(limit: 2),
    );
    expect(page.items, hasLength(2));
    expect(page.hasMore, isTrue);
  });

  test('AuditingEnterpriseRepository appends audit on create', () async {
    final inner = MockEnterpriseRepository();
    const scope = EnterpriseScope(
      organizationId: 'org1',
      actorId: 'actor1',
    );
    final audited = AuditingEnterpriseRepository(inner: inner, scope: scope);
    await audited.tasks.createTask(
      const EnterpriseTask(
        id: 't9',
        organizationId: 'org1',
        title: 'Audited',
      ),
    );
    final entries = await audited.audit.query(organizationId: 'org1');
    expect(entries.any((e) => e.action == 'task.create'), isTrue);
  });
}
