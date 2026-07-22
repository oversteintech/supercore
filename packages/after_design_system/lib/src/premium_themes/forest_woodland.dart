import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// Wild primal forest palette — deep canopy, mist, moss and fireflies.
abstract final class ForestWoodlandColors {
  static const abyss = Color(0xFF040804);
  static const canopyDeep = Color(0xFF0E160E);
  static const canopy = Color(0xFF1A2818);
  static const mossDark = Color(0xFF243824);
  static const moss = Color(0xFF355A36);
  static const fern = Color(0xFF4A7448);
  static const mist = Color(0xFF7A9480);
  static const mistBright = Color(0xFF9CB8A0);
  static const firefly = Color(0xFFB8E986);
  static const moonGlow = Color(0xFF5A7A58);
  static const bark = Color(0xFF241A12);
  static const barkDeep = Color(0xFF120C08);
  static const floor = Color(0xFF0A1008);

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
              ForestWoodlandColors.mossDark,
              0.25 + pulse * 0.08,
            )!,
            Color.lerp(
              ForestWoodlandColors.canopy,
              ForestWoodlandColors.moss,
              0.35 + pulse * 0.12,
            )!,
            ForestWoodlandColors.floor,
          ],
          stops: const [0.0, 0.32, 0.62, 1.0],
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
      final sway = math.sin(progress * math.pi * 2 + index) * 0.03;
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
          ForestWoodlandColors.moonGlow.withValues(alpha: 0.08 + pulse * 0.04),
          ForestWoodlandColors.moss.withValues(alpha: 0.03),
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
          math.sin(progress * math.pi * 2 + layer * 1.4) * size.width * 0.06;
      final baseY = size.height * (0.28 + layer * 0.18);
      final alpha = 0.05 + layer * 0.02;
      mistPaint.color = ForestWoodlandColors.mist.withValues(alpha: alpha);
      final path = Path()
        ..moveTo(-size.width * 0.1 + drift, baseY)
        ..quadraticBezierTo(
          size.width * 0.25 + drift,
          baseY - size.height * 0.04,
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
        math.sin(progress * math.pi * 2 + tree.swayPhase) * size.width * 0.012;
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
            ForestWoodlandColors.abyss.withValues(alpha: 0.18),
            ForestWoodlandColors.abyss.withValues(alpha: 0.62),
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
            painter: WildForestAtmospherePainter(progress: _controller.value),
            isComplex: true,
            willChange: true,
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
