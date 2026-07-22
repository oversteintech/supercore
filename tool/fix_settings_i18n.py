#!/usr/bin/env python3
from pathlib import Path
import re

p = Path(
    r"D:/Projects/HANTURAI/supercore/packages/after_consumer/"
    r"lib/src/family/family_settings_screen.dart"
)
t = p.read_text(encoding="utf-8")

t = re.sub(
    r"s\('([^']+)'\s*,\s*locale:\s*locale\s*,?\s*\)",
    r"s('\1')",
    t,
)
t = re.sub(
    r"s\('([^']+)'\s*,\s*args:\s*(\{[^}]*\})\s*,\s*locale:\s*locale\s*,?\s*\)",
    r"s('\1', args: \2)",
    t,
)

subs = {
    "subtitle: 'Backup and restore across devices'": "subtitle: s('cloud_sync_sub')",
    "subtitle: 'Permissions, policy and data export'": "subtitle: s('privacy_sub')",
    "subtitle: 'Password, rights and account protection'": "subtitle: s('security_sub')",
    "subtitle: 'Founders, pioneers and launch perks'": "subtitle: s('early_user_sub')",
    "subtitle: 'Common questions and support'": "subtitle: s('help_faq_sub')",
    "subtitle: 'Replay the product walkthrough'": "subtitle: s('app_tour_sub')",
    "subtitle: 'Version, support and Overstein Labs'": "subtitle: s('about_sub')",
}
for a, b in subs.items():
    t = t.replace(a, b)

old = """                  const Expanded(
                    child: Text(
                      'Your account and on-device data are protected. '
                      'Sign-in tokens never leave secure storage.',
                      style: TextStyle(height: 1.35),
                    ),
                  ),"""
new = """                  Expanded(
                    child: Text(
                      s('security_body'),
                      style: const TextStyle(height: 1.35),
                    ),
                  ),"""
t = t.replace(old, new)


def fix_info(m: re.Match[str]) -> str:
    block = m.group(0)
    # remove duplicate locale lines
    lines = block.splitlines()
    out: list[str] = []
    seen = False
    for ln in lines:
        if "locale:" in ln:
            if seen:
                continue
            seen = True
        out.append(ln)
    block = "\n".join(out)
    if "locale:" not in block:
        block = block.rstrip()[:-1] + ",\n                  locale: locale,\n                )"
    return block


t = re.sub(r"_info\(\s*context,[^;]+?\)", fix_info, t, flags=re.S)

p.write_text(t, encoding="utf-8")
print("fixed")

# Inject extra keys into FamilyUiStrings maps
ui = Path(
    r"D:/Projects/HANTURAI/supercore/packages/after_consumer/"
    r"lib/src/family/family_ui_strings.dart"
)
u = ui.read_text(encoding="utf-8")
extra_en = {
    "subscription_sub": "Plan, billing and membership badge",
    "cloud_sync_sub": "Backup and restore across devices",
    "privacy_sub": "Permissions, policy and data export",
    "security_sub": "Password, rights and account protection",
    "early_user_sub": "Founders, pioneers and launch perks",
    "help_faq_sub": "Common questions and support",
    "app_tour_sub": "Replay the product walkthrough",
    "about_sub": "Version, support and Overstein Labs",
}
extra_tr = {
    "subscription_sub": "Plan, faturalama ve üyelik rozeti",
    "cloud_sync_sub": "Cihazlar arası yedekleme ve geri yükleme",
    "privacy_sub": "İzinler, politika ve veri dışa aktarma",
    "security_sub": "Şifre, haklar ve hesap koruması",
    "early_user_sub": "Kurucular, öncüler ve lansman ayrıcalıkları",
    "help_faq_sub": "Sık sorulanlar ve destek",
    "app_tour_sub": "Ürün turunu yeniden oynat",
    "about_sub": "Sürüm, destek ve Overstein Labs",
}


def inject(map_name: str, extras: dict[str, str], src: str) -> str:
    marker = f"const {map_name} = <String, String>{{"
    if marker not in src:
        raise SystemExit(f"missing {map_name}")
    # insert before closing of that map: find first }; after marker
    i = src.index(marker)
    j = src.index("};", i)
    chunk = src[i:j]
    for k, v in extras.items():
        if f"'{k}':" in chunk:
            continue
        esc = v.replace("\\", "\\\\").replace("'", "\\'")
        chunk += f"\n  '{k}': '{esc}',"
    return src[:i] + chunk + src[j:]


u = inject("_en", extra_en, u)
u = inject("_tr", extra_tr, u)
codes = [
    "zh",
    "hi",
    "es",
    "fr",
    "ar",
    "bn",
    "pt",
    "ru",
    "ur",
    "id",
    "de",
    "ja",
    "sw",
    "mr",
    "te",
    "ta",
    "vi",
    "ko",
]
for code in codes:
    if code in ("de", "es", "fr"):
        extras_map = {
            "de": {
                "subscription_sub": "Plan, Abrechnung und Mitgliedschaft",
                "cloud_sync_sub": "Backup und Wiederherstellung geräteübergreifend",
                "privacy_sub": "Berechtigungen, Richtlinie und Export",
                "security_sub": "Passwort, Rechte und Kontoschutz",
                "early_user_sub": "Gründer, Pioniere und Launch-Vorteile",
                "help_faq_sub": "Häufige Fragen und Support",
                "app_tour_sub": "Produkt-Tour erneut abspielen",
                "about_sub": "Version, Support und Overstein Labs",
            },
            "es": {
                "subscription_sub": "Plan, facturación e insignia",
                "cloud_sync_sub": "Copia de seguridad entre dispositivos",
                "privacy_sub": "Permisos, política y exportación",
                "security_sub": "Contraseña, derechos y protección",
                "early_user_sub": "Fundadores, pioneros y lanzamiento",
                "help_faq_sub": "Preguntas frecuentes y soporte",
                "app_tour_sub": "Repetir el recorrido del producto",
                "about_sub": "Versión, soporte y Overstein Labs",
            },
            "fr": {
                "subscription_sub": "Offre, facturation et badge",
                "cloud_sync_sub": "Sauvegarde et restauration multi-appareils",
                "privacy_sub": "Autorisations, politique et export",
                "security_sub": "Mot de passe, droits et protection",
                "early_user_sub": "Fondateurs, pionniers et lancement",
                "help_faq_sub": "FAQ et support",
                "app_tour_sub": "Rejouer la visite produit",
                "about_sub": "Version, support et Overstein Labs",
            },
        }[code]
    else:
        extras_map = {k: f"[{code}] {v}" for k, v in extra_en.items()}
    u = inject(f"_{code}", extras_map, u)

ui.write_text(u, encoding="utf-8")
print("ui keys injected")
