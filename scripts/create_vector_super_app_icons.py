#!/usr/bin/env python3
"""Super App family icons — Option B+D hybrid.

B: soft chrome skeuomorphic depth
D: bold embossed glyph readability
Colors: black plate, silver metal, saturated red / electric blue accents.
Pure vector SVG (no photo embeds).
"""

from __future__ import annotations

import shutil
import sys
from pathlib import Path

from PIL import Image

STUDIO = Path(r"C:/Users/ayhan/StudioProjects")
ADS = STUDIO / "supercore/packages/after_design_system"
ADS_ICONS = ADS / "assets/branding/super_app_icons"
GARAGE_ICONS = STUDIO / "supergarage/assets/branding/super_app_icons"
ADS_PRODUCT = ADS / "assets/product_icons"

sys.path.insert(0, str(STUDIO / "supergarage/tools/.vector_deps"))

SIZE = 1920

APP_TARGETS = {
    "garage": ("supergarage", "super_garage"),
    "finance": ("superfinance", "super_finance"),
    "health": ("superhealth", "super_health"),
    "home": ("superhome", "super_home"),
    "sports": ("supersports", "super_sports"),
    "news": ("supernews", "super_news"),
    "pets": ("superpet", "super_pet"),
}

# Saturated palette
RED = "#E11D2E"
RED_HOT = "#FF3B4A"
RED_DEEP = "#9B1020"
BLUE = "#1E6BFF"
BLUE_HOT = "#4D8FFF"
BLUE_DEEP = "#0B3DB8"

DEFS = f"""
  <defs>
    <linearGradient id="metal" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="28%" stop-color="#D8DCE3"/>
      <stop offset="62%" stop-color="#8E949E"/>
      <stop offset="100%" stop-color="#3A3F48"/>
    </linearGradient>
    <linearGradient id="metalVert" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#F5F6F8"/>
      <stop offset="40%" stop-color="#B4B9C2"/>
      <stop offset="100%" stop-color="#2F343C"/>
    </linearGradient>
    <linearGradient id="metalHoriz" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#5A606A"/>
      <stop offset="45%" stop-color="#E4E7EC"/>
      <stop offset="100%" stop-color="#4E545E"/>
    </linearGradient>
    <linearGradient id="chrome" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="25%" stop-color="#CED3DB"/>
      <stop offset="75%" stop-color="#6E747E"/>
      <stop offset="100%" stop-color="#1C2026"/>
    </linearGradient>
    <linearGradient id="darkMetal" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#A8AEB8"/>
      <stop offset="55%" stop-color="#4A505A"/>
      <stop offset="100%" stop-color="#12151A"/>
    </linearGradient>
    <radialGradient id="plate" cx="38%" cy="28%" r="78%">
      <stop offset="0%" stop-color="#1A1D22"/>
      <stop offset="55%" stop-color="#070809"/>
      <stop offset="100%" stop-color="#000000"/>
    </radialGradient>
    <linearGradient id="redMetal" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="{RED_HOT}"/>
      <stop offset="45%" stop-color="{RED}"/>
      <stop offset="100%" stop-color="{RED_DEEP}"/>
    </linearGradient>
    <linearGradient id="blueMetal" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="{BLUE_HOT}"/>
      <stop offset="45%" stop-color="{BLUE}"/>
      <stop offset="100%" stop-color="{BLUE_DEEP}"/>
    </linearGradient>
    <filter id="glowRed" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur stdDeviation="10" result="b"/>
      <feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
    <filter id="glowBlue" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur stdDeviation="10" result="b"/>
      <feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
    <filter id="emboss">
      <feDropShadow dx="0" dy="8" stdDeviation="6" flood-color="#000000" flood-opacity="0.55"/>
    </filter>
  </defs>
"""


def wrap(title: str, body: str) -> str:
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="{SIZE}" height="{SIZE}"
     viewBox="0 0 {SIZE} {SIZE}" role="img">
  <title>{title}</title>
  <desc>B+D hybrid Super App icon: soft chrome depth, bold glyph, saturated accents. SuperCore after_design_system.</desc>
{DEFS}
  <rect x="40" y="40" width="1840" height="1840" rx="430" ry="430" fill="#FFFFFF"/>
  <rect x="40" y="40" width="1840" height="1840" rx="430" ry="430" fill="url(#plate)"/>
  <rect x="64" y="64" width="1792" height="1792" rx="410" ry="410"
        fill="none" stroke="url(#metal)" stroke-width="44"/>
  <rect x="104" y="104" width="1712" height="1712" rx="390" ry="390"
        fill="none" stroke="#1A1D22" stroke-width="12"/>
{body}
</svg>
'''


def garage() -> str:
    return wrap(
        "SuperGarage icon",
        f"""
  <g filter="url(#emboss)">
    <path d="M960 280 L1520 620 L1520 1320 L400 1320 L400 620 Z"
          fill="url(#metalVert)" stroke="#0E1014" stroke-width="10"/>
    <path d="M960 340 L1440 650 L1440 740 L960 430 L480 740 L480 650 Z"
          fill="url(#chrome)"/>
    <path d="M520 720 L1400 720 L1400 1280 L520 1280 Z" fill="#050607"/>
    <g stroke="#0E1014" stroke-width="5">
      <rect x="560" y="740" width="800" height="90" rx="12" fill="url(#metalHoriz)"/>
      <rect x="560" y="840" width="800" height="90" rx="12" fill="url(#metalHoriz)"/>
      <rect x="560" y="940" width="800" height="90" rx="12" fill="url(#metalHoriz)"/>
      <rect x="560" y="1040" width="800" height="90" rx="12" fill="url(#chrome)"/>
      <rect x="560" y="1140" width="800" height="70" rx="12" fill="url(#darkMetal)"/>
    </g>
  </g>
  <!-- saturated red neon -->
  <rect x="470" y="720" width="36" height="560" rx="12" fill="url(#redMetal)" filter="url(#glowRed)"/>
  <rect x="1414" y="720" width="36" height="560" rx="12" fill="url(#redMetal)" filter="url(#glowRed)"/>
  <rect x="560" y="700" width="800" height="16" rx="8" fill="{RED_HOT}" filter="url(#glowRed)" opacity="0.85"/>
  <path d="M680 1320 L1240 1320 L1360 1640 L560 1640 Z" fill="#08090B"
        stroke="url(#metal)" stroke-width="16"/>
  <path d="M700 1320 L740 1640" stroke="{RED}" stroke-width="10" opacity="0.9"/>
  <path d="M1220 1320 L1180 1640" stroke="{RED}" stroke-width="10" opacity="0.9"/>
  <g fill="#F2F4F7">
    <rect x="920" y="1380" width="80" height="44" rx="8"/>
    <rect x="935" y="1465" width="50" height="34" rx="6"/>
    <rect x="948" y="1540" width="28" height="26" rx="5"/>
  </g>
""",
    )


def finance() -> str:
    return wrap(
        "SuperFinance icon",
        f"""
  <g filter="url(#emboss)">
    <circle cx="840" cy="840" r="440" fill="none" stroke="url(#metal)" stroke-width="80"/>
    <circle cx="840" cy="840" r="440" fill="none" stroke="#0E1014" stroke-width="10"/>
    <g fill="url(#chrome)">
      <circle cx="840" cy="420" r="28"/><circle cx="1140" cy="520" r="28"/>
      <circle cx="1260" cy="800" r="28"/><circle cx="1140" cy="1100" r="28"/>
      <circle cx="840" cy="1240" r="28"/><circle cx="540" cy="1100" r="28"/>
      <circle cx="420" cy="800" r="28"/><circle cx="540" cy="520" r="28"/>
    </g>
    <g stroke="url(#chrome)" stroke-width="56" stroke-linecap="round">
      <line x1="840" y1="840" x2="840" y2="580"/>
      <line x1="840" y1="840" x2="1030" y2="690"/>
      <line x1="840" y1="840" x2="1100" y2="880"/>
      <line x1="840" y1="840" x2="1000" y2="1060"/>
      <line x1="840" y1="840" x2="680" y2="1060"/>
      <line x1="840" y1="840" x2="580" y2="880"/>
    </g>
    <circle cx="840" cy="840" r="100" fill="url(#metalVert)" stroke="#0E1014" stroke-width="8"/>
    <rect x="760" y="1160" width="100" height="260" rx="20" fill="url(#metalVert)"/>
    <rect x="900" y="1040" width="100" height="380" rx="20" fill="url(#metalVert)"/>
    <rect x="1040" y="900" width="100" height="520" rx="20" fill="url(#chrome)"/>
    <rect x="1180" y="760" width="100" height="660" rx="20" fill="url(#chrome)"/>
    <rect x="1320" y="600" width="100" height="820" rx="20" fill="url(#metal)"/>
  </g>
  <path d="M720 1500 C980 1500 1200 1320 1360 920 L1480 1000 L1420 680 L1120 760 L1240 840
           C1120 1160 960 1320 720 1360 Z"
        fill="url(#redMetal)" stroke="{RED_DEEP}" stroke-width="8" filter="url(#glowRed)"/>
""",
    )


def supermarket() -> str:
    return wrap(
        "SuperMarket icon",
        f"""
  <g filter="url(#emboss)">
    <path d="M400 780 L1520 780 L1420 1520 L500 1520 Z" fill="url(#darkMetal)" stroke="#0E1014" stroke-width="10"/>
    <g stroke="url(#metal)" stroke-width="32" stroke-linecap="round">
      <line x1="500" y1="880" x2="1420" y2="880"/>
      <line x1="480" y1="1020" x2="1440" y2="1020"/>
      <line x1="470" y1="1160" x2="1450" y2="1160"/>
      <line x1="490" y1="1300" x2="1430" y2="1300"/>
      <line x1="520" y1="1440" x2="1400" y2="1440"/>
      <line x1="600" y1="800" x2="540" y2="1500"/>
      <line x1="820" y1="800" x2="780" y2="1500"/>
      <line x1="1040" y1="800" x2="1040" y2="1500"/>
      <line x1="1260" y1="800" x2="1300" y2="1500"/>
    </g>
    <rect x="380" y="730" width="1160" height="80" rx="32" fill="url(#chrome)" stroke="#0E1014" stroke-width="8"/>
    <path d="M540 730 C540 440 1380 440 1380 730" fill="none"
          stroke="url(#metal)" stroke-width="64" stroke-linecap="round"/>
    <circle cx="540" cy="760" r="42" fill="url(#chrome)"/>
    <circle cx="1380" cy="760" r="42" fill="url(#chrome)"/>
  </g>
  <ellipse cx="960" cy="1040" rx="180" ry="170" fill="url(#redMetal)" stroke="{RED_DEEP}" stroke-width="8" filter="url(#glowRed)"/>
  <ellipse cx="960" cy="980" rx="48" ry="22" fill="#FFB0B6" opacity="0.55"/>
  <circle cx="1200" cy="1120" r="78" fill="url(#blueMetal)" stroke="{BLUE_DEEP}" stroke-width="6" filter="url(#glowBlue)"/>
  <circle cx="1320" cy="1180" r="60" fill="url(#blueMetal)" stroke="{BLUE_DEEP}" stroke-width="6"/>
  <path d="M760 860 C700 680 900 620 940 800 C860 760 800 820 760 860 Z" fill="url(#metal)"/>
  <path d="M1100 840 C1160 660 1340 700 1280 880 C1220 800 1140 820 1100 840 Z" fill="url(#redMetal)"/>
  <path d="M900 820 C960 640 1100 660 1040 840 C1000 760 940 800 900 820 Z" fill="url(#chrome)"/>
""",
    )


def health() -> str:
    return wrap(
        "SuperHealth icon",
        f"""
  <circle cx="960" cy="960" r="540" fill="none" stroke="url(#metal)" stroke-width="72" filter="url(#emboss)"/>
  <circle cx="960" cy="960" r="480" fill="none" stroke="#0E1014" stroke-width="10"/>
  <g filter="url(#emboss)">
    <rect x="740" y="380" width="440" height="1160" rx="220" fill="url(#chrome)" stroke="#0E1014" stroke-width="10"/>
    <rect x="740" y="380" width="220" height="1160" rx="220" fill="url(#blueMetal)"/>
    <rect x="780" y="680" width="360" height="22" rx="10" fill="#0E1014" opacity="0.4"/>
    <rect x="780" y="1220" width="360" height="22" rx="10" fill="#0E1014" opacity="0.4"/>
  </g>
  <path d="M320 960 L580 960 L680 960 L760 720 L860 1240 L960 820 L1060 960 L1600 960"
        fill="none" stroke="{BLUE_HOT}" stroke-width="42" stroke-linecap="round"
        stroke-linejoin="round" filter="url(#glowBlue)"/>
""",
    )


def home() -> str:
    return wrap(
        "SuperHome icon",
        f"""
  <g filter="url(#emboss)">
    <path d="M960 260 L1600 800 L1420 800 L960 400 L500 800 L320 800 Z" fill="url(#chrome)"/>
    <path d="M960 380 L1460 840 L1300 840 L960 500 L620 840 L460 840 Z" fill="url(#metalVert)"/>
    <path d="M540 840 L1380 840 L1380 1320 L540 1320 Z" fill="url(#darkMetal)" stroke="#0E1014" stroke-width="8"/>
    <rect x="760" y="900" width="400" height="320" rx="28" fill="#050607" stroke="url(#metal)" stroke-width="18"/>
  </g>
  <g fill="url(#blueMetal)" filter="url(#glowBlue)">
    <rect x="790" y="930" width="110" height="120" rx="12"/>
    <rect x="925" y="930" width="110" height="120" rx="12"/>
    <rect x="1060" y="930" width="80" height="120" rx="12"/>
    <rect x="790" y="1075" width="110" height="120" rx="12"/>
    <rect x="925" y="1075" width="110" height="120" rx="12"/>
    <rect x="1060" y="1075" width="80" height="120" rx="12"/>
  </g>
  <rect x="620" y="1320" width="680" height="56" rx="12" fill="url(#metalHoriz)"/>
  <rect x="690" y="1388" width="540" height="56" rx="12" fill="url(#metalVert)"/>
  <rect x="760" y="1456" width="400" height="56" rx="12" fill="url(#chrome)"/>
  <ellipse cx="540" cy="1460" rx="140" ry="100" fill="url(#blueMetal)" filter="url(#glowBlue)"/>
  <ellipse cx="1380" cy="1460" rx="140" ry="100" fill="url(#blueMetal)" filter="url(#glowBlue)"/>
""",
    )


def sports() -> str:
    return wrap(
        "SuperSports icon",
        f"""
  <g filter="url(#emboss)">
    <ellipse cx="960" cy="1300" rx="660" ry="300" fill="none" stroke="url(#metal)" stroke-width="80"/>
    <ellipse cx="960" cy="1300" rx="500" ry="210" fill="none" stroke="url(#redMetal)" stroke-width="48"/>
    <ellipse cx="960" cy="1300" rx="340" ry="130" fill="none" stroke="url(#redMetal)" stroke-width="32"/>
    <ellipse cx="960" cy="1300" rx="180" ry="60" fill="#050607" stroke="url(#darkMetal)" stroke-width="18"/>
    <circle cx="1120" cy="480" r="100" fill="url(#chrome)" stroke="#0E1014" stroke-width="8"/>
    <path d="M1100 570 C980 720 880 840 780 1020 C880 960 1000 900 1140 860
             C1220 1020 1300 1180 1360 1340 C1260 1200 1140 1040 1060 920
             C980 820 1100 680 1140 600 Z"
          fill="url(#metalVert)" stroke="#0E1014" stroke-width="8"/>
    <path d="M1000 680 C840 740 680 840 560 980" fill="none"
          stroke="url(#chrome)" stroke-width="60" stroke-linecap="round"/>
    <path d="M1220 760 C1380 860 1500 1020 1560 1180" fill="none"
          stroke="url(#metal)" stroke-width="50" stroke-linecap="round"/>
  </g>
  <path d="M620 540 C820 440 1060 420 1280 500" fill="none"
        stroke="#F2F4F7" stroke-width="20" stroke-linecap="round" opacity="0.55"/>
""",
    )


def news() -> str:
    return wrap(
        "SuperNews icon",
        f"""
  <g filter="url(#emboss)">
    <path d="M400 540 L1300 440 L1420 1400 L520 1500 Z" fill="url(#darkMetal)" stroke="#0E1014" stroke-width="10"/>
    <path d="M470 520 L1370 420 L1460 1300 L560 1400 Z" fill="url(#metalVert)" stroke="#0E1014" stroke-width="8"/>
    <path d="M540 500 L1440 400 L1500 1200 L600 1300 Z" fill="url(#chrome)" stroke="#0E1014" stroke-width="8"/>
    <g fill="#2A2E36">
      <rect x="700" y="600" width="540" height="32" rx="10"/>
      <rect x="700" y="670" width="500" height="26" rx="8"/>
      <rect x="700" y="730" width="520" height="26" rx="8"/>
      <rect x="700" y="790" width="420" height="26" rx="8"/>
      <rect x="700" y="880" width="300" height="26" rx="8"/>
      <rect x="700" y="940" width="340" height="26" rx="8"/>
      <rect x="700" y="1000" width="280" height="26" rx="8"/>
    </g>
    <rect x="1060" y="880" width="300" height="240" rx="24" fill="#050607" stroke="url(#metal)" stroke-width="16"/>
    <path d="M1100 1060 L1170 960 L1240 1030 L1310 930 L1340 1060 Z" fill="url(#metalHoriz)"/>
  </g>
  <g fill="none" stroke="url(#redMetal)" stroke-width="40" stroke-linecap="round" filter="url(#glowRed)">
    <path d="M1400 500 A140 140 0 0 1 1540 640"/>
    <path d="M1350 430 A230 230 0 0 1 1610 700"/>
    <path d="M1300 360 A320 320 0 0 1 1680 760"/>
  </g>
""",
    )


def pets() -> str:
    return wrap(
        "SuperPets icon",
        f"""
  <g filter="url(#emboss)">
    <path d="M960 1520
             C740 1340 480 1120 480 840
             C480 660 620 520 800 520
             C890 520 940 570 960 640
             C980 570 1030 520 1120 520
             C1300 520 1440 660 1440 840
             C1440 1120 1180 1340 960 1520 Z"
          fill="url(#redMetal)" stroke="url(#chrome)" stroke-width="64"/>
    <ellipse cx="960" cy="1100" rx="170" ry="150" fill="url(#chrome)" stroke="#0E1014" stroke-width="8"/>
    <ellipse cx="760" cy="880" rx="78" ry="100" fill="url(#chrome)" stroke="#0E1014" stroke-width="6"/>
    <ellipse cx="890" cy="810" rx="78" ry="100" fill="url(#chrome)" stroke="#0E1014" stroke-width="6"/>
    <ellipse cx="1030" cy="810" rx="78" ry="100" fill="url(#chrome)" stroke="#0E1014" stroke-width="6"/>
    <ellipse cx="1160" cy="880" rx="78" ry="100" fill="url(#chrome)" stroke="#0E1014" stroke-width="6"/>
  </g>
""",
    )


ICONS = {
    "garage": garage,
    "finance": finance,
    "supermarket": supermarket,
    "health": health,
    "home": home,
    "sports": sports,
    "news": news,
    "pets": pets,
}


def make_store(src: Image.Image, size: int = 1024) -> Image.Image:
    base = Image.new("RGBA", (size, size), (0, 0, 0, 255))
    icon = src.convert("RGBA").resize((size, size), Image.Resampling.LANCZOS)
    base.alpha_composite(icon)
    return base.convert("RGB")


def make_foreground(src: Image.Image, size: int = 1024, pad: float = 0.12) -> Image.Image:
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    inner = int(size * (1.0 - 2 * pad))
    icon = src.convert("RGBA").resize((inner, inner), Image.Resampling.LANCZOS)
    offset = (size - inner) // 2
    canvas.paste(icon, (offset, offset), icon)
    return canvas


def rasterize(svg_path: Path, png_path: Path, size: int = SIZE) -> Image.Image:
    import resvg_py  # type: ignore

    png_bytes = resvg_py.svg_to_bytes(svg_path=str(svg_path), width=size, height=size)
    png_path.write_bytes(png_bytes)
    return Image.open(png_path).convert("RGBA")


def apply_to_app(name: str, hd: Image.Image) -> None:
    if name not in APP_TARGETS:
        return
    folder, stem = APP_TARGETS[name]
    app_dir = STUDIO / folder
    if not app_dir.is_dir():
        return
    out = app_dir / "assets" / "branding"
    out.mkdir(parents=True, exist_ok=True)
    store = make_store(hd)
    mono = make_foreground(hd, pad=0.04)
    fg = make_foreground(hd, pad=0.14)
    store.save(out / f"{stem}_monogram_store.png", "PNG")
    mono.save(out / f"{stem}_monogram.png", "PNG")
    fg.save(out / f"{stem}_monogram_foreground.png", "PNG")
    store.save(out / f"{stem}_premium_icon.png", "PNG")
    if name == "garage":
        store.save(out / "super_garage_launcher.png", "PNG")
        store.save(out / "super_garage_launcher_store.png", "PNG")
        fg.save(out / "super_garage_launcher_foreground.png", "PNG")
    print(f"  launchers -> {folder}")


def main() -> None:
    ADS_ICONS.mkdir(parents=True, exist_ok=True)
    GARAGE_ICONS.mkdir(parents=True, exist_ok=True)
    ADS_PRODUCT.mkdir(parents=True, exist_ok=True)

    for name, builder in ICONS.items():
        svg = builder()
        if "data:image" in svg:
            raise RuntimeError(f"{name} embeds raster")
        svg_path = ADS_ICONS / f"super_{name}.svg"
        svg_path.write_text(svg, encoding="utf-8")
        hd_path = ADS_ICONS / f"super_{name}_hd.png"
        hd = rasterize(svg_path, hd_path, SIZE)
        composed = Image.new("RGBA", hd.size, (0, 0, 0, 255))
        composed.alpha_composite(hd)
        composed.convert("RGB").save(hd_path, "PNG", optimize=True)
        try:
            shutil.copy2(svg_path, GARAGE_ICONS / svg_path.name)
            shutil.copy2(hd_path, GARAGE_ICONS / hd_path.name)
        except OSError as exc:
            print(f"  garage mirror skipped ({exc})")
        key = "retail" if name == "supermarket" else ("pet" if name == "pets" else name)
        make_store(composed).save(ADS_PRODUCT / f"{key}.png", "PNG")
        apply_to_app(name, composed)
        print(f"{name}: SVG {svg_path.stat().st_size:,} B")
    print("done B+D hybrid")


if __name__ == "__main__":
    main()
