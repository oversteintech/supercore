import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';

import '../foundations/spacing.dart';
import 'cards.dart';
import 'empty_states.dart';

/// Resolves display strings / metric values for a [DashboardWidgetSpec].
///
/// Products inject domain data without changing dashboard layout code.
typedef AfterDashboardLabelResolver = String Function(String key);

typedef AfterDashboardValueResolver = Object? Function(String? source);

typedef AfterDashboardActionHandler = void Function(DashboardWidgetSpec spec);

/// Renders a Home dashboard from engine specs — layout comes from JSON/RC.
class AfterDashboard extends StatelessWidget {
  const AfterDashboard({
    required this.widgets,
    super.key,
    this.header,
    this.footer,
    this.resolveLabel,
    this.resolveValue,
    this.onAction,
    this.padding = const EdgeInsets.all(AfterSpacing.md),
    this.shrinkWrap = false,
    this.emptyTitle = 'No dashboard widgets',
    this.emptyBody = 'Layout will appear when Remote Config or assets load.',
  });

  final List<DashboardWidgetSpec> widgets;

  /// Optional content above the first widget (greeting, offline banner, …).
  final Widget? header;

  /// Optional content below the last widget (feature grids, …).
  final Widget? footer;
  final AfterDashboardLabelResolver? resolveLabel;
  final AfterDashboardValueResolver? resolveValue;
  final AfterDashboardActionHandler? onAction;
  final EdgeInsetsGeometry padding;

  /// When `true`, nestable inside another scroll view.
  final bool shrinkWrap;
  final String emptyTitle;
  final String emptyBody;

  String _label(String key) => resolveLabel?.call(key) ?? key;

  @override
  Widget build(BuildContext context) {
    if (widgets.isEmpty && header == null && footer == null) {
      return AfterEmptyState(
        title: emptyTitle,
        subtitle: emptyBody,
        icon: Icons.dashboard_outlined,
      );
    }

    return ListView(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      children: [
        if (header != null) ...[
          header!,
          const SizedBox(height: AfterSpacing.md),
        ],
        for (final spec in widgets) ...[
          AfterDashboardTile(
            spec: spec,
            title: _label(spec.titleKey),
            subtitle:
                spec.subtitleKey == null ? null : _label(spec.subtitleKey!),
            value: resolveValue?.call(spec.source),
            onTap: onAction == null ? null : () => onAction!(spec),
          ),
          const SizedBox(height: AfterSpacing.sm),
        ],
        if (footer != null) ...[
          const SizedBox(height: AfterSpacing.md),
          footer!,
        ],
      ],
    );
  }
}

/// Single widget card — kind drives iconography / trailing content.
class AfterDashboardTile extends StatelessWidget {
  const AfterDashboardTile({
    required this.spec,
    required this.title,
    super.key,
    this.subtitle,
    this.value,
    this.onTap,
  });

  final DashboardWidgetSpec spec;
  final String title;
  final String? subtitle;
  final Object? value;
  final VoidCallback? onTap;

  IconData get _icon => switch (spec.kind) {
        DashboardWidgetKind.statistics ||
        DashboardWidgetKind.metric ||
        DashboardWidgetKind.kpi =>
          Icons.insights_outlined,
        DashboardWidgetKind.tasks => Icons.task_alt_outlined,
        DashboardWidgetKind.calendar ||
        DashboardWidgetKind.upcomingEvents =>
          Icons.event_outlined,
        DashboardWidgetKind.notifications => Icons.notifications_outlined,
        DashboardWidgetKind.aiCard => Icons.auto_awesome_outlined,
        DashboardWidgetKind.quickActions => Icons.bolt_outlined,
        DashboardWidgetKind.recentItems => Icons.history,
        DashboardWidgetKind.favorites => Icons.star_outline,
        DashboardWidgetKind.chart => Icons.show_chart,
        DashboardWidgetKind.documents => Icons.folder_outlined,
        DashboardWidgetKind.activityTimeline => Icons.timeline,
        DashboardWidgetKind.weather => Icons.wb_cloudy_outlined,
        DashboardWidgetKind.location => Icons.location_on_outlined,
        DashboardWidgetKind.news => Icons.newspaper_outlined,
        DashboardWidgetKind.vehicleCard => Icons.directions_car_outlined,
        DashboardWidgetKind.healthCard => Icons.favorite_outline,
        DashboardWidgetKind.financeCard => Icons.account_balance_wallet_outlined,
        DashboardWidgetKind.propertyCard => Icons.home_work_outlined,
        DashboardWidgetKind.flightCard => Icons.flight_takeoff_outlined,
        DashboardWidgetKind.patientCard => Icons.local_hospital_outlined,
        DashboardWidgetKind.shipCard => Icons.directions_boat_outlined,
        DashboardWidgetKind.module => Icons.widgets_outlined,
        DashboardWidgetKind.custom => Icons.dashboard_customize_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueText = value?.toString();

    return AfterCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: theme.colorScheme.primary),
          const SizedBox(width: AfterSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: theme.textTheme.bodySmall),
                ],
                if (valueText != null && valueText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    valueText,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                if (spec.kind == DashboardWidgetKind.quickActions &&
                    spec.data['actions'] is List) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final action in spec.data['actions']! as List)
                        Chip(
                          label: Text(
                            action is Map
                                ? '${action['label'] ?? action['id']}'
                                : '$action',
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Text(
            spec.kind.name,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
