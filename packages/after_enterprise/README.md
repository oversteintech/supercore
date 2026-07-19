# After Enterprise

Shared **enterprise OS layer** for AfterArtificial B2B / vertical Super Apps.

`after_enterprise` sits on top of the `after_core` kernel and provides the
14 shared modules every enterprise product needs so verticals can be
generated from **standards, not new architectures**.

Reference implementation: **SuperHospital**.

## Modules

| Module | Ports / entities |
|--------|------------------|
| Organization / tenant | `Organization`, `OrganizationRepository`, memberships |
| RBAC | `Role`, `Permission`, `RbacRepository`, `PermissionSet` |
| Workflow engine | `WorkflowDefinition`, `WorkflowInstance`, `WorkflowEngine`, `WorkflowRepository` |
| Tasks | `EnterpriseTask`, `TaskRepository` |
| Calendar / scheduling | `CalendarEvent`, `CalendarRepository` |
| Documents | `EnterpriseDocument` (vault refs), `DocumentRepository` |
| Enterprise AI | `EnterpriseAiAssistant`, `EnterpriseAiContext` |
| Messaging | `MessagingChannel`, `MessagingMessage`, `MessagingRepository` |
| Notifications | `EnterpriseNotification`, `EnterpriseNotificationDispatcher` |
| Reporting | `ReportDefinition`, `ReportResult`, `ReportingRepository` |
| Analytics | `EnterpriseAnalyticsEvent`, `EnterpriseAnalytics` |
| Audit log | `AuditLogEntry`, append-only `AuditLogRepository` |
| Offline sync | `SyncOperation`, `OfflineSyncQueue` |
| API conventions | `EnterpriseApiHeaders`, `EnterpriseApiClient` |

All modules ship with a deterministic `InMemory*` / `Mock*` implementation
so scaffolds (SuperHospital, SuperAirport, …) run without any backend.

## Composition

Vertical apps depend on the façade [`EnterpriseRepository`] and swap
[`MockEnterpriseRepository`] with a real adapter at composition root:

```dart
final overrides = [
  enterpriseRepositoryProvider.overrideWithValue(MockEnterpriseRepository()),
];
```

## Rules

1. **Ports, never SDKs** — features depend on interfaces from this package.
2. **Tenant plumbing** — every entity carries `organizationId`; the OS layer
   never assumes a single-tenant deployment.
3. **RBAC before persistence** — check `PermissionSet.allows(...)` before
   any mutating call in vertical features.
4. **Audit everything** — mutating enterprise actions must append an
   `AuditLogEntry`.
5. **Family feel** — every enterprise Super App uses the enterprise shell
   tabs (`EnterpriseCoreFeatureId`) plus vertical industry modules under
   `lib/features/`.

See `docs/ENTERPRISE_FRAMEWORK.md` and
`docs/SUPER_HOSPITAL_STANDARD.md` in this repo.
