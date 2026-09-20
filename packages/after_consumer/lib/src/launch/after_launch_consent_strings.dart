import 'package:flutter/widgets.dart';

import 'after_launch_consent_catalog.dart';

/// First-launch Legal + Permission copy for every Super App.
///
/// Sourced from [AfterLaunchConsentCatalog] (all 20 [AfterSupportedLocales]).
/// Placeholders `{app}` are replaced with [appName].
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

  /// Resolve copy for [locale] (falls back to English).
  factory AfterLaunchConsentStrings.forLocale({
    required String appName,
    Locale? locale,
  }) {
    final language = (locale?.languageCode ?? 'en').toLowerCase();
    return AfterLaunchConsentStrings.fromCatalog(
      appName: appName,
      languageCode: language,
    );
  }

  factory AfterLaunchConsentStrings.fromCatalog({
    required String appName,
    required String languageCode,
  }) {
    final table = AfterLaunchConsentCatalog.forLanguage(languageCode);
    String t(String key) => _fill(table[key] ?? '', appName);
    return AfterLaunchConsentStrings(
      appName: appName,
      legalTitle: t('legalTitle'),
      legalSubtitle: t('legalSubtitle'),
      legalCheckbox: t('legalCheckbox'),
      legalAccept: t('legalAccept'),
      legalDecline: t('legalDecline'),
      legalRequiredTitle: t('legalRequiredTitle'),
      legalRequiredBody: t('legalRequiredBody'),
      legalExitApp: t('legalExitApp'),
      privacyPolicy: t('privacyPolicy'),
      privacyPolicyHint: t('privacyPolicyHint'),
      termsOfUse: t('termsOfUse'),
      termsOfUseHint: t('termsOfUseHint'),
      privacyIntro: t('privacyIntro'),
      cancel: t('cancel'),
      permissionTitle: t('permissionTitle'),
      permissionSubtitle: t('permissionSubtitle'),
      permissionCheckbox: t('permissionCheckbox'),
      permissionAccept: t('permissionAccept'),
      permissionFooter: t('permissionFooter'),
      permissionRequiredTitle: t('permissionRequiredTitle'),
      permissionRequiredBody: t('permissionRequiredBody'),
      permissionLocation: t('permissionLocation'),
      permissionLocationBody: t('permissionLocationBody'),
      permissionNotifications: t('permissionNotifications'),
      permissionNotificationsBody: t('permissionNotificationsBody'),
      permissionPhotos: t('permissionPhotos'),
      permissionPhotosBody: t('permissionPhotosBody'),
      permissionCamera: t('permissionCamera'),
      permissionCameraBody: t('permissionCameraBody'),
    );
  }

  /// Back-compat: English table.
  factory AfterLaunchConsentStrings.en(String appName) =>
      AfterLaunchConsentStrings.fromCatalog(
        appName: appName,
        languageCode: 'en',
      );

  /// Back-compat: Turkish table.
  factory AfterLaunchConsentStrings.tr(String appName) =>
      AfterLaunchConsentStrings.fromCatalog(
        appName: appName,
        languageCode: 'tr',
      );

  static String _fill(String template, String appName) {
    return template
        .replaceAll('{app}', appName)
        .replaceAll('{appName}', appName);
  }
}
