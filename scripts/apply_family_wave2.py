#!/usr/bin/env python3
"""Wave 2: Travel, Sports, News — family kit + CRUD completion + chrome shell."""

from __future__ import annotations

import importlib.util
from pathlib import Path

# Reuse helpers from wave1 script
SPEC = Path(__file__).with_name("apply_family_wave.py")
spec = importlib.util.spec_from_file_location("wave1", SPEC)
wave1 = importlib.util.module_from_spec(spec)
assert spec.loader
spec.loader.exec_module(wave1)

HANTURAI = wave1.HANTURAI

APPS = {
    "supertravel": {
        "pkg": "super_travel",
        "bundle": "com.overstein.supertravel",
        "name": "SuperTravel",
        "accent": "0xFF0EA5E9",
        "email": "supertravel@overstein.com",
        "features": [
            ("trips", ["title", "destination", "dates"], "flight"),
            ("flights", ["title", "flightNo", "when"], "airplane_ticket"),
            ("hotels", ["title", "city", "nights"], "hotel"),
            ("passport", ["title", "number", "expires"], "badge"),
            ("visa", ["title", "country", "expires"], "public"),
            ("packing", ["title", "qty", "packed"], "luggage"),
            ("expenses", ["title", "amount", "currency"], "payments"),
            ("documents", ["title", "type", "notes"], "description"),
            ("timeline", ["title", "when", "place"], "timeline"),
        ],
        "live": "Trip Live",
        "prefix": "travel",
        "create_overrides": "createSuperTravelAfterOverrides",
        "manifest": "superTravelManifest",
    },
    "supersports": {
        "pkg": "super_sports",
        "bundle": "com.overstein.supersports",
        "name": "SuperSports",
        "accent": "0xFFEF4444",
        "email": "supersports@overstein.com",
        "features": [
            ("workouts", ["title", "type", "duration"], "fitness_center"),
            ("exercises", ["title", "muscle", "sets"], "sports_gymnastics"),
            ("training_plans", ["title", "weeks", "level"], "calendar_month"),
            ("running", ["title", "distance", "pace"], "directions_run"),
            ("cycling", ["title", "distance", "elevation"], "directions_bike"),
            ("nutrition", ["title", "calories", "notes"], "restaurant"),
            ("body_measurements", ["title", "value", "unit"], "straighten"),
            ("progress", ["title", "metric", "value"], "trending_up"),
            ("challenges", ["title", "goal", "status"], "emoji_events"),
        ],
        "live": "Workout Live",
        "prefix": "sports",
        "create_overrides": "createSuperSportsAfterOverrides",
        "manifest": "superSportsManifest",
    },
    "supernews": {
        "pkg": "super_news",
        "bundle": "com.overstein.supernews",
        "name": "SuperNews",
        "accent": "0xFF111827",
        "email": "supernews@overstein.com",
        "features": [
            ("bookmarks", ["title", "source", "url"], "bookmark"),
            ("read_later", ["title", "source", "added"], "watch_later"),
            ("categories", ["title", "followed", "priority"], "category"),
            ("notification_prefs", ["title", "channel", "enabled"], "notifications"),
            ("ai_summary", ["title", "topic", "summary"], "auto_awesome"),
        ],
        "live": "Breaking Live",
        "prefix": "news",
        "create_overrides": "createSuperNewsAfterOverrides",
        "manifest": "superNewsManifest",
    },
}


def write_framework(app: str, cfg: dict) -> None:
    path = HANTURAI / app / "lib" / "app" / "platform" / "after_framework.dart"
    prefix = cfg["prefix"]
    manifest = cfg["manifest"]
    # Try to detect actual manifest const
    man = HANTURAI / app / "lib" / "app" / "platform" / "manifest.dart"
    if man.exists():
        t = man.read_text(encoding="utf-8")
        import re

        m = re.search(r"const AppPlatformManifest (\w+)", t)
        if m:
            manifest = m.group(1)
    name = cfg["name"]
    path.write_text(
        f"""import 'package:after_ai/after_ai.dart';
import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:riverpod/src/internals.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import '../family/family_stores.dart';
import 'adapters/product_analytics.dart';
import 'manifest.dart';

abstract final class AfterFramework {{
  static var _configured = false;

  static void ensureConfigured() {{
    if (_configured) return;
    PlatformConfig.current = {manifest};
    _configured = true;
  }}

  static List<Override> {cfg['create_overrides']}(
    SharedPreferences preferences, {{
    String? mockGoogleEmailForTests,
  }}) {{
    ensureConfigured();
    return [
      ...AfterStandardOverrides.create(
        preferences: preferences,
        userAgent: '{name}/0.1.0',
      ),
      afterAuthRepositoryProvider.overrideWithValue(FamilyMockAuthRepository()),
      afterAnalyticsProvider.overrideWith(
        (ref) => ProductAnalytics(ref.watch(afterLoggerProvider)),
      ),
      afterAiProfileProvider.overrideWithValue(
        AfterAiProfile(
          appId: {manifest}.appId,
          enabled: const {{
            AfterAiCapability.conversation,
            AfterAiCapability.summarization,
            AfterAiCapability.recommendation,
          }},
        ),
      ),
      afterEntitlementProvider.overrideWith((ref) {{
        return ref.watch({prefix}MembershipProvider).entitlement;
      }}),
    ];
  }}
}}
""",
        encoding="utf-8",
    )


def main() -> None:
    wire_spec = Path(__file__).with_name("wire_family_shells.py")
    wspec = importlib.util.spec_from_file_location("wire", wire_spec)
    wire = importlib.util.module_from_spec(wspec)
    assert wspec.loader
    wspec.loader.exec_module(wire)

    for folder, cfg in APPS.items():
        app_dir = HANTURAI / folder
        if not app_dir.exists():
            print(f"SKIP {folder}")
            continue
        print(f"==> {folder}")
        wave1.ensure_pubspec(app_dir)
        wave1.fix_bundle(app_dir, "afterartificial", cfg["bundle"])
        wave1.write_family_module(app_dir, cfg["prefix"], cfg)
        write_framework(folder, cfg)
        wire.write_shell(folder, cfg["prefix"])
        wire.write_auth(folder, cfg["prefix"])
        hub = app_dir / "lib" / "features" / "family_crud" / "family_hub_screens.dart"
        if hub.exists():
            t = hub.read_text(encoding="utf-8")
            if "app_strings.dart" not in t:
                t = t.replace(
                    "import '../../app/theme/theme_controller.dart';",
                    "import '../../app/l10n/app_strings.dart';\n"
                    "import '../../app/theme/theme_controller.dart';",
                )
                hub.write_text(t, encoding="utf-8")
        print(f"    done ({len(cfg['features'])} features)")


if __name__ == "__main__":
    main()
