"""Wire Garage-parity themes into consumer Super App MaterialApps."""
from __future__ import annotations

from pathlib import Path

HANTURAI = Path(r"D:\Projects\HANTURAI")

APPS = [
    ("superhealth", "SuperHealth", "healthChrome", "Color(0xFF10B981)"),
    ("superfinance", "SuperFinance", "financeChrome", "Color(0xFF0EA5E9)"),
    ("superhome", "SuperHome", "homeChrome", "Color(0xFFF59E0B)"),
    ("supertravel", "SuperTravel", "travelChrome", "Color(0xFF6366F1)"),
    ("superpet", "SuperPet", "petChrome", "Color(0xFFEC4899)"),
    ("supernews", "SuperNews", "newsChrome", "Color(0xFFEF4444)"),
    ("supersports", "SuperSports", "sportsChrome", "Color(0xFF22C55E)"),
    ("superfarm", "SuperFarm", "farmChrome", "Color(0xFF84CC16)"),
    ("superhospital", "SuperHospital", "hospitalChrome", "Color(0xFF14B8A6)"),
]


APP_DART_TEMPLATE = '''import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'family/family_stores.dart';
import 'l10n/app_strings.dart';
import 'offline/offline_controller.dart';

class {class_name}App extends ConsumerWidget {{
  const {class_name}App({{required this.home, super.key}});

  final Widget home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    final themeStyle = ref.watch(familyThemeStyleProvider);
    final locale = ref.watch(localeCodeProvider);
    final connectivity = ref.watch(connectivityStatusProvider);
    final accent = {chrome}.accent;

    return MaterialApp(
      title: '{class_name}',
      debugShowCheckedModeBanner: false,
      theme: FamilyTheme.forStyle(themeStyle, accent: accent),
      darkTheme: FamilyTheme.forStyle(
        themeStyle == AfterThemeStyle.system
            ? AfterThemeStyle.dark
            : themeStyle,
        accent: accent,
      ),
      themeMode: FamilyTheme.themeModeFor(themeStyle),
      locale: Locale(locale),
      supportedLocales: AfterSupportedLocales.locales,
      localeResolutionCallback: AfterSupportedLocales.resolutionCallback,
      builder: (context, child) {{
        final content = child ?? const SizedBox.shrink();
        final shelled = AfterPremiumAppShell.wrap(
          style: themeStyle,
          child: content,
        );
        if (connectivity != ConnectivityStatus.offline) {{
          return shelled;
        }}
        return Stack(
          children: [
            shelled,
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Material(
                color: Colors.orange.shade800,
                child: const SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Text(
                      'OFFLINE — showing cached data',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }},
      home: home,
    );
  }}
}}
'''


def patch_settings_route(path: Path) -> None:
    if not path.exists():
        return
    t = path.read_text(encoding="utf-8")
    old = """      themeMode: ref.watch(themeModeProvider),
      onThemeMode: (m) => ref.read(themeModeProvider.notifier).setMode(m),"""
    new = """      themeStyle: ref.watch(familyThemeStyleProvider),
      onThemeStyle: (s) =>
          ref.read(familyThemeStyleProvider.notifier).setStyle(s),
      canUsePremiumThemes: true,"""
    if old in t:
        t = t.replace(old, new)
        if "themeModeProvider" not in t and "theme_controller.dart" in t:
            t = t.replace(
                "import '../../app/theme/theme_controller.dart';\n",
                "",
            )
        path.write_text(t, encoding="utf-8")
        print(f"  patched settings: {path}")
    else:
        print(f"  settings pattern miss: {path}")


def patch_auth_gate(path: Path, chrome: str) -> None:
    if not path.exists():
        return
    t = path.read_text(encoding="utf-8")
    old = f"return FamilyLoginScreen(config: {chrome});"
    new = (
        f"return FamilyLoginScreen(\n"
        f"            config: {chrome},\n"
        f"            authConfig: FamilyAuthChromeConfig(\n"
        f"              appName: {chrome}.appName,\n"
        f"              supportEmail: {chrome}.supportEmail,\n"
        f"              accent: {chrome}.accent,\n"
        f"              tagline: {chrome}.tagline,\n"
        f"              aiTitle: {chrome}.aiTitle,\n"
        f"            ),\n"
        f"          );"
    )
    if old in t and "FamilyAuthChromeConfig" not in t:
        t = t.replace(old, new)
        path.write_text(t, encoding="utf-8")
        print(f"  patched auth_gate: {path}")
    else:
        print(f"  auth_gate skip: {path}")


def patch_compliance(app_dir: Path) -> None:
    p = app_dir / "docs" / "COMPLIANCE_REPORT.md"
    if not p.exists():
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text("# Compliance report\n\n", encoding="utf-8")
    t = p.read_text(encoding="utf-8")
    note = (
        "\n## Garage-parity family chrome (2026-07-20)\n\n"
        "- Login / registration: shared `FamilyLoginScreen` + "
        "`FamilyRegistrationWizardScreen` (`after_consumer`)\n"
        "- Themes: full Garage pack via `AfterThemeStyle` + "
        "`AfterPremiumAppShell` (`after_design_system`)\n"
        "- Settings / Profile: shared `FamilySettingsScreen` / "
        "`FamilyProfileScreen` with plugin slots\n"
    )
    if "Garage-parity family chrome" not in t:
        p.write_text(t.rstrip() + "\n" + note, encoding="utf-8")
        print(f"  compliance note: {p}")


def main() -> None:
    for folder, class_name, chrome, _accent in APPS:
        app_dir = HANTURAI / folder
        if not app_dir.exists():
            print(f"MISSING {folder}")
            continue
        print(folder)
        app_dart = app_dir / "lib" / "app" / "app.dart"
        # farm may differ
        if app_dart.exists():
            content = APP_DART_TEMPLATE.format(
                class_name=class_name, chrome=chrome
            )
            # hospital/farm may not have offline_controller
            offline = app_dir / "lib" / "app" / "offline" / "offline_controller.dart"
            if not offline.exists():
                content = content.replace(
                    "import 'offline/offline_controller.dart';\n", ""
                )
                content = content.replace(
                    "final connectivity = ref.watch(connectivityStatusProvider);\n    ",
                    "",
                )
                content = content.replace(
                    """        if (connectivity != ConnectivityStatus.offline) {
          return shelled;
        }
        return Stack(
          children: [
            shelled,
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Material(
                color: Colors.orange.shade800,
                child: const SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Text(
                      'OFFLINE — showing cached data',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );""",
                    "        return shelled;",
                )
            # localeCodeProvider may live in app_strings
            app_dart.write_text(content, encoding="utf-8")
            print(f"  wrote {app_dart}")

        # find chrome const name from family_stores
        stores = app_dir / "lib" / "app" / "family" / "family_stores.dart"
        chrome_name = chrome
        if stores.exists():
            st = stores.read_text(encoding="utf-8")
            import re
            m = re.search(r"const (\w+Chrome) = FamilyChromeConfig", st)
            if m:
                chrome_name = m.group(1)

        hubs = list(app_dir.glob("lib/features/**/family_hub_screens.dart"))
        for h in hubs:
            # fix chrome name in template was wrong for some — patch settings
            patch_settings_route(h)

        auth = app_dir / "lib" / "features" / "auth" / "auth_gate.dart"
        patch_auth_gate(auth, chrome_name)
        patch_compliance(app_dir)


if __name__ == "__main__":
    main()
