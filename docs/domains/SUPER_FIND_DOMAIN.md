# SuperFind — Presence, safety & asset awareness Life Domain

> **Not only location sharing.** SuperFind is the intelligent location,
> presence, safety, and asset-awareness platform of the AfterArtificial
> ecosystem — the central hub for finding and monitoring people, pets,
> vehicles, devices, places, and shared assets.

**Admission filter:** ✅ Permanent life domain — families and individuals
manage presence, safety, and “where is X?” for years.

**Package:** `super_find` · **Bundle:** `com.overstein.superfind` ·
**Support:** `superfind@overstein.com`  
**Status:** planned (core Life Domain)  
**Platforms:** Android · iOS · Huawei · Web

---

## 1. Product vision

### One-line
Find anyone and anything that matters — privately, intelligently, across
every Super App.

### Positioning
| Competitor class | SuperFind difference |
|------------------|----------------------|
| Find My / Life360 / Google Find Hub | One After ID + ecosystem graph, not a silo |
| Pure GPS trackers | People + pets + vehicles + devices + places + assets |
| SOS-only apps | Continuous presence + AI anomalies + Safe Zones |
| Map apps | Privacy-first sharing + family/enterprise interop |

SuperFind is a **core ecosystem application**: Garage, Kids, Pet, Travel,
Home, Health, and Finance do not invent private location stacks — they
publish/consume presence through SuperFind + `after_ecosystem`.

### Brand hierarchy
```
Ayhan Uzundal → AfterArtificial → SuperFind (Presence & safety Life Domain)
  → Powered by After Framework / After OS / AfterAI
  → Built by Overstein Labs
```

### Experience principles
1. **Privacy-first** — share the minimum; revoke anytime; E2EE when possible  
2. **Battery-aware** — adaptive sampling; never a silent drain  
3. **One map, many kinds** — people, pets, vehicles, devices, places, assets  
4. **One AI** — skills on After AI; no private assistant  
5. **Cross-domain** — events/APIs only; never sibling Dart imports  

---

## 2. What SuperFind owns (hub)

| Entity | Examples |
|--------|----------|
| People | Self, friends (consent-based) |
| Family members | After Family graph roles |
| Children | Caregiver-supervised sharing (with SuperKids) |
| Friends | Temporary or persistent circles |
| Pets | Collars / phone proxy (with SuperPet) |
| Vehicles | Last park, live trip (with SuperGarage) |
| Devices | Phones, tablets, wearables, tags |
| Important places | Home, school, work, custom |
| Shared assets | Keys, bags, luggage tags, shared gear |

**Does not own:** medical diagnosis (Health), parenting content (Kids),
vehicle maintenance logic (Garage), trip booking (Travel). Those domains
own UX; SuperFind owns **presence truth** and **safety signals**.

---

## 3. Feature specification

### 3.1 Core presence & sharing

| Feature | Spec |
|---------|------|
| Real-time location sharing | Live position to authorized After IDs; precision tiers (exact / approx / city) |
| Temporary location sharing | Time-boxed link or circle (minutes → days); auto-expire |
| Permanent family sharing | Family graph members with role-based precision |
| Arrival notifications | Enter place / Safe Zone → push + ecosystem event |
| Departure notifications | Leave place / Safe Zone → push + event |
| Safe Zones (geofencing) | Named polygons/circles; enter/exit rules; quiet hours |
| SOS | One-tap emergency; share live location + contacts; optional audio/note |
| Emergency contacts | Ordered list; cascade notify; works offline-queued |
| ETA prediction | Destination + mode → ETA; update on deviation |
| Location history | User-controlled retention; export/delete |
| AI timeline | Day/week narrative of places & significant moves |
| Route playback | Replay path with speed/stops |
| Offline synchronization | Queue fixes & SOS; sync when online |
| Cross-platform | Android, iOS, Huawei (HMS where needed), Web (map + manage) |
| Privacy controls | Per-recipient, per-entity, precision, schedule, stealth pause |
| Permission management | OS location / background / notifications; in-app consent ledger |
| Battery-aware tracking | Motion/activity adaptive interval; significant-change mode |
| Smart notifications | Deduped, priority (SOS > Safe Zone > ETA); digest mode |

### 3.2 Entity modules (product `lib/features/`)

1. `map_hub` — unified map + entity layers  
2. `circles` — family / friends / temporary share  
3. `safe_zones` — geofence CRUD + rules  
4. `sos` — emergency flow + contacts  
5. `devices` — Find My–class device registry  
6. `places` — important places + recognition  
7. `history` — history, playback, retention  
8. `privacy` — consent ledger, precision, pause  
9. `timeline` — AI timeline UI  
10. `assistant` — Find AI skills (After AI)  

### 3.3 AI features (After AI skills — never a private stack)

| Skill | Behavior |
|-------|----------|
| Predict arrival | ETA from live track + traffic/habits |
| Unusual behavior | Deviations vs habitual places/routes → soft alert |
| Travel summaries | Trip narrative from presence segments |
| Place recognition | Cluster visits → suggest named places |
| Route suggestions | Safer/faster habitual alternatives |
| Emergency detection | Crash/fall/prolonged immobility heuristics → SOS prompt |
| Forgotten vehicle | Vehicle left outside habitual park window |
| Weekly mobility summary | Digest for user / family (permissioned) |

All skills use `AfterEcosystemAiContext` + encrypted presence features —
raw coordinates leave device only under declared policy.

### 3.4 Integration matrix (events / secure APIs)

| Peer | SuperFind contributes | Peer contributes |
|------|----------------------|------------------|
| **SuperGarage** | Vehicle live/park position, trip path | Vehicle identity, trip sessions, maintenance hooks |
| **SuperKids** | Child presence, school Safe Zone, SOS | Caregiver roles, school calendar, consent |
| **SuperPet** | Pet track / last seen | Pet identity, vet appointment places |
| **SuperTravel** | Trip corridor, hotel/airport pins | Itinerary, flight progress |
| **SuperHome** | Home arrival/departure | Home place, automation triggers |
| **SuperHealth** | Emergency location, hospital route pin | Emergency profile, preferred facilities |
| **SuperFinance** | Visited-place segments (opt-in) | Expense categories from travel presence |
| **Any future Super\*** | Presence Product API | Domain entity IDs linked to Find entities |

**Ownership note:** SuperKids “location sharing” is **not** a second stack —
Kids UX deep-links / embeds Find circles; truth lives in SuperFind.

---

## 4. Technical architecture

### 4.1 Product shape (After OS)

```
SuperFind (lib/features/find_*)
        ↓ events / secure Product APIs
after_ecosystem  (After ID, After+, bus, family, notifications, AI context)
        ↓
after_consumer + after_ai
        ↓
after_core + after_design_system
```

Same shell as SuperGarage: splash → AuthGate → MainShell (map-first home).
≥90% platform reuse; product-owned ≤10%.

### 4.2 Layered system

```
┌─────────────────────────────────────────────────────────────┐
│ Clients: Android · iOS · Huawei · Web (Flutter)              │
│  Map Hub · Circles · Safe Zones · SOS · Privacy · Find AI    │
└────────────────────────────┬────────────────────────────────┘
                             │ TLS + optional E2EE payloads
┌────────────────────────────┴────────────────────────────────┐
│ Presence edge                                                │
│  Ingest · authz · rate limit · battery-aware ack             │
└────────────────────────────┬────────────────────────────────┘
                             │
┌───────────────┬────────────┴────────────┬───────────────────┐
│ Live presence │ Geofence & rules engine │ History & timeline│
│ (ephemeral)   │ (enter/exit/SOS)        │ (retention policy)│
└───────┬───────┴────────────┬────────────┴─────────┬─────────┘
        │                    │                      │
        └────────────────────┼──────────────────────┘
                             ▼
              after_ecosystem event bus + Product APIs
              (kids.*, garage.*, home.*, health.*, …)
```

### 4.3 Privacy & encryption

| Control | Approach |
|---------|----------|
| E2EE location sharing | When peer devices can exchange keys (circle members): encrypt lat/lng (+noise) client-side; server stores ciphertext + routing metadata only |
| Server-assisted mode | Explicit opt-in for web/legacy/SOS cascade where E2EE is impossible; clear UI badge |
| Precision tiers | Exact / ~100m / city — applied before encrypt/share |
| Consent ledger | Append-only grants: who, entity, precision, expiry, purpose |
| Data minimization | Live channel ephemeral; history retention user-set (default short) |
| Stealth / pause | Immediate stop of publish; revoke fan-out |
| Legal | Per-jurisdiction disclosure; child accounts follow Kids + platform policy |

### 4.4 Scale (millions of users)

| Concern | Design |
|---------|--------|
| Ingest | Partition by `afterId` / circle; sharded write path |
| Fan-out | Pub/sub per circle; push via After Notifications |
| Geofence | Client-side primary + server verify for critical SOS/Kids |
| History | Cold storage + compaction; query by entity + time |
| Offline | Local queue with idempotency keys (`AfterEcosystemEvent`) |
| Abuse | Rate limits, device attest, report/block |
| Multi-platform | Single Flutter codebase; Huawei location adapter behind port |

### 4.5 Ports (product + platform)

Product-owned ports (interfaces in SuperFind; mocks for scaffold):

- `PresencePublisher` / `PresenceSubscriber`  
- `GeofenceEngine`  
- `SosDispatcher`  
- `LocationHistoryStore`  
- `DeviceRegistry`  
- `PlaceRecognizer`  
- `FindPrivacyPolicy`  

Platform-owned (never reimplemented): After ID, After+, notifications,
family graph, search, calendar, After AI, design system, settings.

### 4.6 Well-known ecosystem events

```
find.presence.updated
find.share.started / find.share.ended
find.safezone.entered / find.safezone.exited
find.sos.triggered / find.sos.resolved
find.eta.updated
find.place.recognized
find.anomaly.detected
find.vehicle.forgotten   → SuperGarage
find.child.school_arrival → SuperKids
find.home.arrival         → SuperHome
find.emergency.location   → SuperHealth
```

---

## 5. Navigation (consumer shell)

| Tab | Role |
|-----|------|
| Map (home) | Unified hub — people / pets / vehicles / devices / places |
| Circles | Family, friends, temporary shares |
| Assistant | Find AI |
| Search | Entities, places, history |
| Profile | Privacy, permissions, battery, retention |

Domain destinations (Safe Zones, SOS, Devices, History) via feature catalog.

---

## 6. Implementation roadmap

### Phase 0 — Spec & foundation (now)
- [x] Domain brief + catalog entry + factory `product.spec.yaml`  
- [ ] Generate scaffold via `generate_product.ps1`  
- [ ] Ports + mocks; Map Hub empty state; privacy ledger UI  

### Phase 1 — MVP presence (8–10 weeks)
- After ID auth + family permanent sharing (exact/approx)  
- Temporary share links with expiry  
- Map Hub (self + circle members)  
- Arrival/departure for Home + School places  
- Basic Safe Zones (circle geofences)  
- Permission + battery-aware foreground/background (mobile)  
- Android + iOS first  

### Phase 2 — Safety & entities (6–8 weeks)
- SOS + emergency contacts + offline queue  
- Vehicles (Garage interop) + Pets (Pet interop)  
- Devices registry (phone + tag placeholders)  
- Location history + route playback  
- Huawei adapter; Web manage + last-known map  

### Phase 3 — Intelligence (6–8 weeks)
- ETA prediction · place recognition · AI timeline  
- Unusual behavior + forgotten vehicle  
- Weekly mobility summary  
- Kids school arrival / Home automations wired  
- E2EE circle sharing (where key exchange available)  

### Phase 4 — Scale & hardening
- Shard ingest · retention policies · abuse controls  
- Enterprise interop (e.g. SuperSchool campus Safe Zones) via bridge  
- Millions-user load tests; privacy audit; store compliance  

### Non-goals (v1)
- Public social map feed  
- Selling location data  
- Replacing SuperKids / SuperGarage UX  
- Always-on high-precision without battery modes  

---

## 7. Success metrics

| Metric | Target direction |
|--------|------------------|
| Circle attach rate | Families link Find within SuperKids onboarding |
| SOS time-to-notify | Seconds to first contact |
| Battery impact | Competitive with Find My / Life360 class |
| E2EE share ratio | Increase over time among capable devices |
| Cross-domain events | Garage/Kids/Home consuming Find without forks |

---

## 8. Compliance & factory

- Manifest / Life Domains / ≥90% reuse  
- Locales: `AfterSupportedLocales` (≥20)  
- Generate: `factory/specs/examples/super_find.product.spec.yaml`  
- Reference: SuperGarage consumer patterns  

Catalog: [`PRODUCT_CATALOG.md`](../PRODUCT_CATALOG.md) ·
Vision: [`LIFE_DOMAINS.md`](../LIFE_DOMAINS.md)
