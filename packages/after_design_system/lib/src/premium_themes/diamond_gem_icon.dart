import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'theme.dart' show DiamondThemeEffects, SuperGarageColors;

/// Faceted diamond gem — animated shimmer for the Diamond royal theme.
class DiamondGemIcon extends StatefulWidget {
  const DiamondGemIcon({
    this.size = 18,
    this.prominent = false,
    super.key,
  });

  final double size;
  final bool prominent;

  @override
  State<DiamondGemIcon> createState() => _DiamondGemIconState();
}

class _DiamondGemIconState extends State<DiamondGemIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.prominent ? 2400 : 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!DiamondThemeEffects.isActive(context)) {
      return Icon(
        Icons.diamond_rounded,
        size: widget.size,
        color: SuperGarageColors.diamondIce,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pulse = (math.sin(_controller.value * math.pi * 2) + 1) / 2;
        return CustomPaint(
          size: Size.square(widget.size),
          painter: DiamondGemPainter(
            progress: _controller.value,
            pulse: pulse,
            prominent: widget.prominent,
          ),
        );
      },
    );
  }
}

/// Corner + edge diamond accents for premium shells and scaffolds.
class DiamondGemScatterOverlay extends StatefulWidget {
  const DiamondGemScatterOverlay({super.key});

  @override
  State<DiamondGemScatterOverlay> createState() =>
      _DiamondGemScatterOverlayState();
}

class _DiamondGemScatterOverlayState extends State<DiamondGemScatterOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _anchors = <_GemAnchor>[
    _GemAnchor(alignment: Alignment(-0.98, -0.98), size: 14, phase: 0),
    _GemAnchor(alignment: Alignment(0.98, -0.98), size: 12, phase: 0.17),
    _GemAnchor(alignment: Alignment(-0.98, 0.98), size: 11, phase: 0.34),
    _GemAnchor(alignment: Alignment(0.98, 0.98), size: 13, phase: 0.51),
    _GemAnchor(alignment: Alignment(-0.92, 0), size: 9, phase: 0.68),
    _GemAnchor(alignment: Alignment(0.92, 0), size: 10, phase: 0.83),
    _GemAnchor(alignment: Alignment(0, -0.96), size: 10, phase: 0.25),
    _GemAnchor(alignment: Alignment(0, 0.96), size: 9, phase: 0.42),
    _GemAnchor(alignment: Alignment(-0.55, -0.72), size: 8, phase: 0.58),
    _GemAnchor(alignment: Alignment(0.55, -0.72), size: 8, phase: 0.74),
    _GemAnchor(alignment: Alignment(-0.55, 0.72), size: 7, phase: 0.9),
    _GemAnchor(alignment: Alignment(0.55, 0.72), size: 7, phase: 0.12),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!DiamondThemeEffects.isActive(context)) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final pulse = (math.sin(_controller.value * math.pi * 2) + 1) / 2;
          return Stack(
            fit: StackFit.expand,
            children: [
              for (final anchor in _anchors)
                Align(
                  alignment: anchor.alignment,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Opacity(
                      opacity: 0.35 + pulse * 0.45,
                      child: CustomPaint(
                        size: Size.square(anchor.size),
                        painter: DiamondGemPainter(
                          progress: _controller.value + anchor.phase,
                          pulse: pulse,
                          prominent: anchor.size >= 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _GemAnchor {
  const _GemAnchor({
    required this.alignment,
    required this.size,
    required this.phase,
  });

  final Alignment alignment;
  final double size;
  final double phase;
}

class DiamondGemPainter extends CustomPainter {
  DiamondGemPainter({
    required this.progress,
    required this.pulse,
    this.prominent = false,
  });

  final double progress;
  final double pulse;
  final bool prominent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    drawFacetedDiamond(
      canvas,
      center: center,
      radius: radius,
      progress: progress,
      pulse: pulse,
      prominent: prominent,
    );
  }

  @override
  bool shouldRepaint(covariant DiamondGemPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pulse != pulse ||
        oldDelegate.prominent != prominent;
  }
}

void drawFacetedDiamond(
  Canvas canvas, {
  required Offset center,
  required double radius,
  required double progress,
  required double pulse,
  bool prominent = false,
}) {
  final glowAlpha = prominent ? 0.28 + pulse * 0.32 : 0.18 + pulse * 0.22;
  canvas.drawCircle(
    center,
    radius * (1.1 + pulse * 0.15),
    Paint()
      ..color = SuperGarageColors.diamondAccent.withValues(
        alpha: glowAlpha * 0.45,
      )
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.55),
  );

  final rotation = progress * math.pi * 0.35;
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(rotation);
  canvas.translate(-center.dx, -center.dy);

  final top = Offset(center.dx, center.dy - radius);
  final right = Offset(center.dx + radius * 0.62, center.dy);
  final bottom = Offset(center.dx, center.dy + radius * 0.88);
  final left = Offset(center.dx - radius * 0.62, center.dy);
  final crownLeft = Offset(
    center.dx - radius * 0.28,
    center.dy - radius * 0.35,
  );
  final crownRight = Offset(
    center.dx + radius * 0.28,
    center.dy - radius * 0.35,
  );
  final table = Offset(center.dx, center.dy - radius * 0.35);

  final crownPath = Path()
    ..moveTo(left.dx, left.dy)
    ..lineTo(crownLeft.dx, crownLeft.dy)
    ..lineTo(table.dx, table.dy)
    ..lineTo(crownRight.dx, crownRight.dy)
    ..lineTo(right.dx, right.dy)
    ..lineTo(center.dx, center.dy)
    ..close();

  final pavilionPath = Path()
    ..moveTo(left.dx, left.dy)
    ..lineTo(bottom.dx, bottom.dy)
    ..lineTo(right.dx, right.dy)
    ..lineTo(center.dx, center.dy)
    ..close();

  final crownPaint = Paint()
    ..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        SuperGarageColors.diamondSparkle.withValues(alpha: 0.98),
        SuperGarageColors.diamondBright.withValues(alpha: 0.85),
        SuperGarageColors.diamondAccent.withValues(alpha: 0.75),
      ],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

  final pavilionPaint = Paint()
    ..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        SuperGarageColors.diamondAccent.withValues(alpha: 0.8),
        const Color(0xFF1565C0).withValues(alpha: 0.9),
        SuperGarageColors.diamondBackground.withValues(alpha: 0.95),
      ],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

  canvas.drawPath(pavilionPath, pavilionPaint);
  canvas.drawPath(crownPath, crownPaint);

  final facetPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = lerpDouble(0.6, 1.1, pulse)!
    ..color = SuperGarageColors.diamondSparkle.withValues(
      alpha: 0.55 + pulse * 0.35,
    );
  canvas.drawPath(crownPath, facetPaint);
  canvas.drawLine(top, bottom, facetPaint);
  canvas.drawLine(crownLeft, right, facetPaint);
  canvas.drawLine(crownRight, left, facetPaint);

  canvas.drawCircle(
    table,
    radius * 0.08,
    Paint()..color = Colors.white.withValues(alpha: 0.85 + pulse * 0.15),
  );

  canvas.restore();
}
