# Architecture Review 2026 — AfterArtificial Ecosystem

**Status:** Binding  
**Date:** 2026-07-19  
**Scope:** SuperCore (`after_core`, `after_ecosystem`, `after_enterprise`, `after_consumer`, `after_ai`, factory)

**Master Vision:** [`AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md`](AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md) (v2.0)  
**Manifest:** [`AFTER_ECOSYSTEM_MANIFEST.md`](AFTER_ECOSYSTEM_MANIFEST.md) (v2.0)  
**Alignment:** [`MASTER_VISION_ALIGNMENT_2026.md`](MASTER_VISION_ALIGNMENT_2026.md)  
**Life Domains:** [`LIFE_DOMAINS.md`](LIFE_DOMAINS.md) ·
[`LIFE_DOMAIN_ROADMAP.md`](LIFE_DOMAIN_ROADMAP.md) (≥100 apps, zero architecture forks)  
**Technical ADRs:** [`adr/`](adr/) (ADR-001 … ADR-011; 012–018 planned)

---

## Executive verdict

The platform **vision and manifesto are sound**. The current code is a **strong scaffold**, not a 10-year OS. Left as-is, it will force a major rewrite when the first real multi-tenant / multi-product load hits.

### Root causes

1. **Parallel ownership** of the same concerns (calendar, notifications, search, analytics, settings, AI) across packages with no canonical owner + adapters.
2. **Fail-open multi-tenancy** — enterprise list ports return all tenants when `organizationId` is omitted.
3. **Dual identity** — `AfterAuthSession` vs `AfterIdentitySession` with no forced After ID SSO.
4. **Demo event bus** named as production fabric (no durability, schema, idempotency, auth).
5. **Manifest obligations** (One AI + ecosystem context, One Calendar, etc.) are documented but not wired.
6. **Unsafe defaults** — in-memory / mock providers boot as if production.

---

## Severity table

| Sev | Theme | Evidence | Smell |
|-----|--------|----------|--------|
| P0 | Tenant isolation | Enterprise `list*` ports optional `organizationId` | Cross-tenant data leakage |
| P0 | Identity | Dual sessions; AuthGate can skip After ID | Manifest "One Identity" violated |
| P0 | Event fabric | `InMemoryAfterEventBus` — 500-cap RAM bus | Not scalable; spoofable `sourceProductId` |
| P0 | Interop security | `apis.invoke` bypasses bridge; optional audit | Cross-line calls unaccountable |
| P0 | AI wiring | `AfterAiPlatform` unaware of ecosystem context | Manifest "One AI" violated |
| P0 | Pagination | All list ports return unbounded `List` | Millions-of-users bottleneck |
| P0 | Auto-audit | Mutations don't append audit by default | Enterprise compliance gap |
| P1 | Duplicate services | 2–4 ports per concern | Future rewrite magnet |
| P1 | Docs drift | Diagram / sample pubspec omit ecosystem+AI | Generator vs doctrine conflict |
| P1 | Legacy generator | `generate_enterprise_from_hospital.ps1` expands forks | Violates ≥90% reuse |
| P2 | Naming | `Mock` / `InMemory` / `NoOp` stew | Collision risk |
| P2 | Wallet misnamed | Ledger-only API called Wallet | Extensibility lie |

---

## Binding decisions

See ADRs. Summary:

| ADR | Decision |
|-----|----------|
| [ADR-001](adr/ADR-001-canonical-ownership.md) | Canonical ownership model |
| [ADR-002](adr/ADR-002-enterprise-scope.md) | `EnterpriseScope` fail-closed tenancy |
| [ADR-003](adr/ADR-003-page-query.md) | `Page` / `PageQuery` everywhere |
| [ADR-004](adr/ADR-004-durable-event-contract.md) | Durable event contract |
| [ADR-005](adr/ADR-005-single-identity-session.md) | Single After ID session |
| [ADR-006](adr/ADR-006-secure-interop-only.md) | Secure interop only path |
| [ADR-007](adr/ADR-007-bootstrap-mode.md) | Scaffold vs production bootstrap |
| [ADR-008](adr/ADR-008-generators.md) | Canonical `generate_product.ps1` only |
| [ADR-009](adr/ADR-009-naming-standard.md) | Naming standard |
| [ADR-010](adr/ADR-010-wallet-honesty.md) | Wallet honesty |

---

## Target architecture

```
Product modules (SuperGarage, SuperHospital, …)
  → after_ecosystem (After ID, After+, events, interop, shared services, AI context)
  → after_consumer | after_enterprise (+ EnterpriseScope)
  → after_core (Page, auth adapters, BYOK, settings, analytics)
  → after_ai (accepts AfterAiContextBlock)
  → after_design_system
```

Influence stays **event-driven** without product-to-product imports.

---

## Implementation phases

### Phase 0 — Document only

This review + ADRs + Manifest cross-links. No behavior change.

### Phase 1 — Foundations

1. `Page` / `PageQuery` in `after_core`
2. `EnterpriseScope` + fail-closed list signatures
3. `AuditingEnterpriseRepository` decorator
4. Event envelope fields + cursor history; in-memory bus = scaffold
5. Interop: force bridge + mandatory audit
6. `AfterAiContextBlock` + `AfterAiPlatform` accepts it
7. `AfterBootstrapMode` on ecosystem + enterprise
8. Docs + sample pubspec + architecture diagram
9. Legacy generator hard-fail
10. Tests for scope, interop audit, AI context, pagination

### Phase 2 — Collapse duplicates

Notification Center, calendar bridge, search wrap, analytics/settings façades, reuse-contract checks.

### Phase 3 — Product migration

Thin SuperHospital / SuperAirport to mount fabric + scope; stop hospital-clone expansion.

---

## Success criteria (Phase 1)

- No enterprise list API can return cross-tenant data without scope
- Cross-product invoke always audited
- AI chat can receive ecosystem context without circular deps
- Pagination types exist and are used on critical ports
- Manifest + ADRs + this review are the single source of architectural truth
- Scaffold vs production bootstrap modes are explicit
