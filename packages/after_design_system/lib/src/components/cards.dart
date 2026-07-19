import 'package:flutter/material.dart';

import '../foundations/elevations.dart';
import '../foundations/radius.dart';
import '../foundations/shadows.dart';
import '../foundations/spacing.dart';
import '../foundations/theme.dart';

enum AfterCardVariant { outlined, elevated, filled, ghost }

/// Surface container — hairline border by default (Linear), soft shadow optional.
class AfterCard extends StatelessWidget {
  const AfterCard({
    required this.child,
    super.key,
    this.variant = AfterCardVariant.outlined,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final AfterCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final colors = context.afterColors;
    final radius = borderRadius ?? AfterRadius.mdAll;
    final brightness = colors.brightness;

    final (Color bg, Border? border, List<BoxShadow> shadows) = switch (variant) {
      AfterCardVariant.outlined => (
          colors.surface,
          Border.all(color: colors.border.withValues(alpha: 0.9)),
          AfterShadows.none,
        ),
      AfterCardVariant.elevated => (
          colors.surfaceElevated,
          Border.all(color: colors.border.withValues(alpha: 0.5)),
          AfterShadows.level1(brightness),
        ),
      AfterCardVariant.filled => (
          colors.surfaceMuted,
          null,
          AfterShadows.none,
        ),
      AfterCardVariant.ghost => (
          Colors.transparent,
          null,
          AfterShadows.none,
        ),
    };

    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AfterSpacing.lg),
      child: child,
    );

    final decorated = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: border,
        boxShadow: shadows,
      ),
      clipBehavior: clipBehavior,
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: radius,
                child: content,
              ),
            ),
    );

    return decorated;
  }
}

/// Scaffold body wrapper with optional max-width centering.
class AfterScaffoldBody extends StatelessWidget {
  const AfterScaffoldBody({
    required this.child,
    super.key,
    this.padding,
    this.center = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final pad = padding ?? AfterSpacing.pagePaddingForWidth(width);
    final maxW = AfterSpacing.contentMaxWidthFor(width);

    final body = Padding(
      padding: pad,
      child: child,
    );

    if (!center) return body;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: body,
      ),
    );
  }
}

/// Section header used above card groups.
class AfterSectionHeader extends StatelessWidget {
  const AfterSectionHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.afterColors;
    final type = context.afterTypography;

    return Padding(
      padding: const EdgeInsets.only(bottom: AfterSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: type.titleSmall.copyWith(color: colors.foreground),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: type.bodySmall.copyWith(color: colors.muted),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Elevation token re-export for card consumers.
typedef AfterCardElevation = AfterElevations;
