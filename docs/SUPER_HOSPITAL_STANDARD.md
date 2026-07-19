# SuperHospital standard — enterprise reference checklist

**SuperHospital is the enterprise reference** in the AfterArtificial OS.
Every other enterprise Super App (SuperAirport, SuperMaritime,
SuperLogistics, SuperFactory, SuperConstruction, SuperSchool, SuperHotel,
SuperRestaurant, SuperRetail, SuperEnergy, SuperAgriculture,
SuperMunicipality, SuperPolice, SuperFire, SuperMining) MUST feel like a
sibling.

## Identity contract

| Item | Value / requirement |
|------|---------------------|
| Package / bundle | `com.overstein.superhospital` |
| Manifest const | `superHospitalManifest`, `productLine: AfterProductLine.enterprise` |
| App name | `SuperHospital` |
| Splash | OVERSTEIN company splash — black background, no product branding, `onComplete` handoff + 12s bootstrap hard timeout |
| l10n | `en` + `tr` baseline (parity with SuperGarage family) |
| CI | `flutter analyze` clean, `flutter test --coverage`, coverage ≥ 50% |
| Product accent | Vertical-specific (SuperHospital = clinical teal); UI chrome MUST match SuperGarage |

## Shell contract (identical for every enterprise Super App)

Bottom-tab shell, lazy-mounted like SuperGarage, using
`EnterpriseCoreFeatureId`:

1. **Home / Dashboard** — org KPIs, tasks due today, workflow instances
   assigned to me, recent audit highlights.
2. **Tasks** — `TaskRepository`. Filter by status, priority, assignee.
3. **Calendar** — `CalendarRepository`. Day / week views.
4. **Documents** — `DocumentRepository`. Tag search, size, uploader.
5. **AI** — `EnterpriseAiAssistant` scoped to the current org + user.
6. **More** — org switcher, RBAC admin, reporting, analytics, audit
   inspector, settings, AfterSuperAdmin surface.

## Industry modules (lib/features/, hospital-only)

- **Patients** — demographics, MRN, admission status.
- **Appointments** — booking, calendar bridge.
- **Wards** — bed occupancy grid.
- **Staff** — clinicians, on-call roster.
- **Clinical Notes** — patient timeline (writes gated by
  `PermissionSet.allows('notes:write')`, mutations appended to audit).
- **Pharmacy** — stock, dispense records.
- **Lab Orders** — order → collect → resulted workflow.
- **Billing** — line items, payer, claim workflow.
- **Compliance** — HIPAA / GDPR checklists, audit exports.
- **Hospital AI** — wraps `EnterpriseAiAssistant` with hospital tools
  (discharge summariser, triage helper).

Industry modules NEVER migrate up into `after_enterprise` — they are
product-specific by contract.

## Data / port bindings

- `enterpriseRepositoryProvider` → `MockEnterpriseRepository()` in
  the skeleton. Production overrides bind FHIR / HL7 / vendor
  adapters, but only at composition root.
- `afterAuthRepositoryProvider` → mock auth in the skeleton.
- `afterAnalyticsProvider` → product-scoped adapter that reports into
  the org's analytics sink.

## Compliance gate

After scaffolding, produce `docs/COMPLIANCE_REPORT.md` in the
`superhospital` repo comparing against SuperGarage + this standard.
Fix every gap until:

- `flutter analyze` — zero warnings.
- `flutter test --coverage` — green, coverage ≥ 50%.
- Structural parity with SuperGarage on splash / cold start / shell /
  DI / l10n / feature catalog / CI.

Deferred by design (documented, not pretended to be done):
Firebase / real EHR / IoT bridges / full 20-locale pack. Ports stay
swappable so real backends slot in without touching feature code.
