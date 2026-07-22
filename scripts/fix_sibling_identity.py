#!/usr/bin/env python3
"""Fix com.afterartificial → com.overstein identity drift (no APK install)."""
from __future__ import annotations

import re
import shutil
from pathlib import Path

ROOT = Path(r"D:\Projects\HANTURAI")

# (app_dir, short_id used in package path)
APPS = [
    ("superhealth", "superhealth"),
    ("superfinance", "superfinance"),
    ("superhome", "superhome"),
    ("superpet", "superpet"),
    ("supertravel", "supertravel"),
    ("supernews", "supernews"),
]


def fix_tests(app: str, pkg_id: str) -> None:
    test_dir = ROOT / app / "test"
    if not test_dir.is_dir():
        return
    old = f"com.afterartificial.{pkg_id}"
    new = f"com.overstein.{pkg_id}"
    for p in test_dir.rglob("*.dart"):
        t = p.read_text(encoding="utf-8")
        if old not in t:
            continue
        p.write_text(t.replace(old, new), encoding="utf-8")
        print(f"  test: {p.relative_to(ROOT / app)}")


def fix_android_mainactivity(app: str, pkg_id: str) -> None:
    kotlin_root = ROOT / app / "android" / "app" / "src" / "main" / "kotlin"
    if not kotlin_root.is_dir():
        return
    old_pkg = f"com.afterartificial.{pkg_id}"
    new_pkg = f"com.overstein.{pkg_id}"
    # find any MainActivity.kt
    activities = list(kotlin_root.rglob("MainActivity.kt"))
    if not activities:
        print(f"  android: no MainActivity in {app}")
        return
    dest_dir = kotlin_root / "com" / "overstein" / pkg_id
    dest_dir.mkdir(parents=True, exist_ok=True)
    dest = dest_dir / "MainActivity.kt"
    content = (
        f"package {new_pkg}\n\n"
        "import io.flutter.embedding.android.FlutterActivity\n\n"
        "class MainActivity : FlutterActivity()\n"
    )
    dest.write_text(content, encoding="utf-8")
    print(f"  android: wrote {dest.relative_to(ROOT / app)}")
    # remove afterartificial tree
    aa = kotlin_root / "com" / "afterartificial"
    if aa.is_dir():
        shutil.rmtree(aa)
        print(f"  android: removed afterartificial tree")


def fix_ios_bundle(app: str, pkg_id: str) -> None:
    pbx = ROOT / app / "ios" / "Runner.xcodeproj" / "project.pbxproj"
    if not pbx.is_file():
        return
    t = pbx.read_text(encoding="utf-8")
    new_t = t.replace("com.afterartificial.", "com.overstein.")
    # normalize camelCase variants like superHealth if present for this app
    new_t = re.sub(
        rf"com\.overstein\.{pkg_id[0].upper() + pkg_id[1:]}",
        f"com.overstein.{pkg_id}",
        new_t,
    )
    if new_t != t:
        pbx.write_text(new_t, encoding="utf-8")
        print(f"  ios: pbxproj updated")


def fix_readme(app: str, pkg_id: str) -> None:
    for name in ("README.md", "readme.md"):
        p = ROOT / app / name
        if not p.is_file():
            continue
        t = p.read_text(encoding="utf-8")
        n = t.replace("com.afterartificial.", "com.overstein.")
        if n != t:
            p.write_text(n, encoding="utf-8")
            print(f"  readme: {name}")


def fix_hospital_dup() -> None:
    leftover = (
        ROOT
        / "superhospital"
        / "android"
        / "app"
        / "src"
        / "main"
        / "kotlin"
        / "com"
        / "overstein"
        / "super_hospital"
    )
    if leftover.is_dir():
        shutil.rmtree(leftover)
        print("hospital: removed super_hospital kotlin leftover")
    pbx = ROOT / "superhospital" / "ios" / "Runner.xcodeproj" / "project.pbxproj"
    if pbx.is_file():
        t = pbx.read_text(encoding="utf-8")
        n = t.replace("com.overstein.superHospital", "com.overstein.superhospital")
        if n != t:
            pbx.write_text(n, encoding="utf-8")
            print("hospital: ios bundle normalized")
    ph = ROOT / "superhospital" / "lib" / "features" / "common" / "feature_placeholder.dart"
    if ph.is_file():
        ph.unlink()
        print("hospital: deleted feature_placeholder.dart")


def fix_farm_store() -> None:
    for rel in (
        "lib/app/family/family_stores.dart",
        "lib/features/family_crud/weather_notes_crud_screen.dart",
    ):
        p = ROOT / "superfarm" / rel
        if not p.is_file():
            continue
        t = p.read_text(encoding="utf-8")
        n = t.replace("weather_notesStoreProvider", "weatherNotesStoreProvider")
        if n != t:
            p.write_text(n, encoding="utf-8")
            print(f"farm: renamed store in {rel}")


def main() -> None:
    for app, pkg_id in APPS:
        print(f"== {app} ==")
        fix_tests(app, pkg_id)
        fix_android_mainactivity(app, pkg_id)
        fix_ios_bundle(app, pkg_id)
        fix_readme(app, pkg_id)
    print("== hospital ==")
    fix_hospital_dup()
    print("== farm ==")
    fix_farm_store()


if __name__ == "__main__":
    main()
