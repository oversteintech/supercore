# ADR-011 — Master Vision v2.0 taxonomy & platform-first

**Status:** Accepted  
**Date:** 2026-07-20  
**Supersedes conflicts in:** Manifest v1.0 product lists, SuperSchool / SuperAgriculture naming, SuperDocuments “adjacent-only” status

## Context

Master Vision v2.0 defines the decade north star: a Digital OS that generates
unlimited consumer and enterprise modules — not a collection of apps.

## Decision

1. [`AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md`](../AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md)
   is the **superseding** product/platform vision.
2. **Platform-first rule** is binding: prefer shared `after_*` capabilities
   over per-app implementations whenever reasonable.
3. Consumer core includes **SuperFind**, **SuperDocuments**, and Hub AI
   (**SuperAI** branding) in addition to Garage…Games.
4. **SuperEducation** is the canonical name for the school Industry Domain
   (alias: SuperSchool / `super_school` until repos rename).
5. **SuperFarm** is the canonical name for agriculture (alias:
   SuperAgriculture / `super_agriculture` until repos rename).
6. **SuperAI** is capability branding for the **After Hub** AI surface over
   `after_ai` + ecosystem context — never a second AI runtime or peer entry
   app (**ADR-019**).
7. **SuperDocuments** is the consumer UX over **One Documents Library**
   (`AfterEcosystemDocuments`); not a private vault fork.
8. Kids “location sharing” UX consumes **SuperFind**; no second GPS stack.

## Consequences

- Manifest bumped to v2.0 and points at Master Vision.  
- Catalog + Life Domains updated.  
- Follow-on ADRs 012–018 deepen billing, notifications, teams, automation,
  documents collapse, data platform, package freeze.
