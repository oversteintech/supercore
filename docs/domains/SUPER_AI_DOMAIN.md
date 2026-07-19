# SuperAI — capability branding (Hub AI surface)

**Not a second AI runtime. Not a competing entry app.**

Per **ADR-019**, the permanent consumer AI surface lives in **After Hub**
(AI tab + persistent FAB). “SuperAI” remains **capability / marketing
branding** for that surface and for catalog deep links that resolve to Hub AI.

## Owns (as Hub AI surface)
- Unified Mate experience (chat, voice, multimodal entry) inside Hub
- Cross-domain skill routing via `AfterEcosystemAiContext`
- User-visible “what AI knows” / permission surfaces
- Proactive digests that span Garage · Health · Kids · Find · Finance · …

## Does not own
- Capability ports (`after_ai`)  
- BYOK transport (`after_core`)  
- Domain tools/skills (live in each Super App)  
- A separate Life Domain product shell that replaces Hub  

## Architecture
```
After Hub AI tab → AfterAiPlatform + AfterEcosystemAiContext → domain tools via fabric
```

## Catalog
`SuperAI` may remain as `status: planned` / capability alias with
`redirectsTo: AfterHub`. Do **not** generate a peer `super_ai` store listing
that competes with Hub. See [`AFTER_HUB.md`](../AFTER_HUB.md).

## Admission
❌ Not a separate Life Domain app under the admission filter.  
✅ Permanent OS surface: “talk to my life OS” for years — via Hub.
