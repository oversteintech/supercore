#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

HANTURAI = Path(r"D:\Projects\HANTURAI")
SKIP = {"supergarage-ci-29693951454", "supergarage-ci-d15c40267"}


def fix_manifest(text: str) -> str:
    marker = 'android:name=".MonogramWhite"'
    if marker not in text:
        return text
    head, tail = text.split(marker, 1)
    # Only rewrite the first icon= after MonogramWhite (within this alias).
    end = tail.find("</activity-alias>")
    if end < 0:
        return text
    block, rest = tail[:end], tail[end:]
    block = block.replace(
        'android:icon="@mipmap/ic_launcher"',
        'android:icon="@mipmap/ic_launcher_white"',
        1,
    )
    return head + marker + block + rest


def main() -> None:
    for app in sorted(HANTURAI.iterdir()):
        if not app.is_dir() or app.name in SKIP:
            continue
        if not (app.name.startswith("super") or app.name == "afterhub"):
            continue
        path = app / "android" / "app" / "src" / "main" / "AndroidManifest.xml"
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8")
        new = fix_manifest(text)
        if new != text:
            path.write_text(new, encoding="utf-8")
            print(f"FIXED {app.name}")
        elif 'android:name=".MonogramWhite"' in text:
            ok = "ic_launcher_white" in text.split(
                'android:name=".MonogramWhite"', 1
            )[1].split("</activity-alias>", 1)[0]
            print(f"{'OK' if ok else 'FAIL'} {app.name}")
        else:
            print(f"SKIP {app.name} (no MonogramWhite)")


if __name__ == "__main__":
    main()
