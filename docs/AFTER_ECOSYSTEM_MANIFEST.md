# AfterArtificial Ecosystem Manifest v2.0

> **AfterArtificial is an AI Product Platform that generates consumer and
> enterprise software from a unified architecture.**

**Master Vision (superseding):** [`AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md`](AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md) (v2.0)

You are no longer building individual applications.

You are designing the complete **AfterArtificial Ecosystem** — an
AI-powered **Digital Operating System**.

Applications are not standalone products.

Every application is a **Life Domain or Industry Domain module** inside
one intelligent ecosystem. Domains own a slice of life or industry, but
communicate seamlessly through the shared fabric.

The user should never feel like switching between different apps.

Instead, every app should behave as another **window into the same
platform**.

**Platform-first:** prefer shared `after_*` capabilities over
app-specific code whenever reasonable.

**Life Domains:** [`LIFE_DOMAINS.md`](LIFE_DOMAINS.md) ·
**Roadmap:** [`LIFE_DOMAIN_ROADMAP.md`](LIFE_DOMAIN_ROADMAP.md) ·
**Alignment:** [`MASTER_VISION_ALIGNMENT_2026.md`](MASTER_VISION_ALIGNMENT_2026.md)

---

## Core philosophy

| One… | Meaning |
|------|---------|
| **One Identity** | After ID — single account across every module |
| **One AI** | One assistant; every product extends the same AI |
| **One Cloud** | Shared storage, documents, media, files |
| **One Subscription** | After+ — unified entitlement |
| **One Family** | Shared members, permissions, assets |
| **One Calendar** | Unified events, schedules, appointments, tasks |
| **One Wallet** | Payments, subscriptions, invoices, digital cards |
| **One Notification Center** | Centralized alerts across every module |
| **One Search** | Global search across every application |
| **One Marketplace** | Services, partners, bookings, commerce |
| **One Design Language** | `after_design_system` — identical family feel |
| **One Engineering Standard** | AAPS layering, ports, CI, compliance gate |
| **One Documents Library** | Shared vault; SuperDocuments = consumer UX |
| **One API Platform** | Product APIs + secure interop |
| **One Event Bus** | Durable cross-app events |
| **One Data Platform** | Shared schemas, analytics, flags, RC |
| **One Ecosystem** | Consumer + enterprise modules of one OS |

---

## Consumer Life Domains

| Product | Life Domain |
|---------|-------------|
| **SuperGarage** | Mobility (flagship consumer reference) |
| SuperHealth | Personal health |
| SuperKids | Family & parenting |
| SuperFinance | Personal finance |
| SuperHome | Property & household |
| SuperTravel | Travel |
| SuperPet | Pets |
| SuperNews | Information |
| SuperSports | Sport & performance (fitness **and** live sports) |
| SuperGames | Gaming |
| SuperFind | Presence, safety & asset awareness |
| SuperDocuments | Documents (UX over One Documents Library) |
| SuperAI | Hub AI capability branding (ADR-019 — not a peer entry app) |

**After Hub** is the consumer OS shell (not a Life Domain). See
[`AFTER_HUB.md`](AFTER_HUB.md) · ADR-019.

Future Life Domains **must inherit the same architecture automatically**
via the Product Factory + `after_consumer` + `after_ecosystem`.

---

## Enterprise Industry Domains

| Product | Role |
|---------|------|
| **SuperHospital** | Flagship enterprise reference |
| SuperAirport | |
| SuperMaritime | |
| SuperFactory | |
| SuperConstruction | |
| SuperRetail | |
| SuperEducation | *(alias SuperSchool)* |
| SuperHotel | |
| SuperRestaurant | |
| SuperLogistics | |
| SuperEnergy | |
| SuperMunicipality | |
| SuperFarm | *(alias SuperAgriculture)* |

Future Industry Domains **must inherit the same architecture
automatically** via the Product Factory + `after_enterprise` +
`after_ecosystem`.

---

## Shared platform services

| Service | Responsibilities |
|---------|------------------|
| **After ID** | Auth · AuthZ · Organizations · Family · Roles · Permissions · Teams |
| **After+** | Unified subscription · Billing · Wallet ledger · Invoices · Payments · Coupons |
| **After AI** | Conversation · Vision · OCR · STT/TTS · Translation · Recommendations · Automation · Summaries · KB · Semantic search · Decision support · Predictive · Context memory · Cross-app intelligence |
| **After Cloud** | Documents · Media · Secure storage · Sync · Backups · Offline |
| **After Calendar** | Tasks · Schedules · Appointments · Reminders · Events · Recurring · Shared |
| **After Notifications** | Push · Email · SMS · In-app · Emergency · Scheduled · Smart |
| **After Search** | Global · Cross-app · Semantic · AI search |
| **After Marketplace** | Products · Services · Partners · Bookings · Commerce |
| **After Analytics** | User · Business · AI analytics · Crash · Remote Config · Feature Flags |
| **After Automation** | Workflow · Triggers · Actions · Rules · Cross-app events |
| **After Settings** | Global preferences · Theme · Language · Privacy · Devices |

Implementation: [`packages/after_ecosystem`](../packages/after_ecosystem) (+ line OS).  
Gaps: [`MASTER_VISION_ALIGNMENT_2026.md`](MASTER_VISION_ALIGNMENT_2026.md).  
Architecture: [`AFTER_ECOSYSTEM_PLATFORM.md`](AFTER_ECOSYSTEM_PLATFORM.md).

---

## AI principles

There is only **ONE AI assistant**.

Every application extends the capabilities of the same AI.

The AI always has **permission-aware contextual knowledge** across the
ecosystem.

### Influence examples (Life Domains)

| From | Influences |
|------|------------|
| Garage (maintenance) | Finance · Calendar |
| Kids (vaccine / school) | Health · Calendar · Notifications |
| Find (presence / SOS / Safe Zone) | Kids · Home · Garage · Health · Notifications |
| Sports (match day / injury risk) | News · Health · Kids |
| Travel (trip) | Find · Home · Pet · Finance · Garage |
| Games (wishlist purchase) | Finance · News |
| Hospital | SuperHealth *(secure exchange)* |
| Airport | SuperTravel *(schedules)* |
| School (enterprise) | SuperKids · SuperFind *(campus Safe Zones)* |

The AI should **proactively** connect information between products
whenever it improves the user experience.

Capability platform: [`AFTER_AI_PLATFORM.md`](AFTER_AI_PLATFORM.md).  
Ecosystem context: `AfterEcosystemAiContext`.

---

## Architecture

Every application must reuse **at least 90%** of the platform.

Applications should define only:

1. Business Domain  
2. Feature Modules  
3. Navigation  
4. Permissions  
5. AI Skills  
6. Dashboard Widgets  

Everything else must be **inherited automatically**.

- No duplicated code  
- No duplicated business logic  
- No duplicated infrastructure  

Doctrine: [`PLATFORM_DOCTRINE.md`](PLATFORM_DOCTRINE.md).  
Factory: [`PRODUCT_FACTORY.md`](PRODUCT_FACTORY.md).

---

## Communication

Applications communicate through **events**.

- Every application **publishes** domain events.  
- Every application **subscribes** to relevant ecosystem events.  

The ecosystem should behave like a **distributed operating system**.

Fabric: `AfterEventBus` · `AfterProductApiRegistry` ·
`AfterSecureInteropBridge` (consumer ↔ enterprise).

---

## Design principles

Every application must feel like a member of the same family.

Shared:

- Typography  
- Spacing  
- Icons  
- Animations  
- Components  
- Navigation  
- Accessibility  
- Dark Mode  
- Motion Language  
- Brand Identity  

Package: `after_design_system`. Accent + monogram are the only product
visual knobs.

---

## Long-term objective

The objective is **NOT** to build applications.

The objective is to build the world's most scalable **AI Product
Platform**.

The platform should scale to **≥100** applications now and **hundreds**
long-term — consumer Life Domains and enterprise Industry Domains — from
one shared architecture.

Every new application should require **minimal engineering effort**
while preserving the highest quality standards.

| Line | Flagship |
|------|----------|
| Consumer | **SuperGarage** |
| Enterprise | **SuperHospital** |

**Every future product must follow this manifesto without exception.**

---

## Non-negotiable compliance

1. Product Factory generation from `product.spec.yaml`  
2. Mount `after_ecosystem` (After ID, After+, events, shared services)  
3. Mount line OS (`after_consumer` or `after_enterprise`)  
4. AfterAI only via `after_ai` + ecosystem context  
5. Design system only via `after_design_system`  
6. ≥90% platform reuse — `scripts/check_reuse_contract.ps1`  
7. Flagship compliance gate vs SuperGarage / SuperHospital  

**Technical ADRs apply:** see [`ARCHITECTURE_REVIEW_2026.md`](ARCHITECTURE_REVIEW_2026.md) and [`adr/`](adr/) (ADR-001 … ADR-010). Manifest obligations are binding law; ADRs are binding implementation decisions.

Version: **2.0** · Owner: AfterArtificial / Overstein Labs · Master Vision v2.0
