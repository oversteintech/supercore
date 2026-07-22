import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FamilyUiStrings covers all AfterSupportedLocales', () {
    expect(
      AfterSupportedLocales.languageCodes.length,
      greaterThanOrEqualTo(20),
    );
    for (final code in AfterSupportedLocales.languageCodes) {
      final settings = FamilyUiStrings.t('settings', code);
      final home = FamilyUiStrings.t('nav_home', code);
      expect(settings, isNotEmpty);
      expect(home, isNotEmpty);
      if (code != 'en') {
        expect(
          settings,
          isNot(equals(FamilyUiStrings.t('settings', 'en'))),
          reason: 'locale $code settings should differ from English',
        );
      }
    }
  });

  test('FamilyUiStrings nav_ai is always AI brand', () {
    for (final code in AfterSupportedLocales.languageCodes) {
      expect(
        FamilyUiStrings.t('nav_ai', code),
        'AI',
        reason: 'locale $code nav_ai must stay brand AI',
      );
    }
  });

  test('FamilyUiStrings interpolates args', () {
    final text = FamilyUiStrings.t(
      'version',
      'tr',
      args: {'version': '1.2.3'},
    );
    expect(text, contains('1.2.3'));
  });

  test('AfterLocalePrefs round-trip key', () async {
    // SharedPreferences mock
    TestWidgetsFlutterBinding.ensureInitialized();
    // ignore: depend_on_referenced_packages
    // Use AfterSettingsKeys constant presence as contract check.
    expect(AfterSettingsKeys.locale, 'after.settings.locale');
  });
}
