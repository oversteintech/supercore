"""Replace per-app Overstein splashes with the shared Garage-identical widget."""
from __future__ import annotations

from pathlib import Path

HANTURAI = Path(r"D:\Projects\HANTURAI")

# (folder, AppClassName, AfterFramework.create*Overrides method hint)
# Apps that share AppRuntimeBootstrap.load() + BootstrapSnapshot (rewrite cold start).
CONSUMER_REWRITE = [
    ("superhealth", "SuperHealth", "createSuperHealthAfterOverrides"),
    ("superfinance", "SuperFinance", "createSuperFinanceAfterOverrides"),
    ("superhome", "SuperHome", "createSuperHomeAfterOverrides"),
    ("supertravel", "SuperTravel", "createSuperTravelAfterOverrides"),
    ("superpet", "SuperPet", "createSuperPetAfterOverrides"),
    ("supernews", "SuperNews", "createSuperNewsAfterOverrides"),
]

# Already Garage-contract cold start — only point splash at shared package.
CONSUMER_IMPORT_ONLY = [
    "supersports",
    "superhospital",
]

COLD_START = '''import 'dart:async';

import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_gate.dart';
import '../app.dart';
import '../platform/after_framework.dart';
import 'app_runtime_bootstrap.dart';

/// Cold start: shared OVERSTEIN company splash → AuthGate.
///
/// Contract (identical to SuperGarage):
/// 1. Show [OversteinCompanySplash] immediately — no product branding.
/// 2. Bootstrap in parallel with the splash animation.
/// 3. After splash [onComplete], mount AuthGate when bootstrap is ready.
class {app}ColdStart extends StatefulWidget {{
  const {app}ColdStart({{super.key}});

  @override
  State<{app}ColdStart> createState() => _{app}ColdStartState();
}}

class _{app}ColdStartState extends State<{app}ColdStart> {{
  late final Future<BootstrapSnapshot> _bootstrap;
  var _splashFinished = false;
  ProviderContainer? _container;
  Object? _error;

  @override
  void initState() {{
    super.initState();
    _bootstrap = _resolveBootstrap();
  }}

  @override
  void dispose() {{
    _container?.dispose();
    super.dispose();
  }}

  Future<BootstrapSnapshot> _resolveBootstrap() async {{
    try {{
      return await AppRuntimeBootstrap.load().timeout(
        const Duration(seconds: 12),
      );
    }} on Object catch (error, stack) {{
      debugPrint('{app} cold start bootstrap failed: $error\\n$stack');
      rethrow;
    }}
  }}

  void _onSplashComplete() {{
    if (!mounted || _splashFinished) return;
    setState(() => _splashFinished = true);
  }}

  @override
  Widget build(BuildContext context) {{
    if (_error != null) {{
      return AfterLaunchShell(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '{app} failed to start.\\n$_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),
      );
    }}

    if (!_splashFinished) {{
      return AfterLaunchShell(
        child: OversteinCompanySplash(
          key: const ValueKey<String>('overstein-company-splash'),
          onComplete: _onSplashComplete,
        ),
      );
    }}

    return FutureBuilder<BootstrapSnapshot>(
      future: _bootstrap,
      builder: (context, snapshot) {{
        if (snapshot.hasError) {{
          _error = snapshot.error;
          return AfterLaunchShell(
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Text(
                  '{app} failed to start.\\n${{snapshot.error}}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          );
        }}
        if (!snapshot.hasData) {{
          return const AfterLaunchShell(
            child: Scaffold(
              backgroundColor: Colors.black,
              body: SizedBox.expand(),
            ),
          );
        }}

        final boot = snapshot.data!;
        _container ??= ProviderContainer(
          overrides: [
            ...AppRuntimeBootstrap.overrides(boot),
            ...AfterFramework.{overrides}(boot.preferences),
          ],
        );
        unawaited(AppRuntimeBootstrap.warm(_container!));

        return UncontrolledProviderScope(
          container: _container!,
          child: const {app}App(home: AuthGate()),
        );
      }},
    );
  }}
}}
'''

FARM_COLD = '''import 'dart:async';

import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/auth_gate.dart';
import '../app.dart';
import '../platform/after_framework.dart';

/// Cold start: shared OVERSTEIN company splash → AuthGate (SuperGarage contract).
class SuperFarmColdStart extends StatefulWidget {
  const SuperFarmColdStart({super.key, this.preferencesFuture});
  final Future<SharedPreferences>? preferencesFuture;

  @override
  State<SuperFarmColdStart> createState() => _SuperFarmColdStartState();
}

class _SuperFarmColdStartState extends State<SuperFarmColdStart> {
  late final Future<SharedPreferences> _prefs;
  var _splashFinished = false;
  ProviderContainer? _container;

  @override
  void initState() {
    super.initState();
    _prefs = widget.preferencesFuture ?? SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _container?.dispose();
    super.dispose();
  }

  void _onSplashComplete() {
    if (!mounted || _splashFinished) return;
    setState(() => _splashFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashFinished) {
      return AfterLaunchShell(
        child: OversteinCompanySplash(
          key: const ValueKey<String>('overstein-company-splash'),
          onComplete: _onSplashComplete,
        ),
      );
    }
    return FutureBuilder<SharedPreferences>(
      future: _prefs,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const AfterLaunchShell(
            child: Scaffold(
              backgroundColor: Colors.black,
              body: SizedBox.expand(),
            ),
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
'''

REEXPORT_SPLASH = """export 'package:after_design_system/after_design_system.dart'
    show OversteinCompanySplash, OversteinCompanySplashTiming, AfterLaunchShell;
"""


def discover_overrides(app_dir: Path, hint: str) -> str:
    af = app_dir / "lib" / "app" / "platform" / "after_framework.dart"
    if not af.exists():
        return hint
    t = af.read_text(encoding="utf-8")
    import re

    m = re.search(r"static List<Override> (create\w+Overrides)", t)
    if m:
        return m.group(1)
    return hint


def reexport_local_splash(app_dir: Path) -> None:
    for p in [
        app_dir / "lib" / "features" / "splash" / "overstein_company_splash.dart",
        app_dir / "lib" / "features" / "overstein_splash" / "overstein_company_splash.dart",
    ]:
        if p.exists():
            p.write_text(REEXPORT_SPLASH, encoding="utf-8")
            print(f"  reexport {p}")


def patch_cold_import(app_dir: Path) -> None:
    cold = app_dir / "lib" / "app" / "bootstrap" / "cold_start_app.dart"
    if not cold.exists():
        return
    st = cold.read_text(encoding="utf-8")
    for old in (
        "import '../../features/overstein_splash/overstein_company_splash.dart';",
        "import '../../features/splash/overstein_company_splash.dart';",
    ):
        if old in st:
            st = st.replace(
                old,
                "import 'package:after_design_system/after_design_system.dart';",
            )
            cold.write_text(st, encoding="utf-8")
            print(f"  patched import {cold}")
            return


def main() -> None:
    for folder, app, hint in CONSUMER_REWRITE:
        app_dir = HANTURAI / folder
        if not app_dir.exists():
            print("MISSING", folder)
            continue
        overrides = discover_overrides(app_dir, hint)
        boot = app_dir / "lib" / "app" / "bootstrap" / "app_runtime_bootstrap.dart"
        if not boot.exists():
            print(f"  skip {folder}: no app_runtime_bootstrap")
            continue
        cold = app_dir / "lib" / "app" / "bootstrap" / "cold_start_app.dart"
        cold.write_text(COLD_START.format(app=app, overrides=overrides), encoding="utf-8")
        print(f"  wrote {cold} ({overrides})")
        reexport_local_splash(app_dir)

    for folder in CONSUMER_IMPORT_ONLY:
        app_dir = HANTURAI / folder
        if not app_dir.exists():
            print("MISSING", folder)
            continue
        print(folder)
        patch_cold_import(app_dir)
        reexport_local_splash(app_dir)

    farm = HANTURAI / "superfarm" / "lib" / "app" / "bootstrap" / "cold_start_app.dart"
    farm.write_text(FARM_COLD, encoding="utf-8")
    print(f"  wrote {farm}")

    print("DONE")


if __name__ == "__main__":
    main()
