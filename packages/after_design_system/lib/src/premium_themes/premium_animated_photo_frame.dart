import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'premium_frame_style.dart';
import 'racing_theme_effects.dart';
import 'safari_savanna.dart';
import 'silver_grey.dart';
import 'blossom_pink.dart';
import 'dark_night_theme.dart';
import 'forest_woodland.dart';
import 'theme.dart'
    show
        BrightGoldThemeEffects,
        DiamondThemeEffects,
        RoyalThemeEffects,
        SuperGarageColors;

/// Sweep palette used by premium photo frames and hero borders.
@immutable
class PremiumFrameSweep {
  const PremiumFrameSweep({
    required this.colors,
    required this.glow,
  });

  final List<Color> colors;
  final Color glow;
}

PremiumFrameSweep? premiumFrameSweepOf(BuildContext context) {
  if (RacingThemeEffects.isRedActive(context)) {
    return const PremiumFrameSweep(
      colors: RacingFramePalette.redGradient,
      glow: Color(0xFFE10600),
    );
  }
  if (RacingThemeEffects.isBlueActive(context)) {
    return const PremiumFrameSweep(
      colors: RacingFramePalette.blueGradient,
      glow: Color(0xFF1565E6),
    );
  }
  if (DiamondThemeEffects.isActive(context)) {
    return const PremiumFrameSweep(
      colors: [
        SuperGarageColors.diamondIce,
        SuperGarageColors.diamondPlatinum,
        SuperGarageColors.diamondSparkle,
        SuperGarageColors.diamondFire,
        SuperGarageColors.diamondAccent,
      ],
      glow: SuperGarageColors.diamondPlatinum,
    );
  }
  if (BrightGoldThemeEffects.isActive(context)) {
    return const PremiumFrameSweep(
      colors: [
        SuperGarageColors.goldShine,
        SuperGarageColors.goldBright,
        Color(0xFFFFFFFF),
        SuperGarageColors.goldDeep,
        SuperGarageColors.goldBorder,
      ],
      glow: SuperGarageColors.goldBright,
    );
  }
  if (SilverGreyThemeEffects.isActive(context)) {
    return const PremiumFrameSweep(
      colors: SilverGreyColors.frameGradient,
      glow: SuperGarageColors.silverGreySteel,
    );
  }
  if (DarkNightThemeEffects.isActive(context)) {
    return const PremiumFrameSweep(
      colors: [
        Color(0xFF7DD3FC),
        Color(0xFF38BDF8),
        Color(0xFFFFFFFF),
        Color(0xFF0EA5E9),
        Color(0xFF7DD3FC),
      ],
      glow: Color(0xFF38BDF8),
    );
  }
  if (BlossomPinkThemeEffects.isActive(context)) {
    return const PremiumFrameSweep(
      colors: [
        Color(0xFFEC4899),
        Color(0xFFF472B6),
        Color(0xFFFFFFFF),
        Color(0xFFDB2777),
        Color(0xFFEC4899),
      ],
      glow: Color(0xFFEC4899),
    );
  }
  if (ForestWoodlandThemeEffects.isActive(context)) {
    return const PremiumFrameSweep(
      colors: [
        Color(0xFF2D5030),
        Color(0xFF4A7448),
        Color(0xFFB8E986),
        Color(0xFF355A36),
        Color(0xFF2D5030),
      ],
      glow: Color(0xFF4A7448),
    );
  }
  if (SafariSavannaThemeEffects.isActive(context)) {
    return const PremiumFrameSweep(
      colors: [
        Color(0xFFFFC107),
        Color(0xFFFF8F00),
        Color(0xFFFFFFFF),
        Color(0xFFE64A19),
        Color(0xFFFFC107),
      ],
      glow: Color(0xFFFF8F00),
    );
  }
  if (RoyalThemeEffects.isActive(context)) {
    return const PremiumFrameSweep(
      colors: [
        Color(0xFF00B4FF),
        Color(0xFF00D4FF),
        Color(0xFFFFFFFF),
        Color(0xFFFF6B00),
        Color(0xFF00B4FF),
      ],
      glow: Color(0xFF00D4FF),
    );
  }
  return null;
}

/// Animated sweep border used on vehicle photos and dashboard heroes.
class PremiumAnimatedPhotoFrame extends StatefulWidget {
  const PremiumAnimatedPhotoFrame({
    required this.child,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(18)),
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;

  @override
  State<PremiumAnimatedPhotoFrame> createState() =>
      _PremiumAnimatedPhotoFrameState();
}

class _PremiumAnimatedPhotoFrameState extends State<PremiumAnimatedPhotoFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disable = MediaQuery.disableAnimationsOf(context);
    final sweep = premiumFrameSweepOf(context);
    if (sweep == null) {
      _controller.stop();
      return;
    }
    if (disable) {
      _controller.stop();
      _controller.value = 0;
      return;
    }
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sweep = premiumFrameSweepOf(context);
    final child = ClipRRect(
      borderRadius: widget.borderRadius,
      child: widget.child,
    );
    if (sweep == null) return child;

    final disable = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          foregroundPainter: _PremiumPhotoSweepPainter(
            progress: disable ? 0 : _controller.value,
            colors: sweep.colors,
            glow: sweep.glow,
            animated: !disable,
            borderRadius: widget.borderRadius,
          ),
          child: child,
        );
      },
    );
  }
}

class _PremiumPhotoSweepPainter extends CustomPainter {
  _PremiumPhotoSweepPainter({
    required this.progress,
    required this.colors,
    required this.glow,
    required this.animated,
    required this.borderRadius,
  });

  final double progress;
  final List<Color> colors;
  final Color glow;
  final bool animated;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect.deflate(1.5));
    final shader = SweepGradient(
      colors: colors,
      transform: GradientRotation(progress * 2 * math.pi),
    ).createShader(rect);
    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.2);
    canvas.drawRRect(rrect, paint);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = glow.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(covariant _PremiumPhotoSweepPainter oldDelegate) {
    if (!animated) return false;
    return oldDelegate.progress != progress ||
        oldDelegate.glow != glow ||
        oldDelegate.colors != colors;
  }
}
