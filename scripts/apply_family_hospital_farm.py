#!/usr/bin/env python3
"""Wave 3 SuperHospital + Wave 4 SuperFarm family wiring."""

from __future__ import annotations

import importlib.util
import subprocess
from pathlib import Path

SPEC = Path(__file__).with_name("apply_family_wave.py")
spec = importlib.util.spec_from_file_location("wave1", SPEC)
wave1 = importlib.util.module_from_spec(spec)
assert spec.loader
spec.loader.exec_module(wave1)

wire_spec = Path(__file__).with_name("wire_family_shells.py")
wspec = importlib.util.spec_from_file_location("wire", wire_spec)
wire = importlib.util.module_from_spec(wspec)
assert wspec.loader
wspec.loader.exec_module(wire)

HANTURAI = wave1.HANTURAI

HOSPITAL = {
    "pkg": "super_hospital",
    "bundle": "com.overstein.superhospital",
    "name": "SuperHospital",
    "accent": "0xFF0891B2",
    "email": "superhospital@overstein.com",
    "features": [
        ("patients", ["name", "mrn", "ward"], "personal_injury"),
        ("appointments", ["title", "patient", "when"], "event"),
        ("wards", ["title", "beds", "occupancy"], "apartment"),
        ("staff", ["name", "role", "unit"], "badge"),
        ("clinical_notes", ["title", "patient", "notes"], "note_alt"),
        ("pharmacy", ["title", "drug", "status"], "local_pharmacy"),
        ("lab_orders", ["title", "test", "status"], "science"),
        ("billing", ["title", "amount", "status"], "receipt_long"),
        ("compliance", ["title", "item", "status"], "policy"),
    ],
    "live": "Ops Live",
    "prefix": "hospital",
}

FARM = {
    "pkg": "super_farm",
    "bundle": "com.overstein.superfarm",
    "name": "SuperFarm",
    "accent": "0xFF65A30D",
    "email": "superfarm@overstein.com",
    "features": [
        ("fields", ["title", "crop", "hectares"], "grass"),
        ("livestock", ["title", "species", "count"], "pets"),
        ("equipment", ["title", "type", "status"], "agriculture"),
        ("harvests", ["title", "crop", "yield"], "eco"),
        ("inventory", ["title", "qty", "unit"], "inventory_2"),
        ("tasks", ["title", "due", "status"], "task_alt"),
        ("weather_notes", ["title", "condition", "notes"], "cloud"),
    ],
    "live": "Field Live",
    "prefix": "farm",
}


def ensure_hospital_consumer() -> None:
    pub = HANTURAI / "superhospital" / "pubspec.yaml"
    t = pub.read_text(encoding="utf-8")
    if "after_consumer:" not in t:
        t = t.replace(
            "  after_ai:\n",
            "  after_ai:\n    path: ../supercore/packages/after_ai\n  after_consumer:\n"
            "    path: ../supercore/packages/after_consumer\n",
        )
        # if after_ai already has path, avoid dup — simpler append after after_ecosystem
        if "after_consumer:" not in t:
            t = t.replace(
                "  after_ecosystem:\n    path: ../supercore/packages/after_ecosystem\n",
                "  after_ecosystem:\n    path: ../supercore/packages/after_ecosystem\n"
                "  after_consumer:\n    path: ../supercore/packages/after_consumer\n",
            )
        pub.write_text(t, encoding="utf-8")


def write_hospital_framework() -> None:
    path = HANTURAI / "superhospital" / "lib" / "app" / "platform" / "after_framework.dart"
    path.write_text(
        """import 'package:after_ai/after_ai.dart';
import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:after_ecosystem/after_ecosystem.dart';
import 'package:after_enterprise/after_enterprise.dart';
import 'package:riverpod/src/internals.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import '../family/family_stores.dart';
import 'platform_manifest.dart';

abstract final class AfterFramework {
  static var _configured = false;

  static void ensureConfigured() {
    if (_configured) return;
    PlatformConfig.current = superHospitalManifest;
    _configured = true;
  }

  static List<Override> createSuperHospitalOverrides(
    SharedPreferences preferences, {
    EnterpriseRepository? enterpriseRepository,
    AfterEcosystemFabric? fabric,
  }) {
    ensureConfigured();
    final eco = fabric ?? AfterEcosystemFabric.inMemory();
    return [
      ...AfterStandardOverrides.create(
        preferences: preferences,
        userAgent: 'SuperHospital/0.1.0',
      ),
      afterEcosystemProvider.overrideWithValue(eco),
      afterEcosystemCalendarProvider.overrideWithValue(eco.calendar),
      afterNotificationCenterProvider.overrideWithValue(eco.notifications),
      enterpriseBridgeSourceProductIdProvider.overrideWithValue(
        superHospitalManifest.appId,
      ),
      enterpriseRepositoryProvider.overrideWithValue(
        enterpriseRepository ?? MockEnterpriseRepository(),
      ),
      afterAuthRepositoryProvider.overrideWithValue(FamilyMockAuthRepository()),
      afterAiProfileProvider.overrideWithValue(
        AfterAiProfile(
          appId: superHospitalManifest.appId,
          enabled: const {
            AfterAiCapability.conversation,
            AfterAiCapability.summarization,
            AfterAiCapability.decisionSupport,
          },
        ),
      ),
      afterEntitlementProvider.overrideWith((ref) {
        return ref.watch(hospitalMembershipProvider).entitlement;
      }),
    ];
  }
}
""",
        encoding="utf-8",
    )


def scaffold_farm() -> None:
    root = HANTURAI / "superfarm"
    if not (root / "pubspec.yaml").exists():
        subprocess.run(
            [
                "flutter",
                "create",
                "--org",
                "com.overstein",
                "--project-name",
                "super_farm",
                str(root),
            ],
            check=True,
        )
    # Minimal pubspec
    (root / "pubspec.yaml").write_text(
        """name: super_farm
description: SuperFarm — agriculture Life Domain Super App.
publish_to: "none"
version: 0.1.0+1

environment:
  sdk: ^3.12.2

dependencies:
  after_ai:
    path: ../supercore/packages/after_ai
  after_consumer:
    path: ../supercore/packages/after_consumer
  after_core:
    path: ../supercore/packages/after_core
  after_design_system:
    path: ../supercore/packages/after_design_system
  after_ecosystem:
    path: ../supercore/packages/after_ecosystem
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_riverpod: ^3.3.2
  shared_preferences: ^2.5.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  very_good_analysis: ^10.3.0

flutter:
  uses-material-design: true
""",
        encoding="utf-8",
    )

    # Android bundle
    gradle = root / "android" / "app" / "build.gradle.kts"
    if gradle.exists():
        t = gradle.read_text(encoding="utf-8")
        t = t.replace("com.overstein.super_farm", "com.overstein.superfarm")
        gradle.write_text(t, encoding="utf-8")

    lib = root / "lib"
    # platform
    (lib / "app" / "platform").mkdir(parents=True, exist_ok=True)
    (lib / "app" / "platform" / "manifest.dart").write_text(
        """import 'package:after_core/after_core.dart';

const AppPlatformManifest superFarmManifest = AppPlatformManifest(
  appName: 'SuperFarm',
  appId: 'super_farm',
  packageName: 'com.overstein.superfarm',
  androidWidgetProvider: 'com.overstein.superfarm.SuperFarmWidgetProvider',
  iosAppGroupId: 'group.com.overstein.superfarm',
  supportEmail: 'superfarm@overstein.com',
);
""",
        encoding="utf-8",
    )
    (lib / "app" / "platform" / "adapters").mkdir(parents=True, exist_ok=True)
    (lib / "app" / "platform" / "adapters" / "product_analytics.dart").write_text(
        """import 'package:after_core/after_core.dart';

class ProductAnalytics implements AfterAnalytics {
  ProductAnalytics(this._log);
  final AfterLogger _log;

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    _log.info('analytics:$name $parameters');
  }

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setUserProperty(String name, String? value) async {}
}
""",
        encoding="utf-8",
    )

    # Check AfterAnalytics API - might be different. Use NoOp if needed later.

    (lib / "app" / "theme" / "theme_controller.dart").parent.mkdir(parents=True, exist_ok=True)
    (lib / "app" / "theme" / "theme_controller.dart").write_text(
        """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;
  void setMode(ThemeMode mode) => state = mode;
}
""",
        encoding="utf-8",
    )
    (lib / "app" / "l10n" / "app_strings.dart").parent.mkdir(parents=True, exist_ok=True)
    (lib / "app" / "l10n" / "app_strings.dart").write_text(
        """import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeCodeProvider =
    NotifierProvider<LocaleCodeController, String>(LocaleCodeController.new);

class LocaleCodeController extends Notifier<String> {
  @override
  String build() => 'en';
  void setLocale(String code) => state = code;
}
""",
        encoding="utf-8",
    )

    (lib / "features" / "dashboard" / "dashboard_screen.dart").parent.mkdir(
        parents=True, exist_ok=True
    )
    (lib / "features" / "dashboard" / "dashboard_screen.dart").write_text(
        """import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';

import '../family_crud/family_hub_screens.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = sortFamilyDashboardSections([
      FamilyDashboardSection(
        id: 'hero',
        priority: FamilyDashboardPriority.hero,
        builder: (_) => const ListTile(
          title: Text('Season overview'),
          subtitle: Text('Fields healthy · 2 tasks due'),
        ),
      ),
      FamilyDashboardSection(
        id: 'features',
        priority: FamilyDashboardPriority.dailyValue,
        builder: (_) => ListTile(
          title: const Text('All farm features'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const FamilyFeatureCatalogScreen(),
            ),
          ),
        ),
      ),
    ]);
    return ListView(
      children: [for (final s in sections) s.builder(context)],
    );
  }
}
""",
        encoding="utf-8",
    )

    wave1.write_family_module(root, "farm", FARM)
    wire.write_shell("superfarm", "farm")
    wire.write_auth("superfarm", "farm")

    # Framework + app + main + cold start
    (lib / "app" / "platform" / "after_framework.dart").write_text(
        """import 'package:after_ai/after_ai.dart';
import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:riverpod/src/internals.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import '../family/family_stores.dart';
import 'manifest.dart';

abstract final class AfterFramework {
  static var _configured = false;

  static void ensureConfigured() {
    if (_configured) return;
    PlatformConfig.current = superFarmManifest;
    _configured = true;
  }

  static List<Override> createSuperFarmAfterOverrides(
    SharedPreferences preferences,
  ) {
    ensureConfigured();
    return [
      ...AfterStandardOverrides.create(
        preferences: preferences,
        userAgent: 'SuperFarm/0.1.0',
      ),
      afterAuthRepositoryProvider.overrideWithValue(FamilyMockAuthRepository()),
      afterAiProfileProvider.overrideWithValue(
        AfterAiProfile(
          appId: superFarmManifest.appId,
          enabled: const {
            AfterAiCapability.conversation,
            AfterAiCapability.summarization,
            AfterAiCapability.recommendation,
          },
        ),
      ),
      afterEntitlementProvider.overrideWith((ref) {
        return ref.watch(farmMembershipProvider).entitlement;
      }),
    ];
  }
}
""",
        encoding="utf-8",
    )

    (lib / "app" / "app.dart").write_text(
        """import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/theme_controller.dart';

class SuperFarmApp extends ConsumerWidget {
  const SuperFarmApp({required this.home, super.key});
  final Widget home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'SuperFarm',
      debugShowCheckedModeBanner: false,
      theme: AfterThemeData.light(accentOverride: const Color(0xFF65A30D)),
      darkTheme: AfterThemeData.dark(accentOverride: const Color(0xFF65A30D)),
      themeMode: mode,
      home: home,
    );
  }
}
""",
        encoding="utf-8",
    )

    (lib / "app" / "bootstrap" / "cold_start_app.dart").parent.mkdir(
        parents=True, exist_ok=True
    )
    (lib / "app" / "bootstrap" / "cold_start_app.dart").write_text(
        """import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/auth_gate.dart';
import '../app.dart';
import '../platform/after_framework.dart';

class SuperFarmColdStart extends StatefulWidget {
  const SuperFarmColdStart({super.key, this.preferencesFuture});
  final Future<SharedPreferences>? preferencesFuture;

  @override
  State<SuperFarmColdStart> createState() => _SuperFarmColdStartState();
}

class _SuperFarmColdStartState extends State<SuperFarmColdStart> {
  late final Future<SharedPreferences> _prefs;
  var _splashDone = false;
  ProviderContainer? _container;

  @override
  void initState() {
    super.initState();
    _prefs = widget.preferencesFuture ?? SharedPreferences.getInstance();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  @override
  void dispose() {
    _container?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Text('OVERSTEIN',
                style: TextStyle(color: Colors.white, letterSpacing: 4)),
          ),
        ),
      );
    }
    return FutureBuilder<SharedPreferences>(
      future: _prefs,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        _container ??= ProviderContainer(
          overrides: AfterFramework.createSuperFarmAfterOverrides(snap.data!),
        );
        return UncontrolledProviderScope(
          container: _container!,
          child: const SuperFarmApp(home: AuthGate()),
        );
      },
    );
  }
}
""",
        encoding="utf-8",
    )

    (lib / "main.dart").write_text(
        """import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/bootstrap/cold_start_app.dart';
import 'app/platform/after_framework.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AfterFramework.ensureConfigured();
  runApp(SuperFarmColdStart(preferencesFuture: SharedPreferences.getInstance()));
}
""",
        encoding="utf-8",
    )

    (root / "test" / "smoke_test.dart").write_text(
        """import 'package:flutter_test/flutter_test.dart';
import 'package:super_farm/app/platform/after_framework.dart';
import 'package:super_farm/app/platform/manifest.dart';

void main() {
  test('SuperFarm manifest', () {
    AfterFramework.ensureConfigured();
    expect(superFarmManifest.appId, 'super_farm');
    expect(superFarmManifest.packageName, 'com.overstein.superfarm');
  });
}
""",
        encoding="utf-8",
    )

    # catalog update
    catalog = HANTURAI / "supercore" / "catalog" / "products.yaml"
    t = catalog.read_text(encoding="utf-8")
    t = t.replace(
        "    status: planned\n    description: >\n      Agriculture / farm operations",
        "    status: scaffold\n    description: >\n      Agriculture / farm operations",
    )
    # SuperFarm entry might differ - soft replace status planned near SuperFarm
    if "name: SuperFarm" in t:
        parts = t.split("name: SuperFarm", 1)
        head, rest = parts[0], parts[1]
        rest = rest.replace("status: planned", "status: scaffold", 1)
        catalog.write_text(head + "name: SuperFarm" + rest, encoding="utf-8")


def main() -> None:
    print("==> superhospital")
    ensure_hospital_consumer()
    # fix pubspec if broken
    pub = HANTURAI / "superhospital" / "pubspec.yaml"
    t = pub.read_text(encoding="utf-8")
    if t.count("after_ai:") > 1:
        # rewrite clean deps block start
        pass
    if "after_consumer:" not in t:
        t = t.replace(
            "  after_enterprise:\n    path: ../supercore/packages/after_enterprise\n",
            "  after_consumer:\n    path: ../supercore/packages/after_consumer\n"
            "  after_enterprise:\n    path: ../supercore/packages/after_enterprise\n",
        )
        pub.write_text(t, encoding="utf-8")
    app_dir = HANTURAI / "superhospital"
    wave1.write_family_module(app_dir, "hospital", HOSPITAL)
    # theme + locale stubs if missing
    theme = app_dir / "lib" / "app" / "theme" / "theme_controller.dart"
    if not theme.exists():
        theme.parent.mkdir(parents=True, exist_ok=True)
        theme.write_text(
            """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;
  void setMode(ThemeMode mode) => state = mode;
}
""",
            encoding="utf-8",
        )
    strings = app_dir / "lib" / "app" / "l10n" / "app_strings.dart"
    if strings.exists() and "localeCodeProvider" not in strings.read_text(encoding="utf-8"):
        strings.write_text(
            strings.read_text(encoding="utf-8")
            + """
final localeCodeProvider = NotifierProvider<LocaleCodeController, String>(LocaleCodeController.new);
class LocaleCodeController extends Notifier<String> {
  @override
  String build() => 'en';
  void setLocale(String code) => state = code;
}
""",
            encoding="utf-8",
        )
    elif not strings.exists():
        strings.parent.mkdir(parents=True, exist_ok=True)
        strings.write_text(
            """import 'package:flutter_riverpod/flutter_riverpod.dart';
final localeCodeProvider = NotifierProvider<LocaleCodeController, String>(LocaleCodeController.new);
class LocaleCodeController extends Notifier<String> {
  @override
  String build() => 'en';
  void setLocale(String code) => state = code;
}
""",
            encoding="utf-8",
        )
    wire.write_shell("superhospital", "hospital")
    wire.write_auth("superhospital", "hospital")
    write_hospital_framework()
    # minimal dashboard if missing family link
    dash = app_dir / "lib" / "features" / "dashboard" / "dashboard_screen.dart"
    # leave existing dashboard; Features tab has CRUD catalog
    print("    hospital wired")

    print("==> superfarm")
    scaffold_farm()
    print("    farm scaffolded")


if __name__ == "__main__":
    main()
