import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('platform language pack has at least 20 locales', () {
    expect(AfterSupportedLocales.languageCodes.length, greaterThanOrEqualTo(20));
    expect(
      AfterSupportedLocales.languageCodes.toSet().length,
      AfterSupportedLocales.languageCodes.length,
    );
    expect(AfterSupportedLocales.languageCodes, contains('en'));
    expect(AfterSupportedLocales.languageCodes, contains('tr'));
    expect(AfterSupportedLocales.languageCodes, contains('ar'));
  });

  test('resolve falls back to English for unsupported device locale', () {
    final resolved = AfterSupportedLocales.resolve(
      const Locale('xx'),
      AfterSupportedLocales.locales,
    );
    expect(resolved.languageCode, 'en');
  });

  test('resolve matches language code', () {
    final resolved = AfterSupportedLocales.resolve(
      const Locale('tr', 'TR'),
      AfterSupportedLocales.locales,
    );
    expect(resolved.languageCode, 'tr');
  });

  test('RTL set includes Arabic and Urdu', () {
    expect(AfterSupportedLocales.isRtl('ar'), isTrue);
    expect(AfterSupportedLocales.isRtl('ur'), isTrue);
    expect(AfterSupportedLocales.isRtl('en'), isFalse);
  });

  test('localizationsDelegates include Global Material/Widgets/Cupertino', () {
    expect(AfterSupportedLocales.localizationsDelegates, hasLength(3));
  });
}
