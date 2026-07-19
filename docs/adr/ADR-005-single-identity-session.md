# ADR-005 — Single identity session

**Status:** Accepted  
**Date:** 2026-07-19

## Context

Products can gate on `AfterAuthSession` without establishing After ID, violating Manifest "One Identity".

## Decision

- Public session for apps: `AfterIdentitySession` only.
- `AfterAuthRepository` remains the IdP adapter (Google/Apple/email).
- AuthGate / cold start must establish After ID after auth; no product ships without it.
- Deprecate using `afterAuthSessionProvider` as the sole gate.

## Consequences

Phase 1 documents the rule and begins wiring; full AuthGate migration may complete in Phase 3 product work. Ecosystem identity remains the canonical session type.
