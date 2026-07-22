# Platform locales (≥20)

Every AfterArtificial Super App is a **global** product. Shipping only
English + Turkish is not compliant.

## Standard pack (`AfterSupportedLocales`)

Defined in `packages/after_core/lib/src/l10n/after_supported_locales.dart`:

`en, zh, hi, es, fr, ar, bn, pt, ru, ur, id, de, ja, sw, mr, te, tr, ta, vi, ko`

| Rule | Detail |
|------|--------|
| Count | **≥ 20** language codes |
| Fallback | English (`en`) for missing keys / assets |
| RTL | `ar`, `ur` (Flutter `Directionality` via Material) |
| Picker | Settings must offer the full pack (endonyms) |
| Factory | `product.spec` `locales` minItems = 20 |

## Implementation

- Consumer apps: `assets/l10n/{code}.json` + `StringCatalog.load()` over all codes
- Enterprise scaffolds: in-memory tables keyed by all 20 codes (non-`tr` → English until translated)
- SuperGarage: full translated catalog (reference quality bar)
- Stubs may copy English until professional translation lands — **selectable locale still required**

## Seed / repair

```powershell
python scripts\apply_platform_l10n.py
```
