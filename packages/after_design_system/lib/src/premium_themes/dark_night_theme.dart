import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'premium_frame_style.dart';
import 'premium_theme_shell.dart';

/// Matte black night palette — void black, charcoal panels & soft silver text.
abstract final class DarkNightColors {
  static const voidBlack = Color(0xFF050505);
  static const matteBlack = Color(0xFF0A0A0A);
  static const surface = Color(0xFF111111);
  static const surfaceHigh = Color(0xFF161616);
  static const surfaceHighest = Color(0xFF1C1C1C);
  static const charcoal = Color(0xFF242424);
  static const graphite = Color(0xFF333333);
  static const steel = Color(0xFF4A4A4A);
  static const silver = Color(0xFF8A8A8A);
  static const silverBright = Color(0xFFB8B8B8);
  static const foreground = Color(0xFFE6E6E6);
  static const muted = Color(0xFF9A9A9A);
  static const border = Color(0xFF2E2E2E);

  static const borderGradient = <Color>[
    Color(0xFF1A1A1A),
    Color(0xFF3A3A3A),
    Color(0xFF555555),
    Color(0xFF2A2A2A),
    Color(0xFF111111),
    Color(0xFF404040),
    Color(0xFF252525),
    Color(0xFF1A1A1A),
  ];
}

/// Theme extension — attached only to the Dark Night premium theme.
@immutable
class DarkNightThemeEffects extends ThemeExtension<DarkNightThemeEffects> {
  const DarkNightThemeEffects({this.enabled = false});

  final bool enabled;

  static DarkNightThemeEffects? of(BuildContext context) {
    return Theme.of(context).extension<DarkNightThemeEffects>();
  }

  static bool isActive(BuildContext context) => of(context)?.enabled ?? false;

  @override
  DarkNightThemeEffects copyWith({bool? enabled}) {
    return DarkNightThemeEffects(enabled: enabled ?? this.enabled);
  }

  @override
  DarkNightThemeEffects lerp(DarkNightThemeEffects? other, double t) {
    if (other == null) return this;
    return DarkNightThemeEffects(
      enabled: t < 0.5 ? enabled : other.enabled,
    );
  }
}

class DarkNightAtmospherePainter extends CustomPainter {
  DarkNightAtmospherePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final pulse = (math.sin(progress * math.pi * 2) + 1) / 2;

    canvas.drawRect(
      rect,
      Paint()..color = DarkNightColors.voidBlack,
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.0, -0.35),
          radius: 1.15,
          colors: [
            DarkNightColors.charcoal.withValues(alpha: 0.22 + pulse * 0.06),
            DarkNightColors.matteBlack,
            DarkNightColors.voidBlack,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    _drawMatteGrain(canvas, size, progress);

    canvas.drawRect(
      rect,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.38 + pulse * 0.08),
              ],
              stops: const [0.45, 1.0],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.5, size.height * 0.55),
                radius: size.shortestSide * math.sqrt(2) * 0.62,
              ),
            ),
    );
  }

  void _drawMatteGrain(Canvas canvas, Size size, double progress) {
    final paint = Paint();
    for (var i = 0; i < 28; i++) {
      final phase = i / 28.0;
      final twinkle =
          (math.sin((progress * 0.35 + phase) * math.pi * 2) + 1) / 2;
      if (twinkle < 0.42) continue;
      final x = size.width * (0.08 + phase * 0.84);
      final y = size.height * (0.1 + (i % 7) * 0.12);
      paint.color = DarkNightColors.silver.withValues(
        alpha: 0.02 + twinkle * 0.04,
      );
      canvas.drawCircle(Offset(x, y), 0.6 + twinkle * 0.8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DarkNightAtmospherePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class DarkNightAnimatedBackground extends StatefulWidget {
  const DarkNightAnimatedBackground({super.key});

  @override
  State<DarkNightAnimatedBackground> createState() =>
      _DarkNightAnimatedBackgroundState();
}

class _DarkNightAnimatedBackgroundState
    extends State<DarkNightAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox.expand(
          child: CustomPaint(
            painter: DarkNightAtmospherePainter(progress: _controller.value),
            isComplex: true,
            willChange: true,
          ),
        );
      },
    );
  }
}

class DarkNightPreview extends StatelessWidget {
  const DarkNightPreview({
    super.key,
    this.borderRadius = BorderRadius.zero,
  });

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: const SizedBox.expand(
        child: DarkNightAnimatedBackground(),
      ),
    );
  }
}

class DarkNightAppShell extends StatelessWidget {
  const DarkNightAppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PremiumThemeAppShell(
      backgroundColor: DarkNightColors.voidBlack,
      background: const DarkNightAnimatedBackground(),
      child: child,
    );
  }
}

/// Subtle charcoal sweep around cards when the dark night theme is active.
class DarkNightShowcaseFrame extends StatefulWidget {
  const DarkNightShowcaseFrame({
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.prominent = false,
    this.style,
    this.forceShow = false,
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final bool prominent;
  final PremiumFrameStyle? style;
  final bool forceShow;

  PremiumFrameStyle get resolvedStyle =>
      style ?? PremiumFrameStyleX.fromProminent(prominent);

  @override
  State<DarkNightShowcaseFrame> createState() => _DarkNightShowcaseFrameState();
}

class _DarkNightShowcaseFrameState extends State<DarkNightShowcaseFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Duration get _duration => Duration(
    milliseconds: widget.resolvedStyle.borderMs(
      showcaseMs: 14000,
      softMs: 17000,
      menuMs: 20000,
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant DarkNightShowcaseFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resolvedStyle != widget.resolvedStyle) {
      _controller.duration = _duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.forceShow && !DarkNightThemeEffects.isActive(context)) {
      return widget.child;
    }

    final style = widget.resolvedStyle;
    final scale = style.glowScale;
    final pad = 1.5 + style.padExtra * 1.0;
    final innerRadius = BorderRadius.only(
      topLeft: _shrink(widget.borderRadius.topLeft, pad),
      topRight: _shrink(widget.borderRadius.topRight, pad),
      bottomLeft: _shrink(widget.borderRadius.bottomLeft, pad),
      bottomRight: _shrink(widget.borderRadius.bottomRight, pad),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = (math.sin(_controller.value * math.pi * 2) + 1) / 2;
        final glow = (0.06 + pulse * 0.08) * scale;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: SweepGradient(
              colors: DarkNightColors.borderGradient,
              stops: const [0.0, 0.12, 0.28, 0.42, 0.56, 0.72, 0.86, 1.0],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
            boxShadow: [
              BoxShadow(
                color: DarkNightColors.graphite.withValues(alpha: glow),
                blurRadius: (8 + pulse * 6) + style.padExtra * 5,
                spreadRadius: 0.1 + style.padExtra * 0.25,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: ClipRRect(
              borderRadius: innerRadius,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }

  Radius _shrink(Radius radius, double amount) {
    return Radius.circular(math.max(0, radius.x - amount));
  }
}
