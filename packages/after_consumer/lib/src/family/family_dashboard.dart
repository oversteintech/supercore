import 'package:flutter/widgets.dart';

/// Priority tiers for Home dashboard sections (Garage pattern).
enum FamilyDashboardPriority {
  empty,
  hero,
  actionRequired,
  dailyValue,
  secondary,
  admin,
}

@immutable
class FamilyDashboardSection {
  const FamilyDashboardSection({
    required this.id,
    required this.priority,
    required this.builder,
    this.order = 0,
    this.visible = true,
  });

  final String id;
  final FamilyDashboardPriority priority;
  final int order;
  final bool visible;
  final WidgetBuilder builder;
}

/// Stable sort: priority tier then [order], skipping invisible sections.
List<FamilyDashboardSection> sortFamilyDashboardSections(
  Iterable<FamilyDashboardSection> sections,
) {
  final list = sections.where((s) => s.visible).toList(growable: false)
    ..sort((a, b) {
      final byPriority = a.priority.index.compareTo(b.priority.index);
      if (byPriority != 0) return byPriority;
      return a.order.compareTo(b.order);
    });
  return list;
}
