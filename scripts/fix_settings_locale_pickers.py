"""Repair corrupted language pickers after partial SegmentedButton replace."""
from __future__ import annotations

import re
from pathlib import Path

HANTURAI = Path(r"D:\Projects\HANTURAI")
APPS = [
    "supersports",
    "superhealth",
    "superfinance",
    "superhome",
    "superpet",
    "supertravel",
    "supernews",
]


def dropdown(prefs_key: str) -> str:
    return f"""            AfterSectionHeader(title: ref.tr('settings.language')),
            DropdownButtonFormField<String>(
              value: AfterSupportedLocales.isSupported(locale)
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


def fix(app: str) -> None:
    path = HANTURAI / app / "lib" / "features" / "settings" / "settings_screen.dart"
    text = path.read_text(encoding="utf-8")
    prefs_m = re.search(r"setString\('([^']+\.locale)'", text)
    prefs_key = prefs_m.group(1) if prefs_m else f"{app}.locale"

    # Remove any broken language section (dropdown + leftover segments, or old segmented)
    pattern = re.compile(
        r"\s*AfterSectionHeader\(title: ref\.tr\('settings\.language'\)\),"
        r"[\s\S]*?"
        r"(?=const SizedBox\(height: 24\),\s*AfterSectionHeader\(title: ref\.tr\('settings\.(?:notifications|privacy|about))",
        re.M,
    )
    if not pattern.search(text):
        # try looser: from language header through next SizedBox before notifications
        pattern = re.compile(
            r"\s*AfterSectionHeader\(title: ref\.tr\('settings\.language'\)\),"
            r"[\s\S]*?"
            r"(?=\s*const SizedBox\(height: 24\),\s*\n\s*AfterSectionHeader)",
            re.M,
        )
    new_block = "\n" + dropdown(prefs_key) + "\n"
    text2, n = pattern.subn(new_block, text, count=1)
    if n == 0:
        print(f"{app}: NO MATCH")
        return
    if "import 'package:after_core/after_core.dart';" not in text2:
        text2 = "import 'package:after_core/after_core.dart';\n" + text2
    path.write_text(text2, encoding="utf-8")
    print(f"{app}: fixed")


def main() -> None:
    for app in APPS:
        fix(app)


if __name__ == "__main__":
    main()
