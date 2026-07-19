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
import '../sync/offline_sync.dart';
import '../tasks/tasks.dart';
import '../workflow/workflow.dart';

/// Composite façade that groups every enterprise OS port under one object.
///
/// Enterprise Super Apps consume `EnterpriseRepository` from Riverpod
/// (`enterpriseRepositoryProvider`) and swap `MockEnterpriseRepository`
/// with a real backend adapter at composition root — never touching feature
/// code.
abstract class EnterpriseRepository {
  OrganizationRepository get organizations;
  RbacRepository get rbac;
  WorkflowRepository get workflows;
  WorkflowEngine get workflowEngine;
  TaskRepository get tasks;
  CalendarRepository get calendar;
  DocumentRepository get documents;
  EnterpriseAiAssistant get ai;
  MessagingRepository get messaging;
  EnterpriseNotificationDispatcher get notifications;
  ReportingRepository get reporting;
  EnterpriseAnalytics get analytics;
  AuditLogRepository get audit;
  OfflineSyncQueue get sync;
  EnterpriseApiClient get api;
}

/// Reference in-memory [EnterpriseRepository] used by SuperHospital and
/// tests. Every port is backed by a deterministic `InMemory*` / `Mock*`
/// implementation so vertical scaffolds run with zero backend setup.
class MockEnterpriseRepository implements EnterpriseRepository {
  MockEnterpriseRepository({
    OrganizationRepository? organizations,
    RbacRepository? rbac,
    WorkflowRepository? workflows,
    WorkflowEngine? workflowEngine,
    TaskRepository? tasks,
    CalendarRepository? calendar,
    DocumentRepository? documents,
    EnterpriseAiAssistant? ai,
    MessagingRepository? messaging,
    EnterpriseNotificationDispatcher? notifications,
    ReportingRepository? reporting,
    EnterpriseAnalytics? analytics,
    AuditLogRepository? audit,
    OfflineSyncQueue? sync,
    EnterpriseApiClient? api,
  })  : organizations = organizations ?? InMemoryOrganizationRepository(),
        rbac = rbac ?? InMemoryRbacRepository(),
        workflows = workflows ?? InMemoryWorkflowRepository(),
        workflowEngine = workflowEngine ?? WorkflowEngine(),
        tasks = tasks ?? InMemoryTaskRepository(),
        calendar = calendar ?? InMemoryCalendarRepository(),
        documents = documents ?? InMemoryDocumentRepository(),
        ai = ai ?? const MockEnterpriseAiAssistant(),
        messaging = messaging ?? InMemoryMessagingRepository(),
        notifications = notifications ??
            InMemoryEnterpriseNotificationDispatcher(),
        reporting = reporting ?? MockReportingRepository(),
        analytics = analytics ?? InMemoryEnterpriseAnalytics(),
        audit = audit ?? InMemoryAuditLogRepository(),
        sync = sync ?? InMemoryOfflineSyncQueue(),
        api = api ?? const NoOpEnterpriseApiClient();

  @override
  final OrganizationRepository organizations;
  @override
  final RbacRepository rbac;
  @override
  final WorkflowRepository workflows;
  @override
  final WorkflowEngine workflowEngine;
  @override
  final TaskRepository tasks;
  @override
  final CalendarRepository calendar;
  @override
  final DocumentRepository documents;
  @override
  final EnterpriseAiAssistant ai;
  @override
  final MessagingRepository messaging;
  @override
  final EnterpriseNotificationDispatcher notifications;
  @override
  final ReportingRepository reporting;
  @override
  final EnterpriseAnalytics analytics;
  @override
  final AuditLogRepository audit;
  @override
  final OfflineSyncQueue sync;
  @override
  final EnterpriseApiClient api;
}
