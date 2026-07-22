from pathlib import Path

ROOT = Path(r"D:/Projects/HANTURAI")
OLD = "final catalog = await StringCatalog.load();"

for app in ["superairport", "superfactory", "supermaritime"]:
    path = ROOT / app / "lib" / "app" / "bootstrap" / "cold_start_app.dart"
    text = path.read_text(encoding="utf-8")
    if "AfterLocalePrefs" in text:
        print("skip", app)
        continue
    if OLD not in text:
        print("missing", app)
        continue
    new = f"""final catalog = await StringCatalog.load();
    final savedLocale = AfterLocalePrefs.read(
      prefs,
      legacyKey: '{app}.locale',
    );
    if (savedLocale != null) {{
      catalog.setLocale(savedLocale);
    }}"""
    text = text.replace(OLD, new, 1)
    if "package:after_core/after_core.dart" not in text:
        text = "import 'package:after_core/after_core.dart';\n" + text
    path.write_text(text, encoding="utf-8")
    print("patched", app)
