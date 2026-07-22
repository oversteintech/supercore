# Factory templates

The AI Product Factory generates apps from the two canonical blueprints
that live under [`../../templates/`](../../templates/):

- [`super_app_consumer/`](../../templates/super_app_consumer/) — SuperGarage-shaped scaffold.
- [`super_app_enterprise/`](../../templates/super_app_enterprise/) — SuperHospital-shaped scaffold.

Both templates carry:

- `README.md` — how a human would consume the blueprint.
- `product.spec.example.yaml` — a minimal `product.spec` starter for the line.
- `GENERATION.md` — a step-by-step of what
  [`scripts/generate_product.ps1`](../../scripts/generate_product.ps1) fills in.

## Why not real Flutter code inside `templates/`?

`templates/*` intentionally holds only the composition-root contract
(`manifest.dart` + `after_framework.dart` shape + shell wiring rules).
The generator writes those files into a fresh sibling repo from the
values in `product.spec.yaml`. Copying a full pre-built Flutter app
into every new product creates drift; generating from live templates +
`after_core` / `after_consumer` / `after_enterprise` package deps keeps
every Super App identical to the reference implementations at all times.
