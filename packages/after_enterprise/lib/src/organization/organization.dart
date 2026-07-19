import 'package:meta/meta.dart';

/// A tenant / organization inside an enterprise Super App deployment.
///
/// Every enterprise product runs against exactly one active [Organization]
/// at a time; the ID plumbs down into RBAC, audit, workflow, tasks, etc.
@immutable
class Organization {
  const Organization({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String slug;
  final String? parentId;
  final bool isActive;

  Organization copyWith({
    String? name,
    String? slug,
    String? parentId,
    bool? isActive,
  }) {
    return Organization(
      id: id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      parentId: parentId ?? this.parentId,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Membership of a user inside an [Organization] with optional role IDs.
@immutable
class OrganizationMembership {
  const OrganizationMembership({
    required this.organizationId,
    required this.userId,
    required this.roleIds,
    this.joinedAt,
  });

  final String organizationId;
  final String userId;
  final List<String> roleIds;
  final DateTime? joinedAt;
}

/// Port for tenant / organization management. Products depend on this
/// interface only — never on a concrete database or API client.
abstract class OrganizationRepository {
  Future<Organization?> currentOrganization();

  Future<List<Organization>> listOrganizations();

  Future<Organization> createOrganization({
    required String name,
    required String slug,
    String? parentId,
  });

  Future<Organization> updateOrganization(Organization organization);

  Future<void> setActiveOrganization(String id);

  Future<List<OrganizationMembership>> listMemberships(String organizationId);

  Future<OrganizationMembership> addMember({
    required String organizationId,
    required String userId,
    required List<String> roleIds,
  });

  Future<void> removeMember({
    required String organizationId,
    required String userId,
  });
}

/// In-memory [OrganizationRepository] used by mock scaffolds and tests.
class InMemoryOrganizationRepository implements OrganizationRepository {
  InMemoryOrganizationRepository({List<Organization>? seed})
      : _orgs = {for (final o in seed ?? const <Organization>[]) o.id: o},
        _memberships = <String, List<OrganizationMembership>>{},
        _activeId = seed != null && seed.isNotEmpty ? seed.first.id : null;

  final Map<String, Organization> _orgs;
  final Map<String, List<OrganizationMembership>> _memberships;
  String? _activeId;

  @override
  Future<Organization?> currentOrganization() async {
    if (_activeId == null) return null;
    return _orgs[_activeId];
  }

  @override
  Future<List<Organization>> listOrganizations() async =>
      List.unmodifiable(_orgs.values);

  @override
  Future<Organization> createOrganization({
    required String name,
    required String slug,
    String? parentId,
  }) async {
    final id = 'org_${_orgs.length + 1}';
    final org = Organization(
      id: id,
      name: name,
      slug: slug,
      parentId: parentId,
    );
    _orgs[id] = org;
    _activeId ??= id;
    return org;
  }

  @override
  Future<Organization> updateOrganization(Organization organization) async {
    _orgs[organization.id] = organization;
    return organization;
  }

  @override
  Future<void> setActiveOrganization(String id) async {
    if (!_orgs.containsKey(id)) {
      throw StateError('Unknown organization $id');
    }
    _activeId = id;
  }

  @override
  Future<List<OrganizationMembership>> listMemberships(
    String organizationId,
  ) async {
    return List.unmodifiable(_memberships[organizationId] ?? const []);
  }

  @override
  Future<OrganizationMembership> addMember({
    required String organizationId,
    required String userId,
    required List<String> roleIds,
  }) async {
    final membership = OrganizationMembership(
      organizationId: organizationId,
      userId: userId,
      roleIds: List.unmodifiable(roleIds),
      joinedAt: DateTime.now().toUtc(),
    );
    _memberships.putIfAbsent(organizationId, () => []).add(membership);
    return membership;
  }

  @override
  Future<void> removeMember({
    required String organizationId,
    required String userId,
  }) async {
    _memberships[organizationId]?.removeWhere((m) => m.userId == userId);
  }
}
