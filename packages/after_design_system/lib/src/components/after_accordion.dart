import 'package:flutter/material.dart';

import 'settings_section.dart';

enum AfterAccordionVariant { card, nested, inline }

/// Shared accordion metrics + title styles used by every Super App.
class AfterAccordionLayout {
  const AfterAccordionLayout({
    required this.tilePadding,
    required this.childrenPadding,
    required this.dense,
    required this.visualDensity,
    required this.minTileHeight,
  });

  final EdgeInsetsGeometry tilePadding;
  final EdgeInsetsGeometry childrenPadding;
  final bool dense;
  final VisualDensity visualDensity;
  final double minTileHeight;

  static AfterAccordionLayout resolve(AfterAccordionVariant variant) {
    return switch (variant) {
      AfterAccordionVariant.card => const AfterAccordionLayout(
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 14),
          dense: false,
          visualDensity: VisualDensity.standard,
          minTileHeight: 56,
        ),
      AfterAccordionVariant.nested => const AfterAccordionLayout(
          tilePadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          childrenPadding: EdgeInsets.fromLTRB(12, 0, 12, 12),
          dense: true,
          visualDensity: VisualDensity.compact,
          minTileHeight: 48,
        ),
      AfterAccordionVariant.inline => const AfterAccordionLayout(
          tilePadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          childrenPadding: EdgeInsets.fromLTRB(8, 0, 8, 8),
          dense: true,
          visualDensity: VisualDensity.compact,
          minTileHeight: 44,
        ),
    };
  }

  static TextStyle cardTitle({Color? color}) => TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 16,
        height: 1.2,
        color: color,
      );

  static TextStyle cardSubtitle(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 13,
        height: 1.3,
        color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
      );

  static TextStyle nestedTitle({Color? color}) => TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 15,
        height: 1.2,
        color: color,
      );

  static TextStyle nestedSubtitle(BuildContext context, {Color? color}) =>
      cardSubtitle(context, color: color);

  static TextStyle inlineTitle({Color? color}) => TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 1.2,
        color: color,
      );
}

abstract final class AfterAccordionLeading {
  static Widget circleIcon(
    BuildContext context,
    IconData icon, {
    double radius = 18,
    Color? backgroundColor,
    Color? iconColor,
    Color? foregroundColor,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? scheme.primary.withValues(alpha: 0.12),
      foregroundColor: foregroundColor ?? iconColor ?? scheme.primary,
      child: Icon(icon, size: radius),
    );
  }
}

class AfterAccordionInfoButton extends StatelessWidget {
  const AfterAccordionInfoButton({
    required this.title,
    required this.info,
    this.iconColor,
    super.key,
  });

  final String title;
  final String info;
  final Color? iconColor;

  static bool hasText(String? value) =>
      value != null && value.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: title,
      visualDensity: VisualDensity.compact,
      icon: Icon(Icons.info_outline_rounded, color: iconColor),
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(info),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AfterSettingsNestedAccordionTile extends StatelessWidget {
  const AfterSettingsNestedAccordionTile({
    required this.title,
    required this.child,
    this.subtitle,
    this.leading,
    this.initiallyExpanded = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? leading;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        expansionAnimationStyle: AnimationStyle.noAnimation,
        maintainState: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
        childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        leading: leading == null
            ? null
            : AfterAccordionLeading.circleIcon(context, leading!),
        title: Text(title, style: AfterAccordionLayout.nestedTitle()),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                style: AfterAccordionLayout.nestedSubtitle(context),
              ),
        iconColor: scheme.onSurface,
        collapsedIconColor: scheme.onSurfaceVariant,
        children: [
          Align(alignment: Alignment.centerLeft, child: child),
        ],
      ),
    );
  }
}

class AfterSettingsNestedDivider extends StatelessWidget {
  const AfterSettingsNestedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: AfterSettingsMenuMetrics.dividerHeight,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}
