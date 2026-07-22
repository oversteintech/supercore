# After Workflow Engine

Every enterprise Super App supports **configurable workflows**. Definitions
are owned by **JSON** (bundled asset) and/or **Remote Config** — products do
not ship new Dart classes for each admission, flight prep, or repair flow.

## Packages

| Piece | Package | API |
|-------|---------|-----|
| Specs, catalog, engine | `after_enterprise` | `WorkflowDefinition`, `WorkflowCatalog`, `WorkflowEngine`, `WorkflowDefinitionRegistry`, `hydrateWorkflowCatalog`, `WorkflowRepository` |
| Providers | `after_enterprise` | `workflowRepositoryProvider`, `workflowEngineProvider`, `workflowDefinitionRegistryProvider` |

Remote Config key (default): `after.workflow.catalog`

## Capabilities

- Unlimited workflow definitions (catalog grows without code changes)
- States + transitions with optional RBAC (`requiredPermission` / `requiredRole`)
- Terminal states (no further transitions)
- Tenant scoping via `organizationIds`
- Domain / subject typing (`hospital` + `patient`, `airport` + `flight`, …)
- Instance history (`WorkflowEvent`) for audit UI
- Optional `createsTask` hints for the Tasks module
- `applyTransition` convenience on the repository

## JSON shape

```json
{
  "version": 1,
  "id": "superhospital",
  "domain": "hospital",
  "workflows": [
    {
      "id": "patient_admission",
      "name": "Patient Admission",
      "nameKey": "wf.hospital.admission",
      "domain": "hospital",
      "subjectType": "patient",
      "initialState": "registered",
      "states": ["registered", "triaged", "admitted", "cancelled"],
      "terminalStates": ["cancelled"],
      "transitions": [
        {
          "from": "registered",
          "to": "triaged",
          "event": "triage",
          "requiredPermission": "patients.triage"
        }
      ]
    }
  ]
}
```

A bare workflow array is also accepted (version defaults to `1`).

## Reference catalogs

| Vertical | File | Workflows |
|----------|------|-----------|
| Hospital | [`examples/workflows/hospital_catalog.json`](../examples/workflows/hospital_catalog.json) | Patient Admission, Medication Approval, Discharge, Lab Request |
| Airport | [`examples/workflows/airport_catalog.json`](../examples/workflows/airport_catalog.json) | Flight Preparation, Maintenance, Crew Assignment |
| Maritime | [`examples/workflows/maritime_catalog.json`](../examples/workflows/maritime_catalog.json) | Port Arrival, Maintenance, Inspection |
| Factory | [`examples/workflows/factory_catalog.json`](../examples/workflows/factory_catalog.json) | Machine Repair, Quality Control |

## App wiring (no workflow classes in the product)

```dart
final registry = ref.read(workflowDefinitionRegistryProvider);
final asset = await rootBundle.loadString('assets/workflows/catalog.json');
hydrateWorkflowCatalog(
  registry,
  defaultJson: asset,
  remoteConfig: ref.read(afterRemoteConfigProvider),
);

// Also seed the repository (or share the same registry):
final repo = InMemoryWorkflowRepository(registry: registry);

final admission = await repo.getDefinition('patient_admission');
final instance = await repo.startInstance(
  definition: admission!,
  subjectId: patient.id,
  organizationId: org.id,
);

final next = await repo.applyTransition(
  instanceId: instance.id,
  event: 'triage',
  actor: WorkflowActorContext(
    actorId: user.id,
    permissions: {'patients.triage'},
    roles: {'nurse'},
    organizationId: org.id,
  ),
);
```

Ops can push a new `after.workflow.catalog` string via Remote Config;
`hydrateWorkflowCatalog` replaces the definition set without an app store
release.

## Rules

1. Every vertical state change that is a business process MUST go through
   `WorkflowEngine.transition` / `WorkflowRepository.applyTransition`.
2. Do not hard-code workflow graphs in Dart feature code.
3. Check RBAC before UI offers an action; the engine enforces again.
4. Append an audit log entry after successful transitions (enterprise OS).

See [ENTERPRISE_FRAMEWORK.md](ENTERPRISE_FRAMEWORK.md) and
[SUPER_HOSPITAL_STANDARD.md](SUPER_HOSPITAL_STANDARD.md).
