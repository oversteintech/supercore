# AfterArtificial Life Domains

> **Applications are windows into Life Domains — not isolated products.**

**Master Vision v2.0:** [`AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md`](AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md)

The AfterArtificial Ecosystem is organized around **Life Domains**. Each
Super App **owns one domain**, but every app communicates with every other
app through the shared fabric (`after_ecosystem`): After ID, After+, After AI,
events, calendar, notifications, search, documents, family, wallet.

```
Ayhan Uzundal
  → AfterArtificial (AI Product Platform)
      → After Hub (OS shell — entry; not a Life Domain)
      → Life Domain modules (SuperGarage, SuperHealth, SuperKids, …)
      → Industry Domain modules (SuperHospital, SuperAirport, …)
  → Powered by After Framework / After OS / AfterAI
  → Built by Overstein Labs
```

The user never “switches apps.” They navigate **domains of one OS** via
**After Hub** ([`AFTER_HUB.md`](AFTER_HUB.md), ADR-019).

---

## Admission filter (binding)

Applications are **not** named at random (`Super…` for its own sake).

**Rule:** every consumer Super App must represent a **permanent life area**
that people manage for years — not a temporary feature, gimmick, or
narrow utility.

Before adding a product, ask:

> “Is this a fundamental life domain people manage for years?”

| Answer | Action |
|--------|--------|
| **Yes** | Eligible as a Life Domain Super App (factory + catalog) |
| **No** | Keep it as a **feature** (or skill/widget) inside an existing domain |

### Locked consumer core (Phase A)

These pass the filter and form the coherent consumer spine:

SuperGarage · SuperHealth · SuperKids · SuperFinance · SuperHome ·
SuperTravel · SuperPet · SuperSports · SuperNews · SuperGames ·
SuperFind · SuperDocuments

*(SuperAI = Hub AI surface branding — not a separate Life Domain app.)*

Examples that usually **fail** the filter (prefer features, not apps):
receipt scanner → SuperFinance; car wash booking → SuperGarage;
one-off quiz → SuperKids / SuperLearning feature; fantasy-only shell →
SuperSports pillar.

Enterprise products use the parallel filter: a lasting **industry
operating domain** (hospital, airport, factory…), not a single workflow.

---

## Consumer Life Domains

| Product | Life Domain | Owns |
|---------|-------------|------|
| **SuperGarage** | Mobility | Vehicles, maintenance, insurance, fuel, OBD, fleet, transportation |
| **SuperHealth** | Personal health | Medications, medical records, sleep, nutrition, doctors, labs, AI health assistant |
| **SuperKids** | Family & parenting | Pregnancy → newborn → child → teen → parents (see below) |
| **SuperFinance** | Personal finance | Subscriptions, investments, budgets, banking, AI financial assistant |
| **SuperHome** | Property & household | Maintenance, utilities, warranties, smart home, documents |
| **SuperTravel** | Travel | Trips, flights, hotels, visas, passports, itineraries, AI travel planning |
| **SuperPet** | Pets | Vet care, food, health records, AI pet assistant |
| **SuperNews** | Information | AI-personalized news, summaries, recommendations |
| **SuperSports** | Sport & performance | Fitness **and** live sports intelligence (see below) |
| **SuperGames** | Gaming | Library, achievements, store integrations, communities, AI recommendations |
| **SuperFind** | Presence, safety & assets | People, family, children, friends, pets, vehicles, devices, places, shared assets |
| **SuperDocuments** | Documents | Identity, legal, vehicle, insurance, OCR, expirations *(UX over One Documents Library)* |
| **SuperAI** | Hub AI branding | One After AI via After Hub AI tab — never a second runtime or peer entry app |

### SuperFind (presence & safety — not location-sharing only)

Intelligent location, presence, safety, and asset awareness hub:

- Real-time / temporary / family sharing · Safe Zones · SOS · ETA  
- History · AI timeline · route playback · privacy-first E2EE when possible  
- Battery-aware tracking · Android / iOS / Huawei / Web  

Owns **presence truth**; peers (Kids, Garage, Pet, Travel, Home, Health,
Finance) consume via events — they do not ship private location stacks.
Full spec: [`domains/SUPER_FIND_DOMAIN.md`](domains/SUPER_FIND_DOMAIN.md).

### SuperKids (family & parenting)

Support pregnancy, newborns, children, teenagers, and parents:

- Pregnancy tracking · Baby development · Child growth  
- Vaccination schedules · Medical appointments · School activities  
- Family calendar · Parenting AI · Nutrition · Sleep  
- Education milestones · Family tasks · Allowances  
- Shared memories · Emergency information  
- Shopping lists · child-safety UX (presence via **SuperFind**, not a second stack)

Cross-domain: Health (vaccines/appointments), Finance (allowances), Calendar
(family), Home (shopping), Travel (family trips), Garage (school runs),
**SuperFind** (child / school presence, SOS).

### SuperSports (not fitness-only)

Combines **personal performance** and **live sports intelligence**:

| Pillar | Capabilities |
|--------|----------------|
| Fitness OS | Workouts, running, cycling, nutrition, health metrics, sports communities |
| Live sports | Live scores, fixtures, league tables, player stats, transfers |
| Fandom | Favorite teams, match notifications, fantasy features |
| AI | Match analysis, match summaries, sports assistant |

Feels like Apple Fitness + Strava + SofaScore + a modern sports intelligence
layer — one domain, one AI context.

### SuperGames

Game library · Achievements · Steam / Epic / console tracking · Wishlist ·
Gaming news · Communities · AI recommendations.

---

## Enterprise Industry Domains

Industry-specific platforms on the same OS (reference: **SuperHospital**):

SuperHospital · SuperAirport · SuperMaritime · SuperFactory ·
SuperConstruction · SuperRetail · SuperEducation · SuperHotel ·
SuperRestaurant · SuperLogistics · SuperEnergy · SuperMunicipality ·
SuperFarm  

(Plus long-tail: SuperPolice, SuperFire, SuperMining, … · aliases:
SuperSchool→Education, SuperAgriculture→Farm)

Enterprise modules use `EnterpriseScope`, workflows, RBAC, and the same
ecosystem fabric for identity, AI context, and interop.

---

## Cross-domain communication

Products **never** import each other’s Dart packages. They:

1. **Publish** domain events (`AfterEventBus`)  
2. **Subscribe** to relevant ecosystem events  
3. **Invoke** declared product APIs via `AfterSecureInteropBridge`  
4. Contribute to shared calendar / notifications / search / documents  

Example influence graph (soft edges):

```
Kids (vaccine due) → Health → Calendar → Notifications
Find (school arrival) → Kids · Home · Notifications
Find (SOS) → Health · emergency contacts
Garage (vehicle) ↔ Find (live / park / forgotten)
Travel (trip) → Find pins · Home (away) · Pet · Finance
Games (wishlist purchase) → Finance · News (gaming brief)
```

---

## Non-negotiables (scale to 100+ apps)

| One… | Meaning |
|------|---------|
| One Identity | After ID |
| One AI | After AI + ecosystem context |
| One Subscription | After+ |
| One Cloud | After Cloud |
| One Design Language | `after_design_system` |
| One Engineering Standard | AAPS + Product Factory + ≥90% reuse |

Adding a Life Domain **never** requires a new architecture — only a
`product.spec.yaml` + vertical features + AI skills. See
[`LIFE_DOMAIN_ROADMAP.md`](LIFE_DOMAIN_ROADMAP.md).

Catalog: [`PRODUCT_CATALOG.md`](PRODUCT_CATALOG.md) ·
[`catalog/products.yaml`](../catalog/products.yaml)
