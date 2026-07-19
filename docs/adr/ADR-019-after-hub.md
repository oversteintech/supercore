# ADR-019 — After Hub is the consumer OS shell

**Status:** Accepted  
**Date:** 2026-07-20  
**Amends:** ADR-011 (SuperAI positioning), Master Vision v2.0 consumer entry model

## Context

Master Vision describes users navigating domains of one Digital OS, but the
catalog still treated SuperAI as a peer Life Domain app and lacked a single
consumer entry product. Without a shell, every Super App re-implements
dashboard, AI entry, and cross-domain chrome — violating ≥90% reuse and the
“one OS” story.

## Decision

1. **After Hub** (`AfterHub` / `after_hub` / `com.overstein.afterhub`) is the
   **consumer OS shell** — not a Life Domain Super App. Role: `os_shell`.
2. Admission filter does **not** apply to Hub; Hub is platform UX.
3. **SuperAI** is **subsumed** into Hub’s permanent **AI** tab / surface.
   Catalog may keep `SuperAI` as capability branding that redirects to Hub AI;
   no competing standalone entry app.
4. Every shipping consumer Super App **must** declare `spec.hub` contributions
   (widgets and/or calendar feeds / notification categories) via the factory
   schema. Runtime mounts them through Dashboard Engine + Plugin System.
5. Hub **mounts** `after_ecosystem` / `after_ai` / `after_core` — it does not
   fork calendar, search, documents, notifications, or AI runtimes.
6. Public messaging: users enter the OS via After Hub; Super Apps are modules.

## Consequences

- Spec: [`AFTER_HUB.md`](../AFTER_HUB.md)  
- Domain brief: [`domains/AFTER_HUB_SHELL.md`](../domains/AFTER_HUB_SHELL.md)  
- Catalog entry with `role: os_shell`  
- Factory `product.spec.schema.json` gains `spec.hub`  
- SuperAI domain doc redirects ownership of UX to Hub AI  
- H1+ implementation generates `afterhub` shell product
