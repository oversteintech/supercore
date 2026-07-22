import 'package:after_core/after_core.dart';

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
import '../scope/enterprise_scope.dart';
import '../sync/offline_sync.dart';
import '../tasks/tasks.dart';
import '../workflow/workflow.dart';
import 'enterprise_repository.dart';

/// Decorator that appends audit entries for mutating task/document operations.
///
/// Prefer composing with this helper at the DI root (ADR-002 / review P0).
class AuditingEnterpriseRepository implements EnterpriseRepository {
  AuditingEnterpriseRepository({
    required EnterpriseRepository inner,
    required this.scope,
  })  : _inner = inner,
        tasks = _AuditingTaskRepository(
          inner: inner.tasks,
          audit: inner.audit,
          scope: scope,
        ),
        documents = _AuditingDocumentRepository(
          inner: inner.documents,
          audit: inner.audit,
          scope: scope,
        );

  final EnterpriseRepository _inner;
  final EnterpriseScope scope;

  @override
  OrganizationRepository get organizations => _inner.organizations;
  @override
  RbacRepository get rbac => _inner.rbac;
  @override
  WorkflowRepository get workflows => _inner.workflows;
  @override
  WorkflowEngine get workflowEngine => _inner.workflowEngine;
  @override
  final TaskRepository tasks;
  @override
  CalendarRepository get calendar => _inner.calendar;
  @override
  final DocumentRepository documents;
  @override
  EnterpriseAiAssistant get ai => _inner.ai;
  @override
  MessagingRepository get messaging => _inner.messaging;
  @override
  EnterpriseNotificationDispatcher get notifications => _inner.notifications;
  @override
  ReportingRepository get reporting => _inner.reporting;
  @override
  EnterpriseAnalytics get analytics => _inner.analytics;
  @override
  AuditLogRepository get audit => _inner.audit;
  @override
  OfflineSyncQueue get sync => _inner.sync;
  @override
  EnterpriseApiClient get api => _inner.api;
}

class _AuditingTaskRepository implements TaskRepository {
  _AuditingTaskRepository({
    required this.inner,
    required this.audit,
    required this.scope,
  });

  final TaskRepository inner;
  final AuditLogRepository audit;
  final EnterpriseScope scope;

  @override
  Future<List<EnterpriseTask>> listTasks({
    required String organizationId,
    String? assigneeId,
    TaskStatus? status,
  }) =>
      inner.listTasks(
        organizationId: organizationId,
        assigneeId: assigneeId,
        status: status,
      );

  @override
  Future<Page<EnterpriseTask>> pageTasks({
    required String organizationId,
    PageQuery query = const PageQuery(),
    String? assigneeId,
    TaskStatus? status,
  }) =>
      inner.pageTasks(
        organizationId: organizationId,
        query: query,
        assigneeId: assigneeId,
        status: status,
      );

  @override
  Future<EnterpriseTask?> getTask(String id) => inner.getTask(id);

  @override
  Future<EnterpriseTask> createTask(EnterpriseTask task) async {
    final created = await inner.createTask(task);
    await audit.append(
      organizationId: scope.organizationId,
      actorId: scope.actorId,
      action: 'task.create',
      subject: created.id,
    );
    return created;
  }

  @override
  Future<EnterpriseTask> updateTask(EnterpriseTask task) async {
    final updated = await inner.updateTask(task);
    await audit.append(
      organizationId: scope.organizationId,
      actorId: scope.actorId,
      action: 'task.update',
      subject: updated.id,
    );
    return updated;
  }

  @override
  Future<void> deleteTask(String id) async {
    await inner.deleteTask(id);
    await audit.append(
      organizationId: scope.organizationId,
      actorId: scope.actorId,
      action: 'task.delete',
      subject: id,
    );
  }
}

class _AuditingDocumentRepository implements DocumentRepository {
  _AuditingDocumentRepository({
    required this.inner,
    required this.audit,
    required this.scope,
  });

  final DocumentRepository inner;
  final AuditLogRepository audit;
  final EnterpriseScope scope;

  @override
  Future<List<EnterpriseDocument>> listDocuments({
    required String organizationId,
    List<String>? tags,
  }) =>
      inner.listDocuments(organizationId: organizationId, tags: tags);

  @override
  Future<Page<EnterpriseDocument>> pageDocuments({
    required String organizationId,
    PageQuery query = const PageQuery(),
    List<String>? tags,
  }) =>
      inner.pageDocuments(
        organizationId: organizationId,
        query: query,
        tags: tags,
      );

  @override
  Future<EnterpriseDocument?> getDocument(String id) => inner.getDocument(id);

  @override
  Future<EnterpriseDocument> registerDocument(
    EnterpriseDocument document,
  ) async {
    final stored = await inner.registerDocument(document);
    await audit.append(
      organizationId: scope.organizationId,
      actorId: scope.actorId,
      action: 'document.register',
      subject: stored.id,
    );
    return stored;
  }

  @override
  Future<void> deleteDocument(String id) async {
    await inner.deleteDocument(id);
    await audit.append(
      organizationId: scope.organizationId,
      actorId: scope.actorId,
      action: 'document.delete',
      subject: id,
    );
  }
}
