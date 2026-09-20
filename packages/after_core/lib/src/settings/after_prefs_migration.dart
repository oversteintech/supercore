import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/after_locale_prefs.dart';
import 'after_settings.dart';

/// Copies legacy product prefs into [AfterSettingsKeys] without wiping values.
///
/// Safe to call on every cold start — only fills empty After keys from known
/// legacy aliases so theme / locale / country survive SuperCore migration.
abstract final class AfterPrefsMigration {
  /// Common aliases used across SuperGarage and early family scaffolds.
  static const legacyThemeModeKeys = <String>[
    'theme_mode',
    'app.themeMode',
    'app_theme_mode',
  ];

  static const legacyThemeStyleKeys = <String>[
    'theme_style',
    'app.themeStyle',
    'app_theme_style',
  ];

  static const legacyLocaleKeys = <String>[
    'locale',
    'app.locale',
    'app_locale',
  ];

  static const legacyCountryKeys = <String>[
    'country',
    'app.country',
    'app_country',
    'billing_country',
  ];

  /// Returns how many After keys were populated from legacy sources.
  /// Also seeds sticky locale from the device language when unset.
  static Future<int> migrateSharedSettings(SharedPreferences prefs) async {
    var count = 0;
    count += await _copyFirstString(
      prefs,
      AfterSettingsKeys.themeMode,
      legacyThemeModeKeys,
    );
    count += await _copyFirstString(
      prefs,
      AfterSettingsKeys.themeStyle,
      legacyThemeStyleKeys,
    );
    count += await _copyFirstString(
      prefs,
      AfterSettingsKeys.locale,
      legacyLocaleKeys,
    );
    count += await _copyFirstString(
      prefs,
      AfterSettingsKeys.country,
      legacyCountryKeys,
    );
    final before = prefs.getString(AfterSettingsKeys.locale);
    await AfterLocalePrefs.ensurePersisted(prefs);
    final after = prefs.getString(AfterSettingsKeys.locale);
    if (before == null && after != null) count += 1;
    return count;
  }

  static Future<int> _copyFirstString(
    SharedPreferences prefs,
    String afterKey,
    List<String> legacyKeys,
  ) async {
    final existing = prefs.getString(afterKey);
    if (existing != null && existing.isNotEmpty) return 0;
    for (final key in legacyKeys) {
      final value = prefs.getString(key);
      if (value != null && value.isNotEmpty) {
        await prefs.setString(afterKey, value);
        return 1;
      }
    }
    return 0;
  }
}
