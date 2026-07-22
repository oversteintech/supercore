#!/usr/bin/env python3
"""Rewrite MainShell + AuthGate + after_framework for family chrome on Wave 1 apps."""

from pathlib import Path

HANTURAI = Path(r"D:\Projects\HANTURAI")

SHELLS = {
    "superhealth": {
        "prefix": "health",
        "create_overrides": "createSuperHealthAfterOverrides",
        "manifest": "superHealthManifest",
        "manifest_import": "manifest.dart",
        "membership_old": "membership_controller.dart",
    },
    "superfinance": {
        "prefix": "finance",
        "create_overrides": "createSuperFinanceAfterOverrides",
        "manifest": "superFinanceManifest",
        "manifest_import": "manifest.dart",
        "membership_old": "membership_controller.dart",
    },
    "superhome": {
        "prefix": "home",
        "create_overrides": "createSuperHomeAfterOverrides",
        "manifest": "superHomeManifest",
        "manifest_import": "manifest.dart",
        "membership_old": "membership_controller.dart",
    },
    "superpet": {
        "prefix": "pet",
        "create_overrides": "createSuperPetAfterOverrides",
        "manifest": "superPetManifest",
        "manifest_import": "manifest.dart",
        "membership_old": "membership_controller.dart",
    },
}


def write_shell(app: str, prefix: str) -> None:
    path = HANTURAI / app / "lib" / "features" / "shell" / "main_shell.dart"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        f"""import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation/shell_navigation.dart';
import '../dashboard/dashboard_screen.dart';
import '../family_crud/family_hub_screens.dart';

/// Family shell: Home | Live | AI | Features | Profile (lazy Offstage).
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

    return Scaffold(
      appBar: AfterAppBar(title: Text(_title(tab))),
      body: Stack(
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

  String _title(MainTab tab) => switch (tab) {{
        MainTab.dashboard => 'Home',
        MainTab.live => 'Live',
        MainTab.assistant => 'AI',
        MainTab.features => 'Features',
        MainTab.profile => 'Profile',
      }};
}}
""",
        encoding="utf-8",
    )

    nav = HANTURAI / app / "lib" / "app" / "navigation" / "shell_navigation.dart"
    nav.parent.mkdir(parents=True, exist_ok=True)
    nav.write_text(
        """import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MainTab { dashboard, live, assistant, features, profile }

final mainTabProvider =
    NotifierProvider<MainTabController, MainTab>(MainTabController.new);

class MainTabController extends Notifier<MainTab> {
  @override
  MainTab build() => MainTab.dashboard;

  void select(MainTab tab) => state = tab;
}
""",
        encoding="utf-8",
    )


def write_auth(app: str, prefix: str) -> None:
    gate = HANTURAI / app / "lib" / "features" / "auth" / "auth_gate.dart"
    gate.parent.mkdir(parents=True, exist_ok=True)
    gate.write_text(
        f"""import 'package:after_core/after_core.dart';
import 'package:after_consumer/after_consumer.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/family/family_stores.dart';
import '../shell/main_shell.dart';

class AuthGate extends ConsumerWidget {{
  const AuthGate({{super.key}});

  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    final sessionAsync = ref.watch(afterAuthSessionProvider);
    return sessionAsync.when(
      loading: () => const Scaffold(body: Center(child: AfterLoading())),
      error: (e, _) => Scaffold(body: Center(child: Text('Auth error: $e'))),
      data: (session) {{
        if (session.isLoading) {{
          return const Scaffold(body: Center(child: AfterLoading()));
        }}
        if (!session.isAuthenticated) {{
          return FamilyLoginScreen(config: {prefix}Chrome);
        }}
        return const MainShell();
      }},
    );
  }}
}}
""",
        encoding="utf-8",
    )


def patch_framework(app: str, cfg: dict) -> None:
    path = HANTURAI / app / "lib" / "app" / "platform" / "after_framework.dart"
    if not path.exists():
        print(f"  no after_framework for {app}")
        return
    text = path.read_text(encoding="utf-8")
    if "after_ai" in text and "FamilyMockAuth" in text:
        return
    # Ensure AI + family auth imports and overrides
    if "package:after_ai/after_ai.dart" not in text:
        text = text.replace(
            "import 'package:after_core/after_core.dart';",
            "import 'package:after_ai/after_ai.dart';\n"
            "import 'package:after_consumer/after_consumer.dart';\n"
            "import 'package:after_core/after_core.dart';",
        )
    if "afterAiProfileProvider" not in text:
        inject = f"""
      afterAiProfileProvider.overrideWithValue(
        AfterAiProfile(
          appId: {cfg['manifest']}.appId,
          enabled: const {{
            AfterAiCapability.conversation,
            AfterAiCapability.summarization,
            AfterAiCapability.recommendation,
          }},
        ),
      ),
      afterAuthRepositoryProvider.overrideWithValue(
        FamilyMockAuthRepository(),
      ),
"""
        # Insert before closing of return list — find afterEntitlement or last override
        if "afterEntitlementProvider" in text:
            text = text.replace(
                "afterEntitlementProvider.overrideWith((ref) {",
                inject + "      afterEntitlementProvider.overrideWith((ref) {",
            )
        else:
            text = text.replace(
                "    ];\n  }\n}",
                inject + "    ];\n  }\n}",
            )
    # Prefer family membership for entitlement if present
    text = text.replace(
        "return ref.watch(membershipControllerProvider).entitlement;",
        f"return ref.watch({cfg['prefix']}MembershipProvider).entitlement;",
    )
    if f"{cfg['prefix']}MembershipProvider" in text and "family_stores" not in text:
        text = text.replace(
            "import '../membership/membership_controller.dart';\n",
            "import '../family/family_stores.dart';\n",
        )
    path.write_text(text, encoding="utf-8")


def main() -> None:
    for app, cfg in SHELLS.items():
        print(f"==> wire {app}")
        write_shell(app, cfg["prefix"])
        write_auth(app, cfg["prefix"])
        patch_framework(app, cfg)
        # Fix hub imports for app_strings
        hub = HANTURAI / app / "lib" / "features" / "family_crud" / "family_hub_screens.dart"
        if hub.exists():
            t = hub.read_text(encoding="utf-8")
            if "app_strings.dart" not in t:
                t = t.replace(
                    "import '../../app/theme/theme_controller.dart';",
                    "import '../../app/l10n/app_strings.dart';\n"
                    "import '../../app/theme/theme_controller.dart';",
                )
                hub.write_text(t, encoding="utf-8")


if __name__ == "__main__":
    main()
