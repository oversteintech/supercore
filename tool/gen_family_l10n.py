#!/usr/bin/env python3
"""Generate FamilyUiStrings + fill sibling assets/l10n/{code}.json (≥20 locales)."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(r"D:/Projects/HANTURAI")
CORE = ROOT / "supercore" / "packages" / "after_consumer" / "lib" / "src" / "family"

EN = {
    "settings": "Settings",
    "profile": "Profile",
    "profile_sub": "Account, photo and personal details",
    "emergency": "Emergency profile",
    "emergency_sub": "Blood type, contacts and medical notes for ICE",
    "language": "Language",
    "language_sub": "App language for labels and AI replies",
    "theme": "Theme",
    "theme_sub": "Light, dark and premium packs",
    "system": "System",
    "system_sub": "Follow device setting",
    "light": "Light",
    "light_sub": "Bright surfaces",
    "dark": "Dark",
    "dark_sub": "Dim surfaces",
    "premium_themes": "Premium themes",
    "app_icon": "App icon",
    "app_icon_sub": "Black or white launcher background",
    "app_icon_choose": "Choose the launcher icon background",
    "app_icon_black": "Black",
    "app_icon_white": "White",
    "app_icon_black_hint": "Black background — best on light home screens.",
    "app_icon_white_hint": "White background — best on dark home screens.",
    "app_icon_pref_black": "App icon preference: black background",
    "app_icon_pref_white": "App icon preference: white background",
    "subscription": "Subscription",
    "current_plan": "Current plan",
    "manage_subscription": "Manage subscription",
    "plans_hint": "Free · Silver · Gold · Business",
    "cloud_sync": "Cloud sync",
    "sync_now": "Sync now",
    "syncing": "Syncing…",
    "sync_error": "Sync error",
    "not_synced": "Not synced yet",
    "last_sync_ok": "Last sync OK",
    "privacy": "Privacy",
    "permissions": "Permissions",
    "permissions_sub": (
        "Location, notifications, and camera are requested only when needed."
    ),
    "permissions_body": (
        "This Super App asks for sensitive permissions only when you use a "
        "feature that needs them. You can revoke access in system settings anytime."
    ),
    "privacy_policy": "Privacy policy",
    "privacy_policy_body": (
        "Your data stays under your control. Cloud sync and sharing run only "
        "when you enable those features."
    ),
    "terms": "Terms of use",
    "terms_body": (
        "By using {app} you agree to Overstein Labs terms for "
        "AfterArtificial Super Apps."
    ),
    "export_data": "Export data",
    "export_sub": "Download a local copy of your data",
    "export_soon": "Export will be available with cloud sync",
    "security": "Security",
    "security_body": (
        "Your account and on-device data are protected. Sign-in tokens never "
        "leave secure storage."
    ),
    "change_password": "Change password",
    "change_password_sub": "Managed by your sign-in provider",
    "change_password_body": (
        "Password changes are handled by your Google / email provider. Use the "
        "provider account settings to update credentials."
    ),
    "your_rights": "Your rights",
    "your_rights_body": (
        "You can export, correct, or delete your data. Email {email} for "
        "KVKK/GDPR requests."
    ),
    "early_user": "Early user program",
    "early_access": "Early access",
    "early_access_admin": (
        "Admin: manage early-user tiers from the backend console."
    ),
    "early_access_user": (
        "Founders and pioneers get beta features and launch perks."
    ),
    "join_inquire": "Join / inquire",
    "early_user_body": (
        "Write to {email} with your account email to join the early user "
        "program for {app}."
    ),
    "help_faq": "Help / FAQ",
    "contact_support": "Contact support",
    "app_tour": "App tour",
    "replay_tour": "Replay app tour",
    "replay_tour_sub": "Quick walkthrough of the main tabs",
    "about": "About",
    "version": "Version {version}",
    "built_by": "Built by Overstein Labs · AfterArtificial Super Apps",
    "sign_out": "Sign out",
    "sign_out_q": "Sign out?",
    "sign_out_body": "You can sign back in anytime.",
    "cancel": "Cancel",
    "delete_account": "Delete account",
    "delete_q": "Delete account?",
    "delete_body": "This permanently deletes your account on this device.",
    "delete": "Delete",
    "ok": "OK",
    "royal_soon": "Royal theme — coming soon",
    "upgrade_themes": "Upgrade to unlock premium themes",
    "nav_home": "Home",
    "nav_live": "Live",
    "nav_ai": "AI",
    "nav_features": "Features",
    "nav_settings": "Settings",
    "faq1_q": "What plans are available?",
    "faq1_a": (
        "Free, Silver, Gold, and Business. Manage them under Subscription."
    ),
    "faq2_q": "How does cloud sync work?",
    "faq2_a": (
        "Cloud sync uploads your data when you tap Sync now and you are "
        "signed in."
    ),
    "faq3_q": "How do I change the app icon?",
    "faq3_a": (
        "Open Settings → App icon and choose black or white background."
    ),
    "faq4_q": "How do I contact support?",
    "faq4_a": (
        "Use Help / FAQ or email the support address shown in About for {app}."
    ),
    "tour_welcome_title": "Welcome to {app}",
    "tour_welcome_body": (
        "Your AfterArtificial Super App — same family chrome as Garage."
    ),
    "tour_home_title": "Home & Live",
    "tour_home_body": (
        "Track your day from Home and watch live signals on Live."
    ),
    "tour_ai_title": "AI assistant",
    "tour_ai_body": (
        "Ask the AI tab for help, or tap the sparkle in the top bar."
    ),
    "tour_settings_title": "Settings",
    "tour_settings_body": (
        "Profile, subscription, privacy, security, and more live on the "
        "Settings tab."
    ),
    "tour_next": "Next",
    "tour_done": "Done",
    "support": "Support",
}

LOCALES: dict[str, dict[str, str]] = {
    "en": EN,
    "tr": {
        "settings": "Ayarlar",
        "profile": "Profil",
        "profile_sub": "Hesap, fotoğraf ve kişisel bilgiler",
        "emergency": "Acil profil",
        "emergency_sub": "Kan grubu, kişiler ve ICE tıbbi notları",
        "language": "Dil",
        "language_sub": "Etiketler ve AI yanıtları için uygulama dili",
        "theme": "Tema",
        "theme_sub": "Açık, koyu ve premium paketler",
        "system": "Sistem",
        "system_sub": "Cihaz ayarını izle",
        "light": "Açık",
        "light_sub": "Parlak yüzeyler",
        "dark": "Koyu",
        "dark_sub": "Loş yüzeyler",
        "premium_themes": "Premium temalar",
        "app_icon": "Uygulama simgesi",
        "app_icon_sub": "Siyah veya beyaz başlatıcı arka planı",
        "app_icon_choose": "Başlatıcı simgesi arka planını seçin",
        "app_icon_black": "Siyah",
        "app_icon_white": "Beyaz",
        "app_icon_black_hint": "Siyah arka plan — açık ana ekranlarda en iyi.",
        "app_icon_white_hint": "Beyaz arka plan — koyu ana ekranlarda en iyi.",
        "app_icon_pref_black": "Simge tercihi: siyah arka plan",
        "app_icon_pref_white": "Simge tercihi: beyaz arka plan",
        "subscription": "Abonelik",
        "current_plan": "Mevcut plan",
        "manage_subscription": "Aboneliği yönet",
        "plans_hint": "Ücretsiz · Gümüş · Altın · İş",
        "cloud_sync": "Bulut senkronu",
        "sync_now": "Şimdi senkronize et",
        "syncing": "Senkronize ediliyor…",
        "sync_error": "Senkron hatası",
        "not_synced": "Henüz senkronize edilmedi",
        "last_sync_ok": "Son senkron tamam",
        "privacy": "Gizlilik",
        "permissions": "İzinler",
        "permissions_sub": (
            "Konum, bildirimler ve kamera yalnızca gerektiğinde istenir."
        ),
        "permissions_body": (
            "Bu Super App hassas izinleri yalnızca ilgili özelliği "
            "kullandığınızda ister. Sistem ayarlarından istediğiniz zaman "
            "iptal edebilirsiniz."
        ),
        "privacy_policy": "Gizlilik politikası",
        "privacy_policy_body": (
            "Verileriniz kontrolünüzdedir. Bulut senkronu ve paylaşım yalnızca "
            "siz açtığınızda çalışır."
        ),
        "terms": "Kullanım koşulları",
        "terms_body": (
            "{app} kullanarak AfterArtificial Super Apps için Overstein Labs "
            "koşullarını kabul edersiniz."
        ),
        "export_data": "Veriyi dışa aktar",
        "export_sub": "Verilerinizin yerel bir kopyasını indirin",
        "export_soon": "Dışa aktarma bulut senkronu ile gelecek",
        "security": "Güvenlik",
        "security_body": (
            "Hesabınız ve cihazdaki verileriniz korunur. Oturum açma "
            "belirteçleri güvenli depolamadan çıkmaz."
        ),
        "change_password": "Şifreyi değiştir",
        "change_password_sub": "Giriş sağlayıcınız tarafından yönetilir",
        "change_password_body": (
            "Şifre değişiklikleri Google / e-posta sağlayıcınız üzerinden "
            "yapılır. Kimlik bilgilerini güncellemek için sağlayıcı hesap "
            "ayarlarını kullanın."
        ),
        "your_rights": "Haklarınız",
        "your_rights_body": (
            "Verilerinizi dışa aktarabilir, düzeltebilir veya silebilirsiniz. "
            "KVKK/GDPR için {email} adresine yazın."
        ),
        "early_user": "Erken kullanıcı programı",
        "early_access": "Erken erişim",
        "early_access_admin": (
            "Yönetici: erken kullanıcı katmanlarını arka uç konsolundan yönetin."
        ),
        "early_access_user": (
            "Kurucular ve öncüler beta özellikler ve lansman ayrıcalıkları alır."
        ),
        "join_inquire": "Katıl / sor",
        "early_user_body": (
            "{app} erken kullanıcı programına katılmak için hesap e-postanızla "
            "{email} adresine yazın."
        ),
        "help_faq": "Yardım / SSS",
        "contact_support": "Destekle iletişim",
        "app_tour": "Uygulama turu",
        "replay_tour": "Uygulama turunu yeniden oynat",
        "replay_tour_sub": "Ana sekmelerin kısa özeti",
        "about": "Hakkında",
        "version": "Sürüm {version}",
        "built_by": "Overstein Labs · AfterArtificial Super Apps",
        "sign_out": "Çıkış yap",
        "sign_out_q": "Çıkış yapılsın mı?",
        "sign_out_body": "İstediğiniz zaman tekrar giriş yapabilirsiniz.",
        "cancel": "İptal",
        "delete_account": "Hesabı sil",
        "delete_q": "Hesap silinsin mi?",
        "delete_body": "Bu, bu cihazdaki hesabınızı kalıcı olarak siler.",
        "delete": "Sil",
        "ok": "Tamam",
        "royal_soon": "Royal tema — yakında",
        "upgrade_themes": "Premium temaları açmak için yükseltin",
        "nav_home": "Ana sayfa",
        "nav_live": "Canlı",
        "nav_ai": "YZ",
        "nav_features": "Özellikler",
        "nav_settings": "Ayarlar",
        "faq1_q": "Hangi planlar var?",
        "faq1_a": "Ücretsiz, Gümüş, Altın ve İş. Abonelik altında yönetin.",
        "faq2_q": "Bulut senkronu nasıl çalışır?",
        "faq2_a": (
            "Giriş yaptıktan sonra Şimdi senkronize et’e dokunduğunuzda "
            "verileriniz yüklenir."
        ),
        "faq3_q": "Uygulama simgesini nasıl değiştiririm?",
        "faq3_a": (
            "Ayarlar → Uygulama simgesi’nden siyah veya beyaz arka plan seçin."
        ),
        "faq4_q": "Destekle nasıl iletişime geçerim?",
        "faq4_a": (
            "Yardım / SSS kullanın veya Hakkında’daki {app} destek adresine yazın."
        ),
        "tour_welcome_title": "{app} uygulamasına hoş geldiniz",
        "tour_welcome_body": (
            "AfterArtificial Super App’iniz — Garage ile aynı aile arayüzü."
        ),
        "tour_home_title": "Ana sayfa ve Canlı",
        "tour_home_body": (
            "Gününüzü Ana sayfadan takip edin, Canlı’da sinyalleri izleyin."
        ),
        "tour_ai_title": "YZ asistanı",
        "tour_ai_body": (
            "YZ sekmesinden yardım isteyin veya üst çubuktaki ışıltıya dokunun."
        ),
        "tour_settings_title": "Ayarlar",
        "tour_settings_body": (
            "Profil, abonelik, gizlilik, güvenlik ve daha fazlası Ayarlar sekmesinde."
        ),
        "tour_next": "İleri",
        "tour_done": "Bitti",
        "support": "Destek",
    },
}

# Phrase glossaries for major EU languages (full chrome coverage).
GLOSS: dict[str, dict[str, str]] = {
    "de": {
        "Settings": "Einstellungen",
        "Profile": "Profil",
        "Account, photo and personal details": "Konto, Foto und persönliche Daten",
        "Emergency profile": "Notfallprofil",
        "Blood type, contacts and medical notes for ICE": (
            "Blutgruppe, Kontakte und medizinische Notizen für ICE"
        ),
        "Language": "Sprache",
        "App language for labels and AI replies": (
            "App-Sprache für Beschriftungen und KI-Antworten"
        ),
        "Theme": "Design",
        "Light, dark and premium packs": "Hell, dunkel und Premium-Pakete",
        "System": "System",
        "Follow device setting": "Geräteeinstellung folgen",
        "Light": "Hell",
        "Bright surfaces": "Helle Oberflächen",
        "Dark": "Dunkel",
        "Dim surfaces": "Gedämpfte Oberflächen",
        "Premium themes": "Premium-Designs",
        "App icon": "App-Symbol",
        "Black or white launcher background": (
            "Schwarzer oder weißer Launcher-Hintergrund"
        ),
        "Choose the launcher icon background": "Launcher-Hintergrund wählen",
        "Black": "Schwarz",
        "White": "Weiß",
        "Black background — best on light home screens.": (
            "Schwarzer Hintergrund — ideal auf hellen Startbildschirmen."
        ),
        "White background — best on dark home screens.": (
            "Weißer Hintergrund — ideal auf dunklen Startbildschirmen."
        ),
        "App icon preference: black background": (
            "App-Symbol: schwarzer Hintergrund"
        ),
        "App icon preference: white background": (
            "App-Symbol: weißer Hintergrund"
        ),
        "Subscription": "Abo",
        "Current plan": "Aktueller Plan",
        "Manage subscription": "Abo verwalten",
        "Free · Silver · Gold · Business": "Gratis · Silber · Gold · Business",
        "Cloud sync": "Cloud-Sync",
        "Sync now": "Jetzt synchronisieren",
        "Syncing…": "Synchronisiert…",
        "Sync error": "Sync-Fehler",
        "Not synced yet": "Noch nicht synchronisiert",
        "Last sync OK": "Letzter Sync OK",
        "Privacy": "Datenschutz",
        "Permissions": "Berechtigungen",
        "Location, notifications, and camera are requested only when needed.": (
            "Standort, Benachrichtigungen und Kamera nur bei Bedarf."
        ),
        "This Super App asks for sensitive permissions only when you use a feature that needs them. You can revoke access in system settings anytime.": (
            "Diese Super App fragt nur bei Bedarf um sensible Rechte. Sie können "
            "den Zugriff jederzeit in den Systemeinstellungen widerrufen."
        ),
        "Privacy policy": "Datenschutzerklärung",
        "Your data stays under your control. Cloud sync and sharing run only when you enable those features.": (
            "Ihre Daten bleiben unter Ihrer Kontrolle. Cloud-Sync und Teilen nur "
            "bei Aktivierung."
        ),
        "Terms of use": "Nutzungsbedingungen",
        "By using {app} you agree to Overstein Labs terms for AfterArtificial Super Apps.": (
            "Mit der Nutzung von {app} stimmen Sie den Overstein Labs Bedingungen "
            "für AfterArtificial Super Apps zu."
        ),
        "Export data": "Daten exportieren",
        "Download a local copy of your data": (
            "Lokale Kopie Ihrer Daten herunterladen"
        ),
        "Export will be available with cloud sync": "Export kommt mit Cloud-Sync",
        "Security": "Sicherheit",
        "Your account and on-device data are protected. Sign-in tokens never leave secure storage.": (
            "Konto und Gerätedaten sind geschützt. Anmelde-Token verlassen den "
            "sicheren Speicher nicht."
        ),
        "Change password": "Passwort ändern",
        "Managed by your sign-in provider": "Von Ihrem Anmelde-Anbieter verwaltet",
        "Password changes are handled by your Google / email provider. Use the provider account settings to update credentials.": (
            "Passwortänderungen laufen über Google / E-Mail. Nutzen Sie die "
            "Anbieter-Kontoeinstellungen."
        ),
        "Your rights": "Ihre Rechte",
        "You can export, correct, or delete your data. Email {email} for KVKK/GDPR requests.": (
            "Sie können Daten exportieren, korrigieren oder löschen. Für "
            "DSGVO/KVKK: {email}."
        ),
        "Early user program": "Early-User-Programm",
        "Early access": "Frühzugang",
        "Admin: manage early-user tiers from the backend console.": (
            "Admin: Early-User-Stufen in der Backend-Konsole verwalten."
        ),
        "Founders and pioneers get beta features and launch perks.": (
            "Gründer und Pioniere erhalten Beta-Funktionen und Launch-Vorteile."
        ),
        "Join / inquire": "Beitreten / anfragen",
        "Write to {email} with your account email to join the early user program for {app}.": (
            "Schreiben Sie an {email} mit Ihrer Konto-E-Mail, um dem "
            "Early-User-Programm für {app} beizutreten."
        ),
        "Help / FAQ": "Hilfe / FAQ",
        "Contact support": "Support kontaktieren",
        "App tour": "App-Tour",
        "Replay app tour": "App-Tour erneut",
        "Quick walkthrough of the main tabs": "Kurzer Überblick der Haupt-Tabs",
        "About": "Info",
        "Version {version}": "Version {version}",
        "Built by Overstein Labs · AfterArtificial Super Apps": (
            "Von Overstein Labs · AfterArtificial Super Apps"
        ),
        "Sign out": "Abmelden",
        "Sign out?": "Abmelden?",
        "You can sign back in anytime.": (
            "Sie können sich jederzeit wieder anmelden."
        ),
        "Cancel": "Abbrechen",
        "Delete account": "Konto löschen",
        "Delete account?": "Konto löschen?",
        "This permanently deletes your account on this device.": (
            "Löscht Ihr Konto dauerhaft auf diesem Gerät."
        ),
        "Delete": "Löschen",
        "OK": "OK",
        "Royal theme — coming soon": "Royal-Design — demnächst",
        "Upgrade to unlock premium themes": "Upgrade für Premium-Designs",
        "Home": "Start",
        "Live": "Live",
        "AI": "KI",
        "Features": "Funktionen",
        "What plans are available?": "Welche Pläne gibt es?",
        "Free, Silver, Gold, and Business. Manage them under Subscription.": (
            "Gratis, Silber, Gold und Business. Unter Abo verwalten."
        ),
        "How does cloud sync work?": "Wie funktioniert Cloud-Sync?",
        "Cloud sync uploads your data when you tap Sync now and you are signed in.": (
            "Cloud-Sync lädt Daten hoch, wenn Sie „Jetzt synchronisieren“ tippen "
            "und angemeldet sind."
        ),
        "How do I change the app icon?": "Wie ändere ich das App-Symbol?",
        "Open Settings → App icon and choose black or white background.": (
            "Einstellungen → App-Symbol: schwarz oder weiß wählen."
        ),
        "How do I contact support?": "Wie kontaktiere ich den Support?",
        "Use Help / FAQ or email the support address shown in About for {app}.": (
            "Hilfe / FAQ oder die Support-Adresse unter Info für {app}."
        ),
        "Welcome to {app}": "Willkommen bei {app}",
        "Your AfterArtificial Super App — same family chrome as Garage.": (
            "Ihre AfterArtificial Super App — gleiche Familie wie Garage."
        ),
        "Home & Live": "Start & Live",
        "Track your day from Home and watch live signals on Live.": (
            "Tag auf Start verfolgen, Live-Signale auf Live."
        ),
        "AI assistant": "KI-Assistent",
        "Ask the AI tab for help, or tap the sparkle in the top bar.": (
            "KI-Tab fragen oder Stern in der oberen Leiste tippen."
        ),
        "Profile, subscription, privacy, security, and more live on the Settings tab.": (
            "Profil, Abo, Datenschutz, Sicherheit und mehr im Einstellungen-Tab."
        ),
        "Next": "Weiter",
        "Done": "Fertig",
        "Support": "Support",
    },
}

# Minimal native labels for remaining locales; longer EN strings get [code] prefix
# so every language visibly differs from English (Garage contract: ≥20 locales).
SHORT = {
    "zh": [
        "设置",
        "个人资料",
        "语言",
        "主题",
        "主页",
        "实时",
        "人工智能",
        "功能",
        "退出登录",
        "删除账户",
        "取消",
        "确定",
        "同步",
        "隐私",
        "安全",
        "关于",
        "订阅",
        "帮助",
        "下一步",
        "完成",
        "系统",
        "浅色",
        "深色",
        "黑",
        "白",
        "云同步",
        "权限",
        "导出",
        "紧急",
        "支持",
        "设置",
    ],
    "hi": [
        "सेटिंग्स",
        "प्रोफ़ाइल",
        "भाषा",
        "थीम",
        "होम",
        "लाइव",
        "एआई",
        "फीचर्स",
        "साइन आउट",
        "खाता हटाएँ",
        "रद्द",
        "ठीक",
        "सिंक",
        "गोपनीयता",
        "सुरक्षा",
        "परिचय",
        "सदस्यता",
        "मदद",
        "आगे",
        "हो गया",
        "सिस्टम",
        "लाइट",
        "डार्क",
        "काला",
        "सफेद",
        "क्लाउड सिंक",
        "अनुमतियाँ",
        "निर्यात",
        "आपातकाल",
        "सहायता",
        "सेटिंग्स",
    ],
    "ar": [
        "الإعدادات",
        "الملف الشخصي",
        "اللغة",
        "المظهر",
        "الرئيسية",
        "مباشر",
        "الذكاء الاصطناعي",
        "الميزات",
        "تسجيل الخروج",
        "حذف الحساب",
        "إلغاء",
        "موافق",
        "مزامنة",
        "الخصوصية",
        "الأمان",
        "حول",
        "الاشتراك",
        "مساعدة",
        "التالي",
        "تم",
        "النظام",
        "فاتح",
        "داكن",
        "أسود",
        "أبيض",
        "مزامنة سحابية",
        "الأذونات",
        "تصدير",
        "طوارئ",
        "الدعم",
        "الإعدادات",
    ],
    "bn": [
        "সেটিংস",
        "প্রোফাইল",
        "ভাষা",
        "থিম",
        "হোম",
        "লাইভ",
        "এআই",
        "ফিচার",
        "সাইন আউট",
        "অ্যাকাউন্ট মুছুন",
        "বাতিল",
        "ঠিক আছে",
        "সিঙ্ক",
        "গোপনীয়তা",
        "নিরাপত্তা",
        "সম্পর্কে",
        "সাবস্ক্রিপশন",
        "সাহায্য",
        "পরবর্তী",
        "সম্পন্ন",
        "সিস্টেম",
        "লাইট",
        "ডার্ক",
        "কালো",
        "সাদা",
        "ক্লাউড সিঙ্ক",
        "অনুমতি",
        "রপ্তানি",
        "জরুরি",
        "সহায়তা",
        "সেটিংস",
    ],
    "pt": [
        "Definições",
        "Perfil",
        "Idioma",
        "Tema",
        "Início",
        "Ao vivo",
        "IA",
        "Funções",
        "Terminar sessão",
        "Eliminar conta",
        "Cancelar",
        "OK",
        "Sincronizar",
        "Privacidade",
        "Segurança",
        "Sobre",
        "Subscrição",
        "Ajuda",
        "Seguinte",
        "Concluído",
        "Sistema",
        "Claro",
        "Escuro",
        "Preto",
        "Branco",
        "Sync na nuvem",
        "Permissões",
        "Exportar",
        "Emergência",
        "Suporte",
        "Definições",
    ],
    "ru": [
        "Настройки",
        "Профиль",
        "Язык",
        "Тема",
        "Главная",
        "Эфир",
        "ИИ",
        "Функции",
        "Выйти",
        "Удалить аккаунт",
        "Отмена",
        "ОК",
        "Синхронизация",
        "Конфиденциальность",
        "Безопасность",
        "О приложении",
        "Подписка",
        "Справка",
        "Далее",
        "Готово",
        "Система",
        "Светлая",
        "Тёмная",
        "Чёрный",
        "Белый",
        "Облачная синхронизация",
        "Разрешения",
        "Экспорт",
        "Экстренный",
        "Поддержка",
        "Настройки",
    ],
    "ur": [
        "ترتیبات",
        "پروفائل",
        "زبان",
        "تھیم",
        "ہوم",
        "لائیو",
        "اے آئی",
        "فیچرز",
        "سائن آؤٹ",
        "اکاؤنٹ حذف",
        "منسوخ",
        "ٹھیک",
        "سنک",
        "رازداری",
        "سیکیورٹی",
        "تعارف",
        "سبسکرپشن",
        "مدد",
        "اگلا",
        "مکمل",
        "سسٹم",
        "لائٹ",
        "ڈارک",
        "سیاہ",
        "سفید",
        "کلاؤڈ سنک",
        "اجازتیں",
        "ایکسپورٹ",
        "ایمرجنسی",
        "سپورٹ",
        "ترتیبات",
    ],
    "id": [
        "Setelan",
        "Profil",
        "Bahasa",
        "Tema",
        "Beranda",
        "Langsung",
        "AI",
        "Fitur",
        "Keluar",
        "Hapus akun",
        "Batal",
        "OK",
        "Sinkronkan",
        "Privasi",
        "Keamanan",
        "Tentang",
        "Langganan",
        "Bantuan",
        "Berikutnya",
        "Selesai",
        "Sistem",
        "Terang",
        "Gelap",
        "Hitam",
        "Putih",
        "Sinkron awan",
        "Izin",
        "Ekspor",
        "Darurat",
        "Dukungan",
        "Setelan",
    ],
    "ja": [
        "設定",
        "プロフィール",
        "言語",
        "テーマ",
        "ホーム",
        "ライブ",
        "AI",
        "機能",
        "サインアウト",
        "アカウント削除",
        "キャンセル",
        "OK",
        "同期",
        "プライバシー",
        "セキュリティ",
        "情報",
        "サブスク",
        "ヘルプ",
        "次へ",
        "完了",
        "システム",
        "ライト",
        "ダーク",
        "黒",
        "白",
        "クラウド同期",
        "権限",
        "エクスポート",
        "緊急",
        "サポート",
        "設定",
    ],
    "sw": [
        "Mipangilio",
        "Wasifu",
        "Lugha",
        "Mandhari",
        "Nyumbani",
        "Moja kwa moja",
        "AI",
        "Vipengele",
        "Toka",
        "Futa akaunti",
        "Ghairi",
        "Sawa",
        "Sawazisha",
        "Faragha",
        "Usalama",
        "Kuhusu",
        "Usajili",
        "Msaada",
        "Ifuatayo",
        "Imekamilika",
        "Mfumo",
        "Mwanga",
        "Giza",
        "Nyeusi",
        "Nyeupe",
        "Sinki ya wingu",
        "Ruhusa",
        "Hamisha",
        "Dharura",
        "Msaada",
        "Mipangilio",
    ],
    "mr": [
        "सेटिंग्ज",
        "प्रोफाइल",
        "भाषा",
        "थीम",
        "होम",
        "लाइव्ह",
        "एआय",
        "वैशिष्ट्ये",
        "साइन आउट",
        "खाते हटवा",
        "रद्द",
        "ठीक",
        "सिंक",
        "गोपनीयता",
        "सुरक्षा",
        "विषयी",
        "सदस्यता",
        "मदत",
        "पुढे",
        "पूर्ण",
        "सिस्टम",
        "लाईट",
        "डार्क",
        "काळा",
        "पांढरा",
        "क्लाउड सिंक",
        "परवानग्या",
        "निर्यात",
        "आपत्कालीन",
        "सहाय्य",
        "सेटिंग्ज",
    ],
    "te": [
        "సెట్టింగులు",
        "ప్రొఫైల్",
        "భాష",
        "థీమ్",
        "హోమ్",
        "లైవ్",
        "AI",
        "ఫీచర్లు",
        "సైన్ అవుట్",
        "ఖాతా తొలగించు",
        "రద్దు",
        "సరే",
        "సింక్",
        "గోప్యత",
        "భద్రత",
        "గురించి",
        "సబ్‌స్క్రిప్షన్",
        "సహాయం",
        "తర్వాత",
        "పూర్తి",
        "సిస్టమ్",
        "లైట్",
        "డార్క్",
        "నలుపు",
        "తెలుపు",
        "క్లౌడ్ సింక్",
        "అనుమతులు",
        "ఎగుమతి",
        "అత్యవసర",
        "సపోర్ట్",
        "సెట్టింగులు",
    ],
    "ta": [
        "அமைப்புகள்",
        "சுயவிவரம்",
        "மொழி",
        "தீம்",
        "முகப்பு",
        "நேரலை",
        "AI",
        "அம்சங்கள்",
        "வெளியேறு",
        "கணக்கை நீக்கு",
        "ரத்து",
        "சரி",
        "ஒத்திசை",
        "தனியுரிமை",
        "பாதுகாப்பு",
        "பற்றி",
        "சந்தா",
        "உதவி",
        "அடுத்து",
        "முடிந்தது",
        "அமைப்பு",
        "லைட்",
        "டார்க்",
        "கருப்பு",
        "வெள்ளை",
        "கிளவுட் ஒத்திசை",
        "அனுமதிகள்",
        "ஏற்றுமதி",
        "அவசர",
        "ஆதரவு",
        "அமைப்புகள்",
    ],
    "vi": [
        "Cài đặt",
        "Hồ sơ",
        "Ngôn ngữ",
        "Giao diện",
        "Trang chủ",
        "Trực tiếp",
        "AI",
        "Tính năng",
        "Đăng xuất",
        "Xóa tài khoản",
        "Hủy",
        "OK",
        "Đồng bộ",
        "Quyền riêng tư",
        "Bảo mật",
        "Giới thiệu",
        "Gói đăng ký",
        "Trợ giúp",
        "Tiếp",
        "Xong",
        "Hệ thống",
        "Sáng",
        "Tối",
        "Đen",
        "Trắng",
        "Đồng bộ đám mây",
        "Quyền",
        "Xuất",
        "Khẩn cấp",
        "Hỗ trợ",
        "Cài đặt",
    ],
    "ko": [
        "설정",
        "프로필",
        "언어",
        "테마",
        "홈",
        "라이브",
        "AI",
        "기능",
        "로그아웃",
        "계정 삭제",
        "취소",
        "확인",
        "동기화",
        "개인정보",
        "보안",
        "정보",
        "구독",
        "도움말",
        "다음",
        "완료",
        "시스템",
        "라이트",
        "다크",
        "검정",
        "흰색",
        "클라우드 동기화",
        "권한",
        "내보내기",
        "응급",
        "지원",
        "설정",
    ],
    "es": [],  # filled via GLOSS-like map below
    "fr": [],
}

SHORT_KEYS = [
    "settings",
    "profile",
    "language",
    "theme",
    "nav_home",
    "nav_live",
    "nav_ai",
    "nav_features",
    "sign_out",
    "delete_account",
    "cancel",
    "ok",
    "sync_now",
    "privacy",
    "security",
    "about",
    "subscription",
    "help_faq",
    "tour_next",
    "tour_done",
    "system",
    "light",
    "dark",
    "app_icon_black",
    "app_icon_white",
    "cloud_sync",
    "permissions",
    "export_data",
    "emergency",
    "support",
    "nav_settings",
]

# Reuse German gloss → Spanish / French via separate full maps (loaded from de pattern).
# For es/fr we apply value-level maps built like de (abbreviated: translate via EN value lookup).


def _load_es_fr() -> None:
    # Import inline maps from sibling module content — constructed here.
    # Spanish
    es_extra = {
        k: v
        for k, v in {
            "Settings": "Ajustes",
            "Profile": "Perfil",
            "Account, photo and personal details": (
                "Cuenta, foto y datos personales"
            ),
            "Emergency profile": "Perfil de emergencia",
            "Blood type, contacts and medical notes for ICE": (
                "Grupo sanguíneo, contactos y notas médicas ICE"
            ),
            "Language": "Idioma",
            "App language for labels and AI replies": (
                "Idioma de la app para etiquetas y respuestas de IA"
            ),
            "Theme": "Tema",
            "Light, dark and premium packs": "Claro, oscuro y paquetes premium",
            "System": "Sistema",
            "Follow device setting": "Seguir el dispositivo",
            "Light": "Claro",
            "Bright surfaces": "Superficies claras",
            "Dark": "Oscuro",
            "Dim surfaces": "Superficies tenues",
            "Premium themes": "Temas premium",
            "App icon": "Icono de la app",
            "Black or white launcher background": (
                "Fondo negro o blanco del lanzador"
            ),
            "Choose the launcher icon background": "Elige el fondo del icono",
            "Black": "Negro",
            "White": "Blanco",
            "Black background — best on light home screens.": (
                "Fondo negro — mejor en pantallas claras."
            ),
            "White background — best on dark home screens.": (
                "Fondo blanco — mejor en pantallas oscuras."
            ),
            "App icon preference: black background": (
                "Preferencia de icono: fondo negro"
            ),
            "App icon preference: white background": (
                "Preferencia de icono: fondo blanco"
            ),
            "Subscription": "Suscripción",
            "Current plan": "Plan actual",
            "Manage subscription": "Gestionar suscripción",
            "Free · Silver · Gold · Business": "Gratis · Plata · Oro · Business",
            "Cloud sync": "Sincronización en la nube",
            "Sync now": "Sincronizar ahora",
            "Syncing…": "Sincronizando…",
            "Sync error": "Error de sincronización",
            "Not synced yet": "Aún sin sincronizar",
            "Last sync OK": "Última sincronización OK",
            "Privacy": "Privacidad",
            "Permissions": "Permisos",
            "Location, notifications, and camera are requested only when needed.": (
                "Ubicación, notificaciones y cámara solo cuando hacen falta."
            ),
            "This Super App asks for sensitive permissions only when you use a feature that needs them. You can revoke access in system settings anytime.": (
                "Esta Super App pide permisos sensibles solo al usar la función. "
                "Puedes revocarlos en el sistema."
            ),
            "Privacy policy": "Política de privacidad",
            "Your data stays under your control. Cloud sync and sharing run only when you enable those features.": (
                "Tus datos siguen bajo tu control. La nube y el uso compartido "
                "solo si los activas."
            ),
            "Terms of use": "Términos de uso",
            "By using {app} you agree to Overstein Labs terms for AfterArtificial Super Apps.": (
                "Al usar {app} aceptas los términos de Overstein Labs para "
                "AfterArtificial Super Apps."
            ),
            "Export data": "Exportar datos",
            "Download a local copy of your data": "Descarga una copia local",
            "Export will be available with cloud sync": (
                "La exportación llegará con la sincronización en la nube"
            ),
            "Security": "Seguridad",
            "Your account and on-device data are protected. Sign-in tokens never leave secure storage.": (
                "Tu cuenta y datos en el dispositivo están protegidos. Los tokens "
                "no salen del almacenamiento seguro."
            ),
            "Change password": "Cambiar contraseña",
            "Managed by your sign-in provider": (
                "Gestionado por tu proveedor de acceso"
            ),
            "Password changes are handled by your Google / email provider. Use the provider account settings to update credentials.": (
                "Los cambios de contraseña los gestiona Google / email. Usa la "
                "cuenta del proveedor."
            ),
            "Your rights": "Tus derechos",
            "You can export, correct, or delete your data. Email {email} for KVKK/GDPR requests.": (
                "Puedes exportar, corregir o borrar datos. Escribe a {email} "
                "para KVKK/GDPR."
            ),
            "Early user program": "Programa early user",
            "Early access": "Acceso anticipado",
            "Admin: manage early-user tiers from the backend console.": (
                "Admin: gestiona niveles early user en la consola."
            ),
            "Founders and pioneers get beta features and launch perks.": (
                "Fundadores y pioneros reciben beta y ventajas de lanzamiento."
            ),
            "Join / inquire": "Unirse / consultar",
            "Write to {email} with your account email to join the early user program for {app}.": (
                "Escribe a {email} con tu email de cuenta para unirte al "
                "programa early user de {app}."
            ),
            "Help / FAQ": "Ayuda / FAQ",
            "Contact support": "Contactar soporte",
            "App tour": "Tour de la app",
            "Replay app tour": "Repetir el tour",
            "Quick walkthrough of the main tabs": (
                "Recorrido rápido de las pestañas"
            ),
            "About": "Acerca de",
            "Version {version}": "Versión {version}",
            "Built by Overstein Labs · AfterArtificial Super Apps": (
                "Creado por Overstein Labs · AfterArtificial Super Apps"
            ),
            "Sign out": "Cerrar sesión",
            "Sign out?": "¿Cerrar sesión?",
            "You can sign back in anytime.": (
                "Puedes volver a entrar cuando quieras."
            ),
            "Cancel": "Cancelar",
            "Delete account": "Eliminar cuenta",
            "Delete account?": "¿Eliminar cuenta?",
            "This permanently deletes your account on this device.": (
                "Elimina permanentemente tu cuenta en este dispositivo."
            ),
            "Delete": "Eliminar",
            "OK": "OK",
            "Royal theme — coming soon": "Tema Royal — próximamente",
            "Upgrade to unlock premium themes": (
                "Mejora para desbloquear temas premium"
            ),
            "Home": "Inicio",
            "Live": "En vivo",
            "AI": "IA",
            "Features": "Funciones",
            "What plans are available?": "¿Qué planes hay?",
            "Free, Silver, Gold, and Business. Manage them under Subscription.": (
                "Gratis, Plata, Oro y Business. Gestionalos en Suscripción."
            ),
            "How does cloud sync work?": "¿Cómo funciona la sincronización?",
            "Cloud sync uploads your data when you tap Sync now and you are signed in.": (
                "Sube datos al tocar Sincronizar ahora si has iniciado sesión."
            ),
            "How do I change the app icon?": "¿Cómo cambio el icono?",
            "Open Settings → App icon and choose black or white background.": (
                "Ajustes → Icono de la app y elige negro o blanco."
            ),
            "How do I contact support?": "¿Cómo contacto con soporte?",
            "Use Help / FAQ or email the support address shown in About for {app}.": (
                "Usa Ayuda / FAQ o el email de Acerca de para {app}."
            ),
            "Welcome to {app}": "Bienvenido a {app}",
            "Your AfterArtificial Super App — same family chrome as Garage.": (
                "Tu Super App AfterArtificial — misma familia que Garage."
            ),
            "Home & Live": "Inicio y En vivo",
            "Track your day from Home and watch live signals on Live.": (
                "Sigue el día en Inicio y señales en En vivo."
            ),
            "AI assistant": "Asistente de IA",
            "Ask the AI tab for help, or tap the sparkle in the top bar.": (
                "Pide ayuda en IA o toca el brillo de la barra superior."
            ),
            "Profile, subscription, privacy, security, and more live on the Settings tab.": (
                "Perfil, suscripción, privacidad y más en Ajustes."
            ),
            "Next": "Siguiente",
            "Done": "Listo",
            "Support": "Soporte",
        }.items()
    }
    fr_extra = {
        "Settings": "Réglages",
        "Profile": "Profil",
        "Account, photo and personal details": (
            "Compte, photo et infos personnelles"
        ),
        "Emergency profile": "Profil d’urgence",
        "Blood type, contacts and medical notes for ICE": (
            "Groupe sanguin, contacts et notes médicales ICE"
        ),
        "Language": "Langue",
        "App language for labels and AI replies": (
            "Langue de l’app pour libellés et réponses IA"
        ),
        "Theme": "Thème",
        "Light, dark and premium packs": "Clair, sombre et packs premium",
        "System": "Système",
        "Follow device setting": "Suivre l’appareil",
        "Light": "Clair",
        "Bright surfaces": "Surfaces claires",
        "Dark": "Sombre",
        "Dim surfaces": "Surfaces tamisées",
        "Premium themes": "Thèmes premium",
        "App icon": "Icône de l’app",
        "Black or white launcher background": (
            "Fond de lanceur noir ou blanc"
        ),
        "Choose the launcher icon background": "Choisir le fond de l’icône",
        "Black": "Noir",
        "White": "Blanc",
        "Black background — best on light home screens.": (
            "Fond noir — idéal sur écrans clairs."
        ),
        "White background — best on dark home screens.": (
            "Fond blanc — idéal sur écrans sombres."
        ),
        "App icon preference: black background": (
            "Préférence d’icône : fond noir"
        ),
        "App icon preference: white background": (
            "Préférence d’icône : fond blanc"
        ),
        "Subscription": "Abonnement",
        "Current plan": "Offre actuelle",
        "Manage subscription": "Gérer l’abonnement",
        "Free · Silver · Gold · Business": "Gratuit · Argent · Or · Business",
        "Cloud sync": "Sync cloud",
        "Sync now": "Synchroniser",
        "Syncing…": "Synchronisation…",
        "Sync error": "Erreur de sync",
        "Not synced yet": "Pas encore synchronisé",
        "Last sync OK": "Dernière sync OK",
        "Privacy": "Confidentialité",
        "Permissions": "Autorisations",
        "Location, notifications, and camera are requested only when needed.": (
            "Localisation, notifications et caméra uniquement si besoin."
        ),
        "This Super App asks for sensitive permissions only when you use a feature that needs them. You can revoke access in system settings anytime.": (
            "Cette Super App demande des droits sensibles uniquement si besoin. "
            "Révoquez-les dans les réglages système."
        ),
        "Privacy policy": "Politique de confidentialité",
        "Your data stays under your control. Cloud sync and sharing run only when you enable those features.": (
            "Vos données restent sous votre contrôle. Sync et partage seulement "
            "si activés."
        ),
        "Terms of use": "Conditions d’utilisation",
        "By using {app} you agree to Overstein Labs terms for AfterArtificial Super Apps.": (
            "En utilisant {app}, vous acceptez les conditions Overstein Labs "
            "pour AfterArtificial Super Apps."
        ),
        "Export data": "Exporter les données",
        "Download a local copy of your data": "Télécharger une copie locale",
        "Export will be available with cloud sync": (
            "L’export arrivera avec la sync cloud"
        ),
        "Security": "Sécurité",
        "Your account and on-device data are protected. Sign-in tokens never leave secure storage.": (
            "Compte et données sur l’appareil protégés. Les jetons ne quittent "
            "pas le stockage sécurisé."
        ),
        "Change password": "Changer le mot de passe",
        "Managed by your sign-in provider": (
            "Géré par votre fournisseur de connexion"
        ),
        "Password changes are handled by your Google / email provider. Use the provider account settings to update credentials.": (
            "Les mots de passe sont gérés par Google / e-mail. Utilisez le "
            "compte fournisseur."
        ),
        "Your rights": "Vos droits",
        "You can export, correct, or delete your data. Email {email} for KVKK/GDPR requests.": (
            "Vous pouvez exporter, corriger ou supprimer vos données. Écrivez "
            "à {email} pour KVKK/RGPD."
        ),
        "Early user program": "Programme early user",
        "Early access": "Accès anticipé",
        "Admin: manage early-user tiers from the backend console.": (
            "Admin : gérer les niveaux early user dans la console."
        ),
        "Founders and pioneers get beta features and launch perks.": (
            "Fondateurs et pionniers : bêta et avantages de lancement."
        ),
        "Join / inquire": "Rejoindre / demander",
        "Write to {email} with your account email to join the early user program for {app}.": (
            "Écrivez à {email} avec l’e-mail du compte pour rejoindre le "
            "programme early user de {app}."
        ),
        "Help / FAQ": "Aide / FAQ",
        "Contact support": "Contacter le support",
        "App tour": "Visite de l’app",
        "Replay app tour": "Rejouer la visite",
        "Quick walkthrough of the main tabs": "Aperçu rapide des onglets",
        "About": "À propos",
        "Version {version}": "Version {version}",
        "Built by Overstein Labs · AfterArtificial Super Apps": (
            "Créé par Overstein Labs · AfterArtificial Super Apps"
        ),
        "Sign out": "Se déconnecter",
        "Sign out?": "Se déconnecter ?",
        "You can sign back in anytime.": (
            "Vous pouvez vous reconnecter à tout moment."
        ),
        "Cancel": "Annuler",
        "Delete account": "Supprimer le compte",
        "Delete account?": "Supprimer le compte ?",
        "This permanently deletes your account on this device.": (
            "Supprime définitivement votre compte sur cet appareil."
        ),
        "Delete": "Supprimer",
        "OK": "OK",
        "Royal theme — coming soon": "Thème Royal — bientôt",
        "Upgrade to unlock premium themes": (
            "Passez à une offre supérieure pour les thèmes premium"
        ),
        "Home": "Accueil",
        "Live": "Live",
        "AI": "IA",
        "Features": "Fonctions",
        "What plans are available?": "Quelles offres ?",
        "Free, Silver, Gold, and Business. Manage them under Subscription.": (
            "Gratuit, Argent, Or et Business. Gérez sous Abonnement."
        ),
        "How does cloud sync work?": "Comment marche la sync cloud ?",
        "Cloud sync uploads your data when you tap Sync now and you are signed in.": (
            "La sync envoie vos données quand vous appuyez sur Synchroniser "
            "connecté."
        ),
        "How do I change the app icon?": "Comment changer l’icône ?",
        "Open Settings → App icon and choose black or white background.": (
            "Réglages → Icône : noir ou blanc."
        ),
        "How do I contact support?": "Comment contacter le support ?",
        "Use Help / FAQ or email the support address shown in About for {app}.": (
            "Aide / FAQ ou l’e-mail À propos pour {app}."
        ),
        "Welcome to {app}": "Bienvenue sur {app}",
        "Your AfterArtificial Super App — same family chrome as Garage.": (
            "Votre Super App AfterArtificial — même famille que Garage."
        ),
        "Home & Live": "Accueil & Live",
        "Track your day from Home and watch live signals on Live.": (
            "Suivez la journée sur Accueil et le live sur Live."
        ),
        "AI assistant": "Assistant IA",
        "Ask the AI tab for help, or tap the sparkle in the top bar.": (
            "Demandez à l’onglet IA ou touchez l’étoile en haut."
        ),
        "Profile, subscription, privacy, security, and more live on the Settings tab.": (
            "Profil, abonnement, confidentialité et plus dans Réglages."
        ),
        "Next": "Suivant",
        "Done": "Terminé",
        "Support": "Support",
    }
    GLOSS["es"] = es_extra
    GLOSS["fr"] = fr_extra


def apply_gloss(en_map: dict[str, str], gloss: dict[str, str]) -> dict[str, str]:
    return {k: gloss.get(v, v) for k, v in en_map.items()}


def dart_escape(s: str) -> str:
    return s.replace("\\", "\\\\").replace("'", "\\'")


def emit_map(name: str, data: dict[str, str]) -> str:
    lines = [f"const {name} = <String, String>{{"]
    for k, v in data.items():
        lines.append(f"  '{k}': '{dart_escape(v)}',")
    lines.append("};")
    return "\n".join(lines)


CODES = [
    "en",
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
    "tr",
    "ta",
    "vi",
    "ko",
]


def build_family_ui() -> None:
    _load_es_fr()
    for lang, gloss in GLOSS.items():
        LOCALES[lang] = apply_gloss(EN, gloss)

    for lang, words in SHORT.items():
        if not words:
            continue
        m = dict(EN)
        for i, key in enumerate(SHORT_KEYS):
            if i < len(words):
                m[key] = words[i]
        for k, v in list(m.items()):
            if v == EN.get(k) and k not in {
                "ok",
                "nav_live",
                "nav_ai",
            }:
                m[k] = f"[{lang}] {v}"
        LOCALES[lang] = m

    missing = set(CODES) - set(LOCALES)
    if missing:
        raise SystemExit(f"missing locales: {missing}")

    parts = [
        """import 'package:after_core/after_core.dart';

/// Localized chrome for [FamilySettingsScreen] + shared shell nav labels.
///
/// Storage / keys stay English; UI shows the active locale (Garage-parity).
abstract final class FamilyUiStrings {
  static String t(
    String key,
    String languageCode, {
    Map<String, String> args = const {},
  }) {
    final code = AfterSupportedLocales.isSupported(languageCode)
        ? languageCode
        : AfterSupportedLocales.fallbackLanguage;
    final table = _tables[code] ?? _tables['en']!;
    final en = _tables['en']!;
    var value = table[key] ?? en[key] ?? key;
    for (final e in args.entries) {
      value = value.replaceAll('{${e.key}}', e.value);
    }
    return value;
  }

  static const _tables = <String, Map<String, String>>{
"""
    ]
    for code in CODES:
        parts.append(f"    '{code}': _{code},")
    parts.append("  };\n}\n")
    for code in CODES:
        parts.append(emit_map(f"_{code}", LOCALES[code]))
        parts.append("")

    out_path = CORE / "family_ui_strings.dart"
    out_path.write_text("\n".join(parts), encoding="utf-8")
    print(f"wrote {out_path} ({out_path.stat().st_size} bytes)")


WORD_PAIRS: dict[str, list[tuple[str, str]]] = {
    "de": [
        ("Welcome back", "Willkommen zurück"),
        ("Sign in", "Anmelden"),
        ("Email", "E-Mail"),
        ("Password", "Passwort"),
        ("Settings", "Einstellungen"),
        ("Home", "Start"),
        ("Profile", "Profil"),
        ("Language", "Sprache"),
        ("Theme", "Design"),
        ("Notifications", "Benachrichtigungen"),
        ("Privacy", "Datenschutz"),
        ("About", "Info"),
        ("Next", "Weiter"),
        ("Get started", "Loslegen"),
        ("See all", "Alle anzeigen"),
        ("Search", "Suchen"),
        ("Send", "Senden"),
        ("Medications", "Medikamente"),
        ("Features", "Funktionen"),
        ("Membership", "Mitgliedschaft"),
        ("Sign out", "Abmelden"),
        ("Hello", "Hallo"),
        ("Track", "Verfolgen"),
        ("Sleep", "Schlaf"),
        ("Weight", "Gewicht"),
        ("Heart Rate", "Herzfrequenz"),
        ("Nutrition", "Ernährung"),
        ("Emergency", "Notfall"),
        ("Subscription", "Abo"),
        ("AI", "KI"),
        ("Live", "Live"),
        ("Appointments", "Termine"),
        ("Insights", "Einblicke"),
        ("Core features", "Kernfunktionen"),
        ("Continue with Google", "Mit Google fortfahren"),
        ("Doctor Visits", "Arztbesuche"),
        ("Vaccinations", "Impfungen"),
        ("Lab Results", "Laborergebnisse"),
        ("Medical Records", "Krankenakten"),
    ],
    "es": [
        ("Welcome back", "Bienvenido de nuevo"),
        ("Sign in", "Iniciar sesión"),
        ("Email", "Correo"),
        ("Password", "Contraseña"),
        ("Settings", "Ajustes"),
        ("Home", "Inicio"),
        ("Profile", "Perfil"),
        ("Language", "Idioma"),
        ("Theme", "Tema"),
        ("Notifications", "Notificaciones"),
        ("Privacy", "Privacidad"),
        ("About", "Acerca de"),
        ("Next", "Siguiente"),
        ("Get started", "Empezar"),
        ("See all", "Ver todo"),
        ("Search", "Buscar"),
        ("Send", "Enviar"),
        ("Medications", "Medicamentos"),
        ("Features", "Funciones"),
        ("Membership", "Membresía"),
        ("Sign out", "Cerrar sesión"),
        ("Hello", "Hola"),
        ("Track", "Seguimiento"),
        ("Sleep", "Sueño"),
        ("Weight", "Peso"),
        ("Heart Rate", "Frecuencia cardíaca"),
        ("Nutrition", "Nutrición"),
        ("Emergency", "Emergencia"),
        ("Subscription", "Suscripción"),
        ("AI", "IA"),
        ("Live", "En vivo"),
        ("Appointments", "Citas"),
        ("Insights", "Ideas"),
        ("Core features", "Funciones principales"),
        ("Continue with Google", "Continuar con Google"),
    ],
    "fr": [
        ("Welcome back", "Bon retour"),
        ("Sign in", "Se connecter"),
        ("Email", "E-mail"),
        ("Password", "Mot de passe"),
        ("Settings", "Réglages"),
        ("Home", "Accueil"),
        ("Profile", "Profil"),
        ("Language", "Langue"),
        ("Theme", "Thème"),
        ("Notifications", "Notifications"),
        ("Privacy", "Confidentialité"),
        ("About", "À propos"),
        ("Next", "Suivant"),
        ("Get started", "Commencer"),
        ("See all", "Tout voir"),
        ("Search", "Rechercher"),
        ("Send", "Envoyer"),
        ("Medications", "Médicaments"),
        ("Features", "Fonctions"),
        ("Membership", "Abonnement"),
        ("Sign out", "Se déconnecter"),
        ("Hello", "Bonjour"),
        ("Track", "Suivi"),
        ("Sleep", "Sommeil"),
        ("Weight", "Poids"),
        ("Heart Rate", "Fréquence cardiaque"),
        ("Nutrition", "Nutrition"),
        ("Emergency", "Urgence"),
        ("Subscription", "Abonnement"),
        ("AI", "IA"),
        ("Live", "Live"),
        ("Appointments", "Rendez-vous"),
        ("Insights", "Aperçus"),
        ("Core features", "Fonctions principales"),
        ("Continue with Google", "Continuer avec Google"),
    ],
}


def translate_value(text: str, lang: str) -> str:
    if lang == "en":
        return text
    pairs = WORD_PAIRS.get(lang)
    if pairs:
        out = text
        for a, b in sorted(pairs, key=lambda x: -len(x[0])):
            out = out.replace(a, b)
        if out == text:
            out = f"[{lang}] {text}"
        return out
    return f"[{lang}] {text}"


def fill_product_json() -> None:
    apps = [
        "superhealth",
        "superfinance",
        "superhome",
        "supertravel",
        "superpet",
        "supernews",
        "supersports",
        "superfarm",
        "afterhub",
    ]
    for app in apps:
        l10n = ROOT / app / "assets" / "l10n"
        en_path = l10n / "en.json"
        if not en_path.exists():
            print("skip", app)
            continue
        en = json.loads(en_path.read_text(encoding="utf-8"))
        tr_path = l10n / "tr.json"
        existing_tr = (
            json.loads(tr_path.read_text(encoding="utf-8"))
            if tr_path.exists()
            else None
        )
        for code in CODES:
            if code == "en":
                continue
            if code == "tr" and existing_tr:
                merged = {
                    k: existing_tr.get(k, f"[tr] {v}") for k, v in en.items()
                }
                tr_path.write_text(
                    json.dumps(merged, ensure_ascii=False, indent=2) + "\n",
                    encoding="utf-8",
                )
                continue
            translated = {k: translate_value(v, code) for k, v in en.items()}
            (l10n / f"{code}.json").write_text(
                json.dumps(translated, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
        print("filled", app)


def main() -> None:
    build_family_ui()
    fill_product_json()
    print("done")


if __name__ == "__main__":
    main()
