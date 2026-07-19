import 'package:flutter/material.dart';

import '../foundations/motion.dart';
import '../foundations/radius.dart';
import '../foundations/spacing.dart';
import '../foundations/theme.dart';
import 'cards.dart';

/// Centered loading indicator with optional label.
class AfterLoading extends StatelessWidget {
  const AfterLoading({
    super.key,
    this.message,
    this.size = 26,
    this.card = true,
  });

  final String? message;
  final double size;
  final bool card;

  @override
  Widget build(BuildContext context) {
    final colors = context.afterColors;
    final type = context.afterTypography;
    final width = MediaQuery.sizeOf(context).width;
    final maxW = AfterSpacing.contentMaxWidthFor(width);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: colors.accent,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: AfterSpacing.md),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: type.bodyMedium.copyWith(color: colors.muted, height: 1.35),
          ),
        ],
      ],
    );

    final body = card
        ? AfterCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: content,
          )
        : content;

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

/// Shimmer placeholder block.
class AfterSkeleton extends StatefulWidget {
  const AfterSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<AfterSkeleton> createState() => _AfterSkeletonState();
}

class _AfterSkeletonState extends State<AfterSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AfterMotion.shimmer,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.afterColors;
    final base = colors.surfaceMuted;
    final highlight = colors.border.withValues(alpha: 0.55);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? AfterRadius.smAll,
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * _controller.value, 0),
              end: Alignment(1 + 2 * _controller.value, 0),
              colors: [base, highlight, base],
              stops: const [0.25, 0.5, 0.75],
            ),
          ),
        );
      },
    );
  }
}

/// Card-shaped skeleton for list placeholders.
class AfterSkeletonCard extends StatelessWidget {
  const AfterSkeletonCard({super.key, this.lines = 3});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return AfterCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AfterSkeleton(width: 140, height: 14),
          const SizedBox(height: AfterSpacing.md),
          for (var i = 0; i < lines; i++) ...[
            if (i > 0) const SizedBox(height: AfterSpacing.sm),
            AfterSkeleton(
              width: i == lines - 1 ? 180 : double.infinity,
              height: 12,
            ),
          ],
        ],
      ),
    );
  }
}

/// Full-screen or overlay AI “thinking” pulse — use sparingly.
class AfterAiThinking extends StatefulWidget {
  const AfterAiThinking({super.key, this.label = 'Thinking'});

  final String label;

  @override
  State<AfterAiThinking> createState() => _AfterAiThinkingState();
}

class _AfterAiThinkingState extends State<AfterAiThinking>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AfterMotion.emphasis,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.afterColors;
    final type = context.afterTypography;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.accent.withValues(alpha: 0.4 + 0.6 * t),
                boxShadow: [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.35 * t),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AfterSpacing.sm),
            Text(
              widget.label,
              style: type.labelMedium.copyWith(color: colors.muted),
            ),
          ],
        );
      },
    );
  }
}
