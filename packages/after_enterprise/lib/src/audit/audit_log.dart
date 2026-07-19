import 'package:meta/meta.dart';

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

  Future<List<AuditLogEntry>> query({
    String? organizationId,
    String? actorId,
    String? action,
    DateTime? from,
    DateTime? to,
    int limit = 200,
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
    final entry = AuditLogEntry(
      id: 'audit_${_nextId++}',
      organizationId: organizationId,
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
    String? organizationId,
    String? actorId,
    String? action,
    DateTime? from,
    DateTime? to,
    int limit = 200,
  }) async {
    final filtered = _entries.where((e) {
      if (organizationId != null && e.organizationId != organizationId) {
        return false;
      }
      if (actorId != null && e.actorId != actorId) return false;
      if (action != null && e.action != action) return false;
      if (from != null && e.occurredAt.isBefore(from)) return false;
      if (to != null && e.occurredAt.isAfter(to)) return false;
      return true;
    }).toList(growable: false);
    if (filtered.length <= limit) return filtered;
    return List.unmodifiable(filtered.sublist(filtered.length - limit));
  }
}
