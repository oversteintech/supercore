import 'package:after_enterprise/after_enterprise.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('create organization becomes active by default', () async {
    final repo = InMemoryOrganizationRepository();
    final org = await repo.createOrganization(
      name: 'General Hospital',
      slug: 'general',
    );
    final current = await repo.currentOrganization();
    expect(org.id, 'org_1');
    expect(current, isNotNull);
    expect(current!.slug, 'general');
  });

  test('members can be added and removed', () async {
    final repo = InMemoryOrganizationRepository();
    final org = await repo.createOrganization(
      name: 'Central Clinic',
      slug: 'central',
    );
    await repo.addMember(
      organizationId: org.id,
      userId: 'u1',
      roleIds: const ['nurse'],
    );
    await repo.addMember(
      organizationId: org.id,
      userId: 'u2',
      roleIds: const ['doctor'],
    );
    var memberships = await repo.listMemberships(org.id);
    expect(memberships, hasLength(2));

    await repo.removeMember(organizationId: org.id, userId: 'u1');
    memberships = await repo.listMemberships(org.id);
    expect(memberships, hasLength(1));
    expect(memberships.single.userId, 'u2');
  });
}
