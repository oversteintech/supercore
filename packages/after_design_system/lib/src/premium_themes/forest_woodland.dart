import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';
import 'premium_frame_style.dart';

/// Wild primal forest palette — lighter canopy, mist, moss and fireflies.
abstract final class ForestWoodlandColors {
  static const abyss = Color(0xFF0C1A10);
  static const canopyDeep = Color(0xFF163A1C);
  static const canopy = Color(0xFF244A28);
  static const mossDark = Color(0xFF2F5A32);
  static const moss = Color(0xFF458A48);
  static const fern = Color(0xFF5DAD5C);
  static const mist = Color(0xFF9BC4A0);
  static const mistBright = Color(0xFFC5E0C8);
  static const firefly = Color(0xFFD4F5A0);
  static const moonGlow = Color(0xFF7CB87A);
  static const bark = Color(0xFF3A2A1C);
  static const barkDeep = Color(0xFF1C140C);
  static const floor = Color(0xFF122018);

  static const canopyPalette = <Color>[
    mossDark,
    moss,
    fern,
    moonGlow,
    mist,
    mistBright,
  ];
}

class _ForestCanopy {
  const _ForestCanopy({
    required this.nx,
    required this.ny,
    required this.rx,
    required this.ry,
    required this.colorIndex,
  });

  final double nx;
  final double ny;
  final double rx;
  final double ry;
  final int colorIndex;
}

class _ForestTree {
  const _ForestTree({
    required this.nx,
    required this.trunkW,
    required this.trunkH,
    required this.swayPhase,
    required this.canopies,
  });

  final double nx;
  final double trunkW;
  final double trunkH;
  final double swayPhase;
  final List<_ForestCanopy> canopies;
}

class _Firefly {
  const _Firefly({
    required this.nx,
    required this.ny,
    required this.phase,
    required this.speed,
  });

  final double nx;
  final double ny;
  final double phase;
  final double speed;
}

const _trees = <_ForestTree>[
  _ForestTree(
    nx: 0.04,
    trunkW: 0.05,
    trunkH: 0.58,
    swayPhase: 0.1,
    canopies: [
      _ForestCanopy(nx: 0.04, ny: 0.12, rx: 0.18, ry: 0.14, colorIndex: 0),
      _ForestCanopy(nx: 0.01, ny: 0.18, rx: 0.14, ry: 0.11, colorIndex: 2),
    ],
  ),
  _ForestTree(
    nx: 0.18,
    trunkW: 0.042,
    trunkH: 0.52,
    swayPhase: 0.55,
    canopies: [
      _ForestCanopy(nx: 0.18, ny: 0.16, rx: 0.16, ry: 0.12, colorIndex: 1),
      _ForestCanopy(nx: 0.22, ny: 0.22, rx: 0.12, ry: 0.10, colorIndex: 3),
    ],
  ),
  _ForestTree(
    nx: 0.38,
    trunkW: 0.055,
    trunkH: 0.62,
    swayPhase: 1.2,
    canopies: [
      _ForestCanopy(nx: 0.38, ny: 0.10, rx: 0.20, ry: 0.15, colorIndex: 0),
      _ForestCanopy(nx: 0.34, ny: 0.17, rx: 0.15, ry: 0.11, colorIndex: 4),
    ],
  ),
  _ForestTree(
    nx: 0.58,
    trunkW: 0.048,
    trunkH: 0.55,
    swayPhase: 2,
    canopies: [
      _ForestCanopy(nx: 0.58, ny: 0.14, rx: 0.17, ry: 0.13, colorIndex: 2),
      _ForestCanopy(nx: 0.62, ny: 0.20, rx: 0.13, ry: 0.10, colorIndex: 5),
    ],
  ),
  _ForestTree(
    nx: 0.78,
    trunkW: 0.046,
    trunkH: 0.50,
    swayPhase: 2.8,
    canopies: [
      _ForestCanopy(nx: 0.78, ny: 0.18, rx: 0.16, ry: 0.12, colorIndex: 1),
      _ForestCanopy(nx: 0.74, ny: 0.24, rx: 0.11, ry: 0.09, colorIndex: 3),
    ],
  ),
  _ForestTree(
    nx: 0.94,
    trunkW: 0.04,
    trunkH: 0.46,
    swayPhase: 3.4,
    canopies: [
      _ForestCanopy(nx: 0.94, ny: 0.22, rx: 0.14, ry: 0.11, colorIndex: 0),
    ],
  ),
];

const _fireflies = <_Firefly>[
  _Firefly(nx: 0.12, ny: 0.42, phase: 0, speed: 1),
  _Firefly(nx: 0.28, ny: 0.55, phase: 0.7, speed: 1.3),
  _Firefly(nx: 0.45, ny: 0.38, phase: 1.4, speed: 0.9),
  _Firefly(nx: 0.61, ny: 0.48, phase: 2.1, speed: 1.1),
  _Firefly(nx: 0.73, ny: 0.60, phase: 2.8, speed: 1.2),
  _Firefly(nx: 0.86, ny: 0.44, phase: 3.5, speed: 0.85),
  _Firefly(nx: 0.33, ny: 0.68, phase: 4.2, speed: 1.15),
  _Firefly(nx: 0.52, ny: 0.72, phase: 5, speed: 1.05),
];

class WildForestAtmospherePainter extends CustomPainter {
  WildForestAtmospherePainter({required this.progress});

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
            ForestWoodlandColors.abyss,
            Color.lerp(
              ForestWoodlandColors.canopyDeep,
              ForestWoodlandColors.moss,
              0.28 + pulse * 0.12,
            )!,
            Color.lerp(
              ForestWoodlandColors.canopy,
              ForestWoodlandColors.fern,
              0.4 + pulse * 0.14,
            )!,
            ForestWoodlandColors.floor,
          ],
          stops: const [0.0, 0.30, 0.62, 1.0],
        ).createShader(rect),
    );

    _drawMoonShafts(canvas, size, pulse);
    _drawMistLayers(canvas, size, progress);

    for (final tree in _trees) {
      _drawTree(canvas, size, tree, progress);
    }

    _drawFernFloor(canvas, size, progress);
    _drawFireflies(canvas, size, progress);
    _drawVignette(canvas, size);
  }

  void _drawMoonShafts(Canvas canvas, Size size, double pulse) {
    final shaftPaint = Paint()..blendMode = BlendMode.plus;
    for (var index = 0; index < 4; index++) {
      final nx = 0.18 + index * 0.22;
      final sway = math.sin(progress * math.pi * 2 + index) * 0.035;
      final path = Path()
        ..moveTo(size.width * (nx + sway - 0.04), 0)
        ..lineTo(size.width * (nx + sway + 0.04), 0)
        ..lineTo(size.width * (nx + sway + 0.12), size.height * 0.72)
        ..lineTo(size.width * (nx + sway - 0.02), size.height * 0.72)
        ..close();
      shaftPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ForestWoodlandColors.moonGlow.withValues(alpha: 0.12 + pulse * 0.06),
          ForestWoodlandColors.fern.withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(path, shaftPaint);
    }
  }

  void _drawMistLayers(Canvas canvas, Size size, double progress) {
    final mistPaint = Paint()..style = PaintingStyle.fill;
    for (var layer = 0; layer < 3; layer++) {
      final drift =
          math.sin(progress * math.pi * 2 + layer * 1.4) * size.width * 0.08;
      final baseY = size.height * (0.26 + layer * 0.18);
      final alpha = 0.07 + layer * 0.03;
      mistPaint.color = ForestWoodlandColors.mistBright.withValues(
        alpha: alpha,
      );
      final path = Path()
        ..moveTo(-size.width * 0.1 + drift, baseY)
        ..quadraticBezierTo(
          size.width * 0.25 + drift,
          baseY - size.height * 0.05,
          size.width * 0.55 + drift,
          baseY + size.height * 0.02,
        )
        ..quadraticBezierTo(
          size.width * 0.85 + drift,
          baseY + size.height * 0.05,
          size.width * 1.1 + drift,
          baseY - size.height * 0.01,
        )
        ..lineTo(size.width * 1.1 + drift, size.height)
        ..lineTo(-size.width * 0.1 + drift, size.height)
        ..close();
      canvas.drawPath(path, mistPaint);
    }
  }

  void _drawTree(
    Canvas canvas,
    Size size,
    _ForestTree tree,
    double progress,
  ) {
    final sway =
        math.sin(progress * math.pi * 2 + tree.swayPhase) * size.width * 0.016;
    final trunkX = tree.nx * size.width + sway;
    final trunkW = tree.trunkW * size.width;
    final trunkH = tree.trunkH * size.height;
    final trunkTop = size.height - trunkH;
    final trunkRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(trunkX - trunkW / 2, trunkTop, trunkW, trunkH),
      Radius.circular(trunkW * 0.18),
    );

    canvas.drawRRect(
      trunkRect,
      Paint()..color = ForestWoodlandColors.bark.withValues(alpha: 0.95),
    );
    canvas.drawRRect(
      trunkRect.deflate(trunkW * 0.18),
      Paint()..color = ForestWoodlandColors.barkDeep.withValues(alpha: 0.45),
    );

    for (final canopy in tree.canopies) {
      _drawCanopy(
        canvas,
        size,
        _ForestCanopy(
          nx: canopy.nx,
          ny: canopy.ny,
          rx: canopy.rx,
          ry: canopy.ry,
          colorIndex: canopy.colorIndex,
        ),
        sway,
        0.72,
      );
    }
  }

  void _drawCanopy(
    Canvas canvas,
    Size size,
    _ForestCanopy canopy,
    double sway,
    double alpha,
  ) {
    final color =
        ForestWoodlandColors.canopyPalette[canopy.colorIndex %
            ForestWoodlandColors.canopyPalette.length];
    final cx = canopy.nx * size.width + sway;
    final cy = canopy.ny * size.height;
    final rx = canopy.rx * size.width;
    final ry = canopy.ry * size.height;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
      Paint()..color = color.withValues(alpha: alpha),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy - ry * 0.15),
        width: rx * 1.35,
        height: ry * 1.2,
      ),
      Paint()
        ..color = ForestWoodlandColors.canopyDeep.withValues(
          alpha: alpha * 0.55,
        ),
    );
  }

  void _drawFernFloor(Canvas canvas, Size size, double progress) {
    final baseY = size.height * 0.88;
    final bladePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 56; index++) {
      final nx = index / 55;
      final sway = math.sin(progress * math.pi * 2 + index * 0.62) * 7;
      final height = 16 + (index % 6) * 5;
      bladePaint
        ..strokeWidth = 1.1 + (index % 3) * 0.35
        ..color = Color.lerp(
          ForestWoodlandColors.mossDark,
          ForestWoodlandColors.fern,
          (index % 8) / 8,
        )!.withValues(alpha: 0.28 + (index % 4) * 0.06);
      canvas.drawLine(
        Offset(nx * size.width, baseY),
        Offset(nx * size.width + sway, baseY - height),
        bladePaint,
      );
    }
  }

  void _drawFireflies(Canvas canvas, Size size, double progress) {
    final glowPaint = Paint();
    for (final fly in _fireflies) {
      final flicker =
          (math.sin(progress * math.pi * 2 * fly.speed + fly.phase) + 1) / 2;
      if (flicker < 0.35) {
        continue;
      }
      final driftX =
          math.sin(progress * math.pi * 2 + fly.phase) * size.width * 0.015;
      final driftY =
          math.cos(progress * math.pi * 2 + fly.phase * 1.3) *
          size.height *
          0.012;
      final center = Offset(
        fly.nx * size.width + driftX,
        fly.ny * size.height + driftY,
      );
      glowPaint.color = ForestWoodlandColors.firefly.withValues(
        alpha: 0.12 + flicker * 0.55,
      );
      canvas.drawCircle(center, 2.2 + flicker * 2.4, glowPaint);
      glowPaint.color = ForestWoodlandColors.mistBright.withValues(
        alpha: 0.35 + flicker * 0.45,
      );
      canvas.drawCircle(center, 0.8 + flicker * 0.6, glowPaint);
    }
  }

  void _drawVignette(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.05,
          colors: [
            Colors.transparent,
            ForestWoodlandColors.abyss.withValues(alpha: 0.12),
            ForestWoodlandColors.abyss.withValues(alpha: 0.42),
          ],
          stops: const [0.45, 0.78, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant WildForestAtmospherePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class WildForestAnimatedBackground extends StatefulWidget {
  const WildForestAnimatedBackground({super.key});

  @override
  State<WildForestAnimatedBackground> createState() =>
      _WildForestAnimatedBackgroundState();
}

class _WildForestAnimatedBackgroundState
    extends State<WildForestAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce == _reduceMotion) {
      if (!reduce && !_controller.isAnimating) {
        _controller.repeat();
      }
      return;
    }
    _reduceMotion = reduce;
    if (reduce) {
      _controller.stop();
      _controller.value = 0.25;
    } else {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox.expand(
          child: CustomPaint(
            painter: WildForestAtmospherePainter(
              progress: _reduceMotion ? 0.25 : _controller.value,
            ),
            isComplex: true,
            willChange: !_reduceMotion,
          ),
        );
      },
    );
  }
}

class ForestWoodlandBackground extends StatelessWidget {
  const ForestWoodlandBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: SuperGarageColors.forestBackground,
      child: WildForestAnimatedBackground(),
    );
  }
}

class ForestWoodlandPreview extends StatelessWidget {
  const ForestWoodlandPreview({
    super.key,
    this.borderRadius = BorderRadius.zero,
  });

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: const WildForestAnimatedBackground(),
    );
  }
}

class ForestWoodlandAppShell extends StatelessWidget {
  const ForestWoodlandAppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PremiumThemeAppShell(
      backgroundColor: SuperGarageColors.forestBackground,
      background: const WildForestAnimatedBackground(),
      child: child,
    );
  }
}

@immutable
class ForestWoodlandThemeEffects extends ThemeExtension<ForestWoodlandThemeEffects> {
  const ForestWoodlandThemeEffects({this.enabled = false});

  final bool enabled;

  static ForestWoodlandThemeEffects? of(BuildContext context) {
    return Theme.of(context).extension<ForestWoodlandThemeEffects>();
  }

  static bool isActive(BuildContext context) => of(context)?.enabled ?? false;

  @override
  ForestWoodlandThemeEffects copyWith({bool? enabled}) {
    return ForestWoodlandThemeEffects(enabled: enabled ?? this.enabled);
  }

  @override
  ForestWoodlandThemeEffects lerp(ForestWoodlandThemeEffects? other, double t) {
    if (other == null) return this;
    return ForestWoodlandThemeEffects(
      enabled: t < 0.5 ? enabled : other.enabled,
    );
  }
}

class ForestShowcaseFrame extends StatefulWidget {
  const ForestShowcaseFrame({
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.prominent = true,
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
  State<ForestShowcaseFrame> createState() => _ForestShowcaseFrameState();
}

class _ForestShowcaseFrameState extends State<ForestShowcaseFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Duration get _duration => Duration(
        milliseconds: widget.resolvedStyle.borderMs(
          showcaseMs: 22000,
          softMs: 26000,
          menuMs: 32000,
        ),
      );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant ForestShowcaseFrame oldWidget) {
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
    if (!widget.forceShow && !ForestWoodlandThemeEffects.isActive(context)) {
      return widget.child;
    }

    final style = widget.resolvedStyle;
    final scale = style.glowScale;
    final pad = 1.8 + style.padExtra * 1.2;
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
        final spin = _controller.value * 2 * math.pi;
        final glow = (0.10 + pulse * 0.16) * scale;
        final blur = (6.0 + pulse * 6) + style.padExtra * 6;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: SweepGradient(
              colors: const [
                Color(0xFF3D6B40),
                Color(0xFF5DAD5C),
                Color(0xFFD4F5A0),
                Color(0xFF458A48),
                Color(0xFF3D6B40),
              ],
              transform: GradientRotation(spin),
            ),
            boxShadow: [
              BoxShadow(
                color: ForestWoodlandColors.fern.withValues(alpha: glow),
                blurRadius: blur,
                spreadRadius: (0.12 + pulse * 0.18) * scale,
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
    return Radius.elliptical(
      math.max(radius.x - amount, 0),
      math.max(radius.y - amount, 0),
    );
  }
}
