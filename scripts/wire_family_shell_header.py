"""Wire FamilyShellHeader into consumer MainShell scaffolds."""
from __future__ import annotations

import re
from pathlib import Path

HANTURAI = Path(r"D:\Projects\HANTURAI")

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
]

TEMPLATE = """import 'package:after_consumer/after_consumer.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/family/family_stores.dart';
import '../../app/navigation/shell_navigation.dart';
import '../dashboard/dashboard_screen.dart';
import '../family_crud/family_hub_screens.dart';

/// Family shell with Garage-parity top bar (plan badge + short app title).
class MainShell extends ConsumerStatefulWidget {{
  const MainShell({{super.key}});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}}

class _MainShellState extends ConsumerState<MainShell> {{
  final Set<int> _visited = {{0}};
  final Map<int, Widget> _bodies = {{}};

  Widget _body(int index) {{
    return _bodies.putIfAbsent(index, () {{
      switch (MainTab.values[index]) {{
        case MainTab.dashboard:
          return const DashboardScreen();
        case MainTab.live:
          return const FamilyLiveScreen();
        case MainTab.assistant:
          return const FamilyAiTab();
        case MainTab.features:
          return const FamilyFeatureCatalogScreen();
        case MainTab.profile:
          return const FamilyProfileTab();
      }}
    }});
  }}

  @override
  Widget build(BuildContext context) {{
    final tab = ref.watch(mainTabProvider);
    final index = MainTab.values.indexOf(tab);
    _visited.add(index);
    final membership = ref.watch({membership});

    return Scaffold(
      body: Column(
        children: [
          FamilyShellHeader(
            title: {chrome}.shellTitle,
            plan: membership.plan,
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                for (final i in _visited)
                  Offstage(
                    offstage: i != index,
                    child: TickerMode(
                      enabled: i == index,
                      child: KeyedSubtree(key: ValueKey(i), child: _body(i)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AfterNavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {{
          ref.read(mainTabProvider.notifier).select(MainTab.values[i]);
        }},
        destinations: const [
          AfterNavDestination(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Home',
          ),
          AfterNavDestination(
            icon: Icons.sensors_outlined,
            selectedIcon: Icons.sensors,
            label: 'Live',
          ),
          AfterNavDestination(
            icon: Icons.auto_awesome_outlined,
            selectedIcon: Icons.auto_awesome,
            label: 'AI',
          ),
          AfterNavDestination(
            icon: Icons.grid_view_outlined,
            selectedIcon: Icons.grid_view,
            label: 'Features',
          ),
          AfterNavDestination(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }}
}}
"""


def detect(app_dir: Path) -> tuple[str, str]:
    stores = (app_dir / "lib" / "app" / "family" / "family_stores.dart").read_text(
        encoding="utf-8"
    )
    chrome = re.search(r"const (\w+Chrome) = FamilyChromeConfig", stores).group(1)
    mem = re.search(
        r"final (\w+MembershipProvider)\s*=\s*NotifierProvider", stores
    ).group(1)
    return chrome, mem


def add_header_title(stores_path: Path, chrome: str, title: str) -> None:
    st = stores_path.read_text(encoding="utf-8")
    if "headerTitle:" in st:
        return
    st = st.replace(
        f"const {chrome} = FamilyChromeConfig(\n  appName:",
        f"const {chrome} = FamilyChromeConfig(\n  appName:",
        1,
    )
    # insert after appName line
    st = re.sub(
        rf"(const {chrome} = FamilyChromeConfig\(\n  appName: '[^']+',\n)",
        rf"\1  headerTitle: '{title}',\n",
        st,
        count=1,
    )
    stores_path.write_text(st, encoding="utf-8")


def main() -> None:
    titles = {
        "superhealth": "Health",
        "superfinance": "Finance",
        "superhome": "Home",
        "supertravel": "Travel",
        "superpet": "Pet",
        "supernews": "News",
        "supersports": "Sports",
        "superfarm": "Farm",
        "superhospital": "Hospital",
    }
    for folder in APPS:
        app_dir = HANTURAI / folder
        shell = app_dir / "lib" / "features" / "shell" / "main_shell.dart"
        if not shell.exists():
            print("MISSING", shell)
            continue
        chrome, mem = detect(app_dir)
        shell.write_text(
            TEMPLATE.format(membership=mem, chrome=chrome), encoding="utf-8"
        )
        stores = app_dir / "lib" / "app" / "family" / "family_stores.dart"
        add_header_title(stores, chrome, titles[folder])
        print(f"ok {folder}: {chrome}.shellTitle / {mem}")


if __name__ == "__main__":
    main()
