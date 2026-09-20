# Consent / KVKK / permissions (all Super Apps, 20 locales)

Every Super App uses the same first-launch and Settings legal surfaces from
`after_consumer`. Products must **not** fork Legal / Permission / KVKK screens.

## First launch

`FamilyAuthGate` / `AfterLaunchConsentGate`:

1. **Legal** — Privacy Policy + Terms (KVKK / GDPR consent checkbox)
2. **Permissions** — Location, notifications, photos, camera notice
3. OS location request (when accepted)

Copy: `AfterLaunchConsentStrings.forLocale` ← `AfterLaunchConsentCatalog`
(all 20 `AfterSupportedLocales`). Placeholder `{app}` = product name.

In-app document sheets (tap Privacy / Terms):

- Default: `openFamilyLegalDocument` (family privacy 8 + terms 6 sections)
- Garage may keep deeper `LegalDocumentScreen` via `onPrivacyPolicyTap`

## Settings

`FamilySettingsScreen` → same `FamilyUiStrings` + rich overlays for privacy,
terms, permissions, rights (20 locales).

## Regenerating launch copy

```bash
python tools/generate_launch_consent_catalog.py
```

Source: SuperGarage `assets/l10n/*.json` (brand generalized to `{app}`).

## Tests

`test/after_launch_consent_l10n_test.dart` — every language has non-empty
tables; TR/DE/JA differ from EN; no Garage/OBD leftovers.
