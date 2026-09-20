# Location permission + region language (all Super Apps)

Every Super App uses the same SuperCore path — not a SuperGarage fork.

## First launch

1. `FamilyAuthGate` / `AfterLaunchConsentGate` → Legal → Permission intro
2. On accept → `AfterLocationPermission.requestIfConsented()` (OS when-in-use)
3. Soft-seed country if empty via `AfterRegionalLocationApply.seedCountryIfEmpty`
4. Sticky language seeded once via `AfterLocalePrefs.ensurePersisted` (device language, never GPS)

## Settings (shared)

`FamilyRegionLanguageSection` (every family Settings screen):

| Control | Behavior |
|---------|----------|
| Language dropdown | Sticky prefs via product `onLocale` |
| Country dropdown | `AfterCountryPrefs` / `afterCountryCodeProvider` |
| **Match language to country** | Optional — when on, location/country applies `AfterRegionalPreferences.languageForCountry` |
| **Use my location** | `AfterRegionalLocationService` → country (+ language if match enabled) |

## Ports / services

| API | Package |
|-----|---------|
| `AfterLocationPermission` | after_consumer |
| `AfterRegionalLocationService` | after_consumer |
| `AfterRegionalLocationApply` | after_consumer |
| `AfterLocalePrefs.ensurePersisted` | after_core |
| `AfterRegionalPreferences.languageForCountry` | after_core |

## Policy

- Language is **never** auto-rewritten from GPS on cold start.
- Matching language to country is an **opt-in** Settings control.
- Garage keeps thin façades (`AppLocalePersistence`, `RegionalLocationService`) that call SuperCore.
