import 'package:flutter/material.dart';

import '../foundations/icons.dart';
import '../foundations/spacing.dart';
import '../foundations/theme.dart';
import 'buttons.dart';
import 'cards.dart';

enum AfterEmptyKind { empty, error, offline, locked, comingSoon }

/// Shared empty / info / error state — Super Apps MUST use this over one-offs.
class AfterEmptyState extends StatelessWidget {
  const AfterEmptyState({
    required this.title,
    super.key,
    this.subtitle,
    this.icon,
    this.kind = AfterEmptyKind.empty,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.constrained = true,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final AfterEmptyKind kind;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final bool constrained;

  IconData get _defaultIcon => switch (kind) {
        AfterEmptyKind.empty => AfterIcons.empty,
        AfterEmptyKind.error => AfterIcons.error,
        AfterEmptyKind.offline => AfterIcons.cloudOff,
        AfterEmptyKind.locked => AfterIcons.lock,
        AfterEmptyKind.comingSoon => AfterIcons.sparkles,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.afterColors;
    final type = context.afterTypography;
    final width = MediaQuery.sizeOf(context).width;
    final maxW = AfterSpacing.contentMaxWidthFor(width);

    final body = AfterCard(
      variant: AfterCardVariant.outlined,
      padding: const EdgeInsets.all(AfterSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AfterIcons.emptyState(icon ?? _defaultIcon),
          const SizedBox(height: AfterSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: type.titleMedium.copyWith(color: colors.foreground),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AfterSpacing.sm),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: type.bodyMedium.copyWith(color: colors.muted, height: 1.4),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AfterSpacing.lg),
            AfterButton(
              label: actionLabel!,
              onPressed: onAction,
              variant: kind == AfterEmptyKind.error
                  ? AfterButtonVariant.secondary
                  : AfterButtonVariant.primary,
            ),
          ],
          if (secondaryActionLabel != null && onSecondaryAction != null) ...[
            const SizedBox(height: AfterSpacing.sm),
            AfterButton(
              label: secondaryActionLabel!,
              onPressed: onSecondaryAction,
              variant: AfterButtonVariant.ghost,
            ),
          ],
        ],
      ),
    );

    if (!constrained) return Center(child: body);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Padding(
          padding: const EdgeInsets.all(AfterSpacing.xl),
          child: body,
        ),
      ),
    );
  }
}

/// Compact inline info banner (non-blocking).
class AfterInlineBanner extends StatelessWidget {
  const AfterInlineBanner({
    required this.message,
    super.key,
    this.icon = AfterIcons.info,
    this.onDismiss,
  });

  final String message;
  final IconData icon;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.afterColors;
    final type = context.afterTypography;

    return AfterCard(
      variant: AfterCardVariant.filled,
      padding: const EdgeInsets.symmetric(
        horizontal: AfterSpacing.md,
        vertical: AfterSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: AfterIconSpec.sizeMd, color: colors.accent),
          const SizedBox(width: AfterSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: type.bodySmall.copyWith(color: colors.foreground),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(AfterIcons.close, size: 16, color: colors.subtle),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
