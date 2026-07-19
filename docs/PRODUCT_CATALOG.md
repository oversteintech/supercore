# AfterArtificial product catalog

Human-readable mirror of [`catalog/products.yaml`](../catalog/products.yaml).

**Master Vision v2.0:** [`AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md`](AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md)  
**Life Domains:** [`LIFE_DOMAINS.md`](LIFE_DOMAINS.md) ·
**Roadmap:** [`LIFE_DOMAIN_ROADMAP.md`](LIFE_DOMAIN_ROADMAP.md) ·
**Alignment:** [`MASTER_VISION_ALIGNMENT_2026.md`](MASTER_VISION_ALIGNMENT_2026.md)

Products are **Life Domain** (consumer) or **Industry Domain** (enterprise)
modules of one Digital OS — not isolated applications.

## Consumer OS shell

| Product | Role | Package | Bundle | Status |
|---------|------|---------|--------|--------|
| **After Hub** | `os_shell` — Digital OS entry | `after_hub` | `com.overstein.afterhub` | planned |

Spec: [`AFTER_HUB.md`](AFTER_HUB.md) · ADR-019. Super Apps contribute `spec.hub` widgets.

## Consumer Life Domains

| Product | Life Domain | Package | Bundle | Status |
|---------|-------------|---------|--------|--------|
| **SuperGarage** _(reference)_ | Mobility | `super_garage` | `com.overstein.supergarage` | shipping |
| SuperHealth | Personal health | `super_health` | `com.overstein.superhealth` | scaffold |
| SuperKids | Family & parenting | `super_kids` | `com.overstein.superkids` | planned |
| SuperFinance | Personal finance | `super_finance` | `com.overstein.superfinance` | scaffold |
| SuperHome | Property & household | `super_home` | `com.overstein.superhome` | scaffold |
| SuperTravel | Travel | `super_travel` | `com.overstein.supertravel` | scaffold |
| SuperPet | Pets | `super_pet` | `com.overstein.superpet` | scaffold |
| SuperSports | Sport & performance | `super_sports` | `com.overstein.supersports` | scaffold |
| SuperNews | Information | `super_news` | `com.overstein.supernews` | scaffold |
| SuperGames | Gaming | `super_games` | `com.overstein.supergames` | planned |
| SuperFind | Presence, safety & assets | `super_find` | `com.overstein.superfind` | planned |
| SuperDocuments | Documents (UX over One Library) | `super_documents` | `com.overstein.superdocuments` | planned |
| SuperAI | Hub AI branding → After Hub | `super_ai` | `com.overstein.superai` | planned |

### Domain briefs
- Vision: [`AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md`](AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md)  
- Hub: [`AFTER_HUB.md`](AFTER_HUB.md) · [`domains/AFTER_HUB_SHELL.md`](domains/AFTER_HUB_SHELL.md)  
- Find: [`domains/SUPER_FIND_DOMAIN.md`](domains/SUPER_FIND_DOMAIN.md)  
- Documents: [`domains/SUPER_DOCUMENTS_DOMAIN.md`](domains/SUPER_DOCUMENTS_DOMAIN.md)  
- AI: [`domains/SUPER_AI_DOMAIN.md`](domains/SUPER_AI_DOMAIN.md) *(Hub AI surface)*  
- Sports: [`domains/SUPER_SPORTS_DOMAIN.md`](domains/SUPER_SPORTS_DOMAIN.md)  
- Games: [`domains/SUPER_GAMES_DOMAIN.md`](domains/SUPER_GAMES_DOMAIN.md)  
- Kids: [`domains/SUPER_KIDS_DOMAIN.md`](domains/SUPER_KIDS_DOMAIN.md)  

### Adjacent (admission filter)
SuperLearning · SuperFood · SuperWork · SuperShop · … — only if a
years-long life domain; else a feature of the core.

> **SuperFamily** → **SuperKids**. Family graph = `AfterFamilyGraph`.

## Enterprise Industry Domains

| Product | Package | Bundle | Status |
|---------|---------|--------|--------|
| **SuperHospital** _(reference)_ | `super_hospital` | `com.overstein.superhospital` | scaffold |
| SuperAirport | `super_airport` | `com.overstein.superairport` | scaffold |
| SuperMaritime | `super_maritime` | `com.overstein.supermaritime` | scaffold |
| SuperFactory | `super_factory` | `com.overstein.superfactory` | scaffold |
| SuperConstruction | `super_construction` | `com.overstein.superconstruction` | planned |
| SuperRetail | `super_retail` | `com.overstein.superretail` | planned |
| **SuperEducation** _(alias SuperSchool)_ | `super_education` | `com.overstein.supereducation` | planned |
| SuperHotel | `super_hotel` | `com.overstein.superhotel` | planned |
| SuperRestaurant | `super_restaurant` | `com.overstein.superrestaurant` | planned |
| SuperLogistics | `super_logistics` | `com.overstein.superlogistics` | planned |
| SuperEnergy | `super_energy` | `com.overstein.superenergy` | planned |
| SuperMunicipality | `super_municipality` | `com.overstein.supermunicipality` | planned |
| **SuperFarm** _(alias SuperAgriculture)_ | `super_farm` | `com.overstein.superfarm` | planned |
| SuperPolice · SuperFire · SuperMining | *(long-tail)* | | planned |

Briefs: [`domains/SUPER_EDUCATION_DOMAIN.md`](domains/SUPER_EDUCATION_DOMAIN.md) ·
[`domains/SUPER_FARM_DOMAIN.md`](domains/SUPER_FARM_DOMAIN.md)

Stack: `after_ecosystem` + `after_ai` + (`after_consumer` \| `after_enterprise`) +
`after_core` + `after_design_system`.
