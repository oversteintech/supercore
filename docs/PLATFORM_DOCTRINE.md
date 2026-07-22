# AfterArtificial Platform Doctrine

> **AfterArtificial is an AI Product Platform that generates consumer and
> enterprise software from a unified architecture.**

**Master Vision v2.0:** [`AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md`](AFTERARTIFICIAL_ECOSYSTEM_MASTER_VISION.md)  
**Binding law:** [`AFTER_ECOSYSTEM_MANIFEST.md`](AFTER_ECOSYSTEM_MANIFEST.md) (v2.0)  
**Alignment:** [`MASTER_VISION_ALIGNMENT_2026.md`](MASTER_VISION_ALIGNMENT_2026.md)

**Platform-first rule:** Whenever you implement a feature, ask — *Should
this belong to one application, or become a shared platform capability
every future application can reuse?* Always prefer platform capabilities
whenever technically reasonable.

**Locales:** every product ships [`AfterSupportedLocales`](../packages/after_core/lib/src/l10n/after_supported_locales.dart) (≥20 languages) with English fallback — not en/tr only.
Every future product follows Manifest + Master Vision without exception.

Not an app company. Overstein Labs builds the **After Ecosystem
Platform** (After OS + After Ecosystem fabric + AI Product Factory).
Products are **Life Domain / Industry Domain modules of one digital OS**
— One Identity, One AI, One Cloud, One Subscription — not standalone apps.

Organizing principle: [`LIFE_DOMAINS.md`](LIFE_DOMAINS.md).  
Scale plan: [`LIFE_DOMAIN_ROADMAP.md`](LIFE_DOMAIN_ROADMAP.md) (≥100 apps,
zero architecture forks).

Technical fabric: [`AFTER_ECOSYSTEM_PLATFORM.md`](AFTER_ECOSYSTEM_PLATFORM.md).

The economic unit of work is not “ship another app.” It is **one more
Life Domain on the same architecture**, produced with minimal engineering.

---

## 1. North star

| Goal | Target |
|------|--------|
| Platform reuse per new product | **≥ 90%** of runtime capability |
| Product-owned surface | **≤ 10%** — domain, vertical features, AI enablement |
| Architecture variance across products | **Zero** — identical OS shape |
| New product effort | Spec → generate → vertical modules → ship |
| Number of products the platform must support | **≥100 now; hundreds long-term** |

If a change cannot be justified as either (a) a **platform** upgrade that
benefits every product, or (b) a **vertical** module under
`lib/features/<domain>/`, it does not ship.

---

## 2. What changes per product (the only 10%)

A product may own **only**:

1. **Business domain** — one-line domain + tenant semantics  
2. **Vertical feature modules** — industry screens under `lib/features/<domain>/`  
3. **AI capability profile** — enable/disable AfterAI capabilities + vertical skills  
4. **Declarative catalogs** (data, not architecture):  
   - dashboard layout JSON  
   - workflow catalog JSON  
   - plugin catalog JSON  
   - RBAC permission strings  
   - branding accent + monogram + locales  

Everything else is **forbidden** to re-implement in a product repo.

---

## 3. What never changes (the 90%+)

Inherited identically by every Super App:

| Layer | Package(s) |
|-------|------------|
| Kernel | `after_core` — auth, DI, API, storage, flags, RC, search, settings, **dashboard engine**, **plugin system**, notifications, analytics, premium |
| Design system | `after_design_system` — one visual family |
| AI OS | `after_ai` — modular capabilities; products only toggle |
| Consumer OS | `after_consumer` — membership, consumer catalog, vault |
| Enterprise OS | `after_enterprise` — org, RBAC, **workflow engine**, tasks, calendar, documents, messaging, reporting, audit, sync, **product runtime / shell host** |
| Bootstrap contract | OVERSTEIN splash → AuthGate → MainShell |
| CI / quality | sibling `supercore` checkout, analyze, test, coverage gate |

References:

- Consumer: **SuperGarage**  
- Enterprise: **SuperHospital**  

References define the architecture. They are not templates to copy-paste
forever — they are **proof** that the platform packages work. New
products are generated from `product.spec.yaml`, not forked from a
reference git tree.

---

## 4. Identical architecture contract

Every product — consumer or enterprise — has the **same shape**:

```
main.dart
  → PlatformConfig.current = manifest
  → ProviderScope(overrides: After*Overrides…)
  → ColdStart (OVERSTEIN splash)
       → AuthGate
            → ProductShell (tabs from platform + spec)
                 → Home = Dashboard Engine (+ plugins)
                 → OS modules = platform screens
                 → Vertical = product feature modules only
```

Forbidden drift:

- Custom auth stacks  
- Per-app design systems  
- Per-app workflow / dashboard / plugin engines  
- Per-app AI stacks outside `after_ai`  
- Forked shells that diverge tab order or bootstrap timing  

---

## 5. Generation is the only creation path

```
product.spec.yaml  →  scripts/generate_product.ps1  →  thin sibling repo
```

The sibling repo should stay **thin**:

```
superairport/
  product.spec.yaml          # source of truth
  pubspec.yaml               # path deps to supercore only
  lib/
    main.dart                # wires EnterpriseProductRuntime
    app/platform/            # manifest + overrides (generated)
    features/<vertical>/     # ONLY industry modules
    features/feature_catalog.dart
  assets/
    dashboard/home.json
    workflows/catalog.json   # enterprise
    plugins/catalog.json
    l10n/
  test/                      # vertical + smoke
```

**Anti-pattern (transitional, do not expand):** cloning SuperHospital’s
entire `lib/` tree (`generate_enterprise_from_hospital.ps1`). That path
duplicates shell code and **violates the 90% rule**. It exists only as a
bridge until all products mount `AfterEnterpriseProductApp` /
consumer equivalent from platform packages. New work must shrink product
`lib/app` and `lib/features/{shell,auth,tasks,…}`, not grow them.

---

## 6. How to add the N-th product (minimal effort)

1. Write `factory/specs/<name>.product.spec.yaml` (domain, features, AI, catalogs).  
2. `validate_product_spec.ps1` → `generate_product.ps1`.  
3. Implement vertical feature widgets only.  
4. Point AI profile / skills at domain tools.  
5. Drop JSON catalogs for dashboard / workflows / plugins (no Dart layout).  
6. `flutter analyze` + `flutter test` + compliance gate vs reference.  

No new architecture. No new auth. No new design system.

---

## 7. Platform investment rule

Prefer investing in `supercore/packages/*` over any single product.

| If you need… | Do this |
|--------------|---------|
| New Home widget type | Extend Dashboard Engine |
| New enterprise process | Extend Workflow catalog schema / engine |
| New extension point | Extend Plugin System |
| New AI modality | Extend `after_ai` capability + mock |
| New industry screen | Add vertical feature in the **product** repo |

---

## 8. Measurement

Machine-readable reuse contract:
[`factory/reuse_contract.yaml`](../factory/reuse_contract.yaml).

Check a product:

```powershell
powershell -File scripts\check_reuse_contract.ps1 -AppRoot ..\superairport
```

A product fails the doctrine when it re-owns platform concerns or when
vertical LOC dominates platform-inherited surface without justification.

---

## Related docs

- [PRODUCT_FACTORY.md](PRODUCT_FACTORY.md) — handbook  
- [MODULE_REGISTRY.md](MODULE_REGISTRY.md) — inherited modules  
- [AFTER_OS_ARCHITECTURE.md](AFTER_OS_ARCHITECTURE.md) — package map  
- [AFTER_AI_PLATFORM.md](AFTER_AI_PLATFORM.md) — AI enable/disable  
- [DASHBOARD_ENGINE.md](DASHBOARD_ENGINE.md) · [WORKFLOW_ENGINE.md](WORKFLOW_ENGINE.md) · [PLUGIN_SYSTEM.md](PLUGIN_SYSTEM.md)  
