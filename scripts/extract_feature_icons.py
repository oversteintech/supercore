#!/usr/bin/env python3
"""Move IconData out of domain feature catalogs (sports pattern)."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(r"D:\Projects\HANTURAI")

APPS = [
    ("superhealth", "health_feature.dart", "HealthFeatureIcons", "HealthFeatureId"),
    ("superfinance", "finance_feature.dart", "FinanceFeatureIcons", "FinanceFeatureId"),
    ("superhome", "home_feature.dart", "HomeFeatureIcons", "HomeFeatureId"),
    ("superpet", "pet_feature.dart", "PetFeatureIcons", "PetFeatureId"),
    ("supertravel", "travel_feature.dart", "TravelFeatureIcons", "TravelFeatureId"),
    ("supernews", "news_feature.dart", "NewsFeatureIcons", "NewsFeatureId"),
]


def process(app: str, feature_file: str, icon_class: str, enum_name: str) -> None:
    path = ROOT / app / "lib" / "domain" / "entities" / feature_file
    text = path.read_text(encoding="utf-8")
    if "package:flutter" not in text:
        print(f"[skip] {app} domain clean")
        return

    icon_map: dict[str, str] = {}
    # Match each Feature( ... id: Enum.x, ... icon: Icons.y ...)
    for block in re.finditer(
        r"(\w+)\(\s*id:\s*" + re.escape(enum_name) + r"\.(\w+),[\s\S]*?icon:\s*(Icons\.\w+),?",
        text,
    ):
        icon_map[block.group(2)] = block.group(3)

    if not icon_map:
        raise SystemExit(f"No icons parsed for {app}")

    # Strip flutter import and icon fields
    out = text
    out = re.sub(r"import 'package:flutter/material\.dart';\n+", "", out)
    out = re.sub(
        r"required this\.id,\n    required this\.titleKey,\n    required this\.subtitleKey,\n    required this\.icon,",
        "required this.id,\n    required this.titleKey,\n    required this.subtitleKey,",
        out,
    )
    out = re.sub(r"\n  final IconData icon;\n", "\n", out)
    out = re.sub(r",\n      icon: Icons\.\w+", "", out)
    if "Domain feature catalog" not in out:
        out = (
            "/// Domain feature catalog — no Flutter imports.\n"
            f"/// Icons: `lib/app/navigation/{feature_file.replace('_feature.dart', '_feature_icons.dart')}`.\n"
            + out
        )
    path.write_text(out, encoding="utf-8")

    icon_path = (
        ROOT / app / "lib" / "app" / "navigation" / feature_file.replace("_feature.dart", "_feature_icons.dart")
    )
    lines = [
        "import 'package:flutter/material.dart';",
        "",
        f"import '../../domain/entities/{feature_file}';",
        "",
        f"abstract final class {icon_class} {{",
        f"  static const Map<{enum_name}, IconData> _icons = {{",
    ]
    for k, v in icon_map.items():
        lines.append(f"    {enum_name}.{k}: {v},")
    lines += [
        "  };",
        "",
        f"  static IconData iconFor({enum_name} id) =>",
        "      _icons[id] ?? Icons.circle_outlined;",
        "}",
        "",
    ]
    icon_path.write_text("\n".join(lines), encoding="utf-8")

    # Update feature.icon usages
    for dart in (ROOT / app / "lib").rglob("*.dart"):
        if dart.resolve() in {path.resolve(), icon_path.resolve()}:
            continue
        src = dart.read_text(encoding="utf-8")
        if "feature.icon" not in src:
            continue
        updated = src.replace("feature.icon", f"{icon_class}.iconFor(feature.id)")
        if f"import '{icon_class}" not in updated and icon_class not in updated.split("import")[0]:
            # add import near other navigation imports
            nav_import = None
            depth = len(dart.relative_to(ROOT / app / "lib").parts) - 1
            rel = "/".join([".."] * depth + ["app", "navigation", icon_path.name])
            # Prefer package-relative from features: ../../app/navigation/
            if "app/navigation/" in src:
                # insert next to existing navigation import
                updated2 = re.sub(
                    r"(import '.+/app/navigation/[^']+';\n)",
                    rf"\1import '{rel}';\n",
                    updated,
                    count=1,
                )
                if updated2 == updated:
                    updated = updated.replace(
                        "import 'package:flutter/material.dart';\n",
                        f"import 'package:flutter/material.dart';\nimport '{rel}';\n",
                        1,
                    )
                else:
                    updated = updated2
            else:
                updated = updated.replace(
                    "import 'package:flutter/material.dart';\n",
                    f"import 'package:flutter/material.dart';\nimport '{rel}';\n",
                    1,
                )
        # avoid duplicate imports
        lines_u = updated.splitlines(True)
        seen = set()
        deduped = []
        for line in lines_u:
            if line.startswith("import ") and line in seen:
                continue
            if line.startswith("import "):
                seen.add(line)
            deduped.append(line)
        updated = "".join(deduped)
        dart.write_text(updated, encoding="utf-8")
        print(f"  usage: {dart.relative_to(ROOT / app)}")

    print(f"[ok] {app}: {len(icon_map)} icons -> {icon_path.name}")


def main() -> None:
    for row in APPS:
        process(*row)


if __name__ == "__main__":
    main()
