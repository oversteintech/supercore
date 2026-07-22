import 'package:meta/meta.dart';

import '../rbac/rbac.dart';

/// Fail-closed tenant + actor context for enterprise ports (ADR-002).
@immutable
class EnterpriseScope {
  const EnterpriseScope({
    required this.organizationId,
    required this.actorId,
    this.permissions = PermissionSet.empty,
  });

  final String organizationId;
  final String actorId;
  final PermissionSet permissions;

  /// Throws if [organizationId] is missing/blank — never allow all-tenant lists.
  static String requireOrganizationId(String? organizationId) {
    final id = organizationId?.trim() ?? '';
    if (id.isEmpty) {
      throw StateError(
        'EnterpriseScope: organizationId is required (fail-closed tenancy).',
      );
    }
    return id;
  }

  void ensureValid() {
    requireOrganizationId(organizationId);
    if (actorId.trim().isEmpty) {
      throw StateError('EnterpriseScope: actorId is required.');
    }
  }
}
