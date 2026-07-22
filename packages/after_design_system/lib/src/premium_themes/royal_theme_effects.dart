import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'premium_frame_style.dart';
import 'premium_theme_shell.dart';
import 'package:after_core/after_core.dart';
import 'theme.dart' show BrightGoldThemeEffects, SuperGarageColors;

/// Animated imperial atmosphere — purple, gold & black with sparkles.
class RoyalAnimatedBackground extends StatefulWidget {
  const RoyalAnimatedBackground({super.key});

  @override
  State<RoyalAnimatedBackground> createState() =>
      _RoyalAnimatedBackgroundState();
}

class _RoyalAnimatedBackgroundState extends State<RoyalAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
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
            painter: RoyalAtmospherePainter(progress: _controller.value),
            isComplex: true,
            willChange: true,
          ),
        );
      },
    );
  }
}

class RoyalAppShell extends StatelessWidget {
  const RoyalAppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PremiumThemeAppShell(
      backgroundColor: SuperGarageColors.royalBackground,
      background: const RoyalAnimatedBackground(),
      child: child,
    );
  }
}

/// Rotating gold–violet border with traveling sparkles.
class RoyalShowcaseFrame extends StatefulWidget {
  const RoyalShowcaseFrame({
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.prominent = false,
    this.style,
    this.forceShow = false,
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final bool prominent;
  final PremiumFrameStyle? style;

  /// Settings preview tiles — always animate regardless of active theme.
  final bool forceShow;

  PremiumFrameStyle get resolvedStyle =>
      style ?? PremiumFrameStyleX.fromProminent(prominent);

  @override
  State<RoyalShowcaseFrame> createState() => _RoyalShowcaseFrameState();
}

class _RoyalShowcaseFrameState extends State<RoyalShowcaseFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _borderGradient = [
    Color(0xFFE8E8ED),
    Color(0xFF9C27B0),
    Colors.white,
    Color(0xFFD4AF37),
    Color(0xFFFFD54F),
    Color(0xFF7B1FA2),
    Color(0xFFC0C0C8),
    Color(0xFF4A148C),
  ];

  static const _goldBorderGradient = [
    SuperGarageColors.goldDeep,
    SuperGarageColors.goldBright,
    SuperGarageColors.goldShine,
    Colors.white,
    SuperGarageColors.goldBright,
    SuperGarageColors.goldBorder,
    SuperGarageColors.goldShine,
    SuperGarageColors.goldDeep,
  ];

  Duration get _duration => Duration(
    milliseconds: widget.resolvedStyle.borderMs(
      showcaseMs: 32000,
      softMs: 26000,
      menuMs: 36000,
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant RoyalShowcaseFrame oldWidget) {
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
    final isBrightGold = BrightGoldThemeEffects.isActive(context);
    if (!widget.forceShow && !isBrightGold) {
      return widget.child;
    }

    final style = widget.resolvedStyle;
    final scale = style.glowScale;
    final pad = 1.7 + style.padExtra * 1.3;
    final innerRadius = BorderRadius.only(
      topLeft: _shrink(widget.borderRadius.topLeft, pad),
      topRight: _shrink(widget.borderRadius.topRight, pad),
      bottomLeft: _shrink(widget.borderRadius.bottomLeft, pad),
      bottomRight: _shrink(widget.borderRadius.bottomRight, pad),
    );
    final gradientColors = isBrightGold ? _goldBorderGradient : _borderGradient;
    final glowColor = isBrightGold
        ? SuperGarageColors.goldBright
        : SuperGarageColors.royalGold;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = (math.sin(_controller.value * math.pi * 2) + 1) / 2;
        final glow = (0.04 + pulse * 0.05) * scale;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: SweepGradient(
              colors: gradientColors,
              stops: const [0.0, 0.12, 0.22, 0.38, 0.52, 0.68, 0.84, 1.0],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: glow),
                blurRadius: (8 + pulse * 6) + style.padExtra * 6,
                spreadRadius: 0.2 + style.padExtra * 0.4,
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

class _RoyalParticle {
  const _RoyalParticle({
    required this.nx,
    required this.ny,
    required this.phase,
    required this.speed,
    required this.size,
    required this.tone,
  });

  final double nx;
  final double ny;
  final double phase;
  final double speed;
  final double size;
  final int tone;
}

const _royalParticles = <_RoyalParticle>[
  _RoyalParticle(nx: 0.08, ny: 0.12, phase: 0, speed: 0.9, size: 2.2, tone: 0),
  _RoyalParticle(
    nx: 0.22,
    ny: 0.28,
    phase: 0.15,
    speed: 1.1,
    size: 1.6,
    tone: 2,
  ),
  _RoyalParticle(
    nx: 0.38,
    ny: 0.08,
    phase: 0.32,
    speed: 0.7,
    size: 2.8,
    tone: 0,
  ),
  _RoyalParticle(
    nx: 0.52,
    ny: 0.22,
    phase: 0.48,
    speed: 1.3,
    size: 1.4,
    tone: 1,
  ),
  _RoyalParticle(
    nx: 0.68,
    ny: 0.14,
    phase: 0.62,
    speed: 0.85,
    size: 2,
    tone: 0,
  ),
  _RoyalParticle(nx: 0.84, ny: 0.32, phase: 0.78, speed: 1, size: 1.8, tone: 2),
  _RoyalParticle(
    nx: 0.14,
    ny: 0.52,
    phase: 0.22,
    speed: 1.2,
    size: 2.4,
    tone: 0,
  ),
  _RoyalParticle(
    nx: 0.30,
    ny: 0.64,
    phase: 0.38,
    speed: 0.75,
    size: 1.5,
    tone: 1,
  ),
  _RoyalParticle(
    nx: 0.46,
    ny: 0.48,
    phase: 0.55,
    speed: 1.05,
    size: 2.6,
    tone: 0,
  ),
  _RoyalParticle(
    nx: 0.62,
    ny: 0.58,
    phase: 0.71,
    speed: 0.95,
    size: 1.7,
    tone: 2,
  ),
  _RoyalParticle(
    nx: 0.78,
    ny: 0.46,
    phase: 0.88,
    speed: 1.15,
    size: 2.1,
    tone: 0,
  ),
  _RoyalParticle(
    nx: 0.92,
    ny: 0.68,
    phase: 0.05,
    speed: 0.8,
    size: 1.9,
    tone: 1,
  ),
  _RoyalParticle(
    nx: 0.10,
    ny: 0.78,
    phase: 0.28,
    speed: 1.25,
    size: 2.3,
    tone: 0,
  ),
  _RoyalParticle(
    nx: 0.26,
    ny: 0.86,
    phase: 0.44,
    speed: 0.65,
    size: 1.3,
    tone: 2,
  ),
  _RoyalParticle(nx: 0.44, ny: 0.74, phase: 0.59, speed: 1, size: 2.5, tone: 0),
  _RoyalParticle(
    nx: 0.58,
    ny: 0.88,
    phase: 0.73,
    speed: 0.9,
    size: 1.6,
    tone: 1,
  ),
  _RoyalParticle(nx: 0.72, ny: 0.76, phase: 0.86, speed: 1.1, size: 2, tone: 0),
  _RoyalParticle(
    nx: 0.88,
    ny: 0.84,
    phase: 0.12,
    speed: 0.7,
    size: 1.8,
    tone: 2,
  ),
  _RoyalParticle(
    nx: 0.18,
    ny: 0.38,
    phase: 0.67,
    speed: 1.35,
    size: 1.2,
    tone: 1,
  ),
  _RoyalParticle(
    nx: 0.54,
    ny: 0.36,
    phase: 0.91,
    speed: 0.88,
    size: 2.7,
    tone: 0,
  ),
  _RoyalParticle(
    nx: 0.96,
    ny: 0.18,
    phase: 0.34,
    speed: 1.05,
    size: 1.5,
    tone: 0,
  ),
  _RoyalParticle(
    nx: 0.04,
    ny: 0.44,
    phase: 0.51,
    speed: 0.92,
    size: 2.2,
    tone: 2,
  ),
  _RoyalParticle(
    nx: 0.36,
    ny: 0.92,
    phase: 0.19,
    speed: 1.18,
    size: 1.4,
    tone: 0,
  ),
  _RoyalParticle(
    nx: 0.66,
    ny: 0.04,
    phase: 0.82,
    speed: 0.78,
    size: 2.9,
    tone: 0,
  ),
];

class RoyalAtmospherePainter extends CustomPainter {
  RoyalAtmospherePainter({
    required this.progress,
    this.royalMix = false,
  });

  final double progress;
  final bool royalMix;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final pulse = (math.sin(progress * math.pi * 2) + 1) / 2;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: royalMix
              ? [
                  const Color(0xFF1A1035),
                  Color.lerp(
                    const Color(0xFF4A148C),
                    const Color(0xFF7B1FA2),
                    pulse * 0.45,
                  )!,
                  const Color(0xFF2A2340),
                  const Color(0xFF120A1E),
                ]
              : [
                  SuperGarageColors.royalIndigo,
                  Color.lerp(
                    SuperGarageColors.royalViolet,
                    SuperGarageColors.royalPurpleDeep,
                    pulse * 0.35,
                  )!,
                  SuperGarageColors.royalBackground,
                  const Color(0xFF01050C),
                ],
          stops: [0.0, 0.28 + pulse * 0.08, 0.68, 1.0],
        ).createShader(rect),
    );

    _drawShimmerSweep(canvas, size, progress);

    for (final particle in _royalParticles) {
      final twinkle =
          (math.sin(
                (progress * particle.speed + particle.phase) * math.pi * 2,
              ) +
              1) /
          2;
      if (twinkle < 0.22) continue;

      final driftX =
          math.sin((progress + particle.phase) * math.pi * 2) * 0.012;
      final driftY =
          math.cos((progress + particle.phase) * math.pi * 2) * 0.010;
      final x = (particle.nx + driftX) * size.width;
      final y = (particle.ny + driftY) * size.height;
      final color = royalMix
          ? switch (particle.tone) {
              0 => const Color(0xFFFFD54F),
              1 => const Color(0xFFCE93D8),
              _ => const Color(0xFFE8E8ED),
            }
          : switch (particle.tone) {
              0 => SuperGarageColors.royalGold,
              1 => SuperGarageColors.royalViolet,
              _ => Colors.white,
            };

      _drawStarSparkle(
        canvas,
        Offset(x, y),
        particle.size * (0.7 + twinkle * 0.8),
        color.withValues(alpha: 0.25 + twinkle * 0.65),
      );
    }

    final sonicBurst = Offset(
      size.width * (0.18 + math.sin(progress * math.pi * 2) * 0.06),
      size.height * (0.42 + math.cos(progress * math.pi * 2) * 0.04),
    );
    canvas.drawCircle(
      sonicBurst,
      size.shortestSide * (0.38 + pulse * 0.08),
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                SuperGarageColors.royalViolet.withValues(
                  alpha: 0.22 + pulse * 0.16,
                ),
                SuperGarageColors.royalGold.withValues(alpha: 0.12),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(
                center: sonicBurst,
                radius: size.shortestSide * 0.5,
              ),
            ),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.48),
              ],
              stops: const [0.52, 1.0],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.5, size.height * 0.52),
                radius: size.shortestSide * math.sqrt(2) * 0.58,
              ),
            ),
    );
  }

  void _drawShimmerSweep(Canvas canvas, Size size, double progress) {
    final sweepX = (progress * 1.4 - 0.2) * size.width;
    final shimmerRect = Rect.fromLTWH(
      sweepX - size.width * 0.35,
      0,
      size.width * 0.55,
      size.height,
    );
    canvas.drawRect(
      shimmerRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            SuperGarageColors.royalGold.withValues(alpha: 0),
            SuperGarageColors.royalGold.withValues(alpha: 0.11),
            Colors.white.withValues(alpha: 0.07),
            SuperGarageColors.royalGold.withValues(alpha: 0.11),
            Colors.transparent,
          ],
          stops: const [0.0, 0.25, 0.45, 0.5, 0.55, 1.0],
        ).createShader(shimmerRect),
    );
  }

  @override
  bool shouldRepaint(covariant RoyalAtmospherePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.royalMix != royalMix;
  }
}

class RoyalSparkleOverlayPainter extends CustomPainter {
  RoyalSparkleOverlayPainter({
    required this.progress,
    required this.prominent,
    this.goldPalette = false,
  });

  final double progress;
  final bool prominent;
  final bool goldPalette;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < 4 || size.height < 4) {
      return;
    }

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(14));
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().toList(growable: false);
    if (metrics.isEmpty) {
      return;
    }

    final metric = metrics.first;
    final length = metric.length;
    final sparkleCount = prominent ? 10 : 6;

    for (var i = 0; i < sparkleCount; i++) {
      final phase = (progress * 1.15 + i / sparkleCount) % 1.0;
      final tangent = metric.getTangentForOffset(phase * length);
      if (tangent == null) continue;

      final flicker = (math.sin((progress + i * 0.13) * math.pi * 5) + 1) / 2;
      if (flicker < 0.28) continue;

      final sizePx = lerpDouble(2.0, prominent ? 6.5 : 5.0, flicker)!;
      _drawStarSparkle(
        canvas,
        tangent.position,
        sizePx,
        Color.lerp(
          goldPalette
              ? SuperGarageColors.goldBright
              : SuperGarageColors.royalGold,
          Colors.white,
          flicker,
        )!.withValues(alpha: 0.55 + flicker * 0.45),
      );
    }

    for (var i = 0; i < (prominent ? 14 : 8); i++) {
      final px = (i * 0.137 + progress * 0.22) % 1.0;
      final py = (i * 0.089 + progress * 0.17) % 1.0;
      final flicker = (math.sin((progress + i * 0.21) * math.pi * 3) + 1) / 2;
      if (flicker < 0.35) continue;
      _drawStarSparkle(
        canvas,
        Offset(px * size.width, py * size.height),
        lerpDouble(1.2, 3.2, flicker)!,
        (goldPalette
                ? SuperGarageColors.goldShine
                : SuperGarageColors.royalGoldSoft)
            .withValues(alpha: 0.2 + flicker * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant RoyalSparkleOverlayPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.prominent != prominent ||
        oldDelegate.goldPalette != goldPalette;
  }
}

void _drawStarSparkle(Canvas canvas, Offset center, double size, Color color) {
  final paint = Paint()..color = color;
  canvas.drawCircle(center, size * 0.35, paint);

  final path = Path()
    ..moveTo(center.dx, center.dy - size)
    ..lineTo(center.dx, center.dy + size)
    ..moveTo(center.dx - size, center.dy)
    ..lineTo(center.dx + size, center.dy)
    ..moveTo(center.dx - size * 0.72, center.dy - size * 0.72)
    ..lineTo(center.dx + size * 0.72, center.dy + size * 0.72)
    ..moveTo(center.dx + size * 0.72, center.dy - size * 0.72)
    ..lineTo(center.dx - size * 0.72, center.dy + size * 0.72);

  canvas.drawPath(
    path,
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(size * 0.22, 0.8)
      ..strokeCap = StrokeCap.round,
  );
  paint.style = PaintingStyle.fill;
}

/// Hero settings tile — maximum sparkle for the coming-soon Royal theme.
class RoyalThemeShowcaseTile extends StatefulWidget {
  const RoyalThemeShowcaseTile({
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final String badgeLabel;
  final VoidCallback onTap;

  @override
  State<RoyalThemeShowcaseTile> createState() => _RoyalThemeShowcaseTileState();
}

class _RoyalThemeShowcaseTileState extends State<RoyalThemeShowcaseTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _haloController;

  static const _icon = Icons.workspace_premium_rounded;

  @override
  void initState() {
    super.initState();
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _haloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _haloController,
      builder: (context, _) {
        final pulse = _haloController.value;

        return RoyalShowcaseFrame(
          prominent: true,
          forceShow: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: RoyalAtmospherePainter(
                        progress: pulse * 0.35,
                        royalMix: true,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.08),
                            Colors.black.withValues(alpha: 0.38),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 96),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RoyalCrownBadge(
                            icon: _icon,
                            pulse: pulse,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      begin: Alignment(-1.0 + pulse * 2.4, 0),
                                      end: Alignment(0.2 + pulse * 2.4, 0),
                                      colors: const [
                                        Color(0xFFE8E8ED),
                                        Color(0xFFFFD54F),
                                        Color(0xFFCE93D8),
                                        Color(0xFFD4AF37),
                                      ],
                                      stops: const [0.0, 0.35, 0.55, 1.0],
                                    ).createShader(bounds);
                                  },
                                  child: Text(
                                    widget.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 17,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                RoyalMembershipBadge(
                                  tierLabel: widget.badgeLabel,
                                  showComingSoon: true,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.subtitle,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: SuperGarageColors.royalForeground
                                        .withValues(alpha: 0.88),
                                    height: 1.35,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.hourglass_top_rounded,
                            color: SuperGarageColors.royalGold.withValues(
                              alpha: 0.65 + pulse * 0.35,
                            ),
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Pulsing purple–gold crown badge shared by Royal UI surfaces.
class RoyalCrownBadge extends StatelessWidget {
  const RoyalCrownBadge({
    required this.icon,
    required this.pulse,
    this.compact = false,
    super.key,
  });

  final IconData icon;
  final double pulse;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scale = 1 + pulse * 0.12;
    final size = compact ? 44.0 : 58.0;
    final iconSize = compact ? 22.0 : 30.0;
    final radius = compact ? 14.0 : 18.0;
    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: const SweepGradient(
              colors: [
                Color(0xFFE8E8ED),
                Color(0xFFD4AF37),
                Colors.white,
                Color(0xFF9C27B0),
                Color(0xFFFFD54F),
                Color(0xFF7B1FA2),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: SuperGarageColors.royalGold.withValues(
                  alpha: 0.35 + pulse * 0.45,
                ),
                blurRadius: 14 + pulse * 12,
                spreadRadius: 0.8,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(compact ? 1.8 : 2.4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius - 3),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: const [
                    Color(0xFF311B92),
                    Color(0xFF1A1035),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: const Color(0xFFFFD54F),
                  size: iconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated section banner for Royal membership themes.
class RoyalThemesShowcaseBanner extends StatefulWidget {
  const RoyalThemesShowcaseBanner({
    required this.title,
    required this.subtitle,
    required this.expanded,
    this.locked = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool expanded;
  final bool locked;

  @override
  State<RoyalThemesShowcaseBanner> createState() =>
      _RoyalThemesShowcaseBannerState();
}

class _RoyalThemesShowcaseBannerState extends State<RoyalThemesShowcaseBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _haloController;

  static const _icon = Icons.military_tech_rounded;

  @override
  void initState() {
    super.initState();
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _haloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _haloController,
      builder: (context, _) {
        final pulse = _haloController.value;
        final atmosphereProgress = pulse * 0.35;

        return RoyalShowcaseFrame(
          borderRadius: BorderRadius.circular(16),
          prominent: true,
          forceShow: true,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: RoyalAtmospherePainter(
                      progress: atmosphereProgress,
                      royalMix: true,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.06),
                          Colors.black.withValues(alpha: 0.46),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: RoyalSparkleOverlayPainter(
                        progress: atmosphereProgress,
                        prominent: true,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RoyalCrownBadge(
                            icon: _icon,
                            pulse: pulse,
                            compact: true,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      begin: Alignment(-1.0 + pulse * 2.4, 0),
                                      end: Alignment(0.2 + pulse * 2.4, 0),
                                      colors: const [
                                        Color(0xFFE8E8ED),
                                        Color(0xFFFFD54F),
                                        Color(0xFFCE93D8),
                                        Color(0xFFD4AF37),
                                      ],
                                      stops: const [0.0, 0.35, 0.55, 1.0],
                                    ).createShader(bounds);
                                  },
                                  child: Text(
                                    widget.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      letterSpacing: -0.2,
                                      height: 1.15,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                RoyalMembershipBadge(
                                  tierLabel: AfterMembershipBadge.royal,
                                  showComingSoon: false,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (widget.locked)
                            Icon(
                              Icons.lock_rounded,
                              color: SuperGarageColors.royalGold.withValues(
                                alpha: 0.65 + pulse * 0.35,
                              ),
                              size: 20,
                            )
                          else
                            AnimatedRotation(
                              turns: widget.expanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeInOut,
                              child: Icon(
                                Icons.expand_more_rounded,
                                color: SuperGarageColors.royalForeground
                                    .withValues(alpha: 0.9),
                                size: 22,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4A148C).withValues(alpha: 0.78),
                              const Color(0xFF1A1035).withValues(alpha: 0.62),
                              const Color(0xFFB8860B).withValues(alpha: 0.38),
                              const Color(0xFFC0C0C8).withValues(alpha: 0.28),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFFFFD54F).withValues(
                              alpha: 0.45 + pulse * 0.25,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Text(
                            widget.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFFF3E5F5).withValues(
                                alpha: 0.94,
                              ),
                              height: 1.25,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ROYAL + optional COMING SOON badge.
class RoyalMembershipBadge extends StatelessWidget {
  const RoyalMembershipBadge({
    required this.tierLabel,
    this.showComingSoon = false,
    super.key,
  });

  final String tierLabel;
  final bool showComingSoon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: SuperGarageColors.royalGold.withValues(alpha: 0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: SuperGarageColors.royalGold.withValues(
              alpha: showComingSoon ? 0.22 : 0.12,
            ),
            blurRadius: showComingSoon ? 10 : 4,
          ),
        ],
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(
            Icons.military_tech_rounded,
            size: 13,
            color: SuperGarageColors.royalGold.withValues(alpha: 0.95),
          ),
          Text(
            tierLabel,
            style: const TextStyle(
              color: SuperGarageColors.royalGold,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 0.35,
              height: 1.1,
            ),
          ),
          if (showComingSoon) ...[
            Container(
              width: 1,
              height: 11,
              color: SuperGarageColors.royalForeground.withValues(alpha: 0.35),
            ),
            Text(
              AfterMembershipBadge.comingSoon,
              style: TextStyle(
                color: SuperGarageColors.royalForeground.withValues(
                  alpha: 0.88,
                ),
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 0.25,
                height: 1.1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
