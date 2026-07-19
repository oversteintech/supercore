# ADR-009 — Naming standard

**Status:** Accepted  
**Date:** 2026-07-19

## Context

`Mock*`, `InMemory*`, `NoOp*`, and `Memory*` coexist inconsistently; unprefixed enterprise types risk collision with ecosystem types.

## Decision

- `InMemory*` = full port over Map (scaffold).
- `NoOp*` = empty stub.
- `Mock*` = deterministic test double only (prefer under `test/`).
- New enterprise calendar/search types use `Enterprise*` prefix going forward; ecosystem stays `After*`.

Full rename of historical `Mock*` types is out of Phase 1 scope.

## Consequences

New code follows this standard; legacy names remain until Phase 2 cleanup.
