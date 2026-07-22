#!/usr/bin/env python3
"""Rebuild black/white launcher icons for Super App dynamic-icon switching.

Fixes:
1. MonogramWhite aliases that still point at @mipmap/ic_launcher
2. ic_launcher_white.png density assets that were black copies
3. Adaptive XML so white uses white plate + transparent foreground glyph
"""
from __future__ import annotations

import shutil
from pathlib import Path

from PIL import Image

HANTURAI = Path(r"D:\Projects\HANTURAI")
SKIP = {"supergarage-ci-29693951454", "supergarage-ci-d15c40267"}
DENSITIES = ("mdpi", "hdpi", "xhdpi", "xxhdpi", "xxxhdpi")

ADAPTIVE_BLACK = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@color/ic_launcher_background"/>
  <foreground>
      <inset
          android:drawable="@drawable/{fg}"
          android:inset="10%" />
  </foreground>
</adaptive-icon>
"""

ADAPTIVE_WHITE = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@color/ic_launcher_background_white"/>
  <foreground>
      <inset
          android:drawable="@drawable/{fg}"
          android:inset="10%" />
  </foreground>
</adaptive-icon>
"""


def app_res_dirs() -> list[Path]:
    out: list[Path] = []
    for app in sorted(HANTURAI.iterdir()):
        if not app.is_dir() or app.name in SKIP:
            continue
        if not app.name.startswith("super") and app.name != "afterhub":
            continue
        res = app / "android" / "app" / "src" / "main" / "res"
        if res.is_dir():
            out.append(res)
    return out


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
    if "ic_launcher_background_white" not in text:
        text = text.replace(
            "</resources>",
            '    <color name="ic_launcher_background_white">#FFFFFF</color>\n</resources>',
        )
        colors.write_text(text, encoding="utf-8")
    if 'name="ic_launcher_background"' not in text:
        text = colors.read_text(encoding="utf-8").replace(
            "<resources>",
            '<resources>\n    <color name="ic_launcher_background">#000000</color>',
        )
        colors.write_text(text, encoding="utf-8")


def resolve_foreground_name(res: Path) -> str:
    # Prefer density PNG foregrounds; fall back to XML vector.
    for density in DENSITIES:
        if (res / f"drawable-{density}" / "ic_launcher_foreground.png").exists():
            return "ic_launcher_foreground"
    if (res / "drawable" / "ic_launcher_foreground.xml").exists():
        return "ic_launcher_foreground"
    if (res / "drawable" / "ic_launcher_foreground.png").exists():
        return "ic_launcher_foreground"
    return "ic_launcher_foreground"


def black_to_white_icon(src: Path, dst: Path) -> None:
    im = Image.open(src).convert("RGBA")
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a < 8:
                continue
            # Near-black plate → white plate; keep colored glyph pixels.
            if r <= 28 and g <= 28 and b <= 28:
                px[x, y] = (255, 255, 255, a)
    dst.parent.mkdir(parents=True, exist_ok=True)
    im.save(dst, format="PNG")


def composite_white_from_foreground(fg: Path, size: int, dst: Path) -> None:
    glyph = Image.open(fg).convert("RGBA")
    # Fit glyph into safe zone (~80% of canvas) like adaptive inset.
    canvas = Image.new("RGBA", (size, size), (255, 255, 255, 255))
    target = int(size * 0.80)
    glyph = glyph.copy()
    glyph.thumbnail((target, target), Image.Resampling.LANCZOS)
    x = (size - glyph.width) // 2
    y = (size - glyph.height) // 2
    canvas.alpha_composite(glyph, (x, y))
    dst.parent.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGBA").save(dst, format="PNG")


def rebuild_white_mipmaps(res: Path) -> int:
    changed = 0
    for density in DENSITIES:
        mip = res / f"mipmap-{density}"
        src_full = mip / "ic_launcher.png"
        dst_white = mip / "ic_launcher_white.png"
        fg = res / f"drawable-{density}" / "ic_launcher_foreground.png"
        if fg.exists() and src_full.exists():
            size = Image.open(src_full).size[0]
            composite_white_from_foreground(fg, size, dst_white)
            changed += 1
        elif src_full.exists():
            black_to_white_icon(src_full, dst_white)
            changed += 1
        elif dst_white.exists():
            # Ensure existing white asset isn't a black clone of itself path-wise
            black_to_white_icon(dst_white, dst_white)
            changed += 1
    return changed


def write_adaptive(res: Path, fg_name: str) -> None:
    anydpi = res / "mipmap-anydpi-v26"
    anydpi.mkdir(parents=True, exist_ok=True)
    (anydpi / "ic_launcher.xml").write_text(
        ADAPTIVE_BLACK.format(fg=fg_name), encoding="utf-8"
    )
    (anydpi / "ic_launcher_white.xml").write_text(
        ADAPTIVE_WHITE.format(fg=fg_name), encoding="utf-8"
    )


def fix_manifest(manifest: Path) -> bool:
    if not manifest.is_file():
        return False
    text = manifest.read_text(encoding="utf-8")
    orig = text

    # Ensure MonogramWhite uses white mipmap (split-based; avoid regex across aliases).
    marker = 'android:name=".MonogramWhite"'
    if marker in text:
        head, tail = text.split(marker, 1)
        end = tail.find('</activity-alias>')
        if end >= 0:
            block, rest = tail[:end], tail[end:]
            block = block.replace(
                'android:icon="@mipmap/ic_launcher"',
                'android:icon="@mipmap/ic_launcher_white"',
                1,
            )
            text = head + marker + block + rest

    if text != orig:
        manifest.write_text(text, encoding="utf-8")
        return True
    return False


def main() -> None:
    for res in app_res_dirs():
        app = res.parents[3].name
        print(f"== {app}")
        ensure_colors(res)
        fg = resolve_foreground_name(res)
        write_adaptive(res, fg)
        n = rebuild_white_mipmaps(res)
        print(f"  white mipmaps rebuilt: {n}")
        manifest = res.parents[1] / "AndroidManifest.xml"
        if fix_manifest(manifest):
            print("  manifest: MonogramWhite → ic_launcher_white")
        else:
            # still report if already correct
            if manifest.is_file() and "ic_launcher_white" in manifest.read_text(
                encoding="utf-8"
            ):
                print("  manifest: ok")
            else:
                print("  manifest: missing white alias icon")


if __name__ == "__main__":
    main()
