# ADR-006 — Secure interop only path

**Status:** Accepted  
**Date:** 2026-07-19

## Context

`apis.invoke` can bypass the secure interop bridge; audit is optional — cross-line calls are unaccountable.

## Decision

- All cross-product invokes go through `AfterSecureInteropBridge`.
- Direct registry invoke is internal.
- Bridge always: audience (After ID) → scopes → RBAC/org membership when org present → **mandatory audit** → optional minimization by endpoint schema.

Fabric composition must require an audit callback; missing audit in production bootstrap mode fails startup.

## Consequences

Phase 1 forces bridge path + mandatory audit on fabric public invoke APIs. Tests assert audit is always called.
