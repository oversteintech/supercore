import 'package:after_enterprise/after_enterprise.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryRbacRepository', () {
    late InMemoryRbacRepository repo;

    setUp(() {
      repo = InMemoryRbacRepository(
        seed: const [
          Role(
            id: 'nurse',
            name: 'Nurse',
            permissions: {'patients:read', 'notes:write'},
          ),
          Role(
            id: 'admin',
            name: 'Admin',
            permissions: {'*'},
          ),
        ],
      );
    });

    test('resolves union of assigned role permissions', () async {
      await repo.assignRole(
        userId: 'u1',
        roleId: 'nurse',
        organizationId: 'org1',
      );
      final set = await repo.resolvePermissions(
        userId: 'u1',
        organizationId: 'org1',
      );
      expect(set.allows('patients:read'), isTrue);
      expect(set.allows('notes:write'), isTrue);
      expect(set.allows('billing:approve'), isFalse);
    });

    test('wildcard role allows anything', () async {
      await repo.assignRole(
        userId: 'u2',
        roleId: 'admin',
        organizationId: 'org1',
      );
      final set = await repo.resolvePermissions(
        userId: 'u2',
        organizationId: 'org1',
      );
      expect(set.allows('anything:else'), isTrue);
    });

    test('revoke removes role', () async {
      await repo.assignRole(
        userId: 'u3',
        roleId: 'nurse',
        organizationId: 'org1',
      );
      await repo.revokeRole(
        userId: 'u3',
        roleId: 'nurse',
        organizationId: 'org1',
      );
      final set = await repo.resolvePermissions(
        userId: 'u3',
        organizationId: 'org1',
      );
      expect(set.allows('patients:read'), isFalse);
    });

    test('assignments are scoped per-organization', () async {
      await repo.assignRole(
        userId: 'u4',
        roleId: 'admin',
        organizationId: 'org1',
      );
      final setOrg2 = await repo.resolvePermissions(
        userId: 'u4',
        organizationId: 'org2',
      );
      expect(setOrg2.allows('patients:read'), isFalse);
    });
  });
}
