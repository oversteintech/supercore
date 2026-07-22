#!/usr/bin/env python3
"""Wire Garage-parity dynamic app icons (DefaultIcon / MonogramWhite) on sibling apps.

- Moves LAUNCHER intent-filter from MainActivity onto activity-aliases
- Ensures ic_launcher_background_white + mipmap-anydpi-v26/ic_launcher_white.xml
- Copies density mipmap ic_launcher.png → ic_launcher_white.png when present
- Adds dynamic_app_icon_changer to pubspec if missing
"""
from __future__ import annotations

import re
import shutil
from pathlib import Path

HANTURAI = Path(r"D:\Projects\HANTURAI")
APPS = [
    "superfarm",
    "supersports",
    "supertravel",
    "supernews",
    "superpet",
    "superhospital",
    "superhome",
    "superfinance",
    "superhealth",
    "superfactory",
    "supermaritime",
    "superairport",
    "afterhub",
]

ADAPTIVE_WHITE = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@color/ic_launcher_background_white"/>
  <foreground>
      <inset
          android:drawable="@drawable/ic_launcher_foreground"
          android:inset="10%" />
  </foreground>
</adaptive-icon>
"""

ADAPTIVE_DEFAULT = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@color/ic_launcher_background"/>
  <foreground>
      <inset
          android:drawable="@drawable/ic_launcher_foreground"
          android:inset="10%" />
  </foreground>
</adaptive-icon>
"""

VECTOR_FG = """<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M30,34h48v8H30zM30,50h48v8H30zM30,66h32v8H30z"/>
</vector>
"""

ALIASES_TEMPLATE = """
        <activity-alias
            android:name=".DefaultIcon"
            android:enabled="true"
            android:exported="true"
            android:icon="@mipmap/ic_launcher"
            android:label="{label}"
            android:targetActivity=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity-alias>

        <activity-alias
            android:name=".MonogramWhite"
            android:enabled="false"
            android:exported="true"
            android:icon="@mipmap/ic_launcher_white"
            android:label="{label}"
            android:targetActivity=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity-alias>
"""


def ensure_colors(res: Path) -> None:
    values = res / "values"
    values.mkdir(parents=True, exist_ok=True)
    colors = values / "colors.xml"
    if not colors.exists():
        colors.write_text(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            "<resources>\n"
            '    <color name="ic_launcher_background">#000000</color>\n'
            '    <color name="ic_launcher_background_white">#FFFFFF</color>\n'
            "</resources>\n",
            encoding="utf-8",
        )
        return
    text = colors.read_text(encoding="utf-8")
    changed = False
    if "ic_launcher_background_white" not in text:
        text = text.replace(
            "</resources>",
            '    <color name="ic_launcher_background_white">#FFFFFF</color>\n</resources>',
        )
        changed = True
    if 'name="ic_launcher_background"' not in text:
        text = text.replace(
            "<resources>",
            '<resources>\n    <color name="ic_launcher_background">#000000</color>',
        )
        changed = True
    if changed:
        colors.write_text(text, encoding="utf-8")


def ensure_foreground(res: Path) -> None:
    drawable = res / "drawable"
    drawable.mkdir(parents=True, exist_ok=True)
    # Prefer existing density PNGs; only add XML if nothing named ic_launcher_foreground exists.
    existing = list(res.glob("**/ic_launcher_foreground.*"))
    if existing:
        return
    (drawable / "ic_launcher_foreground.xml").write_text(VECTOR_FG, encoding="utf-8")


def ensure_adaptive_icons(res: Path) -> None:
    anydpi = res / "mipmap-anydpi-v26"
    anydpi.mkdir(parents=True, exist_ok=True)
    default = anydpi / "ic_launcher.xml"
    white = anydpi / "ic_launcher_white.xml"
    if not default.exists():
        default.write_text(ADAPTIVE_DEFAULT, encoding="utf-8")
    if not white.exists():
        white.write_text(ADAPTIVE_WHITE, encoding="utf-8")


def copy_white_mipmaps(res: Path) -> None:
    for density in ("mdpi", "hdpi", "xhdpi", "xxhdpi", "xxxhdpi"):
        folder = res / f"mipmap-{density}"
        src = folder / "ic_launcher.png"
        dst = folder / "ic_launcher_white.png"
        if src.exists() and not dst.exists():
            shutil.copy2(src, dst)


def patch_manifest(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    if 'android:name=".DefaultIcon"' in text or 'android:name=".MonogramWhite"' in text:
        return False

    label_m = re.search(r'android:label="([^"]+)"', text)
    label = label_m.group(1) if label_m else "App"

    # Remove LAUNCHER intent-filter block from the main activity (keep activity itself).
    text2 = re.sub(
        r"\s*<intent-filter>\s*"
        r'<action android:name="android\.intent\.action\.MAIN"/>\s*'
        r'<category android:name="android\.intent\.category\.LAUNCHER"/>\s*'
        r"</intent-filter>",
        "",
        text,
        count=1,
        flags=re.MULTILINE,
    )

    aliases = ALIASES_TEMPLATE.format(label=label)
    # Insert aliases after the first </activity>
    if "</activity>" not in text2:
        raise SystemExit(f"No </activity> in {path}")
    text2 = text2.replace("</activity>", "</activity>\n" + aliases, 1)
    path.write_text(text2, encoding="utf-8")
    return True


def patch_pubspec(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    if "dynamic_app_icon_changer" in text:
        return False
    # Insert after flutter: sdk flutter block dependency list — after after_core if present
    needle = "  after_core:\n    path: ../supercore/packages/after_core\n"
    insert = needle + "  dynamic_app_icon_changer: ^0.0.3\n"
    if needle in text:
        path.write_text(text.replace(needle, insert, 1), encoding="utf-8")
        return True
    # afterhub / other layouts
    needle2 = "  flutter:\n    sdk: flutter\n"
    if needle2 in text:
        path.write_text(
            text.replace(needle2, needle2 + "  dynamic_app_icon_changer: ^0.0.3\n", 1),
            encoding="utf-8",
        )
        return True
    print(f"  WARN: could not insert dependency in {path}")
    return False


def patch_ios_info_plist(path: Path) -> bool:
    if not path.is_file():
        return False
    text = path.read_text(encoding="utf-8")
    if "MonogramWhite" in text:
        return False
    block = """	<key>CFBundleIcons</key>
	<dict>
		<key>CFBundleAlternateIcons</key>
		<dict>
			<key>MonogramWhite</key>
			<dict>
				<key>CFBundleIconFiles</key>
				<array>
					<string>AppIcon</string>
				</array>
				<key>UIPrerenderedIcon</key>
				<false/>
			</dict>
		</dict>
	</dict>
"""
    # Insert before </dict></plist> closing of root — before final </dict> that closes root
    if "<key>CFBundleIcons</key>" in text:
        return False
    marker = "\t<key>CFBundleDisplayName</key>"
    if marker in text:
        text = text.replace(marker, block + marker, 1)
        path.write_text(text, encoding="utf-8")
        return True
    # Fallback: before </plist>
    text = text.replace("</plist>", block + "</plist>", 1)
    path.write_text(text, encoding="utf-8")
    return True


def main() -> None:
    for app in APPS:
        root = HANTURAI / app
        if not root.is_dir():
            print(f"SKIP missing {app}")
            continue
        manifest = root / "android" / "app" / "src" / "main" / "AndroidManifest.xml"
        res = root / "android" / "app" / "src" / "main" / "res"
        pubspec = root / "pubspec.yaml"
        print(f"== {app}")
        if manifest.is_file():
            ensure_colors(res)
            ensure_foreground(res)
            ensure_adaptive_icons(res)
            copy_white_mipmaps(res)
            if patch_manifest(manifest):
                print("  manifest: aliases added")
            else:
                print("  manifest: already wired")
        else:
            print("  no AndroidManifest")
        if pubspec.is_file():
            if patch_pubspec(pubspec):
                print("  pubspec: dynamic_app_icon_changer added")
            else:
                print("  pubspec: ok")
        ios_plist = root / "ios" / "Runner" / "Info.plist"
        if patch_ios_info_plist(ios_plist):
            print("  ios: MonogramWhite alternate icon declared")
        elif ios_plist.is_file():
            print("  ios: ok/skip")


if __name__ == "__main__":
    main()
