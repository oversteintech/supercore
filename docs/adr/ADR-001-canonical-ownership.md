# ADR-001 — Canonical ownership model

**Status:** Accepted  
**Date:** 2026-07-19

## Context

Calendar, notifications, search, analytics, settings, and AI exist in parallel across `after_core`, `after_ecosystem`, `after_enterprise`, and `after_ai` with no single owner.

## Decision

| Concern | Canonical owner | Others become |
|---------|-----------------|---------------|
| Identity (After ID SSO) | `after_ecosystem` | `after_core` auth = credential provider only |
| Subscription (After+) | `after_ecosystem` | Maps onto `AfterUserPlan` / store adapters |
| Event fabric | `after_ecosystem` | Products publish/subscribe only |
| Product interop APIs | `after_ecosystem` | All invokes through secure bridge |
| Notification Center | `after_ecosystem` | Core = device channel; Enterprise = scoped writer |
| Merged Calendar | `after_ecosystem` | Enterprise calendar contributes via events/bridge |
| Federated Search | `after_ecosystem` | Core `AfterSearchPort` = index substrate |
| Documents vault | `after_ecosystem` | Enterprise docs contribute / org-scoped view |
| Analytics | `after_core.AfterAnalytics` + scope | Ecosystem/enterprise = decorators |
| Settings | Single façade, scope: device \| user \| org \| family | Two backends, one API |
| AI runtime | `after_ai` | Must accept ecosystem context; BYOK via `after_core` |
| Org/RBAC/Workflow/Tasks | `after_enterprise` | Always under `EnterpriseScope` |
| Design system | `after_design_system` | Unchanged |

**Dependency rule:** `after_enterprise` and `after_consumer` **may depend on** `after_ecosystem`. Products depend on line OS + ecosystem + AI.

**AI context without cycles:** `AfterAiContextBlock` lives in `after_core`; ecosystem builder maps to it; `AfterAiPlatform.chat` accepts optional `AfterAiContextBlock`.

## Consequences

Phase 2 collapses duplicate ports onto the owners above. Phase 1 wires AI context and interop path only.
