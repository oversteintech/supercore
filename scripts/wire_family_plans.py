"""Wire Free/Silver/Gold/Business plans into sibling apps."""
from __future__ import annotations

import json
import re
from pathlib import Path

HANTURAI = Path(r"D:\Projects\HANTURAI")

APPS = [
    ("superhealth", "healthChrome", "healthMembershipProvider", "super_health.membership.plan"),
    ("superfinance", "financeChrome", "financeMembershipProvider", "super_finance.membership.plan"),
    ("superhome", "homeChrome", "homeMembershipProvider", "super_home.membership.plan"),
    ("supertravel", "travelChrome", "travelMembershipProvider", "super_travel.membership.plan"),
    ("superpet", "petChrome", "petMembershipProvider", "super_pet.membership.plan"),
    ("supernews", "newsChrome", "newsMembershipProvider", "super_news.membership.plan"),
    ("supersports", "sportsChrome", "sportsMembershipProvider", "super_sports.membership.plan"),
    ("superfarm", "farmChrome", "farmMembershipProvider", "super_farm.membership.plan"),
    ("superhospital", "hospitalChrome", "hospitalMembershipProvider", "super_hospital.membership.plan"),
]

MEMBERSHIP_SCREEN = """import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/family/family_stores.dart';

/// Garage-parity membership: Free / Silver / Gold / Business.
class MembershipScreen extends ConsumerWidget {{
  const MembershipScreen({{super.key}});

  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    final membership = ref.watch({mem});
    return FamilyMembershipPlansScreen(
      config: {chrome},
      membership: membership,
      onSetPlan: (plan) => ref.read({mem}.notifier).setPlan(plan),
    );
  }}
}}
"""

CONFIG = {
    "version": 1,
    "recommendedNextTiers": {
        "free": "premium",
        "premium": "super",
        "super": "business",
        "business": "business",
    },
    "plans": {
        "free": {
            "badge": "FREE",
            "title": "Free",
            "highlight": "",
        },
        "premium": {
            "badge": "SILVER",
            "title": "Silver",
            "highlight": "Comfort upgrade",
        },
        "super": {
            "badge": "GOLD",
            "title": "Gold",
            "highlight": "Most popular",
        },
        "business": {
            "badge": "BUSINESS",
            "title": "Business",
            "highlight": "Best for teams",
        },
    },
}

CONTROLLER = """import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Legacy alias — delegates to the same prefs key as FamilyMembershipController.
class MembershipState {{
  const MembershipState({{
    this.plan = AfterUserPlan.free,
  }});

  final AfterUserPlan plan;

  AfterEntitlement get entitlement => AfterEntitlement(
        effectivePlan: plan,
        storedPlan: plan,
      );

  String get badge => AfterMembershipBadge.forPlan(plan);

  bool get isSuperAdmin => plan == AfterUserPlan.superadmin;

  MembershipState copyWith({{AfterUserPlan? plan}}) =>
      MembershipState(plan: plan ?? this.plan);
}}

final membershipControllerProvider =
    NotifierProvider<MembershipController, MembershipState>(
  MembershipController.new,
);

class MembershipController extends Notifier<MembershipState> {{
  static const _key = '{key}';

  @override
  MembershipState build() {{
    final prefs = ref.watch(afterSharedPreferencesProvider);
    final session = ref.watch(afterAuthSessionProvider).asData?.value;
    if (AfterSuperAdmin.isSuperAdminEmail(session?.user?.email)) {{
      return const MembershipState(plan: AfterUserPlan.superadmin);
    }}
    final plan = AfterUserPlanRank.fromStorage(prefs.getString(_key));
    if (plan == AfterUserPlan.superadmin) {{
      return const MembershipState(plan: AfterUserPlan.free);
    }}
    return MembershipState(plan: plan);
  }}

  Future<void> setPlan(AfterUserPlan plan) async {{
    if (state.isSuperAdmin) return;
    final prefs = ref.read(afterSharedPreferencesProvider);
    await prefs.setString(_key, plan.storageKey);
    state = state.copyWith(plan: plan);
    await ref.read(afterAnalyticsProvider).logEvent(
      'membership_plan_changed',
      parameters: {{'plan': plan.storageKey}},
    );
  }}

  Future<void> upgradeToPremium() => setPlan(AfterUserPlan.premium);

  Future<void> upgradeToSuper() => setPlan(AfterUserPlan.superPlan);

  Future<void> upgradeToBusiness() => setPlan(AfterUserPlan.business);

  Future<void> downgradeToFree() => setPlan(AfterUserPlan.free);
}}
"""


def detect(app_dir: Path, chrome_h: str, mem_h: str, key_h: str):
    stores = app_dir / "lib" / "app" / "family" / "family_stores.dart"
    chrome, mem, key = chrome_h, mem_h, key_h
    if stores.exists():
        st = stores.read_text(encoding="utf-8")
        m = re.search(r"const (\w+Chrome) = FamilyChromeConfig", st)
        if m:
            chrome = m.group(1)
        m = re.search(
            r"final (\w+MembershipProvider)\s*=\s*NotifierProvider", st
        )
        if m:
            mem = m.group(1)
        m = re.search(
            r"FamilyMembershipController\('([^']+)'\)", st
        )
        if m:
            key = m.group(1)
    return chrome, mem, key


def main() -> None:
    for folder, chrome_h, mem_h, key_h in APPS:
        app_dir = HANTURAI / folder
        if not app_dir.exists():
            print("MISSING", folder)
            continue
        chrome, mem, key = detect(app_dir, chrome_h, mem_h, key_h)

        screen = app_dir / "lib" / "features" / "membership" / "membership_screen.dart"
        screen.parent.mkdir(parents=True, exist_ok=True)
        screen.write_text(
            MEMBERSHIP_SCREEN.format(chrome=chrome, mem=mem), encoding="utf-8"
        )
        print("screen", screen)

        ctrl = app_dir / "lib" / "app" / "membership" / "membership_controller.dart"
        if ctrl.exists():
            ctrl.write_text(CONTROLLER.format(key=key), encoding="utf-8")
            print("controller", ctrl)

        cfg = app_dir / "assets" / "config" / "membership_config.json"
        cfg.parent.mkdir(parents=True, exist_ok=True)
        cfg.write_text(json.dumps(CONFIG, indent=2) + "\n", encoding="utf-8")
        print("config", cfg)

        # Profile / hub: open FamilyMembershipPlansScreen when possible
        hub = app_dir / "lib" / "features" / "family_crud" / "family_hub_screens.dart"
        if hub.exists():
            t = hub.read_text(encoding="utf-8")
            old = f"builder: (_) => _SettingsRoute(membership: membership),"
            # replace onOpenMembership only — find pattern
            if "onOpenMembership:" in t and "FamilyMembershipPlansScreen" not in t:
                t2 = re.sub(
                    r"onOpenMembership: \(\) \{\s*Navigator\.of\(context\)\.push\(\s*"
                    r"MaterialPageRoute<void>\(\s*"
                    r"builder: \(_\) => _SettingsRoute\(membership: membership\),\s*"
                    r"\),\s*\);\s*\},",
                    f"""onOpenMembership: () {{
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FamilyMembershipPlansScreen(
              config: {chrome},
              membership: membership,
              onSetPlan: (p) =>
                  ref.read({mem}.notifier).setPlan(p),
            ),
          ),
        );
      }},""",
                    t,
                    count=1,
                )
                if t2 != t:
                    hub.write_text(t2, encoding="utf-8")
                    print("hub membership", hub)

    print("DONE")


if __name__ == "__main__":
    main()
