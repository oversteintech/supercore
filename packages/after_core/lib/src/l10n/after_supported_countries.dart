import 'package:flutter/widgets.dart';

/// ISO country entry for Region & Language pickers across Super Apps.
class AfterSupportedCountry {
  const AfterSupportedCountry(this.code, this.name);

  /// ISO 3166-1 alpha-2 (e.g. `TR`, `US`).
  final String code;

  /// English display name.
  final String name;
}

/// Shared country catalog — source of truth for every Super App region picker.
///
/// Lifted from Garage / family chrome so locale+country menus stay identical.
abstract final class AfterSupportedCountries {
  static const all = <AfterSupportedCountry>[
    AfterSupportedCountry('US', 'United States'),
    AfterSupportedCountry('TR', 'Türkiye'),
    AfterSupportedCountry('DE', 'Germany'),
    AfterSupportedCountry('FR', 'France'),
    AfterSupportedCountry('IT', 'Italy'),
    AfterSupportedCountry('ES', 'Spain'),
    AfterSupportedCountry('GB', 'United Kingdom'),
    AfterSupportedCountry('NL', 'Netherlands'),
    AfterSupportedCountry('AE', 'United Arab Emirates'),
    AfterSupportedCountry('SA', 'Saudi Arabia'),
    AfterSupportedCountry('JP', 'Japan'),
    AfterSupportedCountry('CN', 'China'),
    AfterSupportedCountry('IN', 'India'),
    AfterSupportedCountry('BR', 'Brazil'),
    AfterSupportedCountry('RU', 'Russia'),
    AfterSupportedCountry('PL', 'Poland'),
    AfterSupportedCountry('SE', 'Sweden'),
    AfterSupportedCountry('NO', 'Norway'),
    AfterSupportedCountry('AU', 'Australia'),
    AfterSupportedCountry('CA', 'Canada'),
    AfterSupportedCountry('KR', 'South Korea'),
  ];

  static final Set<String> _codes = {
    for (final c in all) c.code,
  };

  static bool isSupported(String? code) {
    final normalized = normalize(code);
    return normalized != null && _codes.contains(normalized);
  }

  /// Normalize to ISO alpha-2; maps `UK` → `GB`. Returns null if invalid.
  static String? normalize(String? code) {
    if (code == null || code.trim().isEmpty) {
      return null;
    }
    var upper = code.trim().toUpperCase();
    if (upper == 'UK') {
      upper = 'GB';
    }
    if (RegExp(r'^[A-Z]{2}$').hasMatch(upper)) {
      return upper;
    }
    return null;
  }

  static String displayNameFor(String? code) {
    final normalized = normalize(code);
    if (normalized == null) {
      return code?.toUpperCase() ?? '';
    }
    for (final country in all) {
      if (country.code == normalized) {
        return country.name;
      }
    }
    return normalized;
  }

  /// Platform dispatcher country when it matches the catalog.
  static String? fromPlatformLocale() {
    final platformCountry =
        WidgetsBinding.instance.platformDispatcher.locale.countryCode;
    final normalized = normalize(platformCountry);
    if (normalized != null && _codes.contains(normalized)) {
      return normalized;
    }
    return null;
  }
}
