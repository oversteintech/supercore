# Super App Family — Feature Matrix & Elevation Plan

**Status:** Binding product + architecture companion  
**Date:** 2026-07-20  
**Reference:** SuperGarage (flagship) · Platform Standard v1 · ADR-001 / ADR-019  
**Audience:** Product + engineering elevating POC siblings to Garage-family depth

---

## Family non-negotiables (every Super App)

| Layer | Requirement |
|-------|-------------|
| Identity | `com.overstein.<appid>` (never `com.afterartificial.*`) |
| Membership | Same After+ / `AfterUserPlan` surface as Garage/Sports (`MembershipController` + prefs) |
| Theme | `AfterThemeData` chrome; **product accent only** |
| Shell | Splash → AuthGate → MainShell (lazy tabs); **no go_router** |
| Dashboard | Mandatory Home tab with priority-sorted sections |
| Features | Domain entities support **create · edit · delete** (mutable mock → real ports later) |
| Deps | Consumer: `after_core` + `after_design_system` (+ `after_ecosystem`/`after_ai` when Hub-ready). Enterprise: + `after_enterprise` |

---

## Maturity today

| App | Line | Bundle today | Maturity | Notes |
|-----|------|--------------|----------|-------|
| SuperGarage | consumer | `com.overstein.supergarage` | **Shipping** | Flagship CRUD + Drift/Firebase |
| SuperSports | consumer | `com.overstein.supersports` | Skeleton+ | Correct ID; needs CRUD depth |
| SuperHealth | consumer | `com.afterartificial.*` | POC | Elevate first among twins |
| SuperFinance | consumer | `com.afterartificial.*` | POC | Twin of Health |
| SuperHome | consumer | `com.afterartificial.*` | POC | Twin |
| SuperNews | consumer | `com.afterartificial.*` | POC | Twin; feed UX |
| SuperTravel | consumer | `com.afterartificial.*` | POC | Twin |
| SuperPet | consumer | `com.afterartificial.*` | POC | Twin |
| SuperHospital | enterprise | `com.overstein.superhospital` | Scaffold | Placeholders → CRUD |
| SuperAgriculture / Farm | enterprise | planned | Docs only | Generate after Hospital pattern |

---

## Product feature matrix (PM view)

### SuperGarage (reference — do not regress)

Vehicles, drivers, maintenance, fuel, expenses, documents, insurance, OBD/live, trips, community, Mate AI, membership, dashboard heroes.

### SuperHealth — Personal health OS

| Feature | Priority | CRUD | Dashboard tile | Plan gate |
|---------|----------|------|----------------|-----------|
| Medications | P0 | Y | Next dose | free |
| Vitals | P0 | Y | Latest vitals | free |
| Appointments / doctor visits | P0 | Y | Upcoming | free |
| Weight / heart rate / sleep | P1 | Y | Trends | free/premium |
| Lab results / medical records | P1 | Y | Recent labs | premium |
| Vaccinations | P1 | Y | Due vaccines | free |
| Nutrition | P1 | Y | Today macros | premium |
| Emergency card | P0 | edit | Quick access | free |
| Wellness insights | P2 | read+refresh | AI insight | super |
| Mate / assistant | P1 | chat | FAB | free |

### SuperFinance — Personal money OS

| Feature | Priority | CRUD | Dashboard tile |
|---------|----------|------|----------------|
| Accounts | P0 | Y | Net worth |
| Income / Expenses | P0 | Y | Cashflow |
| Budgets | P0 | Y | Budget health |
| Cards | P1 | Y | Card spend |
| Subscriptions | P1 | Y | Recurring burn |
| Investments | P1 | Y | Portfolio |
| Loans / Insurance | P2 | Y | Liabilities |
| Reports | P2 | generate | Month summary |

### SuperHome — Household OS

| Feature | Priority | CRUD | Dashboard tile |
|---------|----------|------|----------------|
| Properties | P0 | Y | Active home |
| Maintenance | P0 | Y | Due tasks |
| Bills / utilities | P0 | Y | Upcoming bills |
| Appliances / warranty | P1 | Y | Expiring warranty |
| Inventory | P1 | Y | Rooms |
| Cleaning schedule | P1 | Y | Today chores |
| Security / smart home | P2 | Y | Status |

### SuperPet — Pet life OS

| Feature | Priority | CRUD | Dashboard tile |
|---------|----------|------|----------------|
| Pets | P0 | Y | Active pet hero |
| Vet / appointments | P0 | Y | Next visit |
| Vaccinations | P0 | Y | Due shots |
| Food / weight | P1 | Y | Feeding |
| Medical history / docs / insurance | P1 | Y | Alerts |

### SuperTravel — Trip OS

| Feature | Priority | CRUD | Dashboard tile |
|---------|----------|------|----------------|
| Trips | P0 | Y | Next trip |
| Flights / hotels | P0 | Y | Itinerary |
| Packing | P1 | Y | Pack % |
| Expenses / documents | P1 | Y | Trip spend |
| Passport / visa | P1 | Y | Expiry |

### SuperSports — Training OS

| Feature | Priority | CRUD | Dashboard tile |
|---------|----------|------|----------------|
| Workouts | P0 | Y | This week |
| Exercises | P0 | Y | Library |
| Training plans | P0 | Y | Active plan |
| Running / cycling | P1 | Y | Last activity |
| Measurements / nutrition | P1 | Y | Body metrics |
| Challenges / progress | P2 | Y | Streak |

### SuperNews — Information OS

| Feature | Priority | CRUD* | Dashboard tile |
|---------|----------|------|----------------|
| Feed / breaking / trending | P0 | consume | Top stories |
| Bookmarks / read later | P0 | Y | Saved |
| Categories / personalized | P1 | prefs | For you |
| AI summary | P1 | generate | Briefing |

\*News “CRUD” = bookmarks, preferences, saved searches — not inventing journalism CMS.

### SuperHospital — Enterprise ops (reference vertical)

| Feature | Priority | CRUD | Notes |
|---------|----------|------|-------|
| Patients | P0 | Y | Org-scoped |
| Appointments | P0 | Y | Bridge → ecosystem calendar |
| Tasks / wards / staff | P0 | Y | RBAC |
| Clinical notes / labs / pharmacy | P1 | Y | Audit |
| Billing / compliance | P1 | Y | Enterprise |
| Dashboard | P0 | widgets | Mandatory |

### SuperAgriculture / SuperFarm (generate next)

Fields, crops, herds, equipment, harvest, weather alerts, compliance — enterprise template from Hospital.

---

## Architecture elevation recipe (per app)

1. Fix bundle → `com.overstein.<appid>` (Android + iOS + manifest).
2. Keep membership controller identical shape (Sports/Health already correct).
3. Theme: `AfterThemeData.*(accentOverride: productAccent)` only.
4. Replace read-only mock lists with **mutable in-memory** seed + `upsert` / `delete` on repository port.
5. Every feature screen: FAB add · tap edit · confirm delete; invalidate providers.
6. Dashboard sections must read live repository state (not static copy).
7. Tests: repository CRUD unit + one widget smoke per P0 feature.
8. `docs/COMPLIANCE_REPORT.md` until skeleton 100%.

**Defer (honest):** Firebase/Drift/IAP/maps/BLE, full 20-locale, full Mate orchestrator.

---

## Execution order

1. SuperHealth (template for consumer twins)  
2. SuperSports (CRUD depth)  
3. SuperFinance · SuperHome · SuperPet (clone Health CRUD pattern)  
4. SuperTravel · SuperNews  
5. SuperHospital (patients/appointments/tasks)  
6. Generate SuperAgriculture skeleton from enterprise factory  

APK install / store flavors: later.
