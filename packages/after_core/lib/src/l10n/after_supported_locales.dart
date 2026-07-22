import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Platform-wide language pack — every Super App MUST support these (≥20).
///
/// Source of truth for factory defaults, MaterialApp [supportedLocales], and
/// language pickers. Native UI chrome (Material/Cupertino) uses Flutter's
/// delegates; product strings fall back to English when a translation is
/// missing.
///
/// Covers major world languages for global distribution (not a single-region
/// product). RTL: [ar], [ur].
///
/// Wire every MaterialApp with:
/// `localizationsDelegates: AfterSupportedLocales.localizationsDelegates`
/// — without Global* delegates, changing locale away from English red-screens
/// because DefaultMaterialLocalizations only supports `en`.
abstract final class AfterSupportedLocales {
  /// Material / Cupertino / Widgets delegates for [languageCodes].
  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  static const languageCodes = <String>[
    'en',
    'zh',
    'hi',
    'es',
    'fr',
    'ar',
    'bn',
    'pt',
    'ru',
    'ur',
    'id',
    'de',
    'ja',
    'sw',
    'mr',
    'te',
    'tr',
    'ta',
    'vi',
    'ko',
  ];

  static const fallbackLanguage = 'en';

  /// Endonyms (language name in its own script).
  static const nativeDisplayNames = <String, String>{
    'en': 'English',
    'zh': '中文',
    'hi': 'हिन्दी',
    'es': 'Español',
    'fr': 'Français',
    'ar': 'العربية',
    'bn': 'বাংলা',
    'pt': 'Português',
    'ru': 'Русский',
    'ur': 'اردو',
    'id': 'Bahasa Indonesia',
    'de': 'Deutsch',
    'ja': '日本語',
    'sw': 'Kiswahili',
    'mr': 'मराठी',
    'te': 'తెలుగు',
    'tr': 'Türkçe',
    'ta': 'தமிழ்',
    'vi': 'Tiếng Việt',
    'ko': '한국어',
  };

  static const rtlLanguageCodes = <String>{'ar', 'ur'};

  static List<Locale> get locales =>
      languageCodes.map(Locale.new).toList(growable: false);

  static bool isSupported(String languageCode) =>
      languageCodes.contains(languageCode);

  static bool isRtl(String languageCode) =>
      rtlLanguageCodes.contains(languageCode);

  static String displayNameFor(String languageCode) =>
      nativeDisplayNames[languageCode] ?? languageCode.toUpperCase();

  /// Resolve device locale to a supported [Locale], else English.
  static Locale resolve(Locale? device, Iterable<Locale> supported) {
    if (device != null) {
      for (final locale in supported) {
        if (locale.languageCode == device.languageCode) {
          return locale;
        }
      }
    }
    return const Locale(fallbackLanguage);
  }

  static Locale? resolutionCallback(
    Locale? locale,
    Iterable<Locale> supported,
  ) =>
      resolve(locale, supported);
}
