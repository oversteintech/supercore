#!/usr/bin/env python3
"""Apply family kit wiring to consumer Super Apps (Wave 1–2 helpers)."""

from __future__ import annotations

import re
from pathlib import Path

HANTURAI = Path(r"D:\Projects\HANTURAI")

APPS = {
    "superhealth": {
        "pkg": "super_health",
        "bundle": "com.overstein.superhealth",
        "name": "SuperHealth",
        "accent": "0xFF10B981",
        "email": "superhealth@overstein.com",
        "features": [
            ("medications", ["name", "dosage", "schedule"], "medication"),
            ("medical_records", ["title", "category", "notes"], "folder"),
            ("doctor_visits", ["title", "clinician", "when"], "event"),
            ("lab_results", ["title", "status", "date"], "science"),
            ("vaccinations", ["title", "date", "next"], "vaccines"),
            ("heart_rate", ["title", "value", "unit"], "favorite"),
            ("weight", ["title", "value", "unit"], "monitor_weight"),
            ("sleep", ["title", "hours", "quality"], "bedtime"),
            ("nutrition", ["title", "calories", "notes"], "restaurant"),
            ("emergency", ["title", "name", "phone"], "emergency"),
        ],
        "live": "Vitals Live",
    },
    "superfinance": {
        "pkg": "super_finance",
        "bundle": "com.overstein.superfinance",
        "name": "SuperFinance",
        "accent": "0xFF2563EB",
        "email": "superfinance@overstein.com",
        "features": [
            ("accounts", ["name", "type", "balance"], "account_balance"),
            ("cards", ["name", "last4", "network"], "credit_card"),
            ("income", ["title", "amount", "date"], "trending_up"),
            ("expenses", ["title", "amount", "category"], "payments"),
            ("subscriptions", ["title", "amount", "cycle"], "autorenew"),
            ("budgets", ["title", "limit", "spent"], "pie_chart"),
            ("investments", ["title", "value", "type"], "show_chart"),
            ("loans", ["title", "balance", "rate"], "request_quote"),
            ("insurance", ["title", "provider", "premium"], "shield"),
            ("reports", ["title", "period", "notes"], "description"),
        ],
        "live": "Markets Live",
    },
    "superhome": {
        "pkg": "super_home",
        "bundle": "com.overstein.superhome",
        "name": "SuperHome",
        "accent": "0xFFF59E0B",
        "email": "superhome@overstein.com",
        "features": [
            ("properties", ["title", "address", "type"], "home"),
            ("maintenance", ["title", "due", "status"], "build"),
            ("utilities", ["title", "provider", "account"], "bolt"),
            ("bills", ["title", "amount", "due"], "receipt"),
            ("appliances", ["title", "brand", "room"], "kitchen"),
            ("warranty", ["title", "expires", "item"], "verified"),
            ("inventory", ["title", "qty", "location"], "inventory_2"),
            ("cleaning", ["title", "area", "cadence"], "cleaning_services"),
            ("security", ["title", "status", "zone"], "security"),
            ("smart_home", ["title", "device", "state"], "devices"),
        ],
        "live": "Home Live",
    },
    "superpet": {
        "pkg": "super_pet",
        "bundle": "com.overstein.superpet",
        "name": "SuperPet",
        "accent": "0xFFEC4899",
        "email": "superpet@overstein.com",
        "features": [
            ("pets", ["name", "species", "breed"], "pets"),
            ("vaccinations", ["title", "date", "next"], "vaccines"),
            ("veterinary", ["title", "clinic", "when"], "local_hospital"),
            ("food", ["title", "brand", "schedule"], "restaurant"),
            ("weight", ["title", "value", "unit"], "monitor_weight"),
            ("medical_history", ["title", "date", "notes"], "folder"),
            ("appointments", ["title", "when", "place"], "event"),
            ("insurance", ["title", "provider", "policy"], "shield"),
            ("documents", ["title", "type", "notes"], "description"),
        ],
        "live": "Pet Live",
    },
}


def fix_bundle(app_dir: Path, old_hint: str, bundle: str) -> None:
    gradle = app_dir / "android" / "app" / "build.gradle.kts"
    if gradle.exists():
        text = gradle.read_text(encoding="utf-8")
        text = re.sub(r'namespace\s*=\s*"[^"]+"', f'namespace = "{bundle}"', text)
        text = re.sub(
            r'applicationId\s*=\s*"[^"]+"', f'applicationId = "{bundle}"', text
        )
        gradle.write_text(text, encoding="utf-8")
    for p in app_dir.rglob("*.dart"):
        if "manifest" in p.name.lower() or "platform" in str(p).lower():
            t = p.read_text(encoding="utf-8")
            nt = t.replace("com.afterartificial.", "com.overstein.")
            if nt != t:
                p.write_text(nt, encoding="utf-8")


def ensure_pubspec(app_dir: Path) -> None:
    pub = app_dir / "pubspec.yaml"
    text = pub.read_text(encoding="utf-8")
    if "after_consumer:" in text:
        return
    block = """  after_ai:
    path: ../supercore/packages/after_ai
  after_consumer:
    path: ../supercore/packages/after_consumer
  after_ecosystem:
    path: ../supercore/packages/after_ecosystem
"""
    text = text.replace(
        "  after_core:\n",
        block + "  after_core:\n",
        1,
    )
    pub.write_text(text, encoding="utf-8")


def write_family_module(app_dir: Path, key: str, cfg: dict) -> None:
    feats = cfg["features"]
    lines = [
        "import 'package:after_consumer/after_consumer.dart';",
        "import 'package:flutter/material.dart';",
        "import 'package:flutter_riverpod/flutter_riverpod.dart';",
        "",
        f"final {key}MembershipProvider =",
        "    NotifierProvider<FamilyMembershipController, FamilyMembershipState>(",
        f"  () => FamilyMembershipController('{cfg['pkg']}.membership.plan'),",
        ");",
        "",
        f"const {key}Chrome = FamilyChromeConfig(",
        f"  appName: '{cfg['name']}',",
        f"  supportEmail: '{cfg['email']}',",
        f"  accent: Color({cfg['accent']}),",
        f"  tagline: '{cfg['name']} — powered by After Framework',",
        f"  aiTitle: '{cfg['name']} AI',",
        ");",
        "",
    ]
    for feat, fields, _icon in feats:
        seed_fields = ", ".join(f"'{f}': 'Sample {f}'" for f in fields)
        lines += [
            f"final {feat}StoreProvider = familyMapListProvider(",
            f"  '{cfg['pkg']}.{feat}',",
            "  seed: const [",
            "    FamilyMapRecord(",
            f"      id: '{feat}_1',",
            f"      fields: {{{seed_fields}}},",
            "    ),",
            "  ],",
            ");",
            "",
        ]
    out = app_dir / "lib" / "app" / "family" / "family_stores.dart"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text("\n".join(lines), encoding="utf-8")

    # CRUD screen wrappers
    for feat, fields, icon in feats:
        screen_dir = app_dir / "lib" / "features" / "family_crud"
        screen_dir.mkdir(parents=True, exist_ok=True)
        class_name = "".join(p.capitalize() for p in feat.split("_")) + "CrudScreen"
        field_list = ", ".join(f"'{f}'" for f in fields)
        screen = f"""import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';

import '../../app/family/family_stores.dart';

class {class_name} extends StatelessWidget {{
  const {class_name}({{super.key}});

  @override
  Widget build(BuildContext context) {{
    return FamilyCrudListPage(
      title: '{feat.replace('_', ' ').title()}',
      listProvider: {feat}StoreProvider,
      fieldKeys: const [{field_list}],
      icon: Icons.{icon}_outlined,
    );
  }}
}}
"""
        # fix icons that don't have _outlined
        screen = screen.replace("Icons.vaccines_outlined", "Icons.vaccines")
        screen = screen.replace("Icons.monitor_weight_outlined", "Icons.monitor_weight")
        screen = screen.replace("Icons.inventory_2_outlined", "Icons.inventory_2")
        screen = screen.replace("Icons.cleaning_services_outlined", "Icons.cleaning_services")
        screen = screen.replace("Icons.devices_outlined", "Icons.devices_other")
        screen = screen.replace("Icons.autorenew_outlined", "Icons.autorenew")
        screen = screen.replace("Icons.show_chart_outlined", "Icons.show_chart")
        screen = screen.replace("Icons.request_quote_outlined", "Icons.request_quote")
        (screen_dir / f"{feat}_crud_screen.dart").write_text(screen, encoding="utf-8")

    # Live + chrome hub
    hub = app_dir / "lib" / "features" / "family_crud" / "family_hub_screens.dart"
    hub.write_text(
        f"""import 'package:after_ai/after_ai.dart';
import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/family/family_stores.dart';
import '../../app/theme/theme_controller.dart';

class FamilyLiveScreen extends StatelessWidget {{
  const FamilyLiveScreen({{super.key}});

  @override
  Widget build(BuildContext context) {{
    return FamilyLiveScaffold(
      title: '{cfg['live']}',
      subtitle: 'Mock live stream — hardware adapters later',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.sensors),
            title: Text('Signal OK'),
            subtitle: Text('Last pulse: just now'),
          ),
          ListTile(
            leading: Icon(Icons.timeline),
            title: Text('Trend stable'),
            subtitle: Text('No alerts'),
          ),
        ],
      ),
    );
  }}
}}

class FamilyAiTab extends ConsumerWidget {{
  const FamilyAiTab({{super.key}});

  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    final platform = ref.watch(afterAiPlatformProvider);
    return FamilyAiChatScreen(
      title: {key}Chrome.aiTitle,
      onSend: (prompt) => platform.chat(message: prompt),
    );
  }}
}}

class FamilyProfileTab extends ConsumerWidget {{
  const FamilyProfileTab({{super.key}});

  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    final membership = ref.watch({key}MembershipProvider);
    return FamilyProfileScreen(
      config: {key}Chrome,
      membership: membership,
      onOpenSettings: () {{
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FamilySettingsScreen(
              config: {key}Chrome,
              membership: membership,
              onSetPlan: (p) =>
                  ref.read({key}MembershipProvider.notifier).setPlan(p),
              themeMode: ref.watch(themeModeProvider),
              onThemeMode: (m) =>
                  ref.read(themeModeProvider.notifier).setMode(m),
              localeCode: ref.watch(localeCodeProvider),
              onLocale: (c) =>
                  ref.read(localeCodeProvider.notifier).setLocale(c),
            ),
          ),
        );
      }},
      onOpenAbout: () {{
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FamilyAboutScreen(config: {key}Chrome),
          ),
        );
      }},
      onOpenMembership: () {{
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FamilySettingsScreen(
              config: {key}Chrome,
              membership: membership,
              onSetPlan: (p) =>
                  ref.read({key}MembershipProvider.notifier).setPlan(p),
            ),
          ),
        );
      }},
    );
  }}
}}

class FamilyFeatureCatalogScreen extends StatelessWidget {{
  const FamilyFeatureCatalogScreen({{super.key}});

  @override
  Widget build(BuildContext context) {{
    final items = <(String, WidgetBuilder)>[
{chr(10).join(
    f"      ('{feat.replace('_', ' ').title()}', (_) => {''.join(p.capitalize() for p in feat.split('_'))}CrudScreen()),"
    for feat, _, _ in feats
)}
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Features')),
      body: ListView(
        children: [
          for (final item in items)
            ListTile(
              title: Text(item.$1),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: item.$2),
              ),
            ),
        ],
      ),
    );
  }}
}}
""",
        encoding="utf-8",
    )

    # Fix catalog imports
    imports = "\n".join(
        f"import '{feat}_crud_screen.dart';" for feat, _, _ in feats
    )
    text = hub.read_text(encoding="utf-8")
    # Dart 3 records use $1 incorrectly in f-string - I used wrong syntax
    # Rewrite catalog screen properly
    catalog_items = ",\n".join(
        f"      _Feat('{feat.replace('_', ' ').title()}', {''.join(p.capitalize() for p in feat.split('_'))}CrudScreen.new)"
        for feat, _, _ in feats
    )
    hub.write_text(
        f"""import 'package:after_ai/after_ai.dart';
import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/family/family_stores.dart';
import '../../app/l10n/app_strings.dart';
import '../../app/theme/theme_controller.dart';
{imports}

class FamilyLiveScreen extends StatelessWidget {{
  const FamilyLiveScreen({{super.key}});

  @override
  Widget build(BuildContext context) {{
    return FamilyLiveScaffold(
      title: '{cfg['live']}',
      subtitle: 'Mock live stream — hardware adapters later',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.sensors),
            title: Text('Signal OK'),
            subtitle: Text('Last pulse: just now'),
          ),
          ListTile(
            leading: Icon(Icons.timeline),
            title: Text('Trend stable'),
            subtitle: Text('No alerts'),
          ),
        ],
      ),
    );
  }}
}}

class FamilyAiTab extends ConsumerWidget {{
  const FamilyAiTab({{super.key}});

  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    final platform = ref.watch(afterAiPlatformProvider);
    return FamilyAiChatScreen(
      title: {key}Chrome.aiTitle,
      onSend: (prompt) => platform.chat(message: prompt),
    );
  }}
}}

class FamilyProfileTab extends ConsumerWidget {{
  const FamilyProfileTab({{super.key}});

  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    final membership = ref.watch({key}MembershipProvider);
    return FamilyProfileScreen(
      config: {key}Chrome,
      membership: membership,
      onOpenSettings: () {{
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _SettingsRoute(membership: membership),
          ),
        );
      }},
      onOpenAbout: () {{
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FamilyAboutScreen(config: {key}Chrome),
          ),
        );
      }},
      onOpenMembership: () {{
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _SettingsRoute(membership: membership),
          ),
        );
      }},
    );
  }}
}}

class _SettingsRoute extends ConsumerWidget {{
  const _SettingsRoute({{required this.membership}});
  final FamilyMembershipState membership;

  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    return FamilySettingsScreen(
      config: {key}Chrome,
      membership: membership,
      onSetPlan: (p) => ref.read({key}MembershipProvider.notifier).setPlan(p),
      themeMode: ref.watch(themeModeProvider),
      onThemeMode: (m) => ref.read(themeModeProvider.notifier).setMode(m),
      localeCode: ref.watch(localeCodeProvider),
      onLocale: (c) => ref.read(localeCodeProvider.notifier).setLocale(c),
    );
  }}
}}

class _Feat {{
  const _Feat(this.title, this.builder);
  final String title;
  final Widget Function({{Key? key}}) builder;
}}

class FamilyFeatureCatalogScreen extends StatelessWidget {{
  const FamilyFeatureCatalogScreen({{super.key}});

  static final items = <_Feat>[
{catalog_items},
  ];

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      appBar: AppBar(title: const Text('Features')),
      body: ListView(
        children: [
          for (final item in items)
            ListTile(
              title: Text(item.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => item.builder()),
              ),
            ),
        ],
      ),
    );
  }}
}}
""",
        encoding="utf-8",
    )


def main() -> None:
    for folder, cfg in APPS.items():
        app_dir = HANTURAI / folder
        if not app_dir.exists():
            print(f"SKIP missing {folder}")
            continue
        print(f"==> {folder}")
        ensure_pubspec(app_dir)
        fix_bundle(app_dir, "afterartificial", cfg["bundle"])
        key = folder.replace("super", "super")  # healthFinance naming
        # membership provider prefix
        prefix = {
            "superhealth": "health",
            "superfinance": "finance",
            "superhome": "home",
            "superpet": "pet",
        }[folder]
        write_family_module(app_dir, prefix, cfg)
        print(f"    wired {len(cfg['features'])} CRUD features")


if __name__ == "__main__":
    main()
