import 'package:flutter/material.dart';

import 'colors.dart';
import 'spacing.dart';

/// Icon size and stroke specifications for the After ecosystem.
abstract final class AfterIconSpec {
  /// Compact toolbar / dense lists.
  static const double sizeSm = 16;

  /// Default inline / list leading.
  static const double sizeMd = 20;

  /// Navigation / primary actions.
  static const double sizeLg = 24;

  /// Empty states / feature highlights.
  static const double sizeXl = 40;

  /// Hero / onboarding marks.
  static const double sizeHero = 56;

  /// Preferred optical padding around icons in tappable targets.
  static const double tapTarget = 44;

  /// Material symbols: prefer outlined for chrome, rounded for emphasis.
  static const String preferredStyle = 'outlined';

  /// Stroke weight guidance (for custom SVG icon sets).
  static const double strokeRegular = 1.5;
  static const double strokeEmphasis = 2.0;

  static double sizeForWidth(double width) =>
      width < 360 ? sizeMd : sizeLg;
}

/// Semantic icon roles — Super Apps SHOULD map product icons to these roles.
enum AfterIconRole {
  navigation,
  action,
  status,
  decorative,
  emptyState,
  ai,
}

/// Styled icon that respects After size + muted/accent roles.
class AfterIcon extends StatelessWidget {
  const AfterIcon(
    this.icon, {
    super.key,
    this.size = AfterIconSpec.sizeLg,
    this.role = AfterIconRole.action,
    this.color,
  });

  final IconData icon;
  final double size;
  final AfterIconRole role;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scheme = brightness == Brightness.dark
        ? AfterColorScheme.dark
        : AfterColorScheme.light;

    final resolved = color ??
        switch (role) {
          AfterIconRole.navigation => scheme.muted,
          AfterIconRole.action => scheme.foreground,
          AfterIconRole.status => scheme.accent,
          AfterIconRole.decorative => scheme.subtle,
          AfterIconRole.emptyState => scheme.muted,
          AfterIconRole.ai => scheme.accent,
        };

    return Icon(icon, size: size, color: resolved);
  }
}

/// Recommended Material icon mapping for shared Super App chrome.
/// Product features MAY extend; do not replace these keys for shell UI.
abstract final class AfterIcons {
  static const IconData home = Icons.home_outlined;
  static const IconData search = Icons.search;
  static const IconData settings = Icons.settings_outlined;
  static const IconData profile = Icons.person_outline;
  static const IconData notifications = Icons.notifications_outlined;
  static const IconData ai = Icons.auto_awesome_outlined;
  static const IconData add = Icons.add;
  static const IconData close = Icons.close;
  static const IconData back = Icons.arrow_back_ios_new_rounded;
  static const IconData chevronRight = Icons.chevron_right_rounded;
  static const IconData check = Icons.check_rounded;
  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData error = Icons.error_outline_rounded;
  static const IconData info = Icons.info_outline_rounded;
  static const IconData empty = Icons.inbox_outlined;
  static const IconData cloudOff = Icons.cloud_off_outlined;
  static const IconData lock = Icons.lock_outline_rounded;
  static const IconData sparkles = Icons.auto_awesome;
  static const IconData chart = Icons.show_chart_rounded;
  static const IconData menu = Icons.menu_rounded;
  static const IconData more = Icons.more_horiz_rounded;

  /// Preferred leading size in list tiles.
  static Widget listLeading(IconData icon, {Color? color}) {
    return AfterIcon(
      icon,
      size: AfterIconSpec.sizeLg,
      role: AfterIconRole.action,
      color: color,
    );
  }

  /// Preferred empty-state glyph.
  static Widget emptyState(IconData icon, {Color? color}) {
    return AfterIcon(
      icon,
      size: AfterIconSpec.sizeXl,
      role: AfterIconRole.emptyState,
      color: color,
    );
  }
}

/// Spacing helper for icon+label rows.
abstract final class AfterIconGap {
  static const double sm = AfterSpacing.xs;
  static const double md = AfterSpacing.sm;
  static const double lg = AfterSpacing.md;
}
