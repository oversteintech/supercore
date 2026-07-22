import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'premium_frame_style.dart';

/// Warm desert safari palette — yellow, orange, red & coffee brown.
abstract final class SafariSavannaColors {
  static const duskDeep = Color(0xFF2C1810);
  static const coffee = Color(0xFF4E342E);
  static const clay = Color(0xFF6D4C41);
  static const terracotta = Color(0xFFBF360C);
  static const safariRed = Color(0xFFE64A19);
  static const sunsetOrange = Color(0xFFFF8F00);
  static const sandGold = Color(0xFFFFC107);
  static const paleSand = Color(0xFFFFE082);
  static const horizon = Color(0xFFFFAB40);

  static const borderGradient = <Color>[
    paleSand,
    sandGold,
    sunsetOrange,
    safariRed,
    terracotta,
    coffee,
    clay,
    sandGold,
    paleSand,
  ];
}

@immutable
class SafariSavannaThemeEffects
    extends ThemeExtension<SafariSavannaThemeEffects> {
  const SafariSavannaThemeEffects({this.enabled = false});

  final bool enabled;

  static SafariSavannaThemeEffects? of(BuildContext context) {
    return Theme.of(context).extension<SafariSavannaThemeEffects>();
  }

  static bool isActive(BuildContext context) => of(context)?.enabled ?? false;

  @override
  SafariSavannaThemeEffects copyWith({bool? enabled}) {
    return SafariSavannaThemeEffects(enabled: enabled ?? this.enabled);
  }

  @override
  SafariSavannaThemeEffects lerp(SafariSavannaThemeEffects? other, double t) {
    if (other == null) return this;
    return SafariSavannaThemeEffects(
      enabled: t < 0.5 ? enabled : other.enabled,
    );
  }
}

class SafariAtmospherePainter extends CustomPainter {
  SafariAtmospherePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final pulse = (math.sin(progress * math.pi * 2) + 1) / 2;
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            SafariSavannaColors.duskDeep,
            Color.lerp(
              SafariSavannaColors.coffee,
              SafariSavannaColors.terracotta,
              0.35 + pulse * 0.1,
            )!,
            Color.lerp(
              SafariSavannaColors.clay,
              SafariSavannaColors.sunsetOrange,
              0.4 + pulse * 0.12,
            )!,
            Color.lerp(
              SafariSavannaColors.safariRed,
              SafariSavannaColors.sandGold,
              0.45 + pulse * 0.15,
            )!,
            SafariSavannaColors.paleSand.withValues(alpha: 0.75),
          ],
          stops: const [0.0, 0.32, 0.55, 0.78, 1.0],
        ).createShader(rect),
    );

    final sunY = size.height * (0.36 + pulse * 0.015);
    final sunX = size.width * 0.68;
    final sunRadius = size.width * 0.12;
    canvas.drawCircle(
      Offset(sunX, sunY),
      sunRadius,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                SafariSavannaColors.paleSand.withValues(
                  alpha: 0.45 + pulse * 0.15,
                ),
                SafariSavannaColors.sunsetOrange.withValues(
                  alpha: 0.22 + pulse * 0.08,
                ),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(center: Offset(sunX, sunY), radius: sunRadius),
            ),
    );

    final haze = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 10; i++) {
      final phase = (progress + i * 0.08) % 1.0;
      final alpha = (math.sin(phase * math.pi * 2) + 1) / 2;
      if (alpha < 0.35) continue;
      haze.color = SafariSavannaColors.paleSand.withValues(
        alpha: 0.03 + alpha * 0.05,
      );
      canvas.drawCircle(
        Offset(
          size.width * (0.15 + i * 0.08),
          size.height * (0.25 + (i % 4) * 0.12),
        ),
        1.2 + alpha,
        haze,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SafariAtmospherePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class SafariAnimatedBackground extends StatefulWidget {
  const SafariAnimatedBackground({super.key});

  @override
  State<SafariAnimatedBackground> createState() =>
      _SafariAnimatedBackgroundState();
}

class _SafariAnimatedBackgroundState extends State<SafariAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: SafariAtmospherePainter(progress: _controller.value),
            isComplex: true,
            willChange: true,
          );
        },
      ),
    );
  }
}

class SafariSavannaPreview extends StatelessWidget {
  const SafariSavannaPreview({
    super.key,
    this.borderRadius = BorderRadius.zero,
  });

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: const SizedBox.expand(
        child: SafariAnimatedBackground(),
      ),
    );
  }
}

class SafariSavannaAppShell extends StatelessWidget {
  const SafariSavannaAppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: SafariSavannaColors.duskDeep),
        const SafariAnimatedBackground(),
        child,
      ],
    );
  }
}

class SafariShowcaseFrame extends StatefulWidget {
  const SafariShowcaseFrame({
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.prominent = false,
    this.style,
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final bool prominent;
  final PremiumFrameStyle? style;

  PremiumFrameStyle get resolvedStyle =>
      style ?? PremiumFrameStyleX.fromProminent(prominent);

  @override
  State<SafariShowcaseFrame> createState() => _SafariShowcaseFrameState();
}

class _SafariShowcaseFrameState extends State<SafariShowcaseFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Duration get _duration => Duration(
    milliseconds: widget.resolvedStyle.borderMs(
      showcaseMs: 12000,
      softMs: 15000,
      menuMs: 18000,
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant SafariShowcaseFrame oldWidget) {
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
    if (!SafariSavannaThemeEffects.isActive(context)) {
      return widget.child;
    }

    final style = widget.resolvedStyle;
    final scale = style.glowScale;
    final pad = 1.7 + style.padExtra * 1.2;
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
        final glow = (0.10 + pulse * 0.12) * scale;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: SweepGradient(
              colors: SafariSavannaColors.borderGradient,
              stops: const [0.0, 0.12, 0.28, 0.42, 0.56, 0.7, 0.84, 0.94, 1.0],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
            boxShadow: [
              BoxShadow(
                color: SafariSavannaColors.sunsetOrange.withValues(alpha: glow),
                blurRadius: (9 + pulse * 6) + style.padExtra * 7,
                spreadRadius: 0.2 + style.padExtra * 0.5,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: ClipRRect(borderRadius: innerRadius, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }

  Radius _shrink(Radius radius, double amount) {
    return Radius.elliptical(
      math.max(radius.x - amount, 0),
      math.max(radius.y - amount, 0),
    );
  }
}
