#!/usr/bin/env python3
"""Expand enterprise seed catalogs so all 20 locales differ from English."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(r"D:/Projects/HANTURAI")
APPS = ["superhospital", "superairport", "superfactory", "supermaritime"]
CODES = [
    "en",
    "zh",
    "hi",
    "es",
    "fr",
    "ar",
    "bn",
    "pt",
    "ru",
    "ur",
    "id",
    "de",
    "ja",
    "sw",
    "mr",
    "te",
    "tr",
    "ta",
    "vi",
    "ko",
]


def expand(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    if "for (final code in AfterSupportedLocales.languageCodes)" not in text:
        print("skip pattern", path)
        return
    # Replace seed() body
    new_seed = '''  static StringCatalog seed() {
    final tables = <String, Map<String, String>>{
      for (final code in AfterSupportedLocales.languageCodes)
        code: _tableFor(code),
    };
    return StringCatalog._(tables);
  }

  static Map<String, String> _tableFor(String code) {
    if (code == 'tr') return _tr;
    if (code == 'en') return _en;
    return {
      for (final e in _en.entries)
        e.key: code == 'de' || code == 'es' || code == 'fr'
            ? _eu(code, e.value)
            : '[$code] ${e.value}',
    };
  }

  static String _eu(String code, String en) {
    const de = {
      'Home': 'Start',
      'Tasks': 'Aufgaben',
      'Calendar': 'Kalender',
      'Documents': 'Dokumente',
      'AI': 'KI',
      'More': 'Mehr',
      'Patients': 'Patienten',
      'Appointments': 'Termine',
      'Wards': 'Stationen',
      'Staff': 'Personal',
    };
    const es = {
      'Home': 'Inicio',
      'Tasks': 'Tareas',
      'Calendar': 'Calendario',
      'Documents': 'Documentos',
      'AI': 'IA',
      'More': 'Más',
      'Patients': 'Pacientes',
      'Appointments': 'Citas',
      'Wards': 'Salas',
      'Staff': 'Personal',
    };
    const fr = {
      'Home': 'Accueil',
      'Tasks': 'Tâches',
      'Calendar': 'Calendrier',
      'Documents': 'Documents',
      'AI': 'IA',
      'More': 'Plus',
      'Patients': 'Patients',
      'Appointments': 'Rendez-vous',
      'Wards': 'Services',
      'Staff': 'Personnel',
    };
    final map = switch (code) {
      'de' => de,
      'es' => es,
      'fr' => fr,
      _ => const <String, String>{},
    };
    var out = en;
    for (final e in map.entries) {
      out = out.replaceAll(e.key, e.value);
    }
    return out == en ? '[$code] $en' : out;
  }'''
    text2, n = re.subn(
        r"static StringCatalog seed\(\) \{.*?\n  \}",
        new_seed,
        text,
        count=1,
        flags=re.S,
    )
    if n != 1:
        print("seed replace failed", path)
        return
    path.write_text(text2, encoding="utf-8")
    print("expanded", path)


def patch_cold_start_locale(app: str) -> None:
    path = ROOT / app / "lib" / "app" / "bootstrap" / "cold_start_app.dart"
    if not path.exists():
        return
    text = path.read_text(encoding="utf-8")
    if "AfterLocalePrefs.read" in text:
        return
    # After catalog: StringCatalog.seed(), apply locale
    if "catalog: StringCatalog.seed()," not in text:
        return
    text = text.replace(
        "catalog: StringCatalog.seed(),",
        "catalog: _catalogWithSavedLocale(prefs),",
    )
    # hospital uses prefs variable name - check
    if "_catalogWithSavedLocale" not in text:
        helper = '''
StringCatalog _catalogWithSavedLocale(SharedPreferences prefs) {
  final catalog = StringCatalog.seed();
  final saved = AfterLocalePrefs.read(
    prefs,
    legacyKey: '%s.locale',
  );
  if (saved != null) {
    catalog.setLocale(saved);
  }
  return catalog;
}
''' % (app,)
        text = text + "\n" + helper
    # Fix variable name if preferences vs prefs
    text = text.replace(
        "_catalogWithSavedLocale(prefs)",
        "_catalogWithSavedLocale(preferences)"
        if "preferences: prefs" in text or "final prefs =" not in text
        else "_catalogWithSavedLocale(prefs)",
    )
    # careful - read the file pattern
    path.write_text(text, encoding="utf-8")
    print("coldstart", path)


def main() -> None:
    for app in APPS:
        catalog = ROOT / app / "lib" / "app" / "l10n" / "string_catalog.dart"
        if catalog.exists():
            expand(catalog)
        # Fix cold start more carefully
        cs = ROOT / app / "lib" / "app" / "bootstrap" / "cold_start_app.dart"
        if not cs.exists():
            continue
        t = cs.read_text(encoding="utf-8")
        if "AfterLocalePrefs" in t:
            continue
        if "StringCatalog.seed()" not in t:
            continue
        # replace both occurrences of seed in snapshot
        t2 = t.replace(
            "catalog: StringCatalog.seed(),",
            "catalog: _seedCatalog(prefs),",
        )
        # hospital uses `final prefs = await prefsFuture`
        if "catalog: _seedCatalog(prefs)," not in t2:
            t2 = t.replace(
                "catalog: StringCatalog.seed(),",
                "catalog: _seedCatalog(preferences),",
            )
            helper_arg = "preferences"
        else:
            helper_arg = "prefs"
        if "_seedCatalog" not in t2:
            t2 += f"""

StringCatalog _seedCatalog(SharedPreferences {helper_arg}) {{
  final catalog = StringCatalog.seed();
  final saved = AfterLocalePrefs.read(
    {helper_arg},
    legacyKey: '{app}.locale',
  );
  if (saved != null) {{
    catalog.setLocale(saved);
  }}
  return catalog;
}}
"""
        cs.write_text(t2, encoding="utf-8")
        print("patched coldstart", app)


if __name__ == "__main__":
    main()
