import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'premium_theme_shell.dart';

/// Savanna palette — golden grass, ochre soil & sunset glow.
abstract final class SavannaColors {
  static const soilDeep = Color(0xFF2E1A0C);
  static const soil = Color(0xFF5C3418);
  static const soilWarm = Color(0xFF7B4A22);
  static const ochre = Color(0xFFCD853F);
  static const grassGold = Color(0xFFE8C547);
  static const grassBright = Color(0xFFFFD54F);
  static const grassLight = Color(0xFFFFF59D);
  static const sunset = Color(0xFFFF9800);
  static const sunsetDeep = Color(0xFFE65100);
  static const horizon = Color(0xFFFFB74D);

  static const borderGradient = <Color>[
    grassLight,
    grassBright,
    grassGold,
    sunset,
    ochre,
    soilWarm,
    soil,
    grassGold,
    grassLight,
  ];
}

/// Theme extension — attached only to Africa Savanna theme.
@immutable
class AfricaSavannaThemeEffects
    extends ThemeExtension<AfricaSavannaThemeEffects> {
  const AfricaSavannaThemeEffects({this.enabled = false});

  final bool enabled;

  static AfricaSavannaThemeEffects? of(BuildContext context) {
    return Theme.of(context).extension<AfricaSavannaThemeEffects>();
  }

  static bool isActive(BuildContext context) => of(context)?.enabled ?? false;

  @override
  AfricaSavannaThemeEffects copyWith({bool? enabled}) {
    return AfricaSavannaThemeEffects(enabled: enabled ?? this.enabled);
  }

  @override
  AfricaSavannaThemeEffects lerp(AfricaSavannaThemeEffects? other, double t) {
    if (other == null) return this;
    return AfricaSavannaThemeEffects(
      enabled: t < 0.5 ? enabled : other.enabled,
    );
  }
}

class SavannaAtmospherePainter extends CustomPainter {
  SavannaAtmospherePainter({required this.progress});

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
            SavannaColors.soilDeep,
            Color.lerp(
              SavannaColors.soil,
              SavannaColors.sunsetDeep,
              0.35 + pulse * 0.15,
            )!,
            Color.lerp(
              SavannaColors.soilWarm,
              SavannaColors.horizon,
              0.45 + pulse * 0.2,
            )!,
            Color.lerp(
              SavannaColors.ochre,
              SavannaColors.grassGold,
              0.55 + pulse * 0.25,
            )!,
            SavannaColors.grassBright.withValues(alpha: 0.85),
          ],
          stops: const [0.0, 0.35, 0.58, 0.78, 1.0],
        ).createShader(rect),
    );

    final sunY = size.height * (0.34 + pulse * 0.02);
    final sunX = size.width * (0.72 + math.sin(progress * math.pi * 2) * 0.03);
    final sunRadius = size.width * (0.14 + pulse * 0.03);
    canvas.drawCircle(
      Offset(sunX, sunY),
      sunRadius,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                SavannaColors.grassLight.withValues(alpha: 0.55 + pulse * 0.2),
                SavannaColors.sunset.withValues(alpha: 0.28 + pulse * 0.12),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(center: Offset(sunX, sunY), radius: sunRadius),
            ),
    );

    final grassBase = size.height * 0.82;
    final bladePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 48; i++) {
      final nx = i / 47;
      final x = nx * size.width;
      final sway = math.sin(progress * math.pi * 2 + i * 0.55) * 6;
      final height = 18 + (i % 5) * 6 + pulse * 8;
      bladePaint
        ..strokeWidth = 1.2 + (i % 3) * 0.4
        ..color = Color.lerp(
          SavannaColors.grassGold,
          SavannaColors.grassBright,
          (i % 7) / 7,
        )!.withValues(alpha: 0.35 + pulse * 0.25);
      canvas.drawLine(
        Offset(x, grassBase),
        Offset(x + sway, grassBase - height),
        bladePaint,
      );
    }

    final dust = Paint()..style = PaintingStyle.fill;
    final random = math.Random(19);
    for (var i = 0; i < 24; i++) {
      final phase = (progress + i * 0.04) % 1.0;
      final alpha = (math.sin(phase * math.pi * 2) + 1) / 2;
      if (alpha < 0.4) continue;
      dust.color = SavannaColors.grassLight.withValues(
        alpha: 0.04 + alpha * 0.08,
      );
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          size.height * (0.2 + random.nextDouble() * 0.55),
        ),
        0.8 + alpha,
        dust,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SavannaAtmospherePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class SavannaAnimatedBackground extends StatefulWidget {
  const SavannaAnimatedBackground({super.key});

  @override
  State<SavannaAnimatedBackground> createState() =>
      _SavannaAnimatedBackgroundState();
}

class _SavannaAnimatedBackgroundState extends State<SavannaAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
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
            painter: SavannaAtmospherePainter(progress: _controller.value),
            isComplex: true,
            willChange: true,
          ),
        );
      },
    );
  }
}

class AfricaSavannaPreview extends StatelessWidget {
  const AfricaSavannaPreview({
    super.key,
    this.borderRadius = BorderRadius.zero,
  });

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: const SizedBox.expand(
        child: SavannaAnimatedBackground(),
      ),
    );
  }
}

class AfricaSavannaAppShell extends StatelessWidget {
  const AfricaSavannaAppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PremiumThemeAppShell(
      backgroundColor: SavannaColors.soilDeep,
      background: const SavannaAnimatedBackground(),
      child: child,
    );
  }
}

/// Animated gold–grass–soil sweep around cards when savanna theme is active.
class SavannaShowcaseFrame extends StatefulWidget {
  const SavannaShowcaseFrame({
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.prominent = false,
    this.forceShow = false,
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final bool prominent;
  final bool forceShow;

  @override
  State<SavannaShowcaseFrame> createState() => _SavannaShowcaseFrameState();
}

class _SavannaShowcaseFrameState extends State<SavannaShowcaseFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.prominent ? 9000 : 11000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.forceShow && !AfricaSavannaThemeEffects.isActive(context)) {
      return widget.child;
    }

    final pad = widget.prominent ? 3.4 : 2.6;
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
        final glow = widget.prominent
            ? 0.32 + pulse * 0.48
            : 0.22 + pulse * 0.32;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: SweepGradient(
              colors: SavannaColors.borderGradient,
              stops: const [0.0, 0.1, 0.22, 0.36, 0.5, 0.64, 0.78, 0.9, 1.0],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
            boxShadow: [
              BoxShadow(
                color: SavannaColors.grassBright.withValues(alpha: glow),
                blurRadius: widget.prominent
                    ? 24 + pulse * 20
                    : 16 + pulse * 14,
                spreadRadius: widget.prominent ? 1.4 : 0.8,
              ),
              BoxShadow(
                color: SavannaColors.sunset.withValues(
                  alpha: 0.14 + pulse * 0.2,
                ),
                blurRadius: 30,
              ),
              BoxShadow(
                color: SavannaColors.soilWarm.withValues(
                  alpha: 0.12 + pulse * 0.1,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(borderRadius: innerRadius, child: child),
                Positioned.fill(
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: innerRadius,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(
                              math.cos(_controller.value * math.pi * 2),
                              math.sin(_controller.value * math.pi * 2),
                            ),
                            end: Alignment(
                              -math.cos(_controller.value * math.pi * 2),
                              -math.sin(_controller.value * math.pi * 2),
                            ),
                            colors: [
                              SavannaColors.grassLight.withValues(
                                alpha: 0.06 + pulse * 0.08,
                              ),
                              Colors.transparent,
                              SavannaColors.sunset.withValues(
                                alpha: 0.05 + pulse * 0.06,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
