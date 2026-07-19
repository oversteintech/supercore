# AI Product Factory — master handbook

> **AfterArtificial is an AI Product Platform that generates consumer and
> enterprise software from a unified architecture.**

**Read first:** [`AFTER_ECOSYSTEM_MANIFEST.md`](AFTER_ECOSYSTEM_MANIFEST.md)
(Manifest v1.0), [`LIFE_DOMAINS.md`](LIFE_DOMAINS.md),
[`LIFE_DOMAIN_ROADMAP.md`](LIFE_DOMAIN_ROADMAP.md), then
[`PLATFORM_DOCTRINE.md`](PLATFORM_DOCTRINE.md).

The Product Factory is how the manifesto materializes software — ≥90%
reuse; products define only domain, features, navigation, permissions,
AI skills, and dashboard widgets. Adding a Life Domain (e.g. SuperKids)
is a **spec + vertical features** exercise — not an architecture change.

Every Super App is produced by the **AI Product Factory** from
`product.spec.yaml`. **SuperGarage** / **SuperHospital** are reference
*proofs* of the platform packages — not trees to fork forever. New
products must stay thin and mount platform hosts
(`AfterEnterpriseMainShell`, dashboard / workflow / plugin engines).
Consumer example: [`factory/specs/examples/super_kids.product.spec.yaml`](../factory/specs/examples/super_kids.product.spec.yaml).

---

## 1. What is the Product Factory

The Product Factory is the pipeline that turns a `product.spec.yaml`
into a sibling Flutter Super App that:

- depends on `after_core`, `after_design_system`, and either
  `after_consumer` or `after_enterprise` via `path:` deps back to this
  `supercore` repo,
- adopts the family shell and OVERSTEIN splash contract,
- wires its vertical features, dashboard widgets, AI skills and
  permissions into the existing OS ports,
- ships with tests, analyze-clean CI, and l10n stubs.

The factory has three moving parts:

1. **`product.spec.yaml`** — the tiny, product-owned input file. Only
   vertical / industry bits live here.
2. **The generator** — [`scripts/generate_product.ps1`](../scripts/generate_product.ps1)
   reads the spec and emits a sibling Flutter app.
3. **The registry** — [`factory/modules/registry.yaml`](../factory/modules/registry.yaml)
   plus this doc pin every shared module to the package that owns it,
   so nothing gets duplicated per product.

---

## 2. Platform inheritance model

```
┌───────────────────────────────────────────────────────────┐
│                    product.spec.yaml                       │
│  (metadata + domain + features + tabs + perms + dashboard  │
│   + AI skills + branding + locales — nothing else.)        │
└───────────────────────┬────────────────────────────────────┘
                        │  scripts/generate_product.ps1
                        ▼
┌───────────────────────────────────────────────────────────┐
│                 Sibling Super App repo                     │
│   lib/features/<vertical>/    — vertical modules only      │
│   lib/app/platform/           — manifest + AfterFramework  │
│   lib/features/shell/         — inherited shell wiring     │
└───────────────────────┬────────────────────────────────────┘
                        │  path:
                        ▼
┌───────────────────────────────────────────────────────────┐
│              after_consumer  |  after_enterprise           │
│  Consumer OS (SuperGarage    │  Enterprise OS (SuperHosp.  │
│  reference)                  │  reference)                 │
└───────────────────────┬───────┴────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────────┐
│                       after_core                           │
│  auth · api · storage · DI · logging · analytics · AI      │
│  BYOK · premium · notifications · deep-links · manifest    │
│  · dashboard engine · search engine · settings engine      │
└───────────────────────┬────────────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────────┐
│                 after_design_system                        │
│         Ice-on-graphite tokens · identical UI              │
└───────────────────────────────────────────────────────────┘
```

Everything below the dashed line is **the platform**. Verticals never
fork it. Vertical repos only ship the top box.

---

## 3. What a product owns vs. inherits

| Concern | Product-owned (`product.spec.yaml`) | Inherited from the platform |
|---------|-------------------------------------|-----------------------------|
| Identity | ✅ name, package, bundle, product line | — |
| Domain | ✅ 1-line description + reference app | — |
| Vertical features | ✅ list of ids + i18n keys | The catalog *shape* (`EnterpriseIndustryFeature` / `ConsumerVerticalFeature`) |
| Navigation | ✅ tabs (feature or module) | Shell renderer, animations, theming |
| RBAC permissions | ✅ list of permission strings | RBAC engine, `PermissionSet`, mock repo |
| Dashboard | ✅ `DashboardWidgetSpec` list | `DashboardEngine` + renderer contract |
| AI skills | ✅ vertical skills + tool bindings | BYOK AI SDK, orchestrator, credential vault |
| Branding | ✅ accent color + monogram | OVERSTEIN splash, chrome, motion, typography |
| Locales | ✅ ≥20 BCP-47 codes (`AfterSupportedLocales`) | l10n loader, English fallback, language picker |
| Auth | — | `AfterAuthRepository`, Google Sign-In, superadmin |
| Membership / org | — | `ConsumerMembership` (B2C) · `OrganizationRepository` (B2B) |
| Calendar / tasks / documents / messaging | — | `after_enterprise` ports + mocks |
| Notifications | — | `AfterLocalNotifications`, `AfterRemotePush`, `EnterpriseNotificationDispatcher` |
| Analytics | — | `AfterAnalytics`, `EnterpriseAnalytics` |
| Workflow engine | — | `WorkflowCatalog` + `hydrateWorkflowCatalog` (JSON/RC); see WORKFLOW_ENGINE.md |
| API layer | — | `AfterApiClient`, `EnterpriseApiClient`, `EnterpriseApiHeaders` |
| Offline sync | — | `OfflineSyncQueue` |
| Splash contract | — | OVERSTEIN cold-start splash (12s bootstrap hard timeout) |
| CI | — | Sibling-`supercore` checkout, analyze, test, coverage ≥50% |
| Design system | — | `after_design_system` (identical across every product) |
| Search | — | `AfterSearchPort` (+ product registers indexes at bootstrap) |
| Settings | — | `AfterSettingsStore` + `AfterSettingsKeys` catalog |

If it isn't in the left column, **the product does not own it**.
Bypassing this rule is the #1 way Super Apps drift out of the family.

---

## 4. Module registry summary

The machine-readable registry lives in
[`factory/modules/registry.yaml`](../factory/modules/registry.yaml). It
maps every capability a Super App inherits to the package that ships
it. A human-readable overview lives in
[`MODULE_REGISTRY.md`](MODULE_REGISTRY.md).

Highlights:

| Module | Package | Line | Status |
|--------|---------|------|--------|
| Shared Core | `after_core` | shared | shipping |
| Shared Design System | `after_design_system` | shared | shipping |
| Shared Authentication | `after_core` (`AfterAuthRepository`, `PrefsGoogleAuth`, `AfterSuperAdmin`) | shared | shipping |
| Shared Membership | `after_consumer` + `after_core` premium | consumer | shipping |
| Shared Organization | `after_enterprise` | enterprise | shipping |
| Shared Role Management (RBAC) | `after_enterprise` | enterprise | shipping |
| Shared Calendar | `after_enterprise` | enterprise | shipping |
| Shared Task Engine | `after_enterprise` | enterprise | shipping |
| Shared Notification Engine | `after_core` + `after_enterprise` | shared | shipping |
| Shared Document Management | `after_enterprise` | enterprise | shipping |
| Shared Analytics | `after_core` + `after_enterprise` | shared | shipping |
| Shared Workflow Engine | `after_enterprise` | enterprise | shipping |
| Shared AI Modules | `after_core` AI + `after_enterprise` `EnterpriseAi` | shared | shipping |
| Shared API Layer | `after_core` Dio/API + `after_enterprise` `EnterpriseApi` | shared | shipping |
| Shared Dashboard Engine | `after_core` `after_dashboard.dart` | shared | shipping |
| Shared Search Engine | `after_core` `after_search.dart` | shared | shipping |
| Shared Settings Engine | `after_core` `after_settings.dart` | shared | shipping |
| Consumer App Template | `templates/super_app_consumer/` | consumer | expand |
| Enterprise App Template | `templates/super_app_enterprise/` | enterprise | expand |

---

## 5. `product.spec.yaml` reference

The spec is validated against
[`factory/schema/product.spec.schema.json`](../factory/schema/product.spec.schema.json).
Every field is documented there; this section is a friendly summary.

```yaml
apiVersion: after.ai/v1
kind: SuperApp

metadata:
  name: SuperAirport              # PascalCase, must start with a capital
  package: super_airport          # snake_case pubspec name
  bundle: com.overstein.superairport
  productLine: enterprise         # consumer | enterprise

spec:
  domain: Airport / aviation operations
  reference: SuperHospital        # SuperGarage | SuperHospital

  features:                       # VERTICAL ONLY. No OS modules here.
    - id: flights
      titleKey: features.flights
      subtitleKey: features.flights_sub
      icon: flight_takeoff_outlined
      requiredPermission: airport.flights.read

  navigation:
    tabs:                         # 2–6 tabs, matching family shell
      - id: home
        labelKey: nav.home
        icon: dashboard_outlined  # renders inherited dashboard
      - id: flights
        labelKey: nav.flights
        icon: flight_takeoff_outlined
        feature: flights          # points at a spec.features[] id
      - id: tasks
        module: tasks             # inherited OS module — no code emitted

  permissions:                    # Vertical RBAC keys only
    - airport.flights.read
    - airport.gates.write

  dashboard:
    widgets:                      # DashboardWidgetSpec entries
      - type: metric
        id: active_flights
        titleKey: dash.active_flights
        source: vertical.flights.activeCount
        order: 10
        requiredPermission: airport.flights.read
      - type: module
        id: open_tasks
        titleKey: dash.open_tasks
        module: tasks
        limit: 5
        order: 40

  ai:
    skills:
      - id: delay_brief
        description: Brief ops on the top delayed flights of the shift.
        tools: [airport.flights.delayed, airport.flights.reasons]

  branding:
    accent: "#0EA5E9"             # hex
    monogram: SA                  # 2–3 chars used on OVERSTEIN splash

  locales: # AfterSupportedLocales — platform minimum ≥20
    [en, zh, hi, es, fr, ar, bn, pt, ru, ur, id, de, ja, sw, mr, te, tr, ta, vi, ko]
```

Rules of thumb:

- If a tab has `module:`, the generator writes **no** code for it — the
  inherited shell handles it.
- If a widget has `type: module`, ditto.
- `metric` / `chart` widgets declare a `source:` dotted path — the
  vertical resolves it from its own providers.
- `features[]` is the SINGLE source of truth for what UI the product
  actually adds. Everything else piggy-backs on inherited plumbing.

---

## 6. One-day playbook

The Product Factory is built so a single engineer can ship a new
Super App skeleton, mock-clean, in **under a day**. A realistic
hour-by-hour:

### Morning — define + generate

| Time | Task |
|------|------|
| 09:00 – 09:30 | Copy `templates/super_app_<line>/product.spec.example.yaml` to `factory/specs/<name>.product.spec.yaml`. Fill metadata + domain + reference. |
| 09:30 – 10:30 | Enumerate industry features under `spec.features`. Keep it under ~12. Everything cross-cutting is inherited. |
| 10:30 – 11:00 | Draft `navigation.tabs` (2–6 tabs). Use `module:` for inherited tabs. |
| 11:00 – 11:30 | Draft `permissions[]` (enterprise) + `dashboard.widgets[]`. |
| 11:30 – 12:00 | `scripts/validate_product_spec.ps1 -SpecPath ...` → fix errors. |
| 12:00 – 12:15 | `scripts/generate_product.ps1 -SpecPath ...` → sibling repo appears. |

### Afternoon — vertical features + AI + l10n

| Time | Task |
|------|------|
| 13:00 – 15:00 | Flesh out one or two `lib/features/<vertical>/` folders — data models, mock providers, screens using `after_design_system`. |
| 15:00 – 16:00 | Wire `spec.ai.skills` to real tool calls via the `EnterpriseAiAssistant` (or `SimpleAfterAiOrchestrator` for consumer). |
| 16:00 – 16:30 | Fill in i18n strings referenced from `titleKey` / `subtitleKey` / `labelKey` in `assets/l10n/*.json`. |
| 16:30 – 17:00 | Drop the product monogram + accent onto the splash. |

### Evening — tests + compliance

| Time | Task |
|------|------|
| 17:00 – 18:00 | `flutter analyze` clean. Write feature-level tests + at least one workflow / task test. |
| 18:00 – 19:00 | Run the compliance gate against SuperGarage / SuperHospital. Fix any deltas. |
| 19:00 – 19:30 | `flutter test --coverage` ≥ 50%. Push a scaffold PR. |

By 19:30 the new Super App is a family sibling — SuperGarage / SuperHospital
patterns, mock-clean, analyze-clean, coverage-gated.

---

## 7. Consistency guarantees

Every generated Super App inherits, by construction:

- **Reference match.** Consumer apps mirror SuperGarage; enterprise
  apps mirror SuperHospital — same shell topology, same splash, same
  bootstrap, same nav bar, same design language.
- **No forked platform code.** The generator never copies `after_*`
  package sources into a product repo.
- **Ports over SDKs.** Vertical code only depends on interfaces from
  `after_core` / `after_consumer` / `after_enterprise`. Never on
  Firebase / Supabase / vendor SDKs directly.
- **RBAC + audit on every mutation** (enterprise).
- **Compliance gate.** After generation, the compliance gate in
  `.cursor/rules/super-app-compliance-gate.mdc` compares the app to
  the SuperGarage / SuperHospital references and produces
  `docs/COMPLIANCE_REPORT.md`. Anything less than 100% skeleton
  compliance is a fix, not a discussion.
- **After Hub contributions (consumer).** Shipping consumer Super Apps
  must declare `spec.hub` with ≥1 widget **and** at least one of
  `calendarFeeds` / `notificationCategories` (H4+ gate; schema optional
  until then). See [`AFTER_HUB.md`](AFTER_HUB.md) · ADR-019 ·
  `factory/schema/product.spec.schema.json` → `spec.hub`.
- **Regenerability.** Re-running the generator with an evolved spec
  updates skeleton files without destroying human-authored feature
  code or preserved docs (`docs/PRODUCT.md`).

---

## 8. How to add a new shared module to the factory

New capability crosses two or more Super Apps? It belongs in the
platform. To add one cleanly:

1. **Design the port** in `after_core` (if consumer + enterprise share
   it) or `after_enterprise` / `after_consumer` (if only one line
   uses it). Keep it interface-first.
2. **Ship a mock**. Every port ships with an in-memory / no-op default
   so scaffolds compile without backends. See `MockEnterpriseRepository`
   and the `InMemory*` families for the pattern.
3. **Wire a provider** in `after_core.di` / `after_enterprise.di`.
   Default to the mock. Real adapters bind at composition root.
4. **Export** from the package barrel (`after_core.dart`).
5. **Register** in [`factory/modules/registry.yaml`](../factory/modules/registry.yaml).
6. **Update** [`MODULE_REGISTRY.md`](MODULE_REGISTRY.md) and this doc.
7. **Extend** `product.spec.schema.json` only if the new module needs
   product-level configuration. Otherwise it's purely inherited —
   nothing changes in `product.spec.yaml`.
8. **Test** with a unit test in the owning package.

Do **not** add product-specific capabilities to shared packages. If
only SuperAirport needs it, it lives under
`superairport/lib/features/airport/` — full stop.

---

## 9. Anti-patterns (do not do this)

Every Super App drift ever observed traces back to one of these:

- **Forking auth.** No new auth stacks. Use `AfterAuthRepository`. If
  the vertical needs SSO, plug it in behind the same port.
- **Custom routers.** No `go_router`. AuthGate → MainShell → feature
  catalog + navigator is the family shell.
- **Copying Firebase into a vertical.** Verticals depend on ports.
  Firebase (or any vendor SDK) binds at composition root inside the
  product repo, never inside the vertical modules.
- **Reinventing OS modules.** Tasks, calendar, documents, messaging,
  notifications, analytics, workflow, RBAC, audit log — all live in
  `after_enterprise`. If a vertical needs "just a slightly different
  task board", it either uses the shared port or upgrades it upstream
  for everyone.
- **Bypassing the workflow engine.** Every state transition on a
  vertical entity goes through `WorkflowEngine.transition(...)`.
- **Skipping audit.** Every mutating enterprise action leaves an
  `AuditLogEntry`.
- **Greenfield architecture.** New Super Apps ship as
  `product.spec.yaml + branding + industry features` on top of the
  factory — never as a fresh Flutter architecture experiment.

---

## See also

- [`MODULE_REGISTRY.md`](MODULE_REGISTRY.md) — every shared module.
- [`AFTER_OS_ARCHITECTURE.md`](AFTER_OS_ARCHITECTURE.md) — package map.
- [`CONSUMER_FRAMEWORK.md`](CONSUMER_FRAMEWORK.md) — B2C contract.
- [`ENTERPRISE_FRAMEWORK.md`](ENTERPRISE_FRAMEWORK.md) — B2B / vertical contract.
- [`SUPER_HOSPITAL_STANDARD.md`](SUPER_HOSPITAL_STANDARD.md) — enterprise checklist.
- [`../factory/README.md`](../factory/README.md) — factory entry point.
- [`../factory/schema/product.spec.schema.json`](../factory/schema/product.spec.schema.json) — spec schema.
