import 'package:after_core/after_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'after_regional_location.dart';

/// Result of applying a detected region (country ± language).
class AfterRegionalApplyResult {
  const AfterRegionalApplyResult({
    required this.countryCode,
    this.cityName,
    this.districtName,
    this.languageCode,
  });

  final String countryCode;
  final String? cityName;
  final String? districtName;

  /// Set when [matchLanguageToCountry] was true.
  final String? languageCode;
}

/// Shared apply helpers for location → country / optional language.
abstract final class AfterRegionalLocationApply {
  /// Prefs key: user opted in to match app language to detected country.
  static const matchLanguagePrefKey =
      'after.settings.region.matchLanguageToCountry';

  static bool readMatchLanguage(SharedPreferences prefs) =>
      prefs.getBool(matchLanguagePrefKey) ?? false;

  static Future<void> writeMatchLanguage(
    SharedPreferences prefs,
    bool value,
  ) =>
      prefs.setBool(matchLanguagePrefKey, value);

  /// Persist country and optionally language from [AfterRegionalPreferences].
  static Future<AfterRegionalApplyResult> applyDetection({
    required SharedPreferences prefs,
    required AfterRegionalLocationResult detected,
    required bool matchLanguageToCountry,
    String? countryLegacyKey,
    String? localeLegacyKey,
  }) async {
    await AfterCountryPrefs.write(
      prefs,
      detected.countryCode,
      legacyKey: countryLegacyKey,
    );

    String? language;
    if (matchLanguageToCountry) {
      language = AfterRegionalPreferences.languageForCountry(
        detected.countryCode,
      );
      await AfterLocalePrefs.write(
        prefs,
        language,
        legacyKey: localeLegacyKey,
      );
    }

    return AfterRegionalApplyResult(
      countryCode: detected.countryCode,
      cityName: detected.cityName,
      districtName: detected.districtName,
      languageCode: language,
    );
  }

  /// Soft-seed country once after OS location grant (never rewrites language).
  static Future<String?> seedCountryIfEmpty({
    required SharedPreferences prefs,
    String? countryLegacyKey,
  }) async {
    final existing = AfterCountryPrefs.read(
      prefs,
      legacyKey: countryLegacyKey,
    );
    if (existing != null && existing.isNotEmpty) return null;

    final detected =
        await AfterRegionalLocationService.detectRegionalLocation();
    if (detected == null) return null;

    await AfterCountryPrefs.write(
      prefs,
      detected.countryCode,
      legacyKey: countryLegacyKey,
    );
    return detected.countryCode;
  }
}
