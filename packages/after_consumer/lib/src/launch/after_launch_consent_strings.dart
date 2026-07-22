import 'package:flutter/widgets.dart';

/// Built-in EN/TR copy for first-launch legal + permission screens.
class AfterLaunchConsentStrings {
  const AfterLaunchConsentStrings({
    required this.appName,
    required this.legalTitle,
    required this.legalSubtitle,
    required this.legalCheckbox,
    required this.legalAccept,
    required this.legalDecline,
    required this.legalRequiredTitle,
    required this.legalRequiredBody,
    required this.legalExitApp,
    required this.privacyPolicy,
    required this.privacyPolicyHint,
    required this.termsOfUse,
    required this.termsOfUseHint,
    required this.privacyIntro,
    required this.cancel,
    required this.permissionTitle,
    required this.permissionSubtitle,
    required this.permissionCheckbox,
    required this.permissionAccept,
    required this.permissionFooter,
    required this.permissionRequiredTitle,
    required this.permissionRequiredBody,
    required this.permissionLocation,
    required this.permissionLocationBody,
    required this.permissionNotifications,
    required this.permissionNotificationsBody,
    required this.permissionPhotos,
    required this.permissionPhotosBody,
    required this.permissionCamera,
    required this.permissionCameraBody,
  });

  final String appName;
  final String legalTitle;
  final String legalSubtitle;
  final String legalCheckbox;
  final String legalAccept;
  final String legalDecline;
  final String legalRequiredTitle;
  final String legalRequiredBody;
  final String legalExitApp;
  final String privacyPolicy;
  final String privacyPolicyHint;
  final String termsOfUse;
  final String termsOfUseHint;
  final String privacyIntro;
  final String cancel;
  final String permissionTitle;
  final String permissionSubtitle;
  final String permissionCheckbox;
  final String permissionAccept;
  final String permissionFooter;
  final String permissionRequiredTitle;
  final String permissionRequiredBody;
  final String permissionLocation;
  final String permissionLocationBody;
  final String permissionNotifications;
  final String permissionNotificationsBody;
  final String permissionPhotos;
  final String permissionPhotosBody;
  final String permissionCamera;
  final String permissionCameraBody;

  factory AfterLaunchConsentStrings.forLocale({
    required String appName,
    Locale? locale,
  }) {
    final language = (locale?.languageCode ?? 'en').toLowerCase();
    if (language == 'tr') {
      return AfterLaunchConsentStrings.tr(appName);
    }
    return AfterLaunchConsentStrings.en(appName);
  }

  factory AfterLaunchConsentStrings.en(String appName) {
    return AfterLaunchConsentStrings(
      appName: appName,
      legalTitle: 'Privacy & terms',
      legalSubtitle:
          'Before you continue, please read our Privacy Policy and Terms of Use. '
          'By accepting, you consent to data processing under KVKK and GDPR as described there.',
      legalCheckbox:
          'I have read and accept the Privacy Policy and Terms of Use.',
      legalAccept: 'Accept & continue',
      legalDecline: 'Decline',
      legalRequiredTitle: 'Consent required',
      legalRequiredBody:
          '$appName cannot be used without accepting the Privacy Policy and Terms of Use. '
          'You may exit the app or go back to review the documents.',
      legalExitApp: 'Exit app',
      privacyPolicy: 'Privacy Policy',
      privacyPolicyHint: 'How we collect and use your data',
      termsOfUse: 'Terms of Use',
      termsOfUseHint: 'Rules for using $appName',
      privacyIntro:
          'We process account, device, and usage data to operate $appName, '
          'personalize features, and improve reliability. Location is used only '
          'for features you explicitly start (nearby search, regional setup). '
          'You can review the full Privacy Policy and Terms below.',
      cancel: 'Cancel',
      permissionTitle: 'App permissions',
      permissionSubtitle:
          '$appName starts with no permissions granted. We only ask when you '
          'use a feature that needs them.',
      permissionCheckbox:
          'I understand — ask me before any permission is requested.',
      permissionAccept: 'Continue',
      permissionFooter:
          'You can review or change permissions anytime in system Settings.',
      permissionRequiredTitle: 'Permission notice required',
      permissionRequiredBody:
          'Please confirm the permission notice to use $appName.',
      permissionLocation: 'Location',
      permissionLocationBody:
          'Nearby services and regional setup — only when you tap find nearby '
          'or detect country.',
      permissionNotifications: 'Notifications',
      permissionNotificationsBody:
          'Reminders and alerts — only when you turn on push notifications.',
      permissionPhotos: 'Photos',
      permissionPhotosBody:
          'Profile and document photos — only when you pick from gallery.',
      permissionCamera: 'Camera',
      permissionCameraBody:
          'Taking photos in the app — only when you open the camera.',
    );
  }

  factory AfterLaunchConsentStrings.tr(String appName) {
    return AfterLaunchConsentStrings(
      appName: appName,
      legalTitle: 'Gizlilik ve koşullar',
      legalSubtitle:
          'Devam etmeden önce Gizlilik Politikası ve Kullanım Koşullarını okuyun. '
          'Kabul ederek KVKK ve GDPR kapsamında açıklanan veri işlemeye onay verirsiniz.',
      legalCheckbox:
          'Gizlilik Politikası ve Kullanım Koşullarını okudum ve kabul ediyorum.',
      legalAccept: 'Kabul et ve devam et',
      legalDecline: 'Reddet',
      legalRequiredTitle: 'Onay gerekli',
      legalRequiredBody:
          '$appName, Gizlilik Politikası ve Kullanım Koşulları kabul edilmeden kullanılamaz. '
          'Uygulamadan çıkabilir veya belgelere geri dönebilirsiniz.',
      legalExitApp: 'Uygulamadan çık',
      privacyPolicy: 'Gizlilik Politikası',
      privacyPolicyHint: 'Verilerinizi nasıl topluyor ve kullanıyoruz',
      termsOfUse: 'Kullanım Koşulları',
      termsOfUseHint: '$appName kullanım kuralları',
      privacyIntro:
          '$appName’i işletmek, özellikleri kişiselleştirmek ve güvenilirliği artırmak '
          'için hesap, cihaz ve kullanım verilerini işleriz. Konum yalnızca sizin '
          'başlattığınız özellikler için kullanılır (yakındaki yerler, bölgesel kurulum). '
          'Tam metinleri aşağıdan inceleyebilirsiniz.',
      cancel: 'İptal',
      permissionTitle: 'Uygulama izinleri',
      permissionSubtitle:
          '$appName hiçbir izin verilmeden başlar. Yalnızca ihtiyaç duyan bir '
          'özelliği kullandığınızda sorarız.',
      permissionCheckbox:
          'Anladım — herhangi bir izin istenmeden önce bana sorulsun.',
      permissionAccept: 'Devam',
      permissionFooter:
          'İzinleri istediğiniz zaman sistem Ayarları’ndan değiştirebilirsiniz.',
      permissionRequiredTitle: 'İzin bildirimi gerekli',
      permissionRequiredBody:
          '$appName’i kullanmak için izin bildirimini onaylayın.',
      permissionLocation: 'Konum',
      permissionLocationBody:
          'Yakındaki hizmetler ve bölgesel kurulum — yalnızca yakındakileri bul '
          'veya ülke algıla’ya dokunduğunuzda.',
      permissionNotifications: 'Bildirimler',
      permissionNotificationsBody:
          'Hatırlatmalar ve uyarılar — yalnızca anlık bildirimleri açtığınızda.',
      permissionPhotos: 'Fotoğraflar',
      permissionPhotosBody:
          'Profil ve belge fotoğrafları — yalnızca galeriden seçtiğinizde.',
      permissionCamera: 'Kamera',
      permissionCameraBody:
          'Uygulama içi fotoğraf — yalnızca kamerayı açtığınızda.',
    );
  }
}
