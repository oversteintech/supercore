import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const app = 'SuperTest';

  group('AfterLaunchConsentCatalog', () {
    test('covers every AfterSupportedLocales language', () {
      for (final code in AfterSupportedLocales.languageCodes) {
        expect(
          AfterLaunchConsentCatalog.tables.containsKey(code),
          isTrue,
          reason: 'missing launch consent table for $code',
        );
        final table = AfterLaunchConsentCatalog.forLanguage(code);
        expect(table['legalTitle'], isNotEmpty, reason: '$code legalTitle');
        expect(table['permissionTitle'], isNotEmpty, reason: '$code permission');
        expect(table['legalCheckbox'], isNotEmpty);
        expect(table['permissionLocationBody'], isNotEmpty);
      }
    });

    test('Turkish differs from English on core consent keys', () {
      final en = AfterLaunchConsentCatalog.forLanguage('en');
      final tr = AfterLaunchConsentCatalog.forLanguage('tr');
      expect(tr['legalTitle'], isNot(equals(en['legalTitle'])));
      expect(tr['permissionAccept'], isNot(equals(en['permissionAccept'])));
    });

    test('no Garage brand leftovers in catalog bodies', () {
      final joined = AfterLaunchConsentCatalog.tables.values
          .expand((m) => m.values)
          .join('\n');
      expect(joined.contains('Garage'), isFalse);
      expect(joined.contains('Garaj'), isFalse);
      expect(joined.contains('OBD'), isFalse);
    });
  });

  group('AfterLaunchConsentStrings.forLocale', () {
    test('fills {app} placeholder in every locale', () {
      for (final code in AfterSupportedLocales.languageCodes) {
        final strings = AfterLaunchConsentStrings.forLocale(
          appName: app,
          locale: Locale(code),
        );
        expect(strings.legalRequiredBody.contains(app), isTrue, reason: code);
        expect(strings.permissionSubtitle.contains(app), isTrue, reason: code);
        expect(strings.legalRequiredBody.contains('{app}'), isFalse);
      }
    });

    test('de and ja are non-English for legalTitle', () {
      final en = AfterLaunchConsentStrings.en(app);
      final de = AfterLaunchConsentStrings.forLocale(
        appName: app,
        locale: const Locale('de'),
      );
      final ja = AfterLaunchConsentStrings.forLocale(
        appName: app,
        locale: const Locale('ja'),
      );
      expect(de.legalTitle, isNot(equals(en.legalTitle)));
      expect(ja.legalTitle, isNot(equals(en.legalTitle)));
    });
  });
}
