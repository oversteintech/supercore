import 'package:flutter/material.dart';

import '../foundations/colors.dart';
import '../foundations/icons.dart';
import '../foundations/motion.dart';
import '../foundations/radius.dart';
import '../foundations/spacing.dart';
import '../foundations/theme.dart';
import '../foundations/typography.dart';

class AfterNavDestination {
  const AfterNavDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
}

/// Bottom navigation — compact, indicator soft-fill, ice accent when selected.
class AfterNavigationBar extends StatelessWidget {
  const AfterNavigationBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final List<AfterNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.afterColors;
    final type = context.afterTypography;

    return Material(
      color: colors.surface.withValues(alpha: 0.96),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: colors.border.withValues(alpha: 0.7)),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom,
        ),
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(
                  child: _AfterNavItem(
                    destination: destinations[i],
                    selected: i == selectedIndex,
                    onTap: () => onDestinationSelected(i),
                    colors: colors,
                    type: type,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AfterNavItem extends StatelessWidget {
  const _AfterNavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
    required this.colors,
    required this.type,
  });

  final AfterNavDestination destination;
  final bool selected;
  final VoidCallback onTap;
  final AfterColorScheme colors;
  final AfterTypography type;

  @override
  Widget build(BuildContext context) {
    final icon = selected
        ? (destination.selectedIcon ?? destination.icon)
        : destination.icon;
    final color = selected ? colors.accent : colors.muted;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: AfterMotion.micro,
            curve: AfterMotion.standard,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: selected ? colors.accentSoft : Colors.transparent,
              borderRadius: AfterRadius.fullAll,
            ),
            child: Icon(icon, size: AfterIconSpec.sizeLg - 2, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            destination.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: type.labelSmall.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Top app bar with optional AI / notification trailing actions.
class AfterAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AfterAppBar({
    required this.title,
    super.key,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.bottom,
  });

  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.afterColors;
    return AppBar(
      title: title,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      bottom: bottom,
      backgroundColor: colors.background.withValues(alpha: 0.92),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
    );
  }
}

/// Horizontal chip / segment control for filters.
class AfterSegmentedControl extends StatelessWidget {
  const AfterSegmentedControl({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.afterColors;
    final type = context.afterTypography;

    return Container(
      padding: const EdgeInsets.all(AfterSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AfterRadius.smAll,
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(i),
                child: AnimatedContainer(
                  duration: AfterMotion.micro,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: i == selectedIndex
                        ? colors.surface
                        : Colors.transparent,
                    borderRadius: AfterRadius.xsAll,
                    boxShadow: i == selectedIndex
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: type.labelMedium.copyWith(
                      color: i == selectedIndex
                          ? colors.foreground
                          : colors.muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
