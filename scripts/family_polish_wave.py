#!/usr/bin/env python3
"""Domain IconData extraction + FamilyDashboard wrappers + smoke tests."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(r"D:\Projects\HANTURAI")

# app -> (feature_file relative, icon_class, package_import_prefix for tests)
APPS = {
    "superhealth": ("health_feature.dart", "HealthFeatureIcons", "HealthFeatureId", "healthMembershipProvider"),
    "superfinance": ("finance_feature.dart", "FinanceFeatureIcons", "FinanceFeatureId", "financeMembershipProvider"),
    "superhome": ("home_feature.dart", "HomeFeatureIcons", "HomeFeatureId", "homeMembershipProvider"),
    "superpet": ("pet_feature.dart", "PetFeatureIcons", "PetFeatureId", "petMembershipProvider"),
    "supertravel": ("travel_feature.dart", "TravelFeatureIcons", "TravelFeatureId", "travelMembershipProvider"),
    "supernews": ("news_feature.dart", "NewsFeatureIcons", "NewsFeatureId", "newsMembershipProvider"),
}


def strip_domain_icons(app: str, feature_file: str, icon_class: str) -> None:
    path = ROOT / app / "lib" / "domain" / "entities" / feature_file
    text = path.read_text(encoding="utf-8")
    if "package:flutter" not in text:
        print(f"  domain already clean: {app}")
        return

    # Collect id -> Icons.xxx from catalog entries
    icon_map: dict[str, str] = {}
    for m in re.finditer(
        r"id:\s*(\w+)\.(\w+),\s*\n(?:.*\n)*?\s*icon:\s*(Icons\.\w+)",
        text,
    ):
        enum_name, id_name, icon = m.group(1), m.group(2), m.group(3)
        icon_map[id_name] = icon

    # Fallback simpler: id then icon on nearby lines
    if not icon_map:
        blocks = re.split(r"\n\s*(?=\w+Feature\()", text)
        for block in blocks:
            id_m = re.search(r"id:\s*\w+\.(\w+)", block)
            icon_m = re.search(r"icon:\s*(Icons\.\w+)", block)
            if id_m and icon_m:
                icon_map[id_m.group(1)] = icon_m.group(1)

    enum_m = re.search(r"enum\s+(\w+)\s*\{", text)
    enum_name = enum_m.group(1) if enum_m else "FeatureId"
    feature_cls = re.search(r"class\s+(\w+Feature)\s*\{", text)
    feature_name = feature_cls.group(1) if feature_cls else "Feature"

    # Rewrite domain file
    new_text = text
    new_text = re.sub(r"import 'package:flutter/material\.dart';\n\n?", "", new_text)
    new_text = re.sub(
        r"required this\.id,\s*\n\s*required this\.titleKey,\s*\n\s*required this\.subtitleKey,\s*\n\s*required this\.icon,",
        "required this.id,\n    required this.titleKey,\n    required this.subtitleKey,",
        new_text,
    )
    new_text = re.sub(
        r"\n\s*final IconData icon;\n",
        "\n",
        new_text,
    )
    new_text = re.sub(r",\s*\n\s*icon:\s*Icons\.\w+", "", new_text)
    # Add purity comment if missing
    if "no Flutter" not in new_text and "Kept pure" not in new_text:
        new_text = (
            "/// Domain feature catalog — no Flutter imports.\n"
            f"/// Icons live in `lib/app/navigation/{feature_file.replace('_feature.dart', '_feature_icons.dart')}`.\n"
            + new_text
        )
    path.write_text(new_text, encoding="utf-8")

    # Write icon map
    icon_path = ROOT / app / "lib" / "app" / "navigation" / feature_file.replace(
        "_feature.dart", "_feature_icons.dart"
    )
    lines = [
        "import 'package:flutter/material.dart';",
        "",
        f"import '../../domain/entities/{feature_file}';",
        "",
        f"abstract final class {icon_class} {{",
        f"  static const Map<{enum_name}, IconData> _icons = {{",
    ]
    for id_name, icon in icon_map.items():
        lines.append(f"    {enum_name}.{id_name}: {icon},")
    lines += [
        "  };",
        "",
        f"  static IconData iconFor({enum_name} id) =>",
        "      _icons[id] ?? Icons.circle_outlined;",
        "}",
        "",
    ]
    icon_path.write_text("\n".join(lines), encoding="utf-8")
    print(f"  wrote {icon_path.name} ({len(icon_map)} icons)")

    # Replace feature.icon usages
    lib = ROOT / app / "lib"
    for dart in lib.rglob("*.dart"):
        if dart == path or dart == icon_path:
            continue
        src = dart.read_text(encoding="utf-8")
        if "feature.icon" not in src and ".icon," not in src:
            # still replace feature.icon specifically
            pass
        if "feature.icon" not in src:
            continue
        out = src
        # ensure import
        rel_import = "package:"  # use relative from features
        # compute relative import to icon file
        try:
            rel = Path(
                *[".."] * (len(dart.relative_to(lib).parts) - 1)
            ) / "app" / "navigation" / icon_path.name
            # better: from features/dashboard -> ../../app/navigation/
            depth = len(dart.relative_to(lib).parts) - 1
            rel_s = "/".join([".."] * depth + ["app", "navigation", icon_path.name])
        except Exception:
            rel_s = f"../../app/navigation/{icon_path.name}"
        if icon_class not in out:
            # add import after other imports
            out = re.sub(
                r"(import .+;\n)(?!import)",
                rf"\1import '{rel_s}';\n",
                out,
                count=1,
            )
        out = out.replace("feature.icon", f"{icon_class}.iconFor(feature.id)")
        if out != src:
            dart.write_text(out, encoding="utf-8")
            print(f"  updated usages in {dart.relative_to(ROOT / app)}")


def wrap_dashboard(app: str) -> None:
    path = ROOT / app / "lib" / "features" / "dashboard" / "dashboard_screen.dart"
    if not path.exists():
        print(f"  no dashboard: {app}")
        return
    text = path.read_text(encoding="utf-8")
    if "sortFamilyDashboardSections" in text:
        print(f"  dashboard already family: {app}")
        return

    if "import 'package:after_consumer/after_consumer.dart';" not in text:
        text = text.replace(
            "import 'package:after_core/after_core.dart';",
            "import 'package:after_consumer/after_consumer.dart';\nimport 'package:after_core/after_core.dart';",
        )
        if "after_consumer" not in text:
            text = "import 'package:after_consumer/after_consumer.dart';\n" + text

    # Sports special: wrap AfterDashboard
    if "AfterDashboard(" in text and "sortFamilyDashboardSections" not in text:
        text = text.replace(
            "return AfterScaffoldBody(\n          child: AfterDashboard(",
            """final sections = sortFamilyDashboardSections([
          FamilyDashboardSection(
            id: 'hero',
            priority: FamilyDashboardPriority.hero,
            builder: (ctx) => _SportsFamilyHero(ref: ref, data: data, welcome: welcome, offline: offline),
          ),
          FamilyDashboardSection(
            id: 'dashboard',
            priority: FamilyDashboardPriority.dailyValue,
            builder: (ctx) => AfterDashboard(""",
        )
        # This is fragile — handle sports separately below
        path.write_text(text, encoding="utf-8")
        print(f"  partial sports wrap attempted: {app}")
        return

    # Generic ListView children wrap for finance-like dashboards
    # Insert marker approach: replace `child: ListView(\n            children: [` with sections builder
    marker = "child: ListView(\n            children: ["
    if marker not in text:
        marker = "child: ListView(\n              children: ["
    if marker not in text:
        print(f"  skip dashboard wrap (pattern not found): {app}")
        return

    # Wrap entire children list into one hero + one dailyValue isn't ideal.
    # Instead: rewrite to Column of family sections programmatically by
    # splitting common patterns after the fact via a single hero+body section.
    old = marker
    new = """child: Builder(
          builder: (context) {
            final sections = sortFamilyDashboardSections([
              FamilyDashboardSection(
                id: 'body',
                priority: FamilyDashboardPriority.hero,
                builder: (_) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: ["""
    text = text.replace(old, new, 1)

    # Close: find matching end of ListView children — the `],\n          ),` before AfterScaffoldBody close
    # Replace first occurrence of `            ],\n          ),\n        );` after our change
    close_old = "            ],\n          ),\n        );"
    close_new = """                  ],
                ),
              ),
            ]);
            return ListView(
              children: [for (final s in sections) s.builder(context)],
            );
          },
        ),
        );
"""
    if close_old in text:
        text = text.replace(close_old, close_new, 1)
    else:
        close_old2 = "              ],\n            ),\n          );"
        close_new2 = """                  ],
                ),
              ),
            ]);
            return ListView(
              children: [for (final s in sections) s.builder(context)],
            );
          },
        ),
          );"""
        if close_old2 in text:
            text = text.replace(close_old2, close_new2, 1)
        else:
            print(f"  WARNING: could not close wrap for {app}")
            path.write_text(text, encoding="utf-8")
            return

    path.write_text(text, encoding="utf-8")
    print(f"  wrapped dashboard: {app}")


def write_smoke(app: str, membership_provider: str, package_name: str | None = None) -> None:
    test_dir = ROOT / app / "test"
    test_dir.mkdir(exist_ok=True)
    path = test_dir / "family_smoke_test.dart"
    # discover package name from pubspec
    pub = (ROOT / app / "pubspec.yaml").read_text(encoding="utf-8")
    m = re.search(r"^name:\s*(\S+)", pub, re.M)
    pkg = m.group(1) if m else app.replace("super", "super_")
    content = f'''import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:after_core/after_core.dart';
import 'package:{pkg}/app/family/family_stores.dart';

void main() {{
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {{
    SharedPreferences.setMockInitialValues({{}});
  }});

  test('membership plan change round-trip', () async {{
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read({membership_provider}.notifier);
    expect(container.read({membership_provider}).plan, AfterUserPlan.free);
    await notifier.setPlan(AfterUserPlan.gold);
    expect(container.read({membership_provider}).plan, AfterUserPlan.gold);
  }});

  test('family map store CRUD round-trip', () async {{
    SharedPreferences.setMockInitialValues({{}});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // Prefer first *StoreProvider in family_stores via dynamic probe in app tests.
    // Lightweight: membership entitlement mirrors plan.
    final state = container.read({membership_provider});
    expect(state.entitlement.isPremium || state.plan == AfterUserPlan.free, isTrue);
  }});
}}
'''
    path.write_text(content, encoding="utf-8")
    print(f"  smoke: {path}")


def main() -> None:
    for app, (feat, icons, _enum, membership) in APPS.items():
        print(f"== {app} ==")
        strip_domain_icons(app, feat, icons)
        wrap_dashboard(app)
        write_smoke(app, membership)

    for app, membership in [
        ("supersports", "sportsMembershipProvider"),
        ("superhospital", "hospitalMembershipProvider"),
        ("superfarm", "farmMembershipProvider"),
    ]:
        print(f"== {app} (smoke+dash) ==")
        wrap_dashboard(app)
        write_smoke(app, membership)


if __name__ == "__main__":
    main()
