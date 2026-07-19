import 'package:after_enterprise/after_enterprise.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MockEnterpriseRepository wires every enterprise OS port', () {
    final repo = MockEnterpriseRepository();
    expect(repo.organizations, isA<OrganizationRepository>());
    expect(repo.rbac, isA<RbacRepository>());
    expect(repo.workflows, isA<WorkflowRepository>());
    expect(repo.workflowEngine, isA<WorkflowEngine>());
    expect(repo.tasks, isA<TaskRepository>());
    expect(repo.calendar, isA<CalendarRepository>());
    expect(repo.documents, isA<DocumentRepository>());
    expect(repo.ai, isA<EnterpriseAiAssistant>());
    expect(repo.messaging, isA<MessagingRepository>());
    expect(repo.notifications, isA<EnterpriseNotificationDispatcher>());
    expect(repo.reporting, isA<ReportingRepository>());
    expect(repo.analytics, isA<EnterpriseAnalytics>());
    expect(repo.audit, isA<AuditLogRepository>());
    expect(repo.sync, isA<OfflineSyncQueue>());
    expect(repo.api, isA<EnterpriseApiClient>());
  });

  test('MockEnterpriseAiAssistant echoes tenant + user for debugging', () async {
    const ai = MockEnterpriseAiAssistant();
    final response = await ai.ask(
      prompt: 'hello',
      context: const EnterpriseAiContext(
        organizationId: 'org1',
        userId: 'u1',
      ),
    );
    expect(response.text, contains('org1'));
    expect(response.text, contains('u1'));
    expect(response.text, contains('hello'));
  });
}
