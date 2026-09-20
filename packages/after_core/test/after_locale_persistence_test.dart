import 'package:after_core/after_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AfterLocalePrefs.ensurePersisted', () {
    test('seeds device language once', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final code = await AfterLocalePrefs.ensurePersisted(
        prefs,
        deviceLocale: const Locale('tr'),
      );
      expect(code, 'tr');
      expect(prefs.getString(AfterSettingsKeys.locale), 'tr');

      final again = await AfterLocalePrefs.ensurePersisted(
        prefs,
        deviceLocale: const Locale('de'),
      );
      expect(again, 'tr');
    });

    test('falls back to English for unsupported device language', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final code = await AfterLocalePrefs.ensurePersisted(
        prefs,
        deviceLocale: const Locale('xx'),
      );
      expect(code, 'en');
    });
  });

  group('AfterRegionalPreferences.languageForCountry', () {
    test('maps TR → tr and unknown → en', () {
      expect(AfterRegionalPreferences.languageForCountry('TR'), 'tr');
      expect(AfterRegionalPreferences.languageForCountry('DE'), 'de');
      expect(AfterRegionalPreferences.languageForCountry('ZZ'), 'en');
    });
  });
}
