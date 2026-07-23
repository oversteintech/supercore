import 'package:shared_preferences/shared_preferences.dart';

import '../settings/after_settings.dart';
import 'after_supported_countries.dart';

/// Shared country / region persistence — Garage-parity for every Super App.
///
/// Prefer [AfterSettingsKeys.country]. Apps may migrate legacy keys via
/// [read] / [migrateLegacy].
abstract final class AfterCountryPrefs {
  /// Read persisted ISO country code, or `null` when unset / unsupported.
  static String? read(
    SharedPreferences prefs, {
    String? legacyKey,
  }) {
    final primary = AfterSupportedCountries.normalize(
      prefs.getString(AfterSettingsKeys.country),
    );
    if (primary != null && AfterSupportedCountries.isSupported(primary)) {
      return primary;
    }
    if (legacyKey != null) {
      final legacy = AfterSupportedCountries.normalize(
        prefs.getString(legacyKey),
      );
      if (legacy != null && AfterSupportedCountries.isSupported(legacy)) {
        return legacy;
      }
    }
    return null;
  }

  /// Persist [code] to the platform key (and optional legacy key).
  /// Pass `null` / empty to clear.
  static Future<void> write(
    SharedPreferences prefs,
    String? code, {
    String? legacyKey,
  }) async {
    final normalized = AfterSupportedCountries.normalize(code);
    if (normalized == null || !AfterSupportedCountries.isSupported(normalized)) {
      await prefs.remove(AfterSettingsKeys.country);
      if (legacyKey != null) {
        await prefs.remove(legacyKey);
      }
      return;
    }
    await prefs.setString(AfterSettingsKeys.country, normalized);
    if (legacyKey != null) {
      await prefs.setString(legacyKey, normalized);
    }
  }

  /// Copy a legacy key into [AfterSettingsKeys.country] once.
  static Future<void> migrateLegacy(
    SharedPreferences prefs,
    String legacyKey,
  ) async {
    if (prefs.containsKey(AfterSettingsKeys.country)) return;
    final legacy = AfterSupportedCountries.normalize(
      prefs.getString(legacyKey),
    );
    if (legacy == null || !AfterSupportedCountries.isSupported(legacy)) return;
    await prefs.setString(AfterSettingsKeys.country, legacy);
  }
}
