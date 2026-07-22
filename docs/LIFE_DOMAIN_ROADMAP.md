# Life Domain roadmap — 100 apps without architecture changes

**Master Vision v2.0:** [`AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md`](AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md)

## Goal

Scale the AfterArtificial Ecosystem to **≥100 Super Apps** (Life Domains +
Industry Domains) while keeping:

- One Identity · One AI · One Subscription · One Cloud  
- One Design Language · One Engineering Standard  
- ≥90% platform reuse per new product  

**No platform rewrite** is required to add a domain.

---

## How a new Life Domain is added

```
0. Admission filter (required):
   “Is this a fundamental life domain people manage for years?”
   YES → continue as Super App
   NO  → ship as a feature of an existing Life Domain instead
1. Choose domain name + one-line ownership boundary
2. Write product.spec.yaml (locales ≥20, features, nav, AI skills)
3. generate_product.ps1  → thin shell on after_ecosystem + line OS
4. Implement only lib/features/<domain>/
5. Publish domain events + register Product API endpoints
6. Register AI skills that extend After AI (never a private assistant)
7. Compliance gate vs SuperGarage / SuperHospital flagship
8. Ship — architecture unchanged
```

Forbidden when adding a domain:

- Naming a product `Super…` without passing the admission filter  
- New auth stack, new design system, new AI runtime  
- Product-to-product Dart imports  
- Private calendar / notification / search replacements  
- Skipping `after_ecosystem` mount  

Full filter text: [`LIFE_DOMAINS.md`](LIFE_DOMAINS.md) § Admission filter.

---

## Phased product roadmap

### Phase A — Core Life Domains (shipping / scaffold)

| Domain | Product | Status |
|--------|---------|--------|
| Mobility | SuperGarage | shipping (reference) |
| Health | SuperHealth | scaffold |
| Family & parenting | SuperKids | planned → generate next |
| Finance | SuperFinance | scaffold |
| Home | SuperHome | scaffold |
| Travel | SuperTravel | scaffold |
| Pets | SuperPet | scaffold |
| News | SuperNews | scaffold |
| Sport & performance | SuperSports | scaffold (expand live-sports pillar) |
| Gaming | SuperGames | planned / scaffold |
| Presence & safety | SuperFind | planned → core hub |
| Documents | SuperDocuments | planned (UX over One Documents Library) |
| Central AI shell | SuperAI | planned (thin shell over after_ai) |

### Phase B — Adjacent Life Domains (generate from factory)

Only candidates that **pass the admission filter**. If the need is narrow
(e.g. “shopping lists only”), it stays a feature of SuperHome / SuperKids
— not a new Super App.

Examples that *may* pass (still require a clear years-long ownership boundary):

| Domain | Product (example) | Interop highlights |
|--------|-------------------|--------------------|
| Learning | SuperLearning | Kids milestones, Sports coaching |
| Food | SuperFood | Health nutrition, Kids meals, Home shopping |
| Work / career | SuperWork | Calendar, Finance, Travel |
| Legal / admin | SuperLegal | Documents, Municipality interop |
| Shopping | SuperShop | Finance, Home, Kids lists |
| Social / events | SuperSocial | Calendar, Sports, Games |
| Insurance hub | SuperCover | Garage, Health, Home, Travel |
| Climate / sustainability | SuperPlanet | Home energy, Travel carbon |

### Phase C — Industry Domains (enterprise line)

| Product | Status |
|---------|--------|
| SuperHospital | reference scaffold |
| SuperAirport · SuperMaritime · SuperFactory | scaffold |
| SuperConstruction · SuperRetail · **SuperEducation** | planned |
| SuperHotel · SuperRestaurant · SuperLogistics | planned |
| SuperEnergy · SuperMunicipality · **SuperFarm** | planned |
| SuperPolice · SuperFire · SuperMining | long-tail planned |
| Future verticals (clinic chains, campuses, ports, mines, …) | factory |

### Phase D — Long-tail to 100+

Any further Life or Industry domain is a **spec + features** exercise:

- Consumer: `reference: SuperGarage`, `productLine: consumer`  
- Enterprise: `reference: SuperHospital`, `productLine: enterprise`  
- Always mount `after_ecosystem` + `after_ai`  
- Event types under `domain.*` prefixes  
- AI skills registered into the single After AI platform  

Capacity is bounded by **factory + reuse contract**, not by architecture forks.

---

## Architecture invariant (do not break)

```
Product module (≤10%)
    ↓ events / secure APIs only
after_ecosystem (fabric)
    ↓
after_consumer | after_enterprise
    ↓
after_core + after_ai + after_design_system
```

Scale target: **hundreds of modules**, **millions of users**, **thousands of orgs** —
same diagram.

---

## Near-term engineering priorities

1. Generate **SuperKids** from Product Factory; mount family graph + calendar  
2. Generate **SuperFind** scaffold; own presence ports — Kids/Garage consume, never fork GPS stacks  
3. Expand **SuperSports** live-scores / fantasy / AI match modules as vertical features  
4. Flesh **SuperGames** integrations (Steam/Epic) behind ports  
5. Wire ecosystem events: Find ↔ Kids ↔ Garage ↔ Home ↔ Health  
6. Keep hospital-clone generator disabled; only `generate_product.ps1`  

References: [`LIFE_DOMAINS.md`](LIFE_DOMAINS.md) ·
[`PLATFORM_DOCTRINE.md`](PLATFORM_DOCTRINE.md) ·
[`AFTER_ECOSYSTEM_MANIFEST.md`](AFTER_ECOSYSTEM_MANIFEST.md)
