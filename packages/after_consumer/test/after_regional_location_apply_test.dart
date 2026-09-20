import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AfterRegionalLocationApply', () {
    test('applyDetection writes country and optional language', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final withoutLang = await AfterRegionalLocationApply.applyDetection(
        prefs: prefs,
        detected: const AfterRegionalLocationResult(
          countryCode: 'TR',
          cityName: 'İstanbul',
        ),
        matchLanguageToCountry: false,
      );
      expect(withoutLang.languageCode, isNull);
      expect(AfterCountryPrefs.read(prefs), 'TR');
      expect(AfterLocalePrefs.read(prefs), isNull);

      final withLang = await AfterRegionalLocationApply.applyDetection(
        prefs: prefs,
        detected: const AfterRegionalLocationResult(countryCode: 'DE'),
        matchLanguageToCountry: true,
      );
      expect(withLang.languageCode, 'de');
      expect(AfterLocalePrefs.read(prefs), 'de');
      expect(AfterCountryPrefs.read(prefs), 'DE');
    });

    test('match language pref round-trips', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      expect(AfterRegionalLocationApply.readMatchLanguage(prefs), isFalse);
      await AfterRegionalLocationApply.writeMatchLanguage(prefs, true);
      expect(AfterRegionalLocationApply.readMatchLanguage(prefs), isTrue);
    });
  });
}
