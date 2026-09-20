#!/usr/bin/env python3
"""Build Full HD Super App icons from the approved black metallic board.

Writes:
  - after_design_system/assets/branding/super_app_icons/super_*.svg (+ _hd.png)
  - after_design_system/assets/product_icons/<key>.png (1024 masters)
  - Each existing Super App's monogram / store / foreground launcher PNGs
  - Garage local mirror under assets/branding/super_app_icons/

Icons are fed from SuperCore (after_design_system). Sibling apps get launcher
PNGs generated from the same masters so flutter_launcher_icons can run.
"""

from __future__ import annotations

import base64
import shutil
from io import BytesIO
from pathlib import Path
import xml.etree.ElementTree as ET

from PIL import Image, ImageDraw, ImageFilter

STUDIO = Path(r"C:/Users/ayhan/StudioProjects")
GARAGE = STUDIO / "supergarage"
ADS = STUDIO / "supercore/packages/after_design_system"
ADS_ICONS = ADS / "assets/branding/super_app_icons"
ADS_PRODUCT = ADS / "assets/product_icons"
CONCEPTS = ADS / "assets/branding/super_app_concepts"
GARAGE_ICONS = GARAGE / "assets/branding/super_app_icons"
GARAGE_CONCEPTS = GARAGE / "assets/branding/super_app_concepts"

SOURCE_CURSOR = Path(
    r"C:/Users/ayhan/.cursor/projects/c-Users-ayhan-StudioProjects-supergarage/assets/"
    r"c__Users_ayhan_AppData_Roaming_Cursor_User_workspaceStorage_72a631f43a4be8c565c349565700b406_"
    r"images_theme-a-reduced-black-99e804c1-833a-43f5-bcbe-4899ff0d4b6f.jpg"
)

# Board order (2×4): Garage Finance Market Health / Home Sports News Pets
NAMES = [
    "garage",
    "finance",
    "supermarket",
    "health",
    "home",
    "sports",
    "news",
    "pets",
]

# icon key -> (app folder, asset stem) for apps that exist today
APP_TARGETS = {
    "garage": ("supergarage", "super_garage"),
    "finance": ("superfinance", "super_finance"),
    "health": ("superhealth", "super_health"),
    "home": ("superhome", "super_home"),
    "sports": ("supersports", "super_sports"),
    "news": ("supernews", "super_news"),
    "pets": ("superpet", "super_pet"),
}

EXPORT_SIZE = 1920
STORE_SIZE = 1024


def luminance(rgb: tuple[int, int, int]) -> float:
    r, g, b = rgb
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def detect_icon_boxes(im: Image.Image) -> list[tuple[int, int, int, int]]:
    """Find eight metallic icon frames on a near-black board."""
    gray = im.convert("L")
    # Metallic frames are bright; labels are thin white text — ignore small blobs.
    mask = gray.point(lambda p: 255 if p > 35 else 0)
    # Slight blur then re-threshold to connect frame edges.
    mask = mask.filter(ImageFilter.MaxFilter(3))
    w, h = mask.size
    pix = mask.load()
    visited = [[False] * w for _ in range(h)]
    boxes: list[tuple[int, int, int, int]] = []

    def flood(sx: int, sy: int) -> tuple[int, int, int, int] | None:
        stack = [(sx, sy)]
        visited[sy][sx] = True
        min_x = max_x = sx
        min_y = max_y = sy
        count = 0
        while stack:
            x, y = stack.pop()
            count += 1
            if x < min_x:
                min_x = x
            if x > max_x:
                max_x = x
            if y < min_y:
                min_y = y
            if y > max_y:
                max_y = y
            for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if 0 <= nx < w and 0 <= ny < h and not visited[ny][nx]:
                    if pix[nx, ny] > 128:
                        visited[ny][nx] = True
                        stack.append((nx, ny))
                    else:
                        visited[ny][nx] = True
        bw = max_x - min_x + 1
        bh = max_y - min_y + 1
        # Icons are large rounded squares; labels are wide/short.
        if bw < w * 0.12 or bh < h * 0.12:
            return None
        if bw / bh < 0.75 or bw / bh > 1.35:
            return None
        if count < (bw * bh) * 0.04:
            return None
        # Shrink a few px so label dashes below are excluded if attached.
        pad = max(2, bw // 40)
        return (
            max(0, min_x + pad),
            max(0, min_y + pad),
            min(w, max_x - pad + 1),
            min(h, max_y - pad + 1),
        )

    for y in range(0, h, 2):
        for x in range(0, w, 2):
            if visited[y][x] or pix[x, y] <= 128:
                continue
            box = flood(x, y)
            if box is not None:
                boxes.append(box)

    # Prefer the largest 8 square-ish regions, sorted reading order.
    boxes.sort(key=lambda b: (b[2] - b[0]) * (b[3] - b[1]), reverse=True)
    boxes = boxes[:8]
    if len(boxes) < 8:
        raise RuntimeError(f"Detected only {len(boxes)} icon frames; need 8")
    boxes.sort(key=lambda b: (b[1] // 40, b[0]))
    return boxes


def fallback_grid(im: Image.Image) -> list[tuple[int, int, int, int]]:
    """Even 2×4 grid crop if detection fails (tuned for 1024×682 board)."""
    w, h = im.size
    # Empirically: icons sit above labels; use upper portion of each cell.
    cols, rows = 4, 2
    boxes = []
    for r in range(rows):
        for c in range(cols):
            # Margins leave out labels under each icon.
            x0 = int(w * (0.02 + c * 0.245))
            x1 = int(w * (0.02 + c * 0.245 + 0.22))
            y0 = int(h * (0.04 + r * 0.48))
            y1 = int(h * (0.04 + r * 0.48 + 0.38))
            side = min(x1 - x0, y1 - y0)
            cx = (x0 + x1) // 2
            cy = (y0 + y1) // 2
            half = side // 2
            boxes.append((cx - half, cy - half, cx + half, cy + half))
    return boxes


def square_crop(im: Image.Image, box: tuple[int, int, int, int]) -> Image.Image:
    x0, y0, x1, y1 = box
    # Trim bottom ~8% in case a label dash leaked into the bbox.
    h = y1 - y0
    y1 = y0 + int(h * 0.92)
    crop = im.crop((x0, y0, x1, y1))
    side = min(crop.size)
    # Center square
    left = (crop.width - side) // 2
    top = (crop.height - side) // 2
    return crop.crop((left, top, left + side, top + side))


def write_photo_svg(hd: Image.Image, svg_path: Path, title: str) -> None:
    buffer = BytesIO()
    hd.save(buffer, format="PNG", optimize=True)
    encoded = base64.b64encode(buffer.getvalue()).decode("ascii")
    markup = (
        '<svg xmlns="http://www.w3.org/2000/svg" '
        f'width="{EXPORT_SIZE}" height="{EXPORT_SIZE}" '
        f'viewBox="0 0 {EXPORT_SIZE} {EXPORT_SIZE}" role="img">\n'
        f"  <title>{title}</title>\n"
        "  <desc>Full HD Super App icon from the approved metallic black board. "
        "Served from after_design_system (SuperCore).</desc>\n"
        f'  <image x="0" y="0" width="{EXPORT_SIZE}" height="{EXPORT_SIZE}" '
        f'href="data:image/png;base64,{encoded}"/>\n'
        "</svg>\n"
    )
    svg_path.write_text(markup, encoding="utf-8")
    ET.parse(svg_path)


def make_store(src: Image.Image, size: int = STORE_SIZE) -> Image.Image:
    base = Image.new("RGBA", (size, size), (0, 0, 0, 255))
    icon = src.convert("RGBA").resize((size, size), Image.Resampling.LANCZOS)
    base.alpha_composite(icon)
    return base.convert("RGB")


def make_foreground(src: Image.Image, size: int = STORE_SIZE, pad: float = 0.12) -> Image.Image:
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    inner = int(size * (1.0 - 2 * pad))
    icon = src.convert("RGBA").resize((inner, inner), Image.Resampling.LANCZOS)
    # Keep the black icon plate; only punch near-black outside the rounded plate
    # is unnecessary because the artwork already includes its frame.
    offset = (size - inner) // 2
    canvas.paste(icon, (offset, offset), icon)
    return canvas


def apply_to_app(name: str, hd: Image.Image) -> None:
    if name not in APP_TARGETS:
        return
    folder, stem = APP_TARGETS[name]
    app_dir = STUDIO / folder
    if not app_dir.is_dir():
        print(f"skip missing app {folder}")
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
    # Garage also keeps classic launcher alias.
    if name == "garage":
        store.save(out / "super_garage_launcher.png", "PNG")
        store.save(out / "super_garage_launcher_store.png", "PNG")
        fg.save(out / "super_garage_launcher_foreground.png", "PNG")
    print(f"  applied launcher assets -> {folder}")


def main() -> None:
    if not SOURCE_CURSOR.exists():
        raise FileNotFoundError(SOURCE_CURSOR)

    CONCEPTS.mkdir(parents=True, exist_ok=True)
    ADS_ICONS.mkdir(parents=True, exist_ok=True)
    ADS_PRODUCT.mkdir(parents=True, exist_ok=True)
    GARAGE_ICONS.mkdir(parents=True, exist_ok=True)
    GARAGE_CONCEPTS.mkdir(parents=True, exist_ok=True)

    board_name = "theme-a-metallic-black.png"
    source_path = CONCEPTS / board_name
    im = Image.open(SOURCE_CURSOR).convert("RGB")
    im.save(source_path, "PNG")
    shutil.copy2(source_path, GARAGE_CONCEPTS / board_name)
    print(f"source {im.size} -> {source_path}")

    try:
        boxes = detect_icon_boxes(im)
        print(f"detected {len(boxes)} frames via luminance flood")
    except Exception as exc:  # noqa: BLE001
        print(f"detection fallback ({exc})")
        boxes = fallback_grid(im)

    # Debug preview of crops
    preview = im.copy()
    draw = ImageDraw.Draw(preview)
    for box in boxes:
        draw.rectangle(box, outline=(255, 0, 0), width=2)
    preview_path = CONCEPTS / "theme-a-metallic-black-crops.png"
    preview.save(preview_path)
    print(f"crop preview -> {preview_path}")

    for name, box in zip(NAMES, boxes, strict=True):
        crop = square_crop(im, box)
        hd = crop.resize((EXPORT_SIZE, EXPORT_SIZE), Image.Resampling.LANCZOS)
        title = "Super Supermarket icon" if name == "supermarket" else f"Super {name.title()} icon"

        hd_png = ADS_ICONS / f"super_{name}_hd.png"
        hd.save(hd_png, "PNG", optimize=True)
        svg_path = ADS_ICONS / f"super_{name}.svg"
        write_photo_svg(hd, svg_path, title)

        # Mirror into Garage for local tooling / docs.
        shutil.copy2(hd_png, GARAGE_ICONS / hd_png.name)
        shutil.copy2(svg_path, GARAGE_ICONS / svg_path.name)

        # 1024 product master in SuperCore product_icons
        key = "retail" if name == "supermarket" else ("pet" if name == "pets" else name)
        make_store(hd).save(ADS_PRODUCT / f"{key}.png", "PNG")

        apply_to_app(name, hd)
        print(f"{name}: SVG {svg_path.stat().st_size:,} B, PNG {hd_png.stat().st_size:,} B")

    print("done")


if __name__ == "__main__":
    main()
