#!/usr/bin/env python3
"""Generate after_launch_consent_catalog.dart from SuperGarage 20-locale JSON."""

from __future__ import annotations

import json
import pathlib
import re

ROOT = pathlib.Path(r"C:\Users\ayhan\StudioProjects\supergarage\assets\l10n")
OUT = pathlib.Path(
    r"C:\Users\ayhan\StudioProjects\supercore\packages\after_consumer"
    r"\lib\src\launch\after_launch_consent_catalog.dart"
)

FIELD_MAP = {
    "legalConsentTitle": "legalTitle",
    "legalConsentSubtitle": "legalSubtitle",
    "legalConsentCheckbox": "legalCheckbox",
    "legalAcceptButton": "legalAccept",
    "legalDeclineButton": "legalDecline",
    "legalConsentRequiredTitle": "legalRequiredTitle",
    "legalConsentRequiredBody": "legalRequiredBody",
    "legalConsentExitApp": "legalExitApp",
    "privacyPolicy": "privacyPolicy",
    "privacyPolicyHint": "privacyPolicyHint",
    "termsOfUse": "termsOfUse",
    "termsOfUseHint": "termsOfUseHint",
    "cancel": "cancel",
    "permissionConsentTitle": "permissionTitle",
    "permissionConsentSubtitle": "permissionSubtitle",
    "permissionConsentCheckbox": "permissionCheckbox",
    "permissionConsentAcceptButton": "permissionAccept",
    "permissionConsentFooter": "permissionFooter",
    "permissionConsentRequiredTitle": "permissionRequiredTitle",
    "permissionConsentRequiredBody": "permissionRequiredBody",
    "permissionLocation": "permissionLocation",
    "permissionConsentLocationBody": "permissionLocationBody",
    "pushNotifications": "permissionNotifications",
    "permissionConsentNotificationsBody": "permissionNotificationsBody",
    "permissionPhotos": "permissionPhotos",
    "permissionConsentPhotosBody": "permissionPhotosBody",
    "permissionCamera": "permissionCamera",
    "permissionConsentCameraBody": "permissionCameraBody",
}

LANGS = [
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


GENERIC_HINTS = {
    # privacyPolicyHint, termsOfUseHint
    "en": (
        "How we collect, store, and use your data under KVKK and GDPR.",
        "Rules for using {app}, subscriptions, and community features.",
    ),
    "tr": (
        "KVKK ve GDPR kapsamında verilerinizi nasıl topladığımız ve kullandığımız.",
        "{app} kullanımı, abonelikler ve topluluk özellikleri için kurallar.",
    ),
    "de": (
        "Wie wir Ihre Daten unter KVKK und DSGVO erheben und nutzen.",
        "Regeln für die Nutzung von {app}, Abos und Community-Funktionen.",
    ),
    "fr": (
        "Comment nous collectons et utilisons vos données (KVKK / RGPD).",
        "Règles d’utilisation de {app}, abonnements et communauté.",
    ),
    "es": (
        "Cómo recopilamos y usamos tus datos (KVKK / RGPD).",
        "Normas de uso de {app}, suscripciones y comunidad.",
    ),
    "pt": (
        "Como recolhemos e usamos os seus dados (KVKK / RGPD).",
        "Regras de uso de {app}, assinaturas e comunidade.",
    ),
    "ar": (
        "كيف نجمع بياناتك ونستخدمها وفق KVKK وGDPR.",
        "قواعد استخدام {app} والاشتراكات والمجتمع.",
    ),
    "ru": (
        "Как мы собираем и используем ваши данные (KVKK / GDPR).",
        "Правила использования {app}, подписок и сообщества.",
    ),
    "zh": (
        "我们如何依据 KVKK / GDPR 收集和使用您的数据。",
        "{app} 使用、订阅与社区功能的规则。",
    ),
    "ja": (
        "KVKK / GDPR に基づくデータの収集・利用について。",
        "{app} の利用、サブスクリプション、コミュニティのルール。",
    ),
    "ko": (
        "KVKK / GDPR에 따라 데이터를 수집·이용하는 방법.",
        "{app} 이용, 구독 및 커뮤니티 규칙.",
    ),
    "hi": (
        "KVKK / GDPR के तहत हम आपका डेटा कैसे एकत्र और उपयोग करते हैं।",
        "{app} उपयोग, सदस्यता और समुदाय के नियम।",
    ),
    "id": (
        "Bagaimana kami mengumpulkan dan memakai data Anda (KVKK / GDPR).",
        "Aturan memakai {app}, langganan, dan komunitas.",
    ),
    "vi": (
        "Cách chúng tôi thu thập và dùng dữ liệu (KVKK / GDPR).",
        "Quy tắc dùng {app}, gói đăng ký và cộng đồng.",
    ),
    "bn": (
        "KVKK / GDPR অনুসারে আমরা কীভাবে ডেটা সংগ্রহ ও ব্যবহার করি।",
        "{app} ব্যবহার, সাবস্ক্রিপশন ও কমিউনিটির নিয়ম।",
    ),
    "ur": (
        "ہم KVKK / GDPR کے تحت آپ کا ڈیٹا کیسے جمع اور استعمال کرتے ہیں۔",
        "{app} کے استعمال، سبسکرپشن اور کمیونٹی کے اصول۔",
    ),
    "sw": (
        "Jinsi tunavyokusanya na kutumia data yako (KVKK / GDPR).",
        "Sheria za kutumia {app}, usajili, na jamii.",
    ),
    "mr": (
        "KVKK / GDPR अंतर्गत आम्ही तुमचा डेटा कसा गोळा व वापरतो.",
        "{app} वापर, सदस्यता आणि समुदायाचे नियम.",
    ),
    "te": (
        "KVKK / GDPR కింద మేము మీ డేటాను ఎలా సేకరిస్తాము, ఉపయోగిస్తాము.",
        "{app} వినియోగం, సబ్‌స్క్రిప్షన్, కమ్యూనిటీ నియమాలు.",
    ),
    "ta": (
        "KVKK / GDPR கீழ் உங்கள் தரவை எவ்வாறு சேகரித்து பயன்படுத்துகிறோம்.",
        "{app} பயன்பாடு, சந்தா மற்றும் சமூக விதிகள்.",
    ),
}


APP_BODIES = {
    # legalRequiredBody, permissionSubtitle, permissionRequiredBody
    "en": (
        "{app} cannot be used without accepting the Privacy Policy and Terms of Use. You may exit the app or go back to review the documents.",
        "{app} starts with no permissions granted. We only ask when you use a feature that needs them.",
        "Please confirm the permission notice to use {app}.",
    ),
    "tr": (
        "Gizlilik Politikası ve Kullanım Koşulları kabul edilmeden {app} kullanılamaz. Uygulamadan çıkabilir veya belgeleri incelemek için geri dönebilirsiniz.",
        "{app} hiçbir izin verilmeden başlar. Yalnızca ilgili özelliği kullandığınızda izin isteriz.",
        "{app} kullanmak için izin bildirimini onaylayın.",
    ),
    "de": (
        "{app} kann nicht genutzt werden, ohne die Datenschutzbestimmungen und Nutzungsbedingungen zu akzeptieren. Sie können die App beenden oder zurückgehen, um die Dokumente zu überprüfen.",
        "{app} startet ohne erteilte Berechtigungen. Wir fragen nur, wenn Sie eine Funktion nutzen, die diese benötigt.",
        "Bitte bestätigen Sie den Hinweis zu Berechtigungen, um {app} zu nutzen.",
    ),
    "fr": (
        "{app} ne peut pas être utilisé sans accepter la politique de confidentialité et les conditions d'utilisation. Vous pouvez quitter l'application ou revenir pour consulter les documents.",
        "{app} démarre sans aucune autorisation accordée. Nous demandons uniquement lorsque vous utilisez une fonctionnalité qui en a besoin.",
        "Veuillez confirmer l'avis sur les autorisations pour utiliser {app}.",
    ),
    "es": (
        "{app} no se puede utilizar sin aceptar la Política de privacidad y los Términos de uso. Puede salir de la aplicación o regresar para revisar los documentos.",
        "{app} comienza sin permisos concedidos. Solo preguntamos cuando usas una función que los necesita.",
        "Confirma el aviso de permisos para usar {app}.",
    ),
    "pt": (
        "{app} não pode ser utilizado sem aceitar a Política de Privacidade e os Termos de Uso. Você pode sair do aplicativo ou voltar para revisar os documentos.",
        "{app} começa sem permissões concedidas. Perguntamos apenas quando você usa um recurso que precisa deles.",
        "Confirme o aviso de permissões para usar {app}.",
    ),
    "ar": (
        "لا يمكن استخدام {app} دون قبول سياسة الخصوصية وشروط الاستخدام. يمكنك الخروج من التطبيق أو العودة لمراجعة المستندات.",
        "يبدأ {app} دون منح أي أذونات. نسأل فقط عندما تستخدم ميزة تحتاج إليها.",
        "يرجى تأكيد إشعار الأذونات لاستخدام {app}.",
    ),
    "ru": (
        "{app} нельзя использовать без принятия Политики конфиденциальности и Условий использования. Вы можете выйти из приложения или вернуться для просмотра документов.",
        "{app} запускается без каких-либо разрешений. Мы спрашиваем только тогда, когда вы используете функцию, которая в них нуждается.",
        "Подтвердите уведомление о разрешениях, чтобы использовать {app}.",
    ),
    "zh": (
        "如果不接受隐私政策和使用条款，则无法使用 {app}。您可以退出应用程序或返回查看文档。",
        "{app} 在未授予任何权限的情况下启动。我们仅在您使用需要它们的功能时询问。",
        "请确认权限通知以使用 {app}。",
    ),
    "ja": (
        "{app} は、プライバシー ポリシーと利用規約に同意しない限り使用できません。アプリを終了するか、戻ってドキュメントを確認することができます。",
        "{app} は権限が付与されていない状態で開始されます。必要な機能を使用する場合にのみ尋ねられます。",
        "{app} を使用するには権限の通知を確認してください。",
    ),
    "ko": (
        "{app}은(는) 개인정보 보호정책 및 이용 약관에 동의하지 않고 사용할 수 없습니다. 앱을 종료하거나 돌아가서 문서를 검토할 수 있습니다.",
        "{app}은 권한이 부여되지 않은 상태로 시작됩니다. 필요한 기능을 사용할 때만 묻습니다.",
        "{app}을(를) 사용하려면 권한 안내를 확인해 주세요.",
    ),
    "hi": (
        "गोपनीयता नीति और उपयोग की शर्तों को स्वीकार किए बिना {app} का उपयोग नहीं किया जा सकता है। आप दस्तावेज़ों की समीक्षा करने के लिए ऐप से बाहर निकल सकते हैं या वापस जा सकते हैं।",
        "{app} बिना किसी अनुमति के प्रारंभ होता है। हम केवल तभी पूछते हैं जब आप किसी ऐसी सुविधा का उपयोग करते हैं जिसके लिए उनकी आवश्यकता होती है।",
        "कृपया {app} का उपयोग करने की अनुमति सूचना की पुष्टि करें।",
    ),
    "id": (
        "{app} tidak dapat digunakan tanpa menyetujui Kebijakan Privasi dan Ketentuan Penggunaan. Anda dapat keluar dari aplikasi atau kembali meninjau dokumen.",
        "{app} dimulai tanpa izin yang diberikan. Kami hanya menanyakan saat Anda menggunakan fitur yang memerlukannya.",
        "Harap konfirmasi pemberitahuan izin untuk menggunakan {app}.",
    ),
    "vi": (
        "{app} không thể được sử dụng nếu không chấp nhận Chính sách quyền riêng tư và Điều khoản sử dụng. Bạn có thể thoát ứng dụng hoặc quay lại xem tài liệu.",
        "{app} bắt đầu mà không được cấp quyền. Chúng tôi chỉ hỏi khi bạn sử dụng một tính năng cần đến chúng.",
        "Vui lòng xác nhận thông báo quyền để sử dụng {app}.",
    ),
    "bn": (
        "{app} গোপনীয়তা নীতি এবং ব্যবহারের শর্তাবলী স্বীকার না করে ব্যবহার করা যাবে না। আপনি অ্যাপ থেকে প্রস্থান করতে পারেন বা নথি পর্যালোচনা করতে ফিরে যেতে পারেন।",
        "{app} কোনো অনুমতি ছাড়াই শুরু হয়। আমরা তখনই জিজ্ঞাসা করি যখন আপনি এমন একটি বৈশিষ্ট্য ব্যবহার করেন যার জন্য তাদের প্রয়োজন।",
        "{app} ব্যবহার করতে অনুমতি নোটিশ নিশ্চিত করুন।",
    ),
    "ur": (
        "رازداری کی پالیسی اور استعمال کی شرائط کو قبول کیے بغیر {app} استعمال نہیں کیا جا سکتا۔ آپ ایپ سے باہر نکل سکتے ہیں یا دستاویزات کا جائزہ لینے کے لیے واپس جا سکتے ہیں۔",
        "{app} شروع ہوتا ہے بغیر اجازت کے۔ ہم صرف اس وقت پوچھتے ہیں جب آپ کوئی ایسی خصوصیت استعمال کرتے ہیں جس کی ضرورت ہوتی ہے۔",
        "{app} استعمال کرنے کے لیے اجازت نوٹس کی تصدیق کریں۔",
    ),
    "sw": (
        "{app} haiwezi kutumika bila kukubali Sera ya Faragha na Masharti ya Matumizi. Unaweza kuondoka kwenye programu au kurudi nyuma ili kukagua hati.",
        "{app} huanza bila ruhusa yoyote. Tunauliza tu unapotumia kipengele kinachohitaji.",
        "Tafadhali thibitisha notisi ya ruhusa ili kutumia {app}.",
    ),
    "mr": (
        "गोपनीयता धोरण आणि वापर अटी स्वीकारल्याशिवाय {app} वापरता येणार नाही. तुम्ही ॲपमधून बाहेर पडू शकता किंवा कागदपत्रांचे पुनरावलोकन करण्यासाठी परत जाऊ शकता.",
        "{app} कोणत्याही परवानग्या न देता सुरू होते. जेव्हा तुम्ही त्यांची आवश्यकता असलेले वैशिष्ट्य वापरता तेव्हाच आम्ही विचारतो.",
        "{app} वापरण्यासाठी परवानगी सूचना निश्चित करा.",
    ),
    "te": (
        "గోప్యతా విధానం మరియు ఉపయోగ నిబంధనలను ఆమోదించకుండా {app} ఉపయోగించబడదు. మీరు యాప్ నుండి నిష్క్రమించవచ్చు లేదా పత్రాలను సమీక్షించడానికి తిరిగి వెళ్లవచ్చు.",
        "{app} అనుమతులు మంజూరు చేయకుండా ప్రారంభమవుతుంది. మీకు అవసరమైన ఫీచర్‌ని ఉపయోగించినప్పుడు మాత్రమే మేము అడుగుతాము.",
        "{app} ఉపయోగించడానికి అనుమతి నోటీసును నిర్ధారించండి.",
    ),
    "ta": (
        "தனியுரிமைக் கொள்கை மற்றும் பயன்பாட்டு விதிமுறைகளை ஏற்காமல் {app} ஐப் பயன்படுத்த முடியாது. நீங்கள் பயன்பாட்டிலிருந்து வெளியேறலாம் அல்லது ஆவணங்களை மதிப்பாய்வு செய்ய மீண்டும் செல்லலாம்.",
        "{app} எந்த அனுமதியும் வழங்கப்படாமல் தொடங்குகிறது. உங்களுக்குத் தேவைப்படும் அம்சத்தைப் பயன்படுத்தும் போது மட்டுமே நாங்கள் கேட்கிறோம்.",
        "{app} ஐப் பயன்படுத்த அனுமதி அறிவிப்பை உறுதிப்படுத்தவும்.",
    ),
}


def generalize(text: str) -> str:
    text = text.replace("SuperGarage", "{app}")
    text = text.replace("Super Garage", "{app}")
    text = text.replace("supergarage", "{app}")
    text = re.sub(r"\bGarage\b", "{app}", text)
    text = re.sub(r"\bGaraj\b", "{app}", text)
    text = text.replace("Super {app}", "{app}")
    return text


def dart_escape(text: str) -> str:
    return text.replace("\\", "\\\\").replace("'", "\\'")


def main() -> None:
    lines: list[str] = [
        "// GENERATED from SuperGarage assets/l10n — regenerate via",
        "// tools/generate_launch_consent_catalog.py",
        "// ignore_for_file: lines_longer_than_80_chars",
        "",
        "/// Per-locale first-launch Legal + Permission copy.",
        "///",
        "/// Placeholders: `{app}` → product display name.",
        "abstract final class AfterLaunchConsentCatalog {",
        "  AfterLaunchConsentCatalog._();",
        "",
        "  static const tables = <String, Map<String, String>>{",
    ]

    for lang in LANGS:
        data = json.loads((ROOT / f"{lang}.json").read_text(encoding="utf-8"))
        lines.append(f"    '{lang}': <String, String>{{")
        bodies = APP_BODIES.get(lang, APP_BODIES["en"])
        for garage_key, field in FIELD_MAP.items():
            raw = generalize(str(data.get(garage_key, "")))
            if field in ("privacyPolicyHint", "termsOfUseHint"):
                privacy_h, terms_h = GENERIC_HINTS.get(lang, GENERIC_HINTS["en"])
                raw = privacy_h if field == "privacyPolicyHint" else terms_h
            elif field == "legalRequiredBody":
                raw = bodies[0]
            elif field == "permissionSubtitle":
                raw = bodies[1]
            elif field == "permissionRequiredBody":
                raw = bodies[2]
            lines.append(f"      '{field}': '{dart_escape(raw)}',")
        intro = generalize(str(data.get("legalConsentSubtitle", "")))
        lines.append(f"      'privacyIntro': '{dart_escape(intro)}',")
        lines.append("    },")

    lines.extend(
        [
            "  };",
            "",
            "  static Map<String, String> forLanguage(String languageCode) {",
            "    final code = languageCode.toLowerCase();",
            "    return tables[code] ?? tables['en']!;",
            "  }",
            "}",
            "",
        ]
    )

    OUT.write_text("\n".join(lines), encoding="utf-8")
    text = OUT.read_text(encoding="utf-8")
    print(f"wrote {OUT} ({OUT.stat().st_size} bytes)")
    for bad in ("Garage", "Garaj", "Vehicle Advisor", "OBD"):
        count = text.count(bad)
        if count:
            print(f"WARNING leftover {bad!r}: {count}")


if __name__ == "__main__":
    main()
