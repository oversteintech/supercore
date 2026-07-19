import 'package:meta/meta.dart';

/// Analytics event scoped to an enterprise tenant. Bridges to
/// `after_core`'s [AfterAnalytics] port at composition time — but this
/// layer owns the tenant + role attribution and PII scrubbing.
@immutable
class EnterpriseAnalyticsEvent {
  const EnterpriseAnalyticsEvent({
    required this.name,
    required this.organizationId,
    this.userId,
    this.roleIds = const [],
    this.properties = const {},
    this.occurredAt,
  });

  final String name;
  final String organizationId;
  final String? userId;
  final List<String> roleIds;
  final Map<String, Object?> properties;
  final DateTime? occurredAt;
}

abstract class EnterpriseAnalytics {
  Future<void> track(EnterpriseAnalyticsEvent event);
  Future<List<EnterpriseAnalyticsEvent>> recent({int limit = 100});
}

/// Buffers events in memory so tests + mock scaffolds can assert on them.
class InMemoryEnterpriseAnalytics implements EnterpriseAnalytics {
  final List<EnterpriseAnalyticsEvent> _events = [];

  @override
  Future<void> track(EnterpriseAnalyticsEvent event) async {
    _events.add(
      EnterpriseAnalyticsEvent(
        name: event.name,
        organizationId: event.organizationId,
        userId: event.userId,
        roleIds: event.roleIds,
        properties: event.properties,
        occurredAt: event.occurredAt ?? DateTime.now().toUtc(),
      ),
    );
  }

  @override
  Future<List<EnterpriseAnalyticsEvent>> recent({int limit = 100}) async {
    if (_events.length <= limit) return List.unmodifiable(_events);
    return List.unmodifiable(_events.sublist(_events.length - limit));
  }
}
