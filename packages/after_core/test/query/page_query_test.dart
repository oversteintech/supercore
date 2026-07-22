import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Page.fromList paginates with integer cursor', () {
    final all = List<int>.generate(10, (i) => i);
    final page0 = Page.fromList(all, const PageQuery(limit: 3));
    expect(page0.items, [0, 1, 2]);
    expect(page0.hasMore, isTrue);
    expect(page0.nextCursor, '3');

    final page1 = Page.fromList(all, PageQuery(cursor: page0.nextCursor, limit: 3));
    expect(page1.items, [3, 4, 5]);
    expect(page1.hasMore, isTrue);

    final last = Page.fromList(all, const PageQuery(cursor: '9', limit: 3));
    expect(last.items, [9]);
    expect(last.hasMore, isFalse);
    expect(last.nextCursor, isNull);
  });

  test('AfterAiContextBlock merge concatenates text', () {
    const a = AfterAiContextBlock(text: 'A', metadata: {'k': 1});
    const b = AfterAiContextBlock(text: 'B', metadata: {'m': 2});
    final m = a.merge(b);
    expect(m.text, contains('A'));
    expect(m.text, contains('B'));
    expect(m.metadata['k'], 1);
    expect(m.metadata['m'], 2);
  });
}
