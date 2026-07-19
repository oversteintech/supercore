# ADR-002 — EnterpriseScope (fail-closed tenancy)

**Status:** Accepted  
**Date:** 2026-07-19

## Context

Enterprise list ports accept optional `organizationId` and return all tenants when omitted — a cross-tenant leakage risk at scale.

## Decision

Introduce in `after_enterprise`:

```dart
class EnterpriseScope {
  final String organizationId;
  final String actorId;
  final Set<String> permissions;
}
```

Every mutating and listing enterprise port that is org-scoped requires `EnterpriseScope` (or a required non-null `organizationId` derived from it). Missing org = **throw**, never return all tenants.

`listOrganizations` remains an identity-scoped catalog (not org-filtered).

## Consequences

Mocks and `MockEnterpriseRepository` must enforce the same fail-closed rule. Tests cover omitted-org throws.
