# After Ecosystem Platform

> **AfterArtificial is an AI Product Platform that generates consumer and
> enterprise software from a unified architecture.**

**Manifest:** [`AFTER_ECOSYSTEM_MANIFEST.md`](AFTER_ECOSYSTEM_MANIFEST.md)
(v1.0) — binding philosophy and obligations.

This document is the **technical architecture** of that manifesto.

Users should never feel they are switching apps. They should feel they
are navigating **Life Domains** of one intelligent ecosystem — with
**one identity, one subscription, and one assistant** that understands
the whole graph.

Package: [`packages/after_ecosystem`](../packages/after_ecosystem)  
Doctrine: [`PLATFORM_DOCTRINE.md`](PLATFORM_DOCTRINE.md)  
Life Domains: [`LIFE_DOMAINS.md`](LIFE_DOMAINS.md)  
Roadmap: [`LIFE_DOMAIN_ROADMAP.md`](LIFE_DOMAIN_ROADMAP.md)  
AI: [`AFTER_AI_PLATFORM.md`](AFTER_AI_PLATFORM.md)

---

## 1. North star

| Principle | Meaning |
|-----------|---------|
| One OS feel | Shared chrome, identity, subscription, AI, search, calendar, notifications, documents |
| One After ID | Single account across every consumer + enterprise product |
| One After+ | Single subscription entitlement fabric |
| One After AI | Contextual awareness across the entire ecosystem |
| Event-driven | Products publish / subscribe; influence flows without hard coupling |
| Service-oriented | Shared platform services; verticals are modules |
| ≥100 products | Same architecture; only Life/Industry domain + features + AI skills change |
| Consumer ↔ Enterprise | Secure interop APIs between lines |

Influence example (soft edges, not hard-coded pipelines):

```
Kids (vaccine) → Health → Calendar → Notifications
Find (school / SOS) → Kids · Home · Health · Notifications
Garage (vehicle) ↔ Find (live / park)
Sports (match day) → News → Notifications
Travel (trip) → Find pins · Home (away) · Pet · Finance
Games (wishlist) → Finance
Documents, Notifications, Search, Calendar merge across every Life Domain.
```

---

## 2. Layered architecture

```
┌──────────────────────────────────────────────────────────────────┐
│  Life Domains (Garage, Health, Kids, Finance, Home, Travel, …)   │
│  Industry Domains (Hospital, Airport, Factory, …)                 │
│  Only domain features — never own identity / calendar / AI OS     │
└────────────────────────────┬─────────────────────────────────────┘
                             │ publish / subscribe / secure APIs
┌────────────────────────────┴─────────────────────────────────────┐
│                    after_ecosystem                                │
│  After ID · After+ · Event bus · Product APIs · Shared services   │
│  Ecosystem AI context · Consumer↔Enterprise bridge                │
└───────────────┬────────────────────────────┬─────────────────────┘
                │                            │
     ┌──────────┴──────────┐      ┌──────────┴──────────┐
     │   after_consumer    │      │  after_enterprise   │
     └──────────┬──────────┘      └──────────┬──────────┘
                │                            │
                └────────────┬───────────────┘
                             │
              ┌──────────────┴──────────────┐
              │ after_core · after_ai · DS  │
              └─────────────────────────────┘
```

Scale invariant: adding SuperKids / SuperFood / SuperMunicipality **does not**
change this diagram — only a new module box appears on the top layer.

---

## 3. Shared ecosystem services (mandatory)

Every product — consumer or enterprise — consumes these ports. Products
do **not** ship private replacements.

| Service | Responsibility |
|---------|----------------|
| **After ID** | Single account / SSO session across modules |
| **After+ Subscription** | Unified entitlement (maps to `AfterUserPlan` / store billing) |
| **After AI** | One assistant with **ecosystem context** (cross-module graph) |
| **After Cloud** | Sync, backup, device presence |
| **After Calendar** | Merged events from every module |
| **After Notification Center** | Central inbox + push routing |
| **After Search** | Federated search across every module |
| **After Wallet** | Payments, cards, receipts, payouts |
| **After Family** | Household graph, roles, shared spaces |
| **After Marketplace** | Extensions, plugins, vertical add-ons |
| **After Documents** | Shared vault across every module |
| **After Analytics** | Cross-product funnels (PII-safe) |
| **After Settings** | Global prefs (theme, locale, privacy) |
| **After Personalization** | Preferences, recommendations, home layout |

Vertical apps may **contribute** data (calendar events, search indexes,
documents, notifications) — they never own the center of gravity.

---

## 4. Event-driven fabric

### Bus

`AfterEventBus` — publish / subscribe. In-memory for scaffolds; real
deployments bind Kafka / PubSub / Supabase Realtime / etc.

### Event envelope

```json
{
  "id": "evt_…",
  "type": "garage.maintenance.completed",
  "sourceProductId": "super_garage",
  "afterId": "aid_…",
  "organizationId": null,
  "occurredAt": "2026-07-19T20:00:00Z",
  "correlationId": "corr_…",
  "payload": { }
}
```

### Canonical event families (extensible)

| Family | Examples |
|--------|----------|
| `garage.*` | `vehicle.added`, `maintenance.scheduled`, `maintenance.completed` |
| `finance.*` | `expense.recorded`, `budget.threshold` |
| `calendar.*` | `event.created`, `event.updated` |
| `travel.*` | `trip.planned`, `flight.changed` |
| `health.*` | `vitals.logged`, `appointment.due` |
| `family.*` | `member.joined`, `chore.assigned` |
| `documents.*` | `document.shared`, `document.updated` |
| `notifications.*` | `notification.posted` |
| `enterprise.*` | `workflow.transitioned`, `task.completed` |

Subscribers react **asynchronously**. Garage does not import Finance —
Finance listens to `garage.maintenance.completed` and may create an
expense or calendar block.

---

## 5. Cross-product APIs

Every product registers an **`AfterProductApi`** descriptor:

- `productId` (e.g. `super_garage`)
- `line` (`consumer` | `enterprise`)
- `endpoints` — stable method names + schemas
- `scopes` — OAuth-style / After ID scopes required

`AfterProductApiRegistry` routes calls. Enterprise → consumer and
consumer → enterprise go through **`AfterSecureInteropBridge`**:

1. After ID audience check  
2. Scope / RBAC / org membership  
3. Audit log entry  
4. Optional data minimization  

No product calls another product’s private database.

---

## 6. Ecosystem AI context

`AfterEcosystemAiContext` aggregates:

- After ID profile  
- Active modules the user uses  
- Recent ecosystem events (correlation window)  
- Open calendar / tasks / documents summaries  
- Family / org graph (as permitted)  

AfterAI (`after_ai`) receives this context so the assistant can answer:

> “You have a brake service due Friday; Finance shows spare budget;
> Calendar is free Saturday morning; Family share can notify your spouse.”

Products enable/disable AI **capabilities**; they do not ship a private
assistant that is blind to the ecosystem.

---

## 7. UX contract — one ecosystem

| Surface | Behavior |
|---------|----------|
| Account | After ID sign-in looks the same everywhere |
| Subscription | After+ badge / paywall from shared entitlement |
| AI entry | Same Mate surface; module-aware tools |
| Search | Federated hits tagged by module |
| Calendar | Merged timeline |
| Notifications | Single Notification Center |
| Documents | Shared vault; per-module filters |
| Navigation | Deep links feel like module switches, not app launches |

Deep links use `after://{module}/…` (see `AfterDeepLinkService`).

---

## 8. Consumer + Enterprise

| Line | Extra OS | Ecosystem role |
|------|----------|----------------|
| Consumer | `after_consumer` | Everyday life modules |
| Enterprise | `after_enterprise` | Work / org modules + workflows |

Both lines **must**:

- Use After ID  
- Publish/subscribe ecosystem events  
- Register product APIs  
- Contribute to Calendar / Search / Documents / Notifications  
- Honor After+ where features are gated  

Enterprise may publish `organizationId`-scoped events; consumer
subscribers only receive what policy allows.

---

## 9. Product obligations (checklist)

A product is ecosystem-compliant when it:

1. Overrides `afterEcosystemProvider` (or uses default mock fabric)  
2. Signs in via After ID (not a private auth silo)  
3. Registers its `AfterProductApi` at bootstrap  
4. Publishes domain events on mutations  
5. Subscribes to events it cares about (or declares none)  
6. Contributes search indexes / calendar sources / document namespaces  
7. Uses After Notification Center for user-visible alerts  
8. Passes AI context through `AfterEcosystemAiContext` when calling AfterAI  

---

## 10. Long-term objective

An **AI Operating System for everyday life and professional work** —
hundreds of interconnected products, one identity, one subscription,
one intelligent assistant, event-driven and service-oriented, generated
from the Product Factory onto this ecosystem fabric.

---

## Related

- Package API: `packages/after_ecosystem`  
- Engines: Dashboard · Workflow · Plugins · AfterAI  
- Factory: [`PRODUCT_FACTORY.md`](PRODUCT_FACTORY.md)  
