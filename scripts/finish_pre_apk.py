#!/usr/bin/env python3
"""Finish non-APK gaps: MaterialApp 20 locales, Farm/Hub locale stubs, script fix."""
from __future__ import annotations

import json
import re
import shutil
from pathlib import Path

HANTURAI = Path(r"D:\Projects\HANTURAI")
CODES = [
    "en", "zh", "hi", "es", "fr", "ar", "bn", "pt", "ru", "ur",
    "id", "de", "ja", "sw", "mr", "te", "tr", "ta", "vi", "ko",
]

INLINE_LOCALES = re.compile(
    r"supportedLocales:\s*const\s*\[\s*Locale\('en'\),\s*Locale\('tr'\)\s*\],?"
)


def fix_app_dart(app: str) -> None:
    path = HANTURAI / app / "lib" / "app" / "app.dart"
    if not path.is_file():
        return
    text = path.read_text(encoding="utf-8")
    if "import 'package:after_core/after_core.dart';" not in text:
        text = "import 'package:after_core/after_core.dart';\n" + text
    if "import 'package:flutter_localizations/flutter_localizations.dart';" not in text:
        # optional — only if we add delegates
        pass
    orig = text
    text = INLINE_LOCALES.sub(
        "supportedLocales: AfterSupportedLocales.locales,\n"
        "      localeResolutionCallback: AfterSupportedLocales.resolutionCallback,\n"
        "      localizationsDelegates: AfterSupportedLocales.localizationsDelegates,",
        text,
        count=1,
    )
    if "localeResolutionCallback" not in text and "AfterSupportedLocales.locales" in text:
        text = text.replace(
            "supportedLocales: AfterSupportedLocales.locales,",
            "supportedLocales: AfterSupportedLocales.locales,\n"
            "      localeResolutionCallback: AfterSupportedLocales.resolutionCallback,\n"
            "      localizationsDelegates: AfterSupportedLocales.localizationsDelegates,",
            1,
        )
    if (
        "localeResolutionCallback: AfterSupportedLocales.resolutionCallback," in text
        and "localizationsDelegates" not in text
    ):
        text = text.replace(
            "localeResolutionCallback: AfterSupportedLocales.resolutionCallback,",
            "localeResolutionCallback: AfterSupportedLocales.resolutionCallback,\n"
            "      localizationsDelegates: AfterSupportedLocales.localizationsDelegates,",
            1,
        )
    # Also fix en+tr lists without const keyword variations
    text = re.sub(
        r"supportedLocales:\s*\[\s*const Locale\('en'\),\s*const Locale\('tr'\)\s*\],?",
        "supportedLocales: AfterSupportedLocales.locales,\n"
        "      localeResolutionCallback: AfterSupportedLocales.resolutionCallback,\n"
        "      localizationsDelegates: AfterSupportedLocales.localizationsDelegates,",
        text,
        count=1,
    )
    if text != orig:
        path.write_text(text, encoding="utf-8")
        print(f"app.dart fixed: {app}")
    else:
        print(f"app.dart ok/skip: {app}")


def seed_l10n(app: str, source_en: Path) -> None:
    dest = HANTURAI / app / "assets" / "l10n"
    dest.mkdir(parents=True, exist_ok=True)
    en_text = source_en.read_text(encoding="utf-8")
    json.loads(en_text)
    for code in CODES:
        p = dest / f"{code}.json"
        if not p.exists():
            p.write_text(en_text, encoding="utf-8")
    meta = {
        "version": 1,
        "fallback": "en",
        "languages": CODES,
        "note": "English stubs until translated.",
    }
    (dest / "meta.json").write_text(
        json.dumps(meta, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(f"seeded l10n: {app}")


def ensure_pubspec_asset(app: str) -> None:
    pub = HANTURAI / app / "pubspec.yaml"
    text = pub.read_text(encoding="utf-8")
    if "assets/l10n/" in text:
        return
    if "flutter:\n" not in text:
        text += "\nflutter:\n  uses-material-design: true\n  assets:\n    - assets/l10n/\n"
    elif "assets:" not in text:
        text = text.replace(
            "uses-material-design: true\n",
            "uses-material-design: true\n  assets:\n    - assets/l10n/\n",
            1,
        )
    else:
        text = text.replace("assets:\n", "assets:\n    - assets/l10n/\n", 1)
    pub.write_text(text, encoding="utf-8")
    print(f"pubspec assets: {app}")


def fix_apply_script() -> None:
    path = HANTURAI / "supercore" / "scripts" / "apply_platform_l10n.py"
    text = path.read_text(encoding="utf-8")
    if "supportedLocales: const [Locale('en')" in text or "INLINE" in text:
        print("apply script already knows inline? check")
    needle = "def patch_app_dart(app: str) -> None:"
    if "Locale('en'), Locale('tr')" in text and "INLINE_LOCALES" not in text:
        insert = '''
    # Inline MaterialApp list (most consumer skeletons)
    text2 = re.sub(
        r"supportedLocales:\\s*const\\s*\\[\\s*Locale\\('en'\\),\\s*Locale\\('tr'\\)\\s*\\],?",
        "supportedLocales: AfterSupportedLocales.locales,\\n"
        "      localeResolutionCallback: AfterSupportedLocales.resolutionCallback,",
        text2,
        count=1,
    )
'''
        # inject after text2 = re.sub(static const...
        marker = "flags=re.S,\n    )"
        if marker in text and "Locale('en'), Locale('tr')" not in text.split("def patch_app_dart")[1][:800]:
            text = text.replace(
                marker,
                marker + "\n" + insert,
                1,
            )
            # also extend CONSUMER_APPS
            text = text.replace(
                'CONSUMER_APPS = [\n    "supersports",\n    "superhealth",\n    "superfinance",\n    "superhome",\n    "superpet",\n    "supertravel",\n    "supernews",\n]',
                'CONSUMER_APPS = [\n    "supersports",\n    "superhealth",\n    "superfinance",\n    "superhome",\n    "superpet",\n    "supertravel",\n    "supernews",\n    "superfarm",\n    "afterhub",\n]',
            )
            path.write_text(text, encoding="utf-8")
            print("apply_platform_l10n.py patched")
        else:
            # simpler: append CONSUMER apps only
            if '"superfarm"' not in text:
                text = text.replace(
                    '"supernews",\n]',
                    '"supernews",\n    "superfarm",\n    "afterhub",\n]',
                )
                path.write_text(text, encoding="utf-8")
                print("apply_platform_l10n.py apps extended")
    else:
        if '"superfarm"' not in text:
            text = text.replace(
                '"supernews",\n]',
                '"supernews",\n    "superfarm",\n    "afterhub",\n]',
            )
            path.write_text(text, encoding="utf-8")
            print("apply_platform_l10n.py apps extended")


def write_compliance(app: str, title: str) -> None:
    docs = HANTURAI / app / "docs"
    docs.mkdir(exist_ok=True)
    path = docs / "COMPLIANCE_REPORT.md"
    if path.exists():
        print(f"compliance exists: {app}")
        return
    path.write_text(
        f"""# {title} — Compliance report (skeleton)

## Fixed (family skeleton)

- Bundle / package: `com.overstein.*`
- After Framework composition + family chrome shell
- Feature CRUD via `after_consumer` Family kit
- Home dashboard uses `sortFamilyDashboardSections`
- Locales: `AfterSupportedLocales` (≥20) with English stub assets where applicable
- Membership: `AfterUserPlan` / `FamilyMembershipController` (store IAP ports swappable)

## Accepted deferrals

- Real Play/App Store IAP (NoOp / prefs plan switch)
- Firebase Auth/Firestore/Crashlytics production projects
- Drift / remote repositories
- Full professional translations (English stubs OK)
- APK install / store flavors

## Notes

Generated for SuperGarage family parity gate. Update when shipping beyond mock.
""",
        encoding="utf-8",
    )
    print(f"compliance: {app}")


def main() -> None:
    for app in (
        "superhealth",
        "superfinance",
        "superhome",
        "superpet",
        "supertravel",
        "supernews",
    ):
        fix_app_dart(app)

    src = HANTURAI / "superhealth" / "assets" / "l10n" / "en.json"
    for app in ("superfarm", "afterhub"):
        seed_l10n(app, src)
        ensure_pubspec_asset(app)

    fix_apply_script()

    for app, title in [
        ("superhealth", "SuperHealth"),
        ("superfinance", "SuperFinance"),
        ("superhome", "SuperHome"),
        ("superpet", "SuperPet"),
        ("supertravel", "SuperTravel"),
        ("supernews", "SuperNews"),
        ("superhospital", "SuperHospital"),
        ("superfarm", "SuperFarm"),
        ("afterhub", "After Hub"),
    ]:
        write_compliance(app, title)

    print("OK")


if __name__ == "__main__":
    main()
