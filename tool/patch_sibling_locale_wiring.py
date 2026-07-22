#!/usr/bin/env python3
"""Wire MainShell nav labels + locale persistence across Super Apps."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(r"D:/Projects/HANTURAI")

APPS = [
    "superhealth",
    "superfinance",
    "superhome",
    "supertravel",
    "superpet",
    "supernews",
    "supersports",
    "superfarm",
    "superhospital",
    "superairport",
    "superfactory",
    "supermaritime",
    "afterhub",
]


def patch_main_shell(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    if "FamilyUiStrings.t('nav_home'" in text:
        return False
    if "AfterNavigationBar(" not in text and "destinations:" not in text:
        return False

    app_strings = path.parent.parent.parent / "app" / "l10n" / "app_strings.dart"
    if app_strings.exists() and "app_strings.dart" not in text:
        # insert after riverpod import
        text = text.replace(
            "import 'package:flutter_riverpod/flutter_riverpod.dart';\n",
            "import 'package:flutter_riverpod/flutter_riverpod.dart';\n"
            "import '../../app/l10n/app_strings.dart';\n",
        )

    if "afterhub" in str(path).replace("\\", "/") and "theme_controller" not in text:
        text = text.replace(
            "import 'package:flutter_riverpod/flutter_riverpod.dart';\n",
            "import 'package:flutter_riverpod/flutter_riverpod.dart';\n"
            "import '../../app/theme/theme_controller.dart';\n",
        )

    if "ref.watch(localeCodeProvider)" not in text:
        if "final tab = ref.watch(mainTabProvider);" in text:
            text = text.replace(
                "final tab = ref.watch(mainTabProvider);",
                "final tab = ref.watch(mainTabProvider);\n"
                "    final locale = ref.watch(localeCodeProvider);",
            )
        else:
            m = re.search(r"(Widget build\(BuildContext context\) \{\n)(\s+)", text)
            if m:
                text = text.replace(
                    m.group(0),
                    m.group(0) + m.group(2) + "final locale = ref.watch(localeCodeProvider);\n",
                    1,
                )

    def repl_labels(block: str) -> str:
        reps = [
            ("label: 'Home'", "label: FamilyUiStrings.t('nav_home', locale)"),
            ("label: 'Live'", "label: FamilyUiStrings.t('nav_live', locale)"),
            ("label: 'AI'", "label: FamilyUiStrings.t('nav_ai', locale)"),
            ("label: 'Features'", "label: FamilyUiStrings.t('nav_features', locale)"),
            ("label: 'Settings'", "label: FamilyUiStrings.t('nav_settings', locale)"),
            ("label: \"Home\"", "label: FamilyUiStrings.t('nav_home', locale)"),
            ("label: \"Live\"", "label: FamilyUiStrings.t('nav_live', locale)"),
            ("label: \"AI\"", "label: FamilyUiStrings.t('nav_ai', locale)"),
            ("label: \"Features\"", "label: FamilyUiStrings.t('nav_features', locale)"),
            ("label: \"Settings\"", "label: FamilyUiStrings.t('nav_settings', locale)"),
        ]
        for a, b in reps:
            block = block.replace(a, b)
        return block

    m = re.search(r"destinations:\s*const\s*\[(.*?)\],", text, re.S)
    if m:
        block = repl_labels(m.group(1))
        text = text[: m.start()] + f"destinations: [{block}]," + text[m.end() :]
    else:
        m2 = re.search(r"destinations:\s*\[(.*?)\],", text, re.S)
        if not m2:
            print("  no destinations", path)
            return False
        block = repl_labels(m2.group(1))
        text = text[: m2.start()] + f"destinations: [{block}]," + text[m2.end() :]

    path.write_text(text, encoding="utf-8")
    return True


def patch_app_strings(path: Path, app_id: str) -> bool:
    text = path.read_text(encoding="utf-8")
    if "AfterLocalePrefs" in text:
        return False
    if "class LocaleCodeController" not in text:
        return False

    if "import 'dart:async';" not in text:
        text = "import 'dart:async';\n" + text
    if "package:after_core/after_core.dart" not in text:
        text = "import 'package:after_core/after_core.dart';\n" + text
    if "shared_preferences" not in text:
        text = "import 'package:shared_preferences/shared_preferences.dart';\n" + text

    legacy = f"'{app_id}.locale'"
    persist = (
        "\n\n  Future<void> _persist(String code) async {\n"
        "    final prefs = await SharedPreferences.getInstance();\n"
        f"    await AfterLocalePrefs.write(prefs, code, legacyKey: {legacy});\n"
        "  }"
    )

    if "catalog.setLocale(code);" in text and "unawaited(_persist" not in text:
        text = text.replace(
            "catalog.setLocale(code);\n    state = catalog.locale;\n  }",
            "catalog.setLocale(code);\n"
            "    state = catalog.locale;\n"
            "    unawaited(_persist(code));\n"
            "  }" + persist,
            1,
        )
    elif "void setLocale(String code) => state = code;" in text:
        text = text.replace(
            "void setLocale(String code) => state = code;",
            "void setLocale(String code) {\n"
            "    state = code;\n"
            "    unawaited(_persist(code));\n"
            "  }" + persist,
            1,
        )
    elif "void setLocale(String code) {" in text and "unawaited(_persist" not in text:
        text = re.sub(
            r"(void setLocale\(String code\) \{)(.*?)(\n  \})",
            r"\1\2\n    unawaited(_persist(code));\3" + persist,
            text,
            count=1,
            flags=re.S,
        )
    else:
        return False

    path.write_text(text, encoding="utf-8")
    return True


def patch_bootstrap(path: Path, app_id: str) -> bool:
    text = path.read_text(encoding="utf-8")
    if "AfterLocalePrefs" in text:
        return False
    legacy = f"'{app_id}.locale'"

    patterns = [
        (
            "final savedLocale = preferences.getString(" + legacy + ");\n"
            "    if (savedLocale != null) {\n"
            "      catalog.setLocale(savedLocale);\n"
            "    }",
            "final savedLocale = AfterLocalePrefs.read(\n"
            "      preferences,\n"
            f"      legacyKey: {legacy},\n"
            "    );\n"
            "    if (savedLocale != null) {\n"
            "      catalog.setLocale(savedLocale);\n"
            "    }",
        ),
        (
            "final savedLocale = preferences.getString(AppConfig.localePrefsKey);\n"
            "    if (savedLocale != null) {\n"
            "      catalog.setLocale(savedLocale);\n"
            "    }",
            "final savedLocale = AfterLocalePrefs.read(\n"
            "      preferences,\n"
            "      legacyKey: AppConfig.localePrefsKey,\n"
            "    );\n"
            "    if (savedLocale != null) {\n"
            "      catalog.setLocale(savedLocale);\n"
            "    }",
        ),
    ]
    for old, new in patterns:
        if old in text:
            path.write_text(text.replace(old, new, 1), encoding="utf-8")
            return True
    return False


def main() -> None:
    for app in APPS:
        base = ROOT / app
        for shell in base.glob("lib/**/main_shell.dart"):
            ok = patch_main_shell(shell)
            print(("ok" if ok else "skip"), "shell", shell.relative_to(ROOT))
        for p in list(base.glob("lib/**/app_strings.dart")) + list(
            base.glob("lib/**/theme_controller.dart")
        ):
            raw = p.read_text(encoding="utf-8")
            if "LocaleCodeController" not in raw:
                continue
            ok = patch_app_strings(p, app)
            print(("ok" if ok else "skip"), "locale", p.relative_to(ROOT))
        for p in base.glob("lib/**/app_runtime_bootstrap.dart"):
            ok = patch_bootstrap(p, app)
            print(("ok" if ok else "skip"), "boot", p.relative_to(ROOT))


if __name__ == "__main__":
    main()
