import 'package:meta/meta.dart';

/// Cursor-based list query (ADR-003).
@immutable
class PageQuery {
  const PageQuery({
    this.cursor,
    this.limit = 50,
  }) : assert(limit > 0, 'limit must be positive');

  final String? cursor;
  final int limit;

  PageQuery copyWith({String? cursor, int? limit}) => PageQuery(
        cursor: cursor ?? this.cursor,
        limit: limit ?? this.limit,
      );
}

/// Paginated result page (ADR-003).
@immutable
class Page<T> {
  const Page({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<T> items;
  final String? nextCursor;
  final bool hasMore;

  static Page<T> empty<T>() => Page<T>(items: const []);

  /// Slice [all] using an integer index cursor encoded as a decimal string.
  static Page<T> fromList<T>(List<T> all, PageQuery query) {
    final start = query.cursor == null || query.cursor!.isEmpty
        ? 0
        : int.tryParse(query.cursor!) ?? 0;
    if (start < 0 || start >= all.length) {
      return Page<T>(items: const [], hasMore: false);
    }
    final end = (start + query.limit).clamp(0, all.length);
    final slice = all.sublist(start, end);
    final more = end < all.length;
    return Page<T>(
      items: List<T>.unmodifiable(slice),
      nextCursor: more ? '$end' : null,
      hasMore: more,
    );
  }
}
