import 'package:flutter/material.dart';

import '../premium_themes/theme.dart';

/// Shared Super App settings accordion section — SuperGarage visual contract.
///
/// Black/white adaptive leading icon in a soft primary wash, heavy title,
/// subtitle, [SuperGarageCard] + Material [ExpansionTile] with no-animation
/// theme. Every Super App settings shell MUST use this (or a thin wrapper).
class AfterSettingsSection extends StatelessWidget {
  const AfterSettingsSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.headerBackgroundColor,
    this.headerTextColor,
    this.initiallyExpanded = false,
    super.key,
  });

  /// Emergency / ICE accent used by SuperGarage and family settings.
  static const emergencyRed = Color(0xFFC62828);

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final Color? headerBackgroundColor;
  final Color? headerTextColor;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accentHeader =
        headerBackgroundColor != null && headerTextColor != null;
    final headerBg = headerBackgroundColor;
    final headerFg = headerTextColor;
    final titleStyle = TextStyle(
      fontWeight: FontWeight.w900,
      color: accentHeader ? headerFg : null,
    );
    final subtitleStyle = TextStyle(
      color: accentHeader ? headerFg!.withValues(alpha: 0.92) : null,
    );

    return SuperGarageCard(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: accentHeader ? headerBg : null,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          childrenPadding: EdgeInsets.zero,
          maintainState: true,
          backgroundColor: headerBg,
          collapsedBackgroundColor: headerBg,
          iconColor: headerFg,
          collapsedIconColor: headerFg,
          leading: CircleAvatar(
            backgroundColor: accentHeader
                ? headerFg!.withValues(alpha: 0.18)
                : scheme.primary.withValues(alpha: 0.12),
            foregroundColor: accentHeader ? headerFg : scheme.adaptiveIcon,
            child: Icon(icon),
          ),
          title: Text(title, style: titleStyle),
          subtitle: Text(subtitle, style: subtitleStyle),
          children: [
            if (accentHeader)
              ColoredBox(
                color: scheme.surface,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: child,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: child,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Vertical gap between [AfterSettingsSection] cards (SuperGarage = 12).
class AfterSettingsSectionGap extends StatelessWidget {
  const AfterSettingsSectionGap({super.key});

  static const double height = 12;

  @override
  Widget build(BuildContext context) => const SizedBox(height: height);
}
