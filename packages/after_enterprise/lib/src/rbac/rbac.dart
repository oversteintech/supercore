import 'package:meta/meta.dart';

/// A permission is a coarse capability string, e.g. `patients:read`,
/// `workflows:approve`, `documents:delete`. Enterprise products declare
/// their own strings; the OS layer never hard-codes verticals.
typedef Permission = String;

/// A role bundles a set of [Permission]s. Roles are per-organization to
/// support multi-tenant deployments.
@immutable
class Role {
  const Role({
    required this.id,
    required this.name,
    required this.permissions,
    this.organizationId,
    this.isSystem = false,
  });

  final String id;
  final String name;
  final Set<Permission> permissions;
  final String? organizationId;
  final bool isSystem;

  bool allows(Permission permission) =>
      permissions.contains('*') || permissions.contains(permission);
}

/// A resolved permission set for a specific user in a specific organization,
/// merged from all their assigned roles.
@immutable
class PermissionSet {
  const PermissionSet(this.permissions);

  final Set<Permission> permissions;

  bool allows(Permission permission) =>
      permissions.contains('*') || permissions.contains(permission);

  static const PermissionSet empty = PermissionSet(<Permission>{});
}

/// Port for role-based access control.
abstract class RbacRepository {
  Future<List<Role>> listRoles({String? organizationId});
  Future<Role> upsertRole(Role role);
  Future<void> deleteRole(String roleId);

  Future<void> assignRole({
    required String userId,
    required String roleId,
    required String organizationId,
  });

  Future<void> revokeRole({
    required String userId,
    required String roleId,
    required String organizationId,
  });

  Future<PermissionSet> resolvePermissions({
    required String userId,
    required String organizationId,
  });
}

/// In-memory RBAC repository used by mock scaffolds and tests.
class InMemoryRbacRepository implements RbacRepository {
  InMemoryRbacRepository({List<Role>? seed})
      : _roles = {for (final r in seed ?? const <Role>[]) r.id: r};

  final Map<String, Role> _roles;
  final Map<String, Set<String>> _assignments = {};

  String _assignmentKey(String userId, String orgId) => '$orgId::$userId';

  @override
  Future<List<Role>> listRoles({String? organizationId}) async {
    return _roles.values
        .where((r) => organizationId == null ||
            r.organizationId == null ||
            r.organizationId == organizationId)
        .toList(growable: false);
  }

  @override
  Future<Role> upsertRole(Role role) async {
    _roles[role.id] = role;
    return role;
  }

  @override
  Future<void> deleteRole(String roleId) async {
    _roles.remove(roleId);
    for (final entry in _assignments.entries) {
      entry.value.remove(roleId);
    }
  }

  @override
  Future<void> assignRole({
    required String userId,
    required String roleId,
    required String organizationId,
  }) async {
    _assignments
        .putIfAbsent(_assignmentKey(userId, organizationId), () => <String>{})
        .add(roleId);
  }

  @override
  Future<void> revokeRole({
    required String userId,
    required String roleId,
    required String organizationId,
  }) async {
    _assignments[_assignmentKey(userId, organizationId)]?.remove(roleId);
  }

  @override
  Future<PermissionSet> resolvePermissions({
    required String userId,
    required String organizationId,
  }) async {
    final roleIds = _assignments[_assignmentKey(userId, organizationId)] ??
        const <String>{};
    final permissions = <Permission>{};
    for (final id in roleIds) {
      final role = _roles[id];
      if (role != null) {
        permissions.addAll(role.permissions);
      }
    }
    return PermissionSet(Set.unmodifiable(permissions));
  }
}
