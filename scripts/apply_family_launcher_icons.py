#!/usr/bin/env python3
"""Apply white-plate Full HD family icons as store-quality launchers on every OS.

Black icon / logo backgrounds are forbidden. Adaptive + store masters use white.
"""

from __future__ import annotations

import json
import os
import re
import time
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

STUDIO = Path(r"C:/Users/ayhan/StudioProjects")
GARAGE = STUDIO / "supergarage"
HD_DIR = GARAGE / "assets/branding/super_app_icons"
ADS_HD = (
    STUDIO / "supercore/packages/after_design_system/assets/branding/super_app_icons"
)
PREVIEW_DIR = GARAGE / ".artifacts/launcher_previews"

APP_TARGETS: dict[str, tuple[str, str]] = {
    "garage": ("supergarage", "super_garage"),
    "finance": ("superfinance", "super_finance"),
    "health": ("superhealth", "super_health"),
    "home": ("superhome", "super_home"),
    "sports": ("supersports", "super_sports"),
    "news": ("supernews", "super_news"),
    "pets": ("superpet", "super_pet"),
}

STORE_SIZE = 1024
ADAPTIVE_FILL = 0.78
PLATE = (255, 255, 255)
ADAPTIVE_XML = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@color/ic_launcher_background"/>
  <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>
"""

ANDROID_MIPMAP = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}
ANDROID_FOREGROUND = {
    "drawable-mdpi": 108,
    "drawable-hdpi": 162,
    "drawable-xhdpi": 216,
    "drawable-xxhdpi": 324,
    "drawable-xxxhdpi": 432,
}


def _save_png(image: Image.Image, path: Path, *, rgb: bool = False) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    payload = image.convert("RGB") if rgb else image
    last_err: Exception | None = None
    for attempt in range(6):
        try:
            payload.save(tmp, "PNG", optimize=True)
            os.replace(tmp, path)
            return
        except OSError as exc:
            last_err = exc
            time.sleep(0.35 * (attempt + 1))
            if tmp.exists():
                try:
                    tmp.unlink()
                except OSError:
                    pass
    raise RuntimeError(f"Could not write {path}: {last_err}") from last_err


def _hd_path(name: str) -> Path:
    for base in (HD_DIR, ADS_HD):
        path = base / f"super_{name}_hd.png"
        if path.is_file():
            return path
    raise FileNotFoundError(f"Missing HD icon for {name}")


def make_store(src: Image.Image, size: int = STORE_SIZE) -> Image.Image:
    rgb = src.convert("RGB").resize((size, size), Image.Resampling.LANCZOS)
    return rgb.filter(ImageFilter.UnsharpMask(radius=1.2, percent=90, threshold=2))


def make_adaptive_foreground(
    src: Image.Image,
    size: int = STORE_SIZE,
    fill: float = ADAPTIVE_FILL,
) -> Image.Image:
    """White plate + centered framed icon sized for circle masks."""
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    inner = int(round(size * fill))
    if inner % 2:
        inner += 1
    plate = Image.new("RGBA", (inner, inner), (*PLATE, 255))
    icon = src.convert("RGBA").resize((inner, inner), Image.Resampling.LANCZOS)
    plate.alpha_composite(icon)
    plate = plate.filter(ImageFilter.UnsharpMask(radius=1.0, percent=80, threshold=2))
    offset = (size - inner) // 2
    canvas.paste(plate, (offset, offset))
    return canvas


def _patch_pubspec_white(app_dir: Path) -> None:
    pubspec = app_dir / "pubspec.yaml"
    text = pubspec.read_text(encoding="utf-8")
    text2 = text.replace(
        'adaptive_icon_background: "#000000"',
        'adaptive_icon_background: "#FFFFFF"',
    )
    text2 = text2.replace(
        "adaptive_icon_foreground_inset: 10",
        "adaptive_icon_foreground_inset: 0",
    )
    if 'adaptive_icon_background: "#FFFFFF"' not in text2:
        # Force any other black hex variants under flutter_launcher_icons.
        text2 = re.sub(
            r'(adaptive_icon_background:\s*")#[0-9A-Fa-f]{6}(")',
            r'\1#FFFFFF\2',
            text2,
        )
    if text2 != text:
        pubspec.write_text(text2, encoding="utf-8")
        print("  pubspec -> white adaptive background")


def _force_white_launcher_colors(app_dir: Path) -> None:
    colors = app_dir / "android/app/src/main/res/values/colors.xml"
    if not colors.is_file():
        colors.parent.mkdir(parents=True, exist_ok=True)
        colors.write_text(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            "<resources>\n"
            '    <color name="ic_launcher_background">#FFFFFF</color>\n'
            '    <color name="ic_launcher_background_white">#FFFFFF</color>\n'
            "</resources>\n",
            encoding="utf-8",
        )
        return
    text = colors.read_text(encoding="utf-8")
    text2 = re.sub(
        r'(<color name="ic_launcher_background">)#(?:000000|0{6}|FF000000)(</color>)',
        r"\1#FFFFFF\2",
        text,
        flags=re.IGNORECASE,
    )
    if 'name="ic_launcher_background"' not in text2:
        text2 = text2.replace(
            "</resources>",
            '    <color name="ic_launcher_background">#FFFFFF</color>\n</resources>',
        )
    else:
        # Any remaining black value on the primary launcher bg.
        text2 = re.sub(
            r'(<color name="ic_launcher_background">)#[0-9A-Fa-f]{6,8}(</color>)',
            r"\1#FFFFFF\2",
            text2,
        )
    if 'name="ic_launcher_background_white"' not in text2:
        text2 = text2.replace(
            "</resources>",
            '    <color name="ic_launcher_background_white">#FFFFFF</color>\n</resources>',
        )
    if text2 != text:
        colors.write_text(text2, encoding="utf-8")
        print("  colors.xml -> white launcher background")


def _write_adaptive_xml(app_dir: Path) -> None:
    xml_path = app_dir / "android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml"
    if not xml_path.parent.is_dir():
        return
    xml_path.write_text(ADAPTIVE_XML, encoding="utf-8")
    white = xml_path.with_name("ic_launcher_white.xml")
    # White alternate is identical now (primary is already white).
    white.write_text(ADAPTIVE_XML, encoding="utf-8")


def apply_to_app(name: str, hd: Image.Image) -> Path:
    folder, stem = APP_TARGETS[name]
    app_dir = STUDIO / folder
    if not app_dir.is_dir():
        raise FileNotFoundError(app_dir)

    out = app_dir / "assets/branding"
    out.mkdir(parents=True, exist_ok=True)

    icons_dir = app_dir / "assets/branding/super_app_icons"
    icons_dir.mkdir(parents=True, exist_ok=True)
    _save_png(hd, icons_dir / f"super_{name}_hd.png", rgb=True)

    store = make_store(hd)
    mono = make_adaptive_foreground(hd, fill=0.92)
    fg = make_adaptive_foreground(hd, fill=ADAPTIVE_FILL)

    _save_png(store, out / f"{stem}_monogram_store.png", rgb=True)
    _save_png(mono, out / f"{stem}_monogram.png")
    _save_png(fg, out / f"{stem}_monogram_foreground.png")
    _save_png(store, out / f"{stem}_premium_icon.png", rgb=True)

    if name == "garage":
        _save_png(store, out / "super_garage_launcher.png", rgb=True)
        _save_png(store, out / "super_garage_launcher_store.png", rgb=True)
        _save_png(fg, out / "super_garage_launcher_foreground.png")

    _patch_pubspec_white(app_dir)
    _force_white_launcher_colors(app_dir)
    return app_dir


def install_android_icons(app_dir: Path, store: Image.Image, fg: Image.Image) -> None:
    res = app_dir / "android/app/src/main/res"
    if not res.is_dir():
        print(f"  skip Android (no res): {app_dir.name}")
        return
    _force_white_launcher_colors(app_dir)
    for folder, px in ANDROID_MIPMAP.items():
        dest_dir = res / folder
        dest_dir.mkdir(parents=True, exist_ok=True)
        icon = store.resize((px, px), Image.Resampling.LANCZOS)
        _save_png(icon, dest_dir / "ic_launcher.png", rgb=True)
        _save_png(icon, dest_dir / "ic_launcher_white.png", rgb=True)
    for folder, px in ANDROID_FOREGROUND.items():
        dest_dir = res / folder
        dest_dir.mkdir(parents=True, exist_ok=True)
        layer = fg.resize((px, px), Image.Resampling.LANCZOS)
        _save_png(layer, dest_dir / "ic_launcher_foreground.png")
    _write_adaptive_xml(app_dir)
    print(f"  Android OK {app_dir.name}")


def install_ios_icons(app_dir: Path, store: Image.Image) -> None:
    iconset = app_dir / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    contents = iconset / "Contents.json"
    if not contents.is_file():
        print(f"  skip iOS (no AppIcon): {app_dir.name}")
        return
    data = json.loads(contents.read_text(encoding="utf-8"))
    written: set[str] = set()
    for entry in data.get("images", []):
        filename = entry.get("filename")
        if not filename or filename in written:
            continue
        size_pt = float(entry["size"].split("x")[0])
        scale = int(str(entry.get("scale", "1x")).replace("x", ""))
        px = int(round(size_pt * scale))
        icon = store.resize((px, px), Image.Resampling.LANCZOS)
        _save_png(icon, iconset / filename, rgb=True)
        written.add(filename)
    print(f"  iOS OK {app_dir.name} ({len(written)} files)")


def install_platform_icons(app_dir: Path, store: Image.Image, fg: Image.Image) -> None:
    print(f"  installing platform icons @ {app_dir.name}")
    install_android_icons(app_dir, store, fg)
    install_ios_icons(app_dir, store)


def write_mask_previews(name: str, store: Image.Image, fg: Image.Image) -> None:
    """Visual QA: square / squircle / circle on light gray."""
    PREVIEW_DIR.mkdir(parents=True, exist_ok=True)
    size = 512
    store_s = store.resize((size, size), Image.Resampling.LANCZOS)
    fg_s = fg.resize((size, size), Image.Resampling.LANCZOS)

    def composite(mask: Image.Image) -> Image.Image:
        bg = Image.new("RGBA", (size, size), (*PLATE, 255))
        layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        layer.paste(fg_s, (0, 0), fg_s)
        out = Image.alpha_composite(bg, layer)
        out.putalpha(mask)
        final = Image.new("RGBA", (size, size), (230, 230, 230, 255))
        final.alpha_composite(out)
        return final.convert("RGB")

    circle = Image.new("L", (size, size), 0)
    ImageDraw.Draw(circle).ellipse((0, 0, size - 1, size - 1), fill=255)
    squircle = Image.new("L", (size, size), 0)
    ImageDraw.Draw(squircle).rounded_rectangle(
        (0, 0, size - 1, size - 1), radius=int(size * 0.22), fill=255
    )

    sheet = Image.new("RGB", (size * 3 + 40, size + 20), (235, 235, 235))
    sheet.paste(store_s, (10, 10))
    sheet.paste(composite(squircle), (size + 20, 10))
    sheet.paste(composite(circle), (size * 2 + 30, 10))
    _save_png(sheet, PREVIEW_DIR / f"{name}_masks.png", rgb=True)


def delete_black_icon_sources() -> None:
    """Remove black-plate concept boards used for icons (forbidden)."""
    doomed = [
        GARAGE / "assets/branding/super_app_concepts/theme-a-reduced-black.png",
        GARAGE / "assets/branding/super_app_concepts/theme-a-metallic-black.png",
        ADS_HD.parent / "super_app_concepts/theme-a-reduced-black.png",
        ADS_HD.parent / "super_app_concepts/theme-a-metallic-black.png",
        ADS_HD.parent / "super_app_concepts/theme-a-metallic-black-crops.png",
    ]
    for path in doomed:
        if path.is_file():
            path.unlink()
            print(f"deleted black board {path}")


def main() -> None:
    for name in APP_TARGETS:
        hd = Image.open(_hd_path(name)).convert("RGB")
        # Guard: reject mostly-black plates.
        sample = hd.resize((64, 64), Image.Resampling.BOX)
        dark = sum(1 for p in sample.getdata() if p[0] < 40 and p[1] < 40 and p[2] < 40)
        if dark > 64 * 64 * 0.45:
            raise RuntimeError(
                f"{name} HD still looks black-plated ({dark} dark samples). "
                "Rebuild from theme-a-reduced-white.png first."
            )
        print(f"{name}: {hd.size} from {_hd_path(name).name}")
        app_dir = apply_to_app(name, hd)
        store = make_store(hd)
        fg = make_adaptive_foreground(hd)
        write_mask_previews(name, store, fg)
        install_platform_icons(app_dir, store, fg)

    delete_black_icon_sources()
    print(f"mask previews -> {PREVIEW_DIR}")
    print("done")


if __name__ == "__main__":
    main()
