"""Seed 20 locale JSON files + rewrite consumer StringCatalog / MaterialApp locales."""
from __future__ import annotations

import json
import re
from pathlib import Path

CODES = [
    "en", "zh", "hi", "es", "fr", "ar", "bn", "pt", "ru", "ur",
    "id", "de", "ja", "sw", "mr", "te", "tr", "ta", "vi", "ko",
]

HANTURAI = Path(r"D:\Projects\HANTURAI")

CONSUMER_APPS = [
    "supersports",
    "superhealth",
    "superfinance",
    "superhome",
    "superpet",
    "supertravel",
    "supernews",
    "superfarm",
    "afterhub",
]

STRING_CATALOG = r'''import 'dart:convert';

import 'package:after_core/after_core.dart';
import 'package:flutter/services.dart';

/// Runtime JSON string catalog for all [AfterSupportedLocales] (≥20).
///
/// Missing locale assets fall back to English at resolve time.
class StringCatalog {
  StringCatalog._(this._tables);

  /// Test-only constructor — avoids asset bundle dependency.
  factory StringCatalog.forTest(Map<String, Map<String, String>> tables) {
    return StringCatalog._(tables);
  }

  final Map<String, Map<String, String>> _tables;
  String locale = AfterSupportedLocales.fallbackLanguage;

  static Future<StringCatalog>? _cached;

  static Future<StringCatalog> load() async {
    final en = await _loadLocale(AfterSupportedLocales.fallbackLanguage);
    final tables = <String, Map<String, String>>{
      AfterSupportedLocales.fallbackLanguage: en,
    };
    for (final code in AfterSupportedLocales.languageCodes) {
      if (code == AfterSupportedLocales.fallbackLanguage) continue;
      try {
        tables[code] = await _loadLocale(code);
      } on Object {
        // Missing / invalid — English fallback in [t].
      }
    }
    return StringCatalog._(tables);
  }

  /// Cached [load] — safe to call from multiple bootstrap seams.
  static Future<StringCatalog> ensureLoaded() {
    return _cached ??= load();
  }

  static Future<Map<String, String>> _loadLocale(String code) async {
    final raw = await rootBundle.loadString('assets/l10n/$code.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, '$v'));
  }

  String t(String key, {Map<String, String> args = const {}}) {
    final table = _tables[locale] ??
        _tables[AfterSupportedLocales.fallbackLanguage] ??
        const <String, String>{};
    final fallback = _tables[AfterSupportedLocales.fallbackLanguage] ??
        const <String, String>{};
    var value = table[key] ?? fallback[key] ?? key;
    for (final entry in args.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }
    return value;
  }

  void setLocale(String code) {
    if (AfterSupportedLocales.isSupported(code)) {
      locale = code;
    }
  }
}
'''


def seed_locales(app: str) -> None:
    l10n = HANTURAI / app / "assets" / "l10n"
    if not l10n.is_dir():
        print(f"skip seed {app}")
        return
    en_path = l10n / "en.json"
    if not en_path.exists():
        print(f"skip seed {app}: no en.json")
        return
    en_text = en_path.read_text(encoding="utf-8")
    json.loads(en_text)
    created = 0
    for code in CODES:
        dest = l10n / f"{code}.json"
        if dest.exists():
            continue
        dest.write_text(en_text, encoding="utf-8")
        created += 1
    meta = {
        "version": 1,
        "fallback": "en",
        "languages": CODES,
        "note": "Stubs copy English until translated; runtime falls back to en.",
    }
    (l10n / "meta.json").write_text(
        json.dumps(meta, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"{app}: seeded {created} locale files")


def patch_string_catalog(app: str) -> None:
    path = HANTURAI / app / "lib" / "app" / "l10n" / "string_catalog.dart"
    if not path.exists():
        print(f"skip catalog {app}")
        return
    path.write_text(STRING_CATALOG, encoding="utf-8")
    print(f"{app}: string_catalog.dart updated")


def patch_app_dart(app: str) -> None:
    path = HANTURAI / app / "lib" / "app" / "app.dart"
    if not path.exists():
        print(f"skip app.dart {app}")
        return
    text = path.read_text(encoding="utf-8")
    if "AfterSupportedLocales" not in text:
        if "import 'package:after_core/after_core.dart';" not in text:
            text = "import 'package:after_core/after_core.dart';\n" + text
    # Replace hardcoded supportedLocales list
    text2 = re.sub(
        r"static const supportedLocales = <Locale>\[[^\]]*?\];",
        "static List<Locale> get supportedLocales => AfterSupportedLocales.locales;",
        text,
        count=1,
        flags=re.S,
    )
    text2 = re.sub(
        r"supportedLocales:\s*const\s*\[\s*Locale\('en'\),\s*Locale\('tr'\)\s*\],?",
        "supportedLocales: AfterSupportedLocales.locales,\n"
        "      localeResolutionCallback: AfterSupportedLocales.resolutionCallback,",
        text2,
        count=1,
    )
    if "localeResolutionCallback" not in text2:
        text2 = text2.replace(
            "supportedLocales: supportedLocales,",
            "supportedLocales: supportedLocales,\n"
            "      localeResolutionCallback: AfterSupportedLocales.resolutionCallback,",
            1,
        )
    # Fix comment about en+tr
    text2 = text2.replace(
        "Supported locales pinned to en + tr for the skeleton; expand later.",
        "Supported locales: AfterSupportedLocales (≥20) with English fallback.",
    )
    text2 = text2.replace(
        "Supported locales pinned to en + tr",
        "Supported locales: AfterSupportedLocales (≥20)",
    )
    path.write_text(text2, encoding="utf-8")
    print(f"{app}: app.dart patched")


def patch_settings_picker(app: str) -> None:
    path = HANTURAI / app / "lib" / "features" / "settings" / "settings_screen.dart"
    if not path.exists():
        return
    text = path.read_text(encoding="utf-8")
    original = text
    if "import 'package:after_core/after_core.dart';" not in text:
        text = "import 'package:after_core/after_core.dart';\n" + text
    prefs_m = re.search(r"await prefs\.setString\('([^']+\.locale)', code\);", text)
    prefs_key = prefs_m.group(1) if prefs_m else f"{app}.locale"
    dropdown = f"""            AfterSectionHeader(title: ref.tr('settings.language')),
            DropdownButtonFormField<String>(
              initialValue: AfterSupportedLocales.isSupported(locale)
                  ? locale
                  : AfterSupportedLocales.fallbackLanguage,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: [
                for (final code in AfterSupportedLocales.languageCodes)
                  DropdownMenuItem(
                    value: code,
                    child: Text(AfterSupportedLocales.displayNameFor(code)),
                  ),
              ],
              onChanged: (code) async {{
                if (code == null) return;
                ref.read(localeCodeProvider.notifier).setLocale(code);
                final prefs = ref.read(afterSharedPreferencesProvider);
                await prefs.setString('{prefs_key}', code);
              }},
            ),"""
    text2 = re.sub(
        r"AfterSectionHeader\(title: ref\.tr\('settings\.language'\)\),\s*"
        r"SegmentedButton<String>\([\s\S]*?\),",
        dropdown,
        text,
        count=1,
    )
    if text2 == text:
        text2 = text.replace("['en', 'tr']", "AfterSupportedLocales.languageCodes")
    if text2 != original:
        path.write_text(text2, encoding="utf-8")
        print(f"{app}: settings_screen.dart patched")
    else:
        print(f"{app}: settings_screen.dart unchanged")


def patch_enterprise(app: str) -> None:
    path = HANTURAI / app / "lib" / "app" / "l10n" / "string_catalog.dart"
    if not path.exists():
        return
    text = path.read_text(encoding="utf-8")
    if "AfterSupportedLocales" in text:
        print(f"{app}: enterprise catalog already patched")
        return
    if "static StringCatalog seed()" not in text:
        print(f"skip enterprise {app}")
        return
    if "import 'package:after_core/after_core.dart';" not in text:
        text = "import 'package:after_core/after_core.dart';\n" + text
    text = text.replace(
        """  static StringCatalog seed() {
    return StringCatalog._({
      'en': _en,
      'tr': _tr,
    });
  }""",
        """  static StringCatalog seed() {
    // Non-tr locales use English until assets-backed catalogs ship.
    final tables = <String, Map<String, String>>{
      for (final code in AfterSupportedLocales.languageCodes)
        code: code == 'tr' ? _tr : _en,
    };
    return StringCatalog._(tables);
  }""",
    )
    text = text.replace(
        """  void setLocale(String code) {
    if (_tables.containsKey(code)) {
      locale = code;
    }
  }""",
        """  void setLocale(String code) {
    if (AfterSupportedLocales.isSupported(code)) {
      locale = code;
    }
  }""",
    )
    path.write_text(text, encoding="utf-8")
    print(f"{app}: enterprise string_catalog seeded for 20 locales")

    app_dart = HANTURAI / app / "lib" / "app" / "app.dart"
    if app_dart.exists():
        at = app_dart.read_text(encoding="utf-8")
        if "AfterSupportedLocales" not in at:
            if "import 'package:after_core/after_core.dart';" not in at:
                at = "import 'package:after_core/after_core.dart';\n" + at
            at = re.sub(
                r"static const supportedLocales = <Locale>\[[^\]]*?\];",
                "static List<Locale> get supportedLocales => AfterSupportedLocales.locales;",
                at,
                count=1,
                flags=re.S,
            )
            if "localeResolutionCallback" not in at:
                at = at.replace(
                    "supportedLocales: supportedLocales,",
                    "supportedLocales: supportedLocales,\n"
                    "      localeResolutionCallback: AfterSupportedLocales.resolutionCallback,",
                    1,
                )
            app_dart.write_text(at, encoding="utf-8")
            print(f"{app}: enterprise app.dart patched")


def main() -> None:
    for app in CONSUMER_APPS:
        seed_locales(app)
        patch_string_catalog(app)
        patch_app_dart(app)
        patch_settings_picker(app)
    for app in ("superhospital", "superairport", "supermaritime", "superfactory"):
        patch_enterprise(app)
    print("OK")


if __name__ == "__main__":
    main()
