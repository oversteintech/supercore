#!/usr/bin/env python3
"""Generate premium name-related product icons for sibling Super Apps.

Does NOT touch SuperGarage. Writes monogram PNGs under each app's
assets/branding/ using the shared AfterProductIconCatalog conventions.

Requires: pip install pillow
"""

from __future__ import annotations

import math
import os
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError as exc:  # pragma: no cover
    raise SystemExit(
        "Pillow required: pip install pillow\n" + str(exc)
    ) from exc

ROOT = Path(__file__).resolve().parents[2]  # HANTURAI/
SUPERCORE = Path(__file__).resolve().parents[1]

# package_folder -> (monogram, accent_rgb, glyph_hint letter)
# Folder names under HANTURAI (siblingPath basename).
PRODUCTS: dict[str, tuple[str, tuple[int, int, int], str]] = {
    "afterhub": ("AH", (99, 102, 241), "hub"),
    "superhealth": ("S+", (16, 185, 129), "health"),
    "superfinance": ("SF", (14, 165, 233), "finance"),
    "superhome": ("SH", (245, 158, 11), "home"),
    "supertravel": ("ST", (6, 182, 212), "travel"),
    "superpet": ("SP", (217, 119, 6), "pet"),
    "supernews": ("SN", (239, 68, 68), "news"),
    "supersports": ("SS", (34, 197, 94), "sports"),
    "supergames": ("SG", (168, 85, 247), "games"),
    "superfamily": ("SF", (236, 72, 153), "family"),
    "superdocuments": ("SD", (100, 116, 139), "docs"),
    "superlearning": ("SL", (59, 130, 246), "learn"),
    "superhospital": ("SH", (220, 38, 38), "hospital"),
    "superairport": ("SA", (2, 132, 199), "airport"),
    "supermaritime": ("SM", (14, 116, 144), "sea"),
    "superfactory": ("SF", (120, 113, 108), "factory"),
    "superlogistics": ("SL", (234, 88, 12), "logistics"),
    "superconstruction": ("SC", (249, 115, 22), "build"),
    "superschool": ("SS", (37, 99, 235), "school"),
    "superhotel": ("SH", (124, 58, 237), "hotel"),
    "superrestaurant": ("SR", (225, 29, 72), "food"),
    "superretail": ("SR", (219, 39, 119), "shop"),
    "superenergy": ("SE", (234, 179, 8), "energy"),
    "supermunicipality": ("SM", (71, 85, 105), "city"),
    "superfarm": ("SF", (101, 163, 13), "farm"),
    "superagriculture": ("SA", (22, 163, 74), "agri"),
    "superpolice": ("SP", (29, 78, 216), "police"),
    "superfire": ("SF", (220, 38, 38), "fire"),
    "supermining": ("SM", (146, 64, 14), "mine"),
}

# classic family gradient stops
GRADIENT = [
    (0.0, (225, 29, 72)),
    (0.5, (124, 58, 237)),
    (1.0, (37, 99, 235)),
]


def _lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def _mix(c0: tuple[int, int, int], c1: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return (
        int(_lerp(c0[0], c1[0], t)),
        int(_lerp(c0[1], c1[1], t)),
        int(_lerp(c0[2], c1[2], t)),
    )


def _gradient_color(t: float) -> tuple[int, int, int]:
    t = max(0.0, min(1.0, t))
    for i in range(len(GRADIENT) - 1):
        t0, c0 = GRADIENT[i]
        t1, c1 = GRADIENT[i + 1]
        if t0 <= t <= t1:
            local = 0.0 if t1 == t0 else (t - t0) / (t1 - t0)
            return _mix(c0, c1, local)
    return GRADIENT[-1][1]


def _font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "C:/Windows/Fonts/arialbd.ttf",
        "C:/Windows/Fonts/segoeuib.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    ]
    for path in candidates:
        if os.path.exists(path):
            return ImageFont.truetype(path, size=size)
    return ImageFont.load_default()


def render_icon(
    monogram: str,
    accent: tuple[int, int, int],
    size: int = 1024,
    *,
    transparent: bool = False,
    pad: float = 0.12,
) -> Image.Image:
    bg = (0, 0, 0, 0) if transparent else (10, 10, 10, 255)
    img = Image.new("RGBA", (size, size), bg)
    draw = ImageDraw.Draw(img)

    margin = int(size * pad)
    radius = int(size * 0.22)
    box = [margin, margin, size - margin, size - margin]
    if transparent:
        # Soft rounded plate for adaptive foreground.
        plate = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        pdraw = ImageDraw.Draw(plate)
        pdraw.rounded_rectangle(box, radius=radius, fill=(10, 10, 10, 255))
        img.alpha_composite(plate)
        draw = ImageDraw.Draw(img)
    else:
        draw.rounded_rectangle(box, radius=radius, fill=(10, 10, 10, 255))

    # Accent glow disc.
    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glow)
    cx = cy = size // 2
    for i in range(8, 0, -1):
        r = int(size * 0.28 * i / 8)
        alpha = int(28 * (i / 8))
        gdraw.ellipse(
            [cx - r, cy - r, cx + r, cy + r],
            fill=(accent[0], accent[1], accent[2], alpha),
        )
    img.alpha_composite(glow)
    draw = ImageDraw.Draw(img)

    font_size = int(size * (0.34 if len(monogram) > 2 else 0.42))
    font = _font(font_size)
    bbox = draw.textbbox((0, 0), monogram, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    x = (size - tw) / 2 - bbox[0]
    y = size * 0.28 - bbox[1]

    # Draw monogram with per-glyph gradient approximation.
    # Single text with average gradient color + shine.
    mid = _gradient_color(0.45)
    draw.text((x, y), monogram, font=font, fill=(*mid, 255))

    # Shine bar
    shine = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shine)
    sdraw.polygon(
        [
            (margin, margin),
            (size - margin, margin),
            (size - margin, int(size * 0.38)),
            (margin, int(size * 0.22)),
        ],
        fill=(255, 255, 255, 36),
    )
    img.alpha_composite(shine)

    # Domain accent bar under monogram
    bar_w = int(size * 0.28)
    bar_h = int(size * 0.03)
    bx0 = (size - bar_w) // 2
    by0 = int(size * 0.72)
    draw.rounded_rectangle(
        [bx0, by0, bx0 + bar_w, by0 + bar_h],
        radius=bar_h // 2,
        fill=(*accent, 230),
    )

    return img


def asset_stem(folder: str) -> str:
    if folder == "afterhub":
        return "after_hub"
    return folder.replace("super", "super_", 1) if not folder.startswith("super_") else folder
    # superhealth -> super_health


def stem_for(folder: str) -> str:
    mapping = {
        "afterhub": "after_hub",
        "superhealth": "super_health",
        "superfinance": "super_finance",
        "superhome": "super_home",
        "supertravel": "super_travel",
        "superpet": "super_pet",
        "supernews": "super_news",
        "supersports": "super_sports",
        "supergames": "super_games",
        "superfamily": "super_family",
        "superdocuments": "super_documents",
        "superlearning": "super_learning",
        "superhospital": "super_hospital",
        "superairport": "super_airport",
        "supermaritime": "super_maritime",
        "superfactory": "super_factory",
        "superlogistics": "super_logistics",
        "superconstruction": "super_construction",
        "superschool": "super_school",
        "superhotel": "super_hotel",
        "superrestaurant": "super_restaurant",
        "superretail": "super_retail",
        "superenergy": "super_energy",
        "supermunicipality": "super_municipality",
        "superfarm": "super_farm",
        "superagriculture": "super_agriculture",
        "superpolice": "super_police",
        "superfire": "super_fire",
        "supermining": "super_mining",
    }
    return mapping.get(folder, folder)


def write_branding(folder: str, monogram: str, accent: tuple[int, int, int]) -> None:
    app_dir = ROOT / folder
    if not app_dir.is_dir():
        print(f"skip missing app: {folder}")
        return
    out_dir = app_dir / "assets" / "branding"
    out_dir.mkdir(parents=True, exist_ok=True)
    stem = stem_for(folder)

    store = render_icon(monogram, accent, transparent=False, pad=0.0)
    store = store.resize((1024, 1024), Image.Resampling.LANCZOS)
    # Full-bleed black store tile
    store_full = Image.new("RGBA", (1024, 1024), (0, 0, 0, 255))
    mark = render_icon(monogram, accent, size=820, transparent=True, pad=0.08)
    store_full.paste(mark, ((1024 - 820) // 2, (1024 - 820) // 2), mark)

    mono = render_icon(monogram, accent, size=1024, transparent=True, pad=0.08)
    fg = render_icon(monogram, accent, size=1024, transparent=True, pad=0.18)

    store_full.convert("RGB").save(out_dir / f"{stem}_monogram_store.png", "PNG")
    mono.save(out_dir / f"{stem}_monogram.png", "PNG")
    fg.save(out_dir / f"{stem}_monogram_foreground.png", "PNG")
    # Premium alias used by shared catalog consumers
    store_full.convert("RGB").save(out_dir / f"{stem}_premium_icon.png", "PNG")
    print(f"ok {folder} -> {stem}_*")


def main() -> None:
    print(f"ROOT={ROOT}")
    for folder, (monogram, accent, _) in PRODUCTS.items():
        write_branding(folder, monogram, accent)
    print("done (Garage untouched)")


if __name__ == "__main__":
    main()
