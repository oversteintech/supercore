import 'package:flutter/material.dart';

import '../foundations/motion.dart';
import '../foundations/radius.dart';
import '../foundations/spacing.dart';
import '../foundations/theme.dart';
import 'buttons.dart';

/// Shows an After-styled alert dialog. Returns the action result.
Future<T?> showAfterDialog<T>({
  required BuildContext context,
  required String title,
  String? message,
  Widget? content,
  String? confirmLabel,
  String? cancelLabel,
  AfterButtonVariant confirmVariant = AfterButtonVariant.primary,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: AfterMotion.modalTransition,
    pageBuilder: (context, animation, secondaryAnimation) {
      return AfterDialog(
        title: title,
        message: message,
        content: content,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmVariant: confirmVariant,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AfterMotion.entrance,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.96, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class AfterDialog extends StatelessWidget {
  const AfterDialog({
    required this.title,
    super.key,
    this.message,
    this.content,
    this.confirmLabel,
    this.cancelLabel,
    this.confirmVariant = AfterButtonVariant.primary,
    this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String? message;
  final Widget? content;
  final String? confirmLabel;
  final String? cancelLabel;
  final AfterButtonVariant confirmVariant;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.afterColors;
    final type = context.afterTypography;
    final width = MediaQuery.sizeOf(context).width;
    final maxW = width < 360 ? width - 24 : (width < 420 ? 560.0 : 420.0);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW.clamp(280, 560)),
        child: Material(
          color: colors.surfaceElevated,
          borderRadius: AfterRadius.lgAll,
          child: Padding(
            padding: const EdgeInsets.all(AfterSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: type.titleLarge.copyWith(color: colors.foreground),
                ),
                if (message != null) ...[
                  const SizedBox(height: AfterSpacing.md),
                  Text(
                    message!,
                    style: type.bodyMedium.copyWith(color: colors.muted),
                  ),
                ],
                if (content != null) ...[
                  const SizedBox(height: AfterSpacing.lg),
                  content!,
                ],
                if (confirmLabel != null || cancelLabel != null) ...[
                  const SizedBox(height: AfterSpacing.xxl),
                  Row(
                    children: [
                      if (cancelLabel != null)
                        Expanded(
                          child: AfterButton(
                            label: cancelLabel!,
                            variant: AfterButtonVariant.secondary,
                            onPressed: onCancel ?? () => Navigator.of(context).pop(false),
                          ),
                        ),
                      if (cancelLabel != null && confirmLabel != null)
                        const SizedBox(width: AfterSpacing.sm),
                      if (confirmLabel != null)
                        Expanded(
                          child: AfterButton(
                            label: confirmLabel!,
                            variant: confirmVariant,
                            onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// After-styled modal bottom sheet.
Future<T?> showAfterBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool showDragHandle = true,
}) {
  final colors = context.afterColors;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    showDragHandle: showDragHandle,
    backgroundColor: colors.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AfterRadius.lg)),
    ),
    builder: builder,
  );
}
