import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AfterAccountDeletionCopy', () {
    test('forLocale picks turkish for tr', () {
      final copy = AfterAccountDeletionCopy.forLocale('tr');
      expect(copy.title, contains('üzgünüz'));
      expect(copy.deleteAnyway, 'Yine de sil');
      expect(copy.goodbyeTitle, contains('😢'));
    });

    test('forLocale falls back to english', () {
      final copy = AfterAccountDeletionCopy.forLocale('de');
      expect(copy.deleteAnyway, 'Delete anyway');
      expect(copy.goodbyeTitle, contains('😢'));
    });
  });
}
