#!/usr/bin/env python3
from pathlib import Path
import re

p = Path(
    r"D:/Projects/HANTURAI/supercore/packages/after_consumer/"
    r"lib/src/family/family_settings_screen.dart"
)
t = p.read_text(encoding="utf-8")

# Fix multiline mangled s('key',\n locale: locale,\n)
t = re.sub(
    r"s\('([^']+)'\s*,\s*\n\s*locale:\s*locale\s*,?\s*\n\s*\)",
    r"s('\1')",
    t,
)
t = re.sub(
    r"s\('([^']+)'\s*,\s*args:\s*(\{[^}]*\})\s*,\s*\n\s*locale:\s*locale\s*,?\s*\n\s*\)",
    r"s('\1', args: \2)",
    t,
)
# single-line leftovers
t = re.sub(
    r"s\('([^']+)'\s*,\s*locale:\s*locale\s*,?\s*\)",
    r"s('\1')",
    t,
)

p.write_text(t, encoding="utf-8")
print("cleaned s() calls")
# show any remaining locale inside s(
for i, line in enumerate(t.splitlines(), 1):
    if "s('" in line and "locale:" in line:
        print(i, line.strip())
