# Enterprise Framework

The enterprise product line (`AfterProductLine.enterprise`) is the family
of B2B **Industry Domain** modules. **SuperHospital is the reference.**

Organizing principle: [`LIFE_DOMAINS.md`](LIFE_DOMAINS.md) (Industry Domains
section) · Roadmap: [`LIFE_DOMAIN_ROADMAP.md`](LIFE_DOMAIN_ROADMAP.md).

Industry Domains (Hospital, Airport, Maritime, Factory, Construction,
Retail, School, Hotel, Restaurant, Logistics, Energy, Municipality, …)
mount the same fabric as consumer Life Domains and interoperate via
secure APIs (e.g. SuperSchool ↔ SuperKids).

## Stack

```
Industry Domain product (lib/features/<vertical>/)
        ↓
after_ecosystem + after_ai + after_enterprise
        ↓
after_core + after_design_system
```

Technical ADRs: [`ARCHITECTURE_REVIEW_2026.md`](ARCHITECTURE_REVIEW_2026.md).

## Non-negotiable enterprise OS modules

Every enterprise Super App gets these 14 ports out of the box. They ship
with in-memory `Mock*` implementations behind `MockEnterpriseRepository`
so scaffolds run without any backend.

1. **Organization / tenant** — `OrganizationRepository`. Every entity in
   the enterprise OS carries `organizationId`.
2. **RBAC** — `RbacRepository`, `Role`, `PermissionSet`. Verticals
   declare their own permission strings; the OS never hard-codes them.
3. **Workflow engine** — JSON/RC catalog of unlimited definitions
   (`WorkflowCatalog`, `hydrateWorkflowCatalog`), plus
   `WorkflowEngine` / `WorkflowRepository`. See
   [WORKFLOW_ENGINE.md](WORKFLOW_ENGINE.md).
4. **Tasks** — `EnterpriseTask`, `TaskRepository`. Optional
   `linkedWorkflowInstanceId` glues tasks to workflows.
5. **Calendar / scheduling** — `CalendarEvent`, `CalendarRepository`
   with attendee + resource lists.
6. **Documents** — `EnterpriseDocument` metadata + `vaultKey`
   references. Actual binary storage is delegated to a vault adapter.
7. **Enterprise AI** — `EnterpriseAiAssistant` wraps `after_core` AI
   ports with tenant + role context.
8. **Messaging** — `MessagingChannel` + `MessagingMessage` with
   broadcast `Stream` for reactive UI.
9. **Notifications** — `EnterpriseNotificationDispatcher` bridges to
   `after_core` push / local notifications for tenant-scoped events.
10. **Reporting** — `ReportDefinition` + `ReportResult` for structured
    reports (columns + rows + metadata).
11. **Analytics** — `EnterpriseAnalytics` mirrors `after_core` analytics
    with tenant / role attribution and PII scrubbing.
12. **Audit log** — `AuditLogRepository` (append-only). Every mutating
    action MUST leave an audit entry.
13. **Offline sync** — `OfflineSyncQueue` for enterprise apps used in
    the field (hospital wards, ships, factory floors, mines).
14. **API architecture** — `EnterpriseApiHeaders` conventions +
    `EnterpriseApiClient` port so verticals share the same wire format.

## Composition contract (enterprise Super App)

1. `main.dart` runs the standard AfterArtificial cold-start (OVERSTEIN
   splash → AuthGate → MainShell).
2. `AppPlatformManifest` has
   `productLine: AfterProductLine.enterprise` — this is REQUIRED for
   enterprise apps.
3. `ProviderScope.overrides` includes:
   - `AfterStandardOverrides.create(preferences, userAgent)` from
     `after_core`, and
   - `enterpriseRepositoryProvider.overrideWithValue(...)` — mock or
     real adapter.
4. Shell tabs mirror `EnterpriseCoreFeatureId`: **Home / Dashboard,
   Tasks, Calendar, Documents, AI, More**. "More" hosts org, RBAC,
   analytics, reporting, audit and settings.
5. Vertical industry modules live under `lib/features/<vertical>/` in
   the product repo (Patients / Wards / Pharmacy in SuperHospital,
   Runways / Gates in SuperAirport, Berths / Manifests in SuperMaritime,
   …).

## Rules for enterprise verticals

- Depend on ports from `after_enterprise`. Never bypass and talk to a
  backend SDK directly.
- Every mutating action checks
  `PermissionSet.allows('<domain>:<verb>')` before persisting.
- Every mutating action appends an `AuditLogEntry`.
- Every workflow transition goes through `WorkflowEngine.transition(...)`
  so the state machine invariants stay in one place.
- Real backends override `enterpriseRepositoryProvider` at composition
  root — the OS layer never learns the vendor's name.

See `templates/super_app_enterprise/` and
`docs/SUPER_HOSPITAL_STANDARD.md` in this repo.
