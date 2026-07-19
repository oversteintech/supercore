# ADR-003 — Page\<T\> everywhere

**Status:** Accepted  
**Date:** 2026-07-19

## Context

All list/query ports return unbounded `List<T>`, which cannot scale to millions of users.

## Decision

Introduce in `after_core`:

```dart
class PageQuery {
  final String? cursor;
  final int limit;
}

class Page<T> {
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;
}
```

Migrate list/query ports over time. Phase 1 adds types and migrates the hottest enterprise + ecosystem list APIs (or provides paginated overloads alongside legacy list methods marked for removal).

## Consequences

New ports prefer `Page` / `PageQuery`. Unbounded `List` returns are transitional and must not be added for new APIs.
