# Master Vision v2.0 — Architecture alignment

**Status:** Binding planning companion  
**Vision:** [`AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md`](AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md)  
**Prior review:** [`ARCHITECTURE_REVIEW_2026.md`](ARCHITECTURE_REVIEW_2026.md) (Phase 0–1 foundations still apply)

---

## Executive verdict

Master Vision v2.0 does **not** require a new architecture.

SuperCore already encodes the OS shape (After ID, After+, event bus,
shared services, dual product lines, factory, ≥90% reuse). The decade
work is:

1. Finish **Phase 2–3** (collapse duplicate ownership, durable bus, single identity in every AuthGate).  
2. Deepen **Billing · Notifications (SMS/email/emergency) · Teams/AuthZ · Cross-app Automation · Data Platform**.  
3. Promote **After Hub** (OS shell) + **SuperDocuments · SuperEducation · SuperFarm**;
   SuperAI = Hub AI branding (ADR-019).  
4. Enforce the **platform-first rule** on every feature PR.

Current code remains a **strong scaffold** — not yet a 10-year production OS.

---

## What already matches

| Vision pillar | Evidence |
|---------------|----------|
| One OS / modules | Manifest, Life Domains, factory |
| Package map | `after_ecosystem` + line OS + `after_ai` + DS |
| Most consumer/enterprise names | `catalog/products.yaml` |
| Event-driven interop | `AfterEventBus`, secure bridge |
| ≥90% reuse | `PLATFORM_DOCTRINE.md`, reuse contract |
| After AI capability catalog | `after_ai` |
| Shared service ports | Cloud, calendar, notifications, search, wallet ledger, family, marketplace, documents, analytics |

---

## Gaps (priority)

| Pri | Gap | Direction |
|-----|-----|-----------|
| P0 | Dual identity / AuthGate | Finish ADR-005 in every product |
| P0 | In-memory event bus | Durable adapter + schema registry (ADR-004/017) |
| P0 | Unbounded lists | `Page`/`PageQuery` on every hot path |
| P1 | Duplicate calendar/search/docs/notifications | Collapse per ADR-001 Phase 2 |
| P1 | Wallet ≠ payments | ADR-012 Billing fabric (invoices, payments, coupons) |
| P1 | SMS / email / emergency channels | ADR-013 on `AfterNotificationCenter` |
| P1 | Cross-app automation | ADR-015 — separate from enterprise WorkflowEngine |
| P1 | Teams | ADR-014 under Organizations |
| P1 | After Hub + Hub AI (SuperAI branding) | OS shell; Mate surface over `after_ai` + context — **H0 done** (ADR-019 / AFTER_HUB.md) |
| P2 | SuperSchool → SuperEducation | Catalog rename + alias |
| P2 | SuperAgriculture → SuperFarm | Catalog rename + alias |
| P2 | Documents triplication | ADR-016 — one vault; SuperDocuments = UX |

---

## Scalability risks (decade)

1. Shipping N apps on **in-memory** fabric → rewrite under load.  
2. Letting each app invent location / documents / billing → forks.  
3. Treating SuperAI as a second AI runtime → Manifest violation.  
4. Expanding hospital-clone generators → reuse collapse.  
5. Feature work that asks “app?” before “platform?” → infrastructure debt.

Mitigation: Master Vision platform-first rule + factory gate + ADRs 011–018.

---

## Decade roadmap (platform)

| Phase | Focus |
|-------|--------|
| **Now** | Vision v2.0 + catalog promotions + SuperFind/Kids/AI specs |
| **Q+1** | Phase 2 ownership collapse; notification multi-channel ports |
| **Q+2** | Billing fabric; Teams; durable event bus adapter |
| **Q+3** | Cross-app Automation; SuperAI scaffold; Documents vault unify |
| **Ongoing** | Generate Life/Industry Domains via factory only; ≥90% reuse check |

Product generation stays: `product.spec.yaml` → `generate_product.ps1` →
vertical features only.

---

## ADR follow-ups

| ADR | Topic |
|-----|--------|
| [ADR-011](adr/ADR-011-master-vision-v2.md) | Master Vision v2.0 taxonomy & platform-first |
| ADR-012 | Billing fabric |
| ADR-013 | Notification multi-channel |
| ADR-014 | Teams & AuthZ graph |
| ADR-015 | After Automation (cross-app) |
| ADR-016 | Documents ownership |
| ADR-017 | Durable Data Platform |
| ADR-018 | Package dependency freeze for N apps |

---

## Platform-first checklist (every PR)

- [ ] Could another Super App need this in 2 years? → put it in `after_*`  
- [ ] Is it a permanent life/industry domain? → new product; else feature  
- [ ] Does it duplicate calendar/search/docs/notifications/AI? → extend canonical owner  
- [ ] Does it use events / secure APIs instead of sibling imports?  
- [ ] Does reuse contract still hold (≥90%)?  
