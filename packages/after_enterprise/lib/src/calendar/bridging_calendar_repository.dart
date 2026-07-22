import 'package:after_core/after_core.dart';
import 'package:after_ecosystem/after_ecosystem.dart';

import 'calendar.dart';

/// Enterprise calendar as a scoped writer into the ecosystem merged calendar
/// (ADR-001 Phase 2).
///
/// CRUD stays on [inner]; create/update/delete also upsert/remove
/// [AfterEcosystemCalendarEvent]s so Hub / consumer surfaces see org events.
class BridgingCalendarRepository implements CalendarRepository {
  BridgingCalendarRepository({
    required CalendarRepository inner,
    required AfterEcosystemCalendar ecosystem,
    required this.sourceProductId,
    this.resolveAfterId,
  })  : _inner = inner,
        _ecosystem = ecosystem;

  final CalendarRepository _inner;
  final AfterEcosystemCalendar _ecosystem;

  /// Catalog / package id of the writing product (e.g. `super_hospital`).
  final String sourceProductId;

  /// Optional map from enterprise event → After ID (attendee, owner, …).
  final AfterId? Function(CalendarEvent event)? resolveAfterId;

  @override
  Future<List<CalendarEvent>> listEvents({
    required String organizationId,
    DateTime? from,
    DateTime? to,
    String? attendeeId,
  }) =>
      _inner.listEvents(
        organizationId: organizationId,
        from: from,
        to: to,
        attendeeId: attendeeId,
      );

  @override
  Future<Page<CalendarEvent>> pageEvents({
    required String organizationId,
    PageQuery query = const PageQuery(),
    DateTime? from,
    DateTime? to,
    String? attendeeId,
  }) =>
      _inner.pageEvents(
        organizationId: organizationId,
        query: query,
        from: from,
        to: to,
        attendeeId: attendeeId,
      );

  @override
  Future<CalendarEvent?> getEvent(String id) => _inner.getEvent(id);

  @override
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    final stored = await _inner.createEvent(event);
    await _mirrorUpsert(stored);
    return stored;
  }

  @override
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    final stored = await _inner.updateEvent(event);
    await _mirrorUpsert(stored);
    return stored;
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _inner.deleteEvent(id);
    await _ecosystem.remove(id);
  }

  Future<void> _mirrorUpsert(CalendarEvent event) {
    return _ecosystem.upsert(
      AfterEcosystemCalendarEvent(
        id: event.id,
        title: event.title,
        start: event.start,
        end: event.end,
        sourceProductId: sourceProductId,
        afterId: resolveAfterId?.call(event),
        organizationId: event.organizationId,
        metadata: {
          if (event.location != null) 'location': event.location,
          if (event.description != null) 'description': event.description,
          'isAllDay': event.isAllDay,
          'attendeeIds': event.attendeeIds,
        },
      ),
    );
  }
}
