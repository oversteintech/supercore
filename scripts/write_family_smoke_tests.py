#!/usr/bin/env python3
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(r"D:\Projects\HANTURAI")

APPS = [
    # app, createOverrides method, membershipProvider, storeProvider
    ("superfinance", "createSuperFinanceAfterOverrides", "financeMembershipProvider", "accountsStoreProvider"),
    ("superhealth", "createSuperHealthAfterOverrides", "healthMembershipProvider", "medicationsStoreProvider"),
    ("superhome", "createSuperHomeAfterOverrides", "homeMembershipProvider", "propertiesStoreProvider"),
    ("superpet", "createSuperPetAfterOverrides", "petMembershipProvider", "petsStoreProvider"),
    ("supertravel", "createSuperTravelAfterOverrides", "travelMembershipProvider", "tripsStoreProvider"),
    ("supersports", "createSuperSportsAfterOverrides", "sportsMembershipProvider", "workoutsStoreProvider"),
    ("supernews", "createSuperNewsAfterOverrides", "newsMembershipProvider", "bookmarksStoreProvider"),
    ("superhospital", "createSuperHospitalAfterOverrides", "hospitalMembershipProvider", "patientsStoreProvider"),
    ("superfarm", "createSuperFarmAfterOverrides", "farmMembershipProvider", "fieldsStoreProvider"),
]


def pkg_name(app: str) -> str:
    pub = (ROOT / app / "pubspec.yaml").read_text(encoding="utf-8-sig")
    m = re.search(r"(?m)^name:\s*([A-Za-z0-9_]+)", pub)
    if not m:
        raise SystemExit(f"no package name in {app}/pubspec.yaml")
    return m.group(1)


def resolve_override(app: str, preferred: str) -> str:
    fw = (ROOT / app / "lib" / "app" / "platform" / "after_framework.dart").read_text(encoding="utf-8")
    m = re.search(r"static List<Override> (\w+)\(", fw)
    if m:
        return m.group(1)
    if preferred in fw:
        return preferred
    raise SystemExit(f"No override method in {app}")


def resolve_store(app: str, preferred: str) -> str:
    stores = (ROOT / app / "lib" / "app" / "family" / "family_stores.dart").read_text(encoding="utf-8")
    if preferred in stores:
        return preferred
    m = re.search(r"final (\w+StoreProvider) = familyMapListProvider", stores)
    if not m:
        raise SystemExit(f"No store in {app}")
    return m.group(1)


TEMPLATE = '''import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:{pkg}/app/family/family_stores.dart';
import 'package:{pkg}/app/platform/after_framework.dart';

void main() {{
  TestWidgetsFlutterBinding.ensureInitialized();

  test('family membership plan change', () async {{
    SharedPreferences.setMockInitialValues({{}});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: AfterFramework.{override}(prefs),
    );
    addTearDown(container.dispose);

    expect(container.read({membership}).plan, AfterUserPlan.free);
    await container.read({membership}.notifier).setPlan(AfterUserPlan.superPlan);
    expect(container.read({membership}).plan, AfterUserPlan.superPlan);
    expect(container.read({membership}).badge, AfterMembershipBadge.gold);
  }});

  test('family store CRUD round-trip', () async {{
    SharedPreferences.setMockInitialValues({{}});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: AfterFramework.{override}(prefs),
    );
    addTearDown(container.dispose);

    final notifier = container.read({store}.notifier);
    final before = container.read({store}).length;
    await notifier.upsert(
      const FamilyMapRecord(
        id: 'smoke_1',
        fields: {{'name': 'Smoke', 'note': 'round-trip'}},
      ),
    );
    expect(container.read({store}).any((e) => e.id == 'smoke_1'), isTrue);
    expect(container.read({store}).length, before + 1);
    await notifier.deleteById('smoke_1');
    expect(container.read({store}).any((e) => e.id == 'smoke_1'), isFalse);
  }});

  test('family dashboard section sort order', () {{
    final sections = sortFamilyDashboardSections([
      const FamilyDashboardSection(
        id: 'secondary',
        priority: FamilyDashboardPriority.secondary,
        builder: _box,
      ),
      const FamilyDashboardSection(
        id: 'hero',
        priority: FamilyDashboardPriority.hero,
        builder: _box,
      ),
      const FamilyDashboardSection(
        id: 'hidden',
        priority: FamilyDashboardPriority.hero,
        visible: false,
        builder: _box,
      ),
    ]);
    expect(sections.map((s) => s.id).toList(), ['hero', 'secondary']);
  }});
}}

Widget _box(BuildContext context) => const SizedBox.shrink();
'''


def main() -> None:
    for app, preferred_override, membership, preferred_store in APPS:
        override = resolve_override(app, preferred_override)
        store = resolve_store(app, preferred_store)
        pkg = pkg_name(app)
        body = TEMPLATE.format(
            pkg=pkg,
            override=override,
            membership=membership,
            store=store,
        )
        path = ROOT / app / "test" / "family_smoke_test.dart"
        path.write_text(body, encoding="utf-8")
        print(f"wrote {path} ({override}, {store})")


if __name__ == "__main__":
    main()
