import 'package:after_core/after_core.dart';
import 'package:meta/meta.dart';

import '../scope/enterprise_scope.dart';

@immutable
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.organizationId,
    required this.title,
    required this.start,
    required this.end,
    this.location,
    this.description,
    this.attendeeIds = const [],
    this.resourceIds = const [],
    this.isAllDay = false,
  });

  final String id;
  final String organizationId;
  final String title;
  final DateTime start;
  final DateTime end;
  final String? location;
  final String? description;
  final List<String> attendeeIds;
  final List<String> resourceIds;
  final bool isAllDay;

  bool overlaps(CalendarEvent other) =>
      start.isBefore(other.end) && other.start.isBefore(end);
}

abstract class CalendarRepository {
  /// Fail-closed: [organizationId] is required (ADR-002).
  Future<List<CalendarEvent>> listEvents({
    required String organizationId,
    DateTime? from,
    DateTime? to,
    String? attendeeId,
  });

  Future<Page<CalendarEvent>> pageEvents({
    required String organizationId,
    PageQuery query = const PageQuery(),
    DateTime? from,
    DateTime? to,
    String? attendeeId,
  });

  Future<CalendarEvent?> getEvent(String id);
  Future<CalendarEvent> createEvent(CalendarEvent event);
  Future<CalendarEvent> updateEvent(CalendarEvent event);
  Future<void> deleteEvent(String id);
}

class InMemoryCalendarRepository implements CalendarRepository {
  InMemoryCalendarRepository({List<CalendarEvent>? seed})
      : _events = {for (final e in seed ?? const <CalendarEvent>[]) e.id: e};

  final Map<String, CalendarEvent> _events;
  var _nextId = 1;

  @override
  Future<List<CalendarEvent>> listEvents({
    required String organizationId,
    DateTime? from,
    DateTime? to,
    String? attendeeId,
  }) async {
    final org = EnterpriseScope.requireOrganizationId(organizationId);
    return _events.values.where((e) {
      if (e.organizationId != org) return false;
      if (from != null && e.end.isBefore(from)) return false;
      if (to != null && e.start.isAfter(to)) return false;
      if (attendeeId != null && !e.attendeeIds.contains(attendeeId)) {
        return false;
      }
      return true;
    }).toList(growable: false)
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  @override
  Future<Page<CalendarEvent>> pageEvents({
    required String organizationId,
    PageQuery query = const PageQuery(),
    DateTime? from,
    DateTime? to,
    String? attendeeId,
  }) async {
    final all = await listEvents(
      organizationId: organizationId,
      from: from,
      to: to,
      attendeeId: attendeeId,
    );
    return Page.fromList(all, query);
  }

  @override
  Future<CalendarEvent?> getEvent(String id) async => _events[id];

  @override
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    final id = event.id.isEmpty ? 'evt_${_nextId++}' : event.id;
    final stored = CalendarEvent(
      id: id,
      organizationId: event.organizationId,
      title: event.title,
      start: event.start,
      end: event.end,
      location: event.location,
      description: event.description,
      attendeeIds: event.attendeeIds,
      resourceIds: event.resourceIds,
      isAllDay: event.isAllDay,
    );
    _events[id] = stored;
    return stored;
  }

  @override
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    _events[event.id] = event;
    return event;
  }

  @override
  Future<void> deleteEvent(String id) async {
    _events.remove(id);
  }
}
