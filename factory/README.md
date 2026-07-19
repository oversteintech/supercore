# AI Product Factory — entry point

> **AfterArtificial is an AI Product Platform that generates consumer and
> enterprise software from a unified architecture.**

**Manifest:** [`docs/AFTER_ECOSYSTEM_MANIFEST.md`](../docs/AFTER_ECOSYSTEM_MANIFEST.md)  
Life Domains: [`docs/LIFE_DOMAINS.md`](../docs/LIFE_DOMAINS.md) ·
[`docs/LIFE_DOMAIN_ROADMAP.md`](../docs/LIFE_DOMAIN_ROADMAP.md)  
Doctrine: [`docs/PLATFORM_DOCTRINE.md`](../docs/PLATFORM_DOCTRINE.md) (≥90% reuse).

This is the entry point of the **AfterArtificial AI Product Factory**.
Handbook: [`docs/PRODUCT_FACTORY.md`](../docs/PRODUCT_FACTORY.md).
Reuse check: `scripts/check_reuse_contract.ps1 -AppRoot ..\<product>`.

New Life Domains are added by writing a `product.spec.yaml` — **not** by
forking architecture. Example: `specs/examples/super_kids.product.spec.yaml`.

## What's in here

| Path | What it does |
|------|--------------|
| [`schema/product.spec.schema.json`](schema/product.spec.schema.json) | JSON Schema for `product.spec.yaml`. |
| [`specs/examples/`](specs/examples/) | Reference specs (garage, kids, hospital, airport, …). |
| [`modules/registry.yaml`](modules/registry.yaml) | Machine-readable map of shared modules → packages. |
| [`templates/README.md`](templates/README.md) | Pointers to the consumer + enterprise scaffolds. |

## One-command generation

From the supercore repo root:

```powershell
powershell -File scripts\generate_product.ps1 -SpecPath factory\specs\examples\super_airport.product.spec.yaml
```

or, when you only have a name:

```powershell
powershell -File scripts\generate_product.ps1 -Name SuperAirport -Reference SuperHospital
```

Validate first (fast, no Flutter required):

```powershell
powershell -File scripts\validate_product_spec.ps1 -SpecPath factory\specs\examples\super_airport.product.spec.yaml
```

## What a `product.spec.yaml` owns

- Metadata: name, package, bundle, product line.
- Domain: business domain string + reference app (SuperGarage / SuperHospital).
- **Industry features only** — everything cross-cutting is inherited.
- Navigation tabs (product-owned + inherited OS modules).
- RBAC permissions specific to this vertical.
- Dashboard widgets.
- AI skills (vertical prompts + tool bindings).
- **After Hub contributions** (`spec.hub` — widgets, calendar feeds,
  notification categories) for consumer apps — see
  [`docs/AFTER_HUB.md`](../docs/AFTER_HUB.md) · ADR-019.
- Product branding accent + monogram + locales list.

Everything else — auth, membership/org, RBAC engine, calendar, tasks,
notifications, documents, analytics, workflow, design system, API,
offline sync, splash, CI, settings, search, dashboard engine — is
inherited from the platform. See
[`docs/MODULE_REGISTRY.md`](../docs/MODULE_REGISTRY.md).
After Hub is the consumer OS shell (not a Life Domain); Super Apps
contribute Hub tiles rather than each shipping a parallel entry chrome.
