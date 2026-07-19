# ADR-008 — Generators

**Status:** Accepted  
**Date:** 2026-07-19

## Context

`generate_enterprise_from_hospital.ps1` expands full forks and violates ≥90% reuse doctrine. Generated pubspecs omit `after_ecosystem` and `after_ai`.

## Decision

- Canonical generator: `scripts/generate_product.ps1` only.
- Legacy hospital-clone script: **hard-fail** unless an explicit override switch is passed; delete `.bak` artifacts; no new verticals added via clone.
- Generated pubspec **must** include `after_ecosystem` + `after_ai`.

## Consequences

New products mount thin shells over platform packages. Existing clones are transitional; migrate via Phase 3.
