import 'package:after_consumer/after_consumer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FamilyMapRecord', () {
    test('title prefers title field', () {
      const r = FamilyMapRecord(
        id: '1',
        fields: {'title': 'T', 'name': 'N'},
      );
      expect(r.title, 'T');
    });

    test('title falls back to name', () {
      const r = FamilyMapRecord(id: '1', fields: {'name': 'N'});
      expect(r.title, 'N');
    });

    test('title falls back to id when empty', () {
      const r = FamilyMapRecord(id: 'abc', fields: {});
      expect(r.title, 'abc');
    });

    test('title uses first value when no title/name', () {
      const r = FamilyMapRecord(id: '1', fields: {'qty': '3'});
      expect(r.title, '3');
    });

    test('json round-trip', () {
      const r = FamilyMapRecord(
        id: '9',
        fields: {'title': 'Hello', 'notes': 'n'},
      );
      final again = FamilyMapRecord.fromJson(r.toJson());
      expect(again.id, '9');
      expect(again.fields['notes'], 'n');
    });

    test('copyWith replaces fields', () {
      const r = FamilyMapRecord(id: '1', fields: {'a': '1'});
      final next = r.copyWith(fields: {'a': '2'});
      expect(next.fields['a'], '2');
      expect(next.id, '1');
    });

    test('fromJson coerces field values to strings', () {
      final r = FamilyMapRecord.fromJson(const {
        'id': 7,
        'fields': {'n': 3},
      });
      expect(r.id, '7');
      expect(r.fields['n'], '3');
    });
  });
}
