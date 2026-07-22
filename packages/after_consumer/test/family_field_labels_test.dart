import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FamilyFieldLabels.label', () {
    test('english dosage', () {
      expect(FamilyFieldLabels.label('dosage', 'en'), 'Dosage');
    });
    test('turkish dosage', () {
      expect(FamilyFieldLabels.label('dosage', 'tr'), 'Doz');
    });
    test('unsupported locale falls back to english', () {
      expect(FamilyFieldLabels.label('dosage', 'xx'), 'Dosage');
    });
    test('german name is localized', () {
      expect(FamilyFieldLabels.label('name', 'de'), isNot(equals('name')));
    });
    test('unknown key humanized', () {
      expect(FamilyFieldLabels.label('custom_field', 'en'), 'Custom Field');
    });
  });

  group('FamilyFieldLabels.mapFor', () {
    test('maps all keys', () {
      final m = FamilyFieldLabels.mapFor(['name', 'dosage'], 'en');
      expect(m.keys, containsAll(['name', 'dosage']));
      expect(m['name'], 'Name');
    });
    test('empty iterable', () {
      expect(FamilyFieldLabels.mapFor([], 'en'), isEmpty);
    });
    test('turkish titles', () {
      final m = FamilyFieldLabels.mapFor(['title'], 'tr');
      expect(m['title'], 'Başlık');
    });
    test('includes humanized unknown', () {
      final m = FamilyFieldLabels.mapFor(['weird_key'], 'en');
      expect(m['weird_key'], 'Weird Key');
    });
    test('preserves order of keys', () {
      final m = FamilyFieldLabels.mapFor(['b', 'a'], 'en');
      expect(m.keys.toList(), ['b', 'a']);
    });
  });

  group('FamilyFieldLabels.ui', () {
    test('save en', () {
      expect(FamilyFieldLabels.ui('ui.save', 'en'), 'Save');
    });
    test('save tr', () {
      expect(FamilyFieldLabels.ui('ui.save', 'tr'), 'Kaydet');
    });
    test('empty all locales clean', () {
      for (final code in AfterSupportedLocales.languageCodes) {
        final empty = FamilyFieldLabels.ui('ui.empty', code);
        expect(empty.contains('�'), isFalse, reason: code);
        expect(empty, isNotEmpty);
      }
    });
    test('language label exists', () {
      expect(FamilyFieldLabels.ui('ui.language', 'tr'), 'Dil');
    });
    test('delete label exists', () {
      expect(FamilyFieldLabels.ui('ui.delete', 'en'), 'Delete');
    });
  });
}
