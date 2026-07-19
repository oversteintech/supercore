import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/enterprise_ai.dart';
import '../analytics/enterprise_analytics.dart';
import '../api/enterprise_api.dart';
import '../audit/audit_log.dart';
import '../calendar/calendar.dart';
import '../documents/documents.dart';
import '../messaging/messaging.dart';
import '../notifications/enterprise_notifications.dart';
import '../organization/organization.dart';
import '../rbac/rbac.dart';
import '../reporting/reporting.dart';
import '../repository/enterprise_repository.dart';
import '../sync/offline_sync.dart';
import '../tasks/tasks.dart';
import '../workflow/workflow.dart';

/// Composition root binds a concrete [EnterpriseRepository] here — override
/// with a real backend adapter or [MockEnterpriseRepository] in tests /
/// mock scaffolds.
final enterpriseRepositoryProvider = Provider<EnterpriseRepository>((ref) {
  return MockEnterpriseRepository();
});

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
  return ref.watch(enterpriseRepositoryProvider).calendar;
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
  return ref.watch(enterpriseRepositoryProvider).notifications;
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
