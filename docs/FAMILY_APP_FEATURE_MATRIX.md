# Family Super App — Feature Matrix & Chrome Contract

**Status:** Binding for POC → Garage-parity skeleton  
**Reference:** SuperGarage  
**Kit:** `after_consumer` (`Family*` primitives)

---

## Mandatory chrome (every Super App)

| Surface | Required | Notes |
|---------|----------|-------|
| Login | Yes | Garage-parity `FamilyLoginScreen` — **Firebase Auth Google** via `after_firebase` (`FirebaseAfterAuthRepository`); PrefsGoogle fallback while `firebase_options` placeholder |
| Register | Yes | Garage-parity `FamilyRegistrationWizardScreen` (5 steps) + optional `FamilyRegistrationPlugin` |
| AuthGate | Yes | No `go_router`; `FamilySessionEffects` restores cloud blob when empty |
| Cloud sync | Yes | **Option A:** `FirestoreAfterUserBlobSync` (`users/{uid}/apps/{appId}/blob/data`) + `FamilyCloudSyncController`; Prefs blob fallback until Firebase configured |
| Profile | Yes | Garage-parity `FamilyProfileScreen` / `FamilyProfileSection` — animated avatar picker, up to 5 profile photos, editable display name / email / username / phone (`FamilyProfileIdentity`) |
| Settings | Yes | Garage-parity `FamilySettingsScreen` — full `AfterThemeStyle` pack, locale, membership, about, sign-out/delete; domain via `FamilySettingsPlugins` |
| Themes | Yes | Shared Garage pack in `after_design_system` (`AfterThemeStyle` + `AfterPremiumAppShell`) |
| Typography | Yes | `AfterTypography.garage` — same sizes/weights/tracking as SuperGarage (`headlineSmall` L1 w900, `titleMedium` L0/L2 w800); `FamilyTheme` / `AfterFrameworkTheme` for every consumer app |
| OVERSTEIN splash | Yes | Shared `OversteinCompanySplash` only — black company intro, no product branding (`after_design_system`) |
| Shell top bar | Yes | Garage-parity `FamilyShellHeader` — short title (`Garage`/`Health`/…), FREE/SILVER/GOLD/… badge + plan header colors |
| About | Yes | App name, version, Overstein, support email |
| AI tab / Mate | Yes | `after_ai` or `FamilyAiChatScreen` |
| Live | Domain-dependent | See Live mapping |
| Dashboard (Home) | Yes | `FamilyDashboardSection` priority sort |
| Membership | Consumer: Free / Silver / Gold / Business (`AfterUserPlan` + `FamilyPlanCatalog` / `FamilyMembershipPlansScreen`) | Hospital: org/RBAC may overlay; Family plan ladder still available in chrome |

Package: `com.overstein.<appid>` (not `com.afterartificial.*`).

---

## Live mapping

| App | Live |
|-----|------|
| SuperSports | Live workout / HR |
| SuperHealth | Live vitals |
| SuperFinance | Live markets |
| SuperNews | Live breaking |
| SuperFarm | Live weather / fields |
| SuperHospital | Ops Live (census) |
| SuperHome | Security / sensors strip or tab |
| SuperPet | Activity strip or tab |
| SuperTravel | Trip day / flight strip |

---

## Domain features (CRUD = add/edit/delete)

### SuperHealth
medications, medicalRecords, doctorVisits, labResults, vaccinations, heartRate, weight, sleep, nutrition, emergencyCard + healthAi

### SuperFinance
accounts, cards, income, expenses, subscriptions, budgets, investments, loans, insurance, reports + financeAi

### SuperHome
properties, maintenance, utilities, bills, appliances, warranty, inventory, cleaning, security, smartHome + homeAi

### SuperPet
pets, vaccinations, veterinary, food, weight, medicalHistory, appointments, insurance, documents + petAi

### SuperTravel
trips, flights, hotels, passport, visa, packing, expenses, documents, timeline + travelAi

### SuperSports
workouts, exercises, trainingPlans, running, cycling, nutrition, bodyMeasurements, progress, challenges + sportsAi

### SuperNews
bookmarks, readLater, categories (follow), notificationPrefs (CRUD); feed/trending/breaking (read + personalize) + aiSummary

### SuperHospital
patients, appointments, wards, staff, clinicalNotes, pharmacy, labOrders, billing, compliance + hospitalAi

### SuperFarm
fields/crops, livestock, equipment, harvests, inventory, tasks, weatherNotes + farmAi

---

## Shared kit (`after_consumer` + `after_design_system`)

- `FamilyScopedListController`
- `showEntityEditorSheet` / `confirmDelete`
- `FamilyDashboardSection` / `sortFamilyDashboardSections`
- `FamilyMembershipController`
- `FamilyChromeConfig` / `FamilyAuthChromeConfig` + Garage-parity Login / Registration / Profile / Settings / About / AI / Live
- `familyPrefsGoogleAuthOverride` / `PrefsGoogleAuthRepository` (CI: `mockGoogleEmailForTests`)
- `FamilyCloudSyncController` + Settings **Sync now**
- `FamilyRegistrationPlugin` / `FamilySettingsPlugins` for domain slots
- `FamilyTheme.forStyle` + `familyThemeStyleProvider`
- `AfterThemeStyle` / `AfterPremiumAppShell` / premium theme pack (Garage flagship)

Setup: [`GOOGLE_AND_SYNC_SETUP.md`](./GOOGLE_AND_SYNC_SETUP.md).

---

## Wave status

1. Kit + this doc — **done** (`after_consumer` Family* primitives)  
2. Health, Finance, Home, Pet — **done** (chrome shell + CRUD catalog + Live/AI/Profile)  
3. Travel, Sports, News — **done**  
4. Hospital — **done** (enterprise fabric retained + family CRUD Features tab)  
5. SuperFarm scaffold — **done** (`D:\Projects\HANTURAI\superfarm`, status scaffold)  

Scripts: `supercore/scripts/apply_family_wave.py`, `wire_family_shells.py`, `apply_family_wave2.py`, `apply_family_hospital_farm.py`, `extract_feature_icons.py`, `write_family_smoke_tests.py`.

Polish follow-up (2026-07-20): Home dashboards use `sortFamilyDashboardSections`; domain catalogs are Flutter-free (icon maps in `*_feature_icons.dart`); Hospital placeholders → CRUD wrappers; per-app `test/family_smoke_test.dart` (membership + CRUD + section sort).

Identity + Hub (same day): `com.overstein.*` Android/iOS/tests for consumer siblings; Hospital dead placeholder removed; After Hub **H2** shell (Calendar/Apps tabs + Garage/Health/Find `HubWidgetAdapter`s). **APK install deferred.**

Pre-APK finish: MaterialApp → `AfterSupportedLocales` on consumer twins; Farm/Hub locale asset stubs; Hub `after://` router + `assets/hub/*.hub_contribution.json`; `MemoryAfterSubscriptionVerifier` (store IAP still NoOp by default); per-app `docs/COMPLIANCE_REPORT.md`.  

