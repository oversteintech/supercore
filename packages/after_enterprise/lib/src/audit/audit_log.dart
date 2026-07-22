import 'package:after_core/after_core.dart';
import 'package:meta/meta.dart';

import '../scope/enterprise_scope.dart';

/// Immutable enterprise audit log entry. Append-only by contract; mutations
/// on the underlying store MUST be forbidden by production adapters.
@immutable
class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.organizationId,
    required this.actorId,
    required this.action,
    required this.subject,
    required this.occurredAt,
    this.metadata = const {},
  });

  final String id;
  final String organizationId;
  final String actorId;
  final String action;
  final String subject;
  final DateTime occurredAt;
  final Map<String, Object?> metadata;
}

abstract class AuditLogRepository {
  Future<AuditLogEntry> append({
    required String organizationId,
    required String actorId,
    required String action,
    required String subject,
    Map<String, Object?> metadata,
  });

  /// Fail-closed: [organizationId] is required (ADR-002).
  Future<List<AuditLogEntry>> query({
    required String organizationId,
    String? actorId,
    String? action,
    DateTime? from,
    DateTime? to,
    int limit = 200,
  });

  Future<Page<AuditLogEntry>> pageQuery({
    required String organizationId,
    PageQuery query = const PageQuery(),
    String? actorId,
    String? action,
    DateTime? from,
    DateTime? to,
  });
}

class InMemoryAuditLogRepository implements AuditLogRepository {
  final List<AuditLogEntry> _entries = [];
  var _nextId = 1;

  @override
  Future<AuditLogEntry> append({
    required String organizationId,
    required String actorId,
    required String action,
    required String subject,
    Map<String, Object?> metadata = const {},
  }) async {
    final org = EnterpriseScope.requireOrganizationId(organizationId);
    final entry = AuditLogEntry(
      id: 'audit_${_nextId++}',
      organizationId: org,
      actorId: actorId,
      action: action,
      subject: subject,
      occurredAt: DateTime.now().toUtc(),
      metadata: Map.unmodifiable(metadata),
    );
    _entries.add(entry);
    return entry;
  }

  @override
  Future<List<AuditLogEntry>> query({
    required String organizationId,
    String? actorId,
    String? action,
    DateTime? from,
    DateTime? to,
    int limit = 200,
  }) async {
    final org = EnterpriseScope.requireOrganizationId(organizationId);
    final filtered = _entries.where((e) {
      if (e.organizationId != org) return false;
      if (actorId != null && e.actorId != actorId) return false;
      if (action != null && e.action != action) return false;
      if (from != null && e.occurredAt.isBefore(from)) return false;
      if (to != null && e.occurredAt.isAfter(to)) return false;
      return true;
    }).toList(growable: false);
    if (filtered.length <= limit) return filtered;
    return List.unmodifiable(filtered.sublist(filtered.length - limit));
  }

  @override
  Future<Page<AuditLogEntry>> pageQuery({
    required String organizationId,
    PageQuery query = const PageQuery(),
    String? actorId,
    String? action,
    DateTime? from,
    DateTime? to,
  }) async {
    final all = await this.query(
      organizationId: organizationId,
      actorId: actorId,
      action: action,
      from: from,
      to: to,
      limit: 100000,
    );
    return Page.fromList(all, query);
  }
}
