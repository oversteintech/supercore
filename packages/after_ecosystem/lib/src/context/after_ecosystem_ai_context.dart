import 'package:after_core/after_core.dart';
import 'package:meta/meta.dart';

import '../events/after_event_bus.dart';
import '../identity/after_id.dart';
import '../services/after_shared_services.dart';
import '../subscription/after_plus.dart';

/// Cross-module context passed into AfterAI — one assistant for the ecosystem.
@immutable
class AfterEcosystemAiContext {
  const AfterEcosystemAiContext({
    required this.afterId,
    this.organizationId,
    this.activeProductId,
    this.plan,
    this.recentEvents = const <AfterEcosystemEvent>[],
    this.upcomingCalendar = const <AfterEcosystemCalendarEvent>[],
    this.openNotifications = const <AfterEcosystemNotification>[],
    this.familySummary,
    this.moduleHints = const <String, String>{},
  });

  final AfterId afterId;
  final String? organizationId;
  final String? activeProductId;
  final AfterPlusSubscription? plan;
  final List<AfterEcosystemEvent> recentEvents;
  final List<AfterEcosystemCalendarEvent> upcomingCalendar;
  final List<AfterEcosystemNotification> openNotifications;
  final String? familySummary;

  /// Free-form module summaries (garage: "2 vehicles", finance: "budget OK").
  final Map<String, String> moduleHints;

  /// Compact prompt block for AfterAI system / tool context.
  String toPromptBlock() {
    final buf = StringBuffer()
      ..writeln('After ecosystem context')
      ..writeln('afterId: ${afterId.value}')
      ..writeln('activeModule: ${activeProductId ?? "none"}')
      ..writeln('plan: ${plan?.plan.name ?? "unknown"}');
    if (organizationId != null) {
      buf.writeln('organizationId: $organizationId');
    }
    if (familySummary != null) {
      buf.writeln('family: $familySummary');
    }
    if (moduleHints.isNotEmpty) {
      buf.writeln('modules:');
      moduleHints.forEach((k, v) => buf.writeln('  - $k: $v'));
    }
    if (upcomingCalendar.isNotEmpty) {
      buf.writeln('calendar:');
      for (final e in upcomingCalendar.take(5)) {
        buf.writeln(
          '  - [${e.sourceProductId}] ${e.title} @ ${e.start.toIso8601String()}',
        );
      }
    }
    if (recentEvents.isNotEmpty) {
      buf.writeln('recentEvents:');
      for (final e in recentEvents.take(8)) {
        buf.writeln('  - ${e.type} from ${e.sourceProductId}');
      }
    }
    if (openNotifications.isNotEmpty) {
      buf.writeln('notifications: ${openNotifications.length} unread/open');
    }
    return buf.toString();
  }

  /// Maps to [AfterAiContextBlock] for `after_ai` without package cycles (ADR-001).
  AfterAiContextBlock toContextBlock() => AfterAiContextBlock(
        text: toPromptBlock(),
        metadata: {
          'afterId': afterId.value,
          if (organizationId != null) 'organizationId': organizationId,
          if (activeProductId != null) 'activeProductId': activeProductId,
          'plan': plan?.plan.name,
        },
      );
}

/// Builds [AfterEcosystemAiContext] from shared services + event bus.
class AfterEcosystemAiContextBuilder {
  AfterEcosystemAiContextBuilder({
    required this.eventBus,
    required this.calendar,
    required this.notifications,
    required this.family,
    required this.plus,
  });

  final AfterEventBus eventBus;
  final AfterEcosystemCalendar calendar;
  final AfterNotificationCenter notifications;
  final AfterFamilyGraph family;
  final AfterPlusRepository plus;

  Future<AfterEcosystemAiContext> build({
    required AfterId afterId,
    String? organizationId,
    String? activeProductId,
    Map<String, String> moduleHints = const {},
  }) async {
    final now = DateTime.now().toUtc();
    final events = eventBus
        .recent(limit: 40)
        .where((e) => e.afterId == null || e.afterId == afterId)
        .toList();
    final cal = await calendar.listMerged(
      afterId: afterId,
      from: now,
      to: now.add(const Duration(days: 14)),
    );
    final inbox = await notifications.inbox(afterId);
    final space = await family.spaceFor(afterId);
    final sub = await plus.subscriptionFor(afterId);

    return AfterEcosystemAiContext(
      afterId: afterId,
      organizationId: organizationId,
      activeProductId: activeProductId,
      plan: sub,
      recentEvents: events,
      upcomingCalendar: cal,
      openNotifications: inbox.where((n) => !n.read).toList(),
      familySummary: space == null
          ? null
          : '${space.name} (${space.members.length} members)',
      moduleHints: moduleHints,
    );
  }
}
