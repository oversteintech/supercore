import 'after_supported_countries.dart';
import 'after_supported_locales.dart';

/// Language + currency defaults for a supported country (Garage-parity).
class AfterRegionalDefaults {
  const AfterRegionalDefaults({
    required this.languageCode,
    required this.currencyCode,
  });

  final String languageCode;
  final String currencyCode;
}

/// Cross-app regional defaults keyed by ISO country.
///
/// Product-specific units (fuel, distance, map centers) stay in each Super App.
abstract final class AfterRegionalPreferences {
  AfterRegionalPreferences._();

  static AfterRegionalDefaults defaultsForCountry(String countryCode) {
    final code = AfterSupportedCountries.normalize(countryCode) ?? 'US';
    return AfterRegionalDefaults(
      languageCode: languageForCountry(code),
      currencyCode: currencyForCountry(code),
    );
  }

  static String languageForCountry(String? countryCode) {
    final code = AfterSupportedCountries.normalize(countryCode) ?? 'US';
    final language = switch (code) {
      'TR' => 'tr',
      'DE' => 'de',
      'FR' => 'fr',
      'IT' => 'it',
      'ES' => 'es',
      'BR' => 'pt',
      'RU' => 'ru',
      'KR' => 'ko',
      'AE' || 'SA' => 'ar',
      'JP' => 'ja',
      'CN' => 'zh',
      'IN' => 'hi',
      _ => 'en',
    };
    return AfterSupportedLocales.isSupported(language)
        ? language
        : AfterSupportedLocales.fallbackLanguage;
  }

  static String currencyForCountry(String? countryCode) {
    final code = AfterSupportedCountries.normalize(countryCode);
    if (code == null) {
      return 'USD';
    }
    return switch (code) {
      'US' => 'USD',
      'TR' => 'TRY',
      'DE' || 'FR' || 'IT' || 'ES' || 'NL' => 'EUR',
      'GB' => 'GBP',
      'AE' => 'AED',
      'SA' => 'SAR',
      'JP' => 'JPY',
      'CN' => 'CNY',
      'IN' => 'INR',
      'BR' => 'BRL',
      'RU' => 'RUB',
      'PL' => 'PLN',
      'SE' => 'SEK',
      'NO' => 'NOK',
      'AU' => 'AUD',
      'CA' => 'CAD',
      'KR' => 'KRW',
      _ => 'USD',
    };
  }
}
