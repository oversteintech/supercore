import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryAfterSearch', () {
    test('returns empty when query is blank', () async {
      final port = InMemoryAfterSearch(seed: [
        InMemorySearchIndex(id: 'tasks', labelKey: 'search.tasks'),
      ]);
      final hits = await port.search(const SearchQuery(text: '   '));
      expect(hits, isEmpty);
    });

    test('fans out across registered indexes and sorts by score', () async {
      final tasks = InMemorySearchIndex(
        id: 'tasks',
        labelKey: 'search.tasks',
        seed: const [
          SearchHit(
            id: 't1',
            indexId: 'tasks',
            title: 'Runway inspection',
            score: 0.7,
          ),
          SearchHit(
            id: 't2',
            indexId: 'tasks',
            title: 'Cabin cleaning',
            score: 0.1,
          ),
        ],
      );
      final flights = InMemorySearchIndex(
        id: 'flights',
        labelKey: 'search.flights',
        seed: const [
          SearchHit(
            id: 'f1',
            indexId: 'flights',
            title: 'TK1 Istanbul inbound Ankara',
            score: 0.9,
          ),
        ],
      );
      final port = InMemoryAfterSearch(seed: [tasks, flights]);

      final hits = await port.search(const SearchQuery(text: 'in'));
      expect(hits.map((h) => h.id).toList(), ['f1', 't1', 't2']);
    });

    test('respects index filter and limit', () async {
      final tasks = InMemorySearchIndex(
        id: 'tasks',
        labelKey: 'search.tasks',
        seed: const [
          SearchHit(id: 't1', indexId: 'tasks', title: 'Alpha', score: 1),
          SearchHit(id: 't2', indexId: 'tasks', title: 'Alpha two', score: 0.5),
          SearchHit(id: 't3', indexId: 'tasks', title: 'Beta', score: 0.5),
        ],
      );
      final port = InMemoryAfterSearch(seed: [tasks]);

      final hits = await port.search(
        const SearchQuery(text: 'alpha', indexes: {'tasks'}, limit: 1),
      );
      expect(hits, hasLength(1));
      expect(hits.first.id, 't1');
    });

    test('register / unregister updates index catalogue', () {
      final port = InMemoryAfterSearch();
      port.register(InMemorySearchIndex(id: 'a', labelKey: 'a'));
      port.register(InMemorySearchIndex(id: 'b', labelKey: 'b'));
      expect(port.indexIds, containsAll({'a', 'b'}));
      port.unregister('a');
      expect(port.indexIds, {'b'});
    });
  });
}
