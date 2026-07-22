import 'package:after_core/after_core.dart';
import 'package:after_ecosystem/after_ecosystem.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/enterprise_ai.dart';
import '../analytics/enterprise_analytics.dart';
import '../api/enterprise_api.dart';
import '../audit/audit_log.dart';
import '../calendar/bridging_calendar_repository.dart';
import '../calendar/calendar.dart';
import '../documents/documents.dart';
import '../messaging/messaging.dart';
import '../notifications/bridging_enterprise_notification_dispatcher.dart';
import '../notifications/enterprise_notifications.dart';
import '../organization/organization.dart';
import '../rbac/rbac.dart';
import '../reporting/reporting.dart';
import '../repository/enterprise_repository.dart';
import '../scope/enterprise_scope.dart';
import '../sync/offline_sync.dart';
import '../tasks/tasks.dart';
import '../workflow/workflow.dart';

/// Product id stamped on ecosystem bridge writes (override at app root).
final enterpriseBridgeSourceProductIdProvider = Provider<String>((ref) {
  return 'after_enterprise';
});

/// Optional device delivery for bridged notifications (override at app root).
final enterpriseNotificationDeviceChannelProvider =
    Provider<AfterLocalNotifications?>((ref) => null);

/// Bootstrap mode for enterprise composition (ADR-007).
///
/// Override to [AfterBootstrapMode.production] at the app root — mock
/// repository defaults are then rejected.
final enterpriseBootstrapModeProvider = Provider<AfterBootstrapMode>((ref) {
  return AfterBootstrapMode.scaffold;
});

/// Composition root binds a concrete [EnterpriseRepository] here — override
/// with a real backend adapter or [MockEnterpriseRepository] in tests /
/// mock scaffolds.
final enterpriseRepositoryProvider = Provider<EnterpriseRepository>((ref) {
  final mode = ref.watch(enterpriseBootstrapModeProvider);
  if (mode == AfterBootstrapMode.production) {
    throw StateError(
      'enterpriseRepositoryProvider: MockEnterpriseRepository is not allowed '
      'in production bootstrap mode. Override with a real adapter (ADR-007).',
    );
  }
  return MockEnterpriseRepository();
});

/// Optional active tenant scope for UI / auditing helpers.
final enterpriseScopeProvider = Provider<EnterpriseScope?>((ref) => null);

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return ref.watch(enterpriseRepositoryProvider).organizations;
});

final currentOrganizationProvider = FutureProvider<Organization?>((ref) {
  return ref.watch(organizationRepositoryProvider).currentOrganization();
});

final rbacRepositoryProvider = Provider<RbacRepository>((ref) {
  return ref.watch(enterpriseRepositoryProvider).rbac;
});

final workflowRepositoryProvider = Provider<WorkflowRepository>((ref) {
  return ref.watch(enterpriseRepositoryProvider).workflows;
});

final workflowEngineProvider = Provider<WorkflowEngine>((ref) {
  return ref.watch(enterpriseRepositoryProvider).workflowEngine;
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return ref.watch(enterpriseRepositoryProvider).tasks;
});

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return BridgingCalendarRepository(
    inner: ref.watch(enterpriseRepositoryProvider).calendar,
    ecosystem: ref.watch(afterEcosystemCalendarProvider),
    sourceProductId: ref.watch(enterpriseBridgeSourceProductIdProvider),
  );
});

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return ref.watch(enterpriseRepositoryProvider).documents;
});

final enterpriseAiAssistantProvider = Provider<EnterpriseAiAssistant>((ref) {
  return ref.watch(enterpriseRepositoryProvider).ai;
});

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  return ref.watch(enterpriseRepositoryProvider).messaging;
});

final enterpriseNotificationDispatcherProvider =
    Provider<EnterpriseNotificationDispatcher>((ref) {
  return BridgingEnterpriseNotificationDispatcher(
    inner: ref.watch(enterpriseRepositoryProvider).notifications,
    notificationCenter: ref.watch(afterNotificationCenterProvider),
    sourceProductId: ref.watch(enterpriseBridgeSourceProductIdProvider),
    deviceChannel: ref.watch(enterpriseNotificationDeviceChannelProvider),
  );
});

final reportingRepositoryProvider = Provider<ReportingRepository>((ref) {
  return ref.watch(enterpriseRepositoryProvider).reporting;
});

final enterpriseAnalyticsProvider = Provider<EnterpriseAnalytics>((ref) {
  return ref.watch(enterpriseRepositoryProvider).analytics;
});

final auditLogRepositoryProvider = Provider<AuditLogRepository>((ref) {
  return ref.watch(enterpriseRepositoryProvider).audit;
});

final offlineSyncQueueProvider = Provider<OfflineSyncQueue>((ref) {
  return ref.watch(enterpriseRepositoryProvider).sync;
});

final enterpriseApiClientProvider = Provider<EnterpriseApiClient>((ref) {
  return ref.watch(enterpriseRepositoryProvider).api;
});
