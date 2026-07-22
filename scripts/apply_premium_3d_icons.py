#!/usr/bin/env python3
"""Apply generated letter-free premium 3D icons to ALL Super Apps including Garage.

Source icons: Cursor assets/icon_<key>.png
Outputs per app:
  assets/branding/<stem>_monogram.png
  assets/branding/<stem>_monogram_foreground.png
  assets/branding/<stem>_monogram_store.png
  assets/branding/<stem>_premium_icon.png
Also copies masters into after_design_system/assets/product_icons/
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image

HANTURAI = Path(r"D:/Projects/HANTURAI")
SRC_DIR = Path(
    r"C:/Users/a00929216/.cursor/projects/d-Projects-HANTURAI-overstein-web/assets"
)
ADS_OUT = HANTURAI / "supercore/packages/after_design_system/assets/product_icons"

# icon key -> (folder, asset stem)
APPS = {
    "garage": ("supergarage", "super_garage"),
    "hub": ("afterhub", "after_hub"),
    "health": ("superhealth", "super_health"),
    "finance": ("superfinance", "super_finance"),
    "home": ("superhome", "super_home"),
    "travel": ("supertravel", "super_travel"),
    "pet": ("superpet", "super_pet"),
    "news": ("supernews", "super_news"),
    "sports": ("supersports", "super_sports"),
    "games": ("supergames", "super_games"),
    "family": ("superfamily", "super_family"),
    "documents": ("superdocuments", "super_documents"),
    "learning": ("superlearning", "super_learning"),
    "hospital": ("superhospital", "super_hospital"),
    "airport": ("superairport", "super_airport"),
    "maritime": ("supermaritime", "super_maritime"),
    "factory": ("superfactory", "super_factory"),
    "logistics": ("superlogistics", "super_logistics"),
    "construction": ("superconstruction", "super_construction"),
    "school": ("superschool", "super_school"),
    "hotel": ("superhotel", "super_hotel"),
    "restaurant": ("superrestaurant", "super_restaurant"),
    "retail": ("superretail", "super_retail"),
    "energy": ("superenergy", "super_energy"),
    "municipality": ("supermunicipality", "super_municipality"),
    "farm": ("superfarm", "super_farm"),
    "agriculture": ("superagriculture", "super_agriculture"),
    "police": ("superpolice", "super_police"),
    "fire": ("superfire", "super_fire"),
    "mining": ("supermining", "super_mining"),
}


def to_rgba(img: Image.Image) -> Image.Image:
    if img.mode != "RGBA":
        return img.convert("RGBA")
    return img


def make_store(src: Image.Image, size: int = 1024) -> Image.Image:
    base = Image.new("RGBA", (size, size), (0, 0, 0, 255))
    icon = to_rgba(src).resize((size, size), Image.Resampling.LANCZOS)
    base.alpha_composite(icon)
    return base.convert("RGB")


def make_foreground(src: Image.Image, size: int = 1024, pad: float = 0.18) -> Image.Image:
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    inner = int(size * (1.0 - 2 * pad))
    icon = to_rgba(src).resize((inner, inner), Image.Resampling.LANCZOS)
    pixels = icon.load()
    for y in range(inner):
        for x in range(inner):
            r, g, b, a = pixels[x, y]
            if r < 28 and g < 28 and b < 28:
                pixels[x, y] = (r, g, b, 0)
    offset = (size - inner) // 2
    canvas.paste(icon, (offset, offset), icon)
    return canvas


def make_monogram(src: Image.Image, size: int = 1024) -> Image.Image:
    return make_foreground(src, size=size, pad=0.06)


def apply_one(key: str, folder: str, stem: str) -> None:
    src_path = SRC_DIR / f"icon_{key}.png"
    if not src_path.exists():
        print(f"MISSING source icon_{key}.png")
        return
    app_dir = HANTURAI / folder
    if not app_dir.is_dir():
        print(f"skip missing app {folder}")
        return
    out = app_dir / "assets" / "branding"
    out.mkdir(parents=True, exist_ok=True)
    src = Image.open(src_path)

    store = make_store(src)
    mono = make_monogram(src)
    fg = make_foreground(src)

    store.save(out / f"{stem}_monogram_store.png", "PNG")
    mono.save(out / f"{stem}_monogram.png", "PNG")
    fg.save(out / f"{stem}_monogram_foreground.png", "PNG")
    store.save(out / f"{stem}_premium_icon.png", "PNG")

    ADS_OUT.mkdir(parents=True, exist_ok=True)
    store.save(ADS_OUT / f"{key}.png", "PNG")
    print(f"ok {folder}")


def main() -> None:
    for key, (folder, stem) in APPS.items():
        apply_one(key, folder, stem)
    print("done — all apps including Garage")


if __name__ == "__main__":
    main()
