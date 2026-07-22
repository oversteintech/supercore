#!/usr/bin/env python3
"""Switch bottom-nav AI tab icons from auto_awesome → hub (Garage AI mark)."""
from __future__ import annotations

from pathlib import Path

HANTURAI = Path(r"D:\Projects\HANTURAI")

# Skip CI checkout trees
SKIP_PARTS = {"supergarage-ci-29693951454", "supergarage-ci-d15c40267"}


def patch_text(text: str) -> str:
    text = text.replace(
        "icon: Icons.auto_awesome_outlined,\n            selectedIcon: Icons.auto_awesome,",
        "icon: Icons.hub_outlined,\n            selectedIcon: Icons.hub_rounded,",
    )
    text = text.replace(
        "icon: Icons.auto_awesome_outlined,\n            selectedIcon: Icons.auto_awesome_rounded,",
        "icon: Icons.hub_outlined,\n            selectedIcon: Icons.hub_rounded,",
    )
    text = text.replace(
        "icon: const Icon(Icons.auto_awesome_outlined),\n"
        "                                  selectedIcon: const Icon(\n"
        "                                    Icons.auto_awesome_rounded,",
        "icon: const Icon(Icons.hub_outlined),\n"
        "                                  selectedIcon: const Icon(\n"
        "                                    Icons.hub_rounded,",
    )
    # enterprise / compact
    text = text.replace(
        "Icons.auto_awesome_outlined",
        "Icons.hub_outlined",
    )
    # Only replace remaining auto_awesome / auto_awesome_rounded if they are selectedIcon companions
    text = text.replace(
        "selectedIcon: Icons.auto_awesome,",
        "selectedIcon: Icons.hub_rounded,",
    )
    text = text.replace(
        "selectedIcon: Icons.auto_awesome_rounded,",
        "selectedIcon: Icons.hub_rounded,",
    )
    text = text.replace(
        "Icons.auto_awesome_rounded,",
        "Icons.hub_rounded,",
    )
    text = text.replace(
        "Icons.auto_awesome,",
        "Icons.hub_rounded,",
    )
    return text


def main() -> None:
    paths = list(HANTURAI.glob("*/lib/features/shell/main_shell.dart"))
    paths += list(
        HANTURAI.glob(
            "supercore/packages/after_enterprise/lib/src/shell/enterprise_product_shell.dart"
        )
    )
    for path in paths:
        if any(p in path.parts for p in SKIP_PARTS):
            continue
        text = path.read_text(encoding="utf-8")
        if "auto_awesome" not in text and "hub_outlined" in text:
            print(f"OK {path.relative_to(HANTURAI)}")
            continue
        if "auto_awesome" not in text:
            print(f"SKIP {path.relative_to(HANTURAI)}")
            continue
        new = patch_text(text)
        if new != text:
            path.write_text(new, encoding="utf-8")
            print(f"FIXED {path.relative_to(HANTURAI)}")
        else:
            print(f"NOCHANGE {path.relative_to(HANTURAI)}")


if __name__ == "__main__":
    main()
