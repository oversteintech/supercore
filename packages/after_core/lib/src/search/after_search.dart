import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// Query issued against [AfterSearchPort]. Verticals + OS modules
/// register [SearchIndex]es; a single query fans out across them.
@immutable
class SearchQuery {
  const SearchQuery({
    required this.text,
    this.indexes = const <String>{},
    this.limit = 20,
    this.filters = const <String, Object?>{},
  });

  /// Free-form search text.
  final String text;

  /// Optional set of index ids to restrict the search to. Empty = all.
  final Set<String> indexes;

  /// Max number of hits to return across all indexes.
  final int limit;

  /// Structured filters (e.g. `{ 'status': 'open' }`).
  final Map<String, Object?> filters;

  bool get isEmpty => text.trim().isEmpty;
}

/// A single search hit returned by an index.
@immutable
class SearchHit {
  const SearchHit({
    required this.id,
    required this.indexId,
    required this.title,
    this.subtitle,
    this.score = 0,
    this.deepLink,
    this.data = const <String, Object?>{},
  });

  /// Id of the underlying entity (task id, patient id, gate id, …).
  final String id;

  /// Id of the index this hit came from.
  final String indexId;

  final String title;
  final String? subtitle;

  /// Relevance score — higher is better. Used to sort combined results.
  final double score;

  /// Optional deep link into the app (`app://tasks/123`).
  final String? deepLink;

  /// Extra structured data (kind, tags, timestamps, badges).
  final Map<String, Object?> data;
}

/// A registered search-able collection. Each OS module and each
/// vertical feature registers one — the port is intentionally simple so
/// mocks and remote adapters share the same shape.
abstract class SearchIndex {
  /// Stable id (`tasks`, `patients`, `flights`, `documents`).
  String get id;

  /// Human-readable label rendered in the search UI (i18n key).
  String get labelKey;

  /// Run the query against this index only.
  Future<List<SearchHit>> search(SearchQuery query);
}

/// Cross-index search port. Verticals register their indexes at
/// bootstrap; the shell renders a unified search screen powered by
/// [search].
abstract class AfterSearchPort {
  /// Register a new index (idempotent by `index.id`).
  void register(SearchIndex index);

  /// Unregister a previously registered index.
  void unregister(String indexId);

  /// Every registered index id.
  Set<String> get indexIds;

  /// Fan out across all matching indexes and return a merged, sorted
  /// list of hits (highest score first, capped at [SearchQuery.limit]).
  Future<List<SearchHit>> search(SearchQuery query);
}

/// Default implementation. Delegates to registered [SearchIndex]es and
/// merges/sorts results by score.
class InMemoryAfterSearch implements AfterSearchPort {
  InMemoryAfterSearch({Iterable<SearchIndex>? seed}) {
    if (seed != null) {
      for (final index in seed) {
        register(index);
      }
    }
  }

  final Map<String, SearchIndex> _indexes = <String, SearchIndex>{};

  @override
  void register(SearchIndex index) {
    _indexes[index.id] = index;
  }

  @override
  void unregister(String indexId) {
    _indexes.remove(indexId);
  }

  @override
  Set<String> get indexIds => Set<String>.unmodifiable(_indexes.keys);

  @override
  Future<List<SearchHit>> search(SearchQuery query) async {
    if (query.isEmpty) return const <SearchHit>[];
    final targets = query.indexes.isEmpty
        ? _indexes.values
        : _indexes.entries
            .where((e) => query.indexes.contains(e.key))
            .map((e) => e.value);
    final results = <SearchHit>[];
    for (final index in targets) {
      results.addAll(await index.search(query));
    }
    results.sort((a, b) => b.score.compareTo(a.score));
    if (results.length > query.limit) {
      return List<SearchHit>.unmodifiable(results.take(query.limit));
    }
    return List<SearchHit>.unmodifiable(results);
  }
}

/// Handy index that keeps entries in memory. Verticals use this to
/// expose static / mock catalogs (feature ids, screens, docs).
class InMemorySearchIndex implements SearchIndex {
  InMemorySearchIndex({
    required this.id,
    required this.labelKey,
    List<SearchHit>? seed,
  }) : _hits = List<SearchHit>.from(seed ?? const <SearchHit>[]);

  @override
  final String id;

  @override
  final String labelKey;

  final List<SearchHit> _hits;

  void add(SearchHit hit) => _hits.add(hit);

  void clear() => _hits.clear();

  @override
  Future<List<SearchHit>> search(SearchQuery query) async {
    final needle = query.text.trim().toLowerCase();
    if (needle.isEmpty) return const <SearchHit>[];
    return _hits.where((h) {
      final t = h.title.toLowerCase();
      final s = h.subtitle?.toLowerCase() ?? '';
      return t.contains(needle) || s.contains(needle);
    }).toList(growable: false);
  }
}

/// Provider for the app-wide search port. Verticals override with
/// pre-registered indexes at bootstrap.
final afterSearchPortProvider = Provider<AfterSearchPort>((ref) {
  return InMemoryAfterSearch();
});
