import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../settings/after_settings.dart';
import 'after_supported_locales.dart';

/// Shared locale persistence — Garage-parity for every Super App.
///
/// Prefer [AfterSettingsKeys.locale] so family chrome and product catalogs
/// share one key. Apps may still migrate legacy `<appid>.locale` keys via
/// [read] / [migrateLegacy].
///
/// Sticky language policy (all Super Apps):
/// - First launch: seed from device language if supported, else English.
/// - Later launches: never auto-follow device/GPS/SIM — only Settings.
/// - Optional: user can apply country-default language via Settings
///   (“match language to location”).
abstract final class AfterLocalePrefs {
  /// Read persisted language code, or `null` when unset / unsupported.
  static String? read(
    SharedPreferences prefs, {
    String? legacyKey,
  }) {
    final primary = prefs.getString(AfterSettingsKeys.locale);
    if (primary != null && AfterSupportedLocales.isSupported(primary)) {
      return primary;
    }
    if (legacyKey != null) {
      final legacy = prefs.getString(legacyKey);
      if (legacy != null && AfterSupportedLocales.isSupported(legacy)) {
        return legacy;
      }
    }
    return null;
  }

  /// Persist [code] to the platform key (and optional legacy key).
  static Future<void> write(
    SharedPreferences prefs,
    String code, {
    String? legacyKey,
  }) async {
    if (!AfterSupportedLocales.isSupported(code)) return;
    await prefs.setString(AfterSettingsKeys.locale, code);
    if (legacyKey != null) {
      await prefs.setString(legacyKey, code);
    }
  }

  /// Copy a legacy key into [AfterSettingsKeys.locale] once.
  static Future<void> migrateLegacy(
    SharedPreferences prefs,
    String legacyKey,
  ) async {
    if (prefs.containsKey(AfterSettingsKeys.locale)) return;
    final legacy = prefs.getString(legacyKey);
    if (legacy == null || !AfterSupportedLocales.isSupported(legacy)) return;
    await prefs.setString(AfterSettingsKeys.locale, legacy);
  }

  /// Device language → supported code (never GPS / region / SIM).
  static String resolveInitialLanguageCode([Locale? deviceLocale]) {
    final device =
        deviceLocale ?? WidgetsBinding.instance.platformDispatcher.locale;
    return AfterSupportedLocales.resolve(
      device,
      AfterSupportedLocales.locales,
    ).languageCode;
  }

  /// Seed sticky language once on cold start. No-ops when already set.
  ///
  /// Returns the language code every Super App should load for strings.
  static Future<String> ensurePersisted(
    SharedPreferences prefs, {
    Locale? deviceLocale,
    String? legacyKey,
  }) async {
    if (legacyKey != null) {
      await migrateLegacy(prefs, legacyKey);
    }
    var code = read(prefs, legacyKey: legacyKey);
    if (code == null) {
      code = resolveInitialLanguageCode(deviceLocale);
      await write(prefs, code, legacyKey: legacyKey);
    }
    return code;
  }
}
