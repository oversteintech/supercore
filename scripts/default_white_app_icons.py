#!/usr/bin/env python3
"""Make white launcher the install-time default on every Super App.

- application android:icon → @mipmap/ic_launcher_white
- MonogramWhite alias enabled=true (white)
- DefaultIcon alias enabled=false (black alternate)
"""
from __future__ import annotations

import re
from pathlib import Path

HANTURAI = Path(r"D:\Projects\HANTURAI")
SKIP = {"supergarage-ci-29693951454", "supergarage-ci-d15c40267"}


def flip_alias_enabled(block: str, *, enabled: bool) -> str:
    flag = "true" if enabled else "false"
    if re.search(r'android:enabled="(true|false)"', block):
        return re.sub(
            r'android:enabled="(true|false)"',
            f'android:enabled="{flag}"',
            block,
            count=1,
        )
    # Insert after android:name=...
    return re.sub(
        r'(android:name="\.[^"]+")',
        rf'\1\n            android:enabled="{flag}"',
        block,
        count=1,
    )


def patch_manifest(text: str) -> str:
    # App-level icon → white plate
    text = re.sub(
        r'android:icon="@mipmap/ic_launcher"',
        'android:icon="@mipmap/ic_launcher_white"',
        text,
        count=1,
    )

    for name, enabled in (("DefaultIcon", False), ("MonogramWhite", True)):
        marker = f'android:name=".{name}"'
        if marker not in text:
            continue
        head, tail = text.split(marker, 1)
        end = tail.find("</activity-alias>")
        if end < 0:
            continue
        block, rest = tail[:end], tail[end:]
        block = flip_alias_enabled(block, enabled=enabled)
        text = head + marker + block + rest
    return text


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
        if 'android:name=".MonogramWhite"' not in text:
            print(f"SKIP {app.name}")
            continue
        new = patch_manifest(text)
        if new != text:
            path.write_text(new, encoding="utf-8")
            print(f"FIXED {app.name}")
        else:
            print(f"OK {app.name}")


if __name__ == "__main__":
    main()
