import 'package:flutter/material.dart';

import '../foundations/colors.dart';
import '../foundations/motion.dart';
import '../foundations/radius.dart';
import '../foundations/spacing.dart';
import '../foundations/theme.dart';

enum AfterButtonVariant { primary, secondary, ghost, danger, ai }

enum AfterButtonSize { sm, md, lg }

/// Primary action control — Linear-sharp, Apple-calm.
class AfterButton extends StatelessWidget {
  const AfterButton({
    required this.label,
    super.key,
    this.onPressed,
    this.variant = AfterButtonVariant.primary,
    this.size = AfterButtonSize.md,
    this.icon,
    this.expand = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AfterButtonVariant variant;
  final AfterButtonSize size;
  final IconData? icon;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.afterColors;
    final typography = context.afterTypography;
    final enabled = onPressed != null && !loading;

    final (bg, fg, border) = switch (variant) {
      AfterButtonVariant.primary => (colors.accent, colors.onAccent, null),
      AfterButtonVariant.secondary => (
          colors.surfaceMuted,
          colors.foreground,
          colors.border,
        ),
      AfterButtonVariant.ghost => (Colors.transparent, colors.accent, null),
      AfterButtonVariant.danger => (AfterColors.danger, Colors.white, null),
      AfterButtonVariant.ai => (colors.accent, colors.onAccent, null),
    };

    final padding = switch (size) {
      AfterButtonSize.sm =>
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      AfterButtonSize.md =>
        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      AfterButtonSize.lg =>
        const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
    };

    final textStyle = switch (size) {
      AfterButtonSize.sm => typography.labelMedium,
      AfterButtonSize.md => typography.labelLarge,
      AfterButtonSize.lg => typography.titleSmall,
    };

    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: fg,
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: size == AfterButtonSize.sm ? 16 : 18, color: fg),
          const SizedBox(width: AfterSpacing.sm),
        ],
        if (!loading)
          Text(label, style: textStyle.copyWith(color: fg)),
      ],
    );

    return AnimatedOpacity(
      duration: AfterMotion.micro,
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: bg,
        borderRadius: AfterRadius.smAll,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: AfterRadius.smAll,
          child: Container(
            width: expand ? double.infinity : null,
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: AfterRadius.smAll,
              border: border == null ? null : Border.all(color: border),
              boxShadow: variant == AfterButtonVariant.ai && enabled
                  ? [
                      BoxShadow(
                        color: colors.accent.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Icon-only circular control for toolbars.
class AfterIconButton extends StatelessWidget {
  const AfterIconButton({
    required this.icon,
    super.key,
    this.onPressed,
    this.tooltip,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.afterColors;
    final button = Material(
      color: colors.surfaceMuted,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: 20, color: colors.foreground),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
