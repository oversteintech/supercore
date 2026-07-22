import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'premium_theme_shell.dart';
import 'theme.dart' show BrightGoldThemeEffects, SuperGarageColors;

/// Ultra-premium bright gold royal theme — shell, atmosphere & settings preview.
abstract final class BrightGoldTheme {
  static const frameGradient = <Color>[
    Color(0xFFFFFDE7),
    Color(0xFFFFEA00),
    Color(0xFFFFD700),
    Color(0xFFFFC107),
    Color(0xFFFFFFFF),
    Color(0xFFFFE082),
    Color(0xFFD4AF37),
    Color(0xFFFFFDE7),
  ];
}

class BrightGoldAppShell extends StatelessWidget {
  const BrightGoldAppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PremiumThemeAppShell(
      backgroundColor: SuperGarageColors.goldBackground,
      background: const BrightGoldLuxuryBackground(),
      foregroundOverlays: const [BrightGoldDustOverlay()],
      child: child,
    );
  }
}

class BrightGoldLuxuryBackground extends StatefulWidget {
  const BrightGoldLuxuryBackground({super.key});

  @override
  State<BrightGoldLuxuryBackground> createState() =>
      _BrightGoldLuxuryBackgroundState();
}

class _BrightGoldLuxuryBackgroundState extends State<BrightGoldLuxuryBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
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
        return CustomPaint(
          painter: _BrightGoldLuxuryPainter(progress: _controller.value),
          isComplex: true,
          willChange: true,
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _BrightGoldLuxuryPainter extends CustomPainter {
  _BrightGoldLuxuryPainter({required this.progress});

  final double progress;

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
          colors: [
            const Color(0xFFFFF8E1),
            Color.lerp(
              const Color(0xFFFFE082),
              const Color(0xFFFFD54F),
              pulse,
            )!,
            const Color(0xFFFFC107),
            const Color(0xFFFFE57F),
            const Color(0xFFFFF3C4),
          ],
        ).createShader(rect),
    );

    final sweepX = (progress * 1.4 - 0.2) * size.width;
    final shimmer = Rect.fromLTWH(
      sweepX - size.width * 0.35,
      0,
      size.width * 0.55,
      size.height,
    );
    canvas.drawRect(
      shimmer,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.22 + pulse * 0.12),
            const Color(0xFFFFEA00).withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.22 + pulse * 0.12),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.48, 0.5, 0.52, 1.0],
        ).createShader(shimmer),
    );

    for (var i = 0; i < 20; i++) {
      final twinkle =
          (math.sin((progress * (0.75 + i * 0.04) + i * 0.13) * math.pi * 2) +
              1) /
          2;
      if (twinkle < 0.35) continue;
      final x = ((i * 0.137 + 0.05) % 1.0) * size.width;
      final y = ((i * 0.091 + 0.08) % 1.0) * size.height;
      canvas.drawCircle(
        Offset(x, y),
        1.2 + twinkle * 2.4,
        Paint()
          ..color = const Color(
            0xFFFFEA00,
          ).withValues(alpha: 0.25 + twinkle * 0.55),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BrightGoldLuxuryPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Subtle gold dust — decorative foreground layer only (never wraps [child]).
class BrightGoldDustOverlay extends StatefulWidget {
  const BrightGoldDustOverlay({super.key});

  @override
  State<BrightGoldDustOverlay> createState() => _BrightGoldDustOverlayState();
}

class _BrightGoldDustOverlayState extends State<BrightGoldDustOverlay>
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
        return CustomPaint(
          painter: _BrightGoldDustPainter(progress: _controller.value),
          isComplex: true,
          willChange: true,
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _BrightGoldDustPainter extends CustomPainter {
  _BrightGoldDustPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(17);
    for (var i = 0; i < 18; i++) {
      final phase = (progress + i * 0.07) % 1.0;
      final alpha = (math.sin(phase * math.pi * 2) + 1) / 2;
      if (alpha < 0.4) continue;
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        0.8 + alpha * 1.6,
        Paint()
          ..color = const Color(
            0xFFFFD700,
          ).withValues(alpha: 0.08 + alpha * 0.14),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BrightGoldDustPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class BrightGoldPageChrome extends StatelessWidget {
  const BrightGoldPageChrome({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!BrightGoldThemeEffects.isActive(context)) {
      return child;
    }
    return ColoredBox(
      color: SuperGarageColors.goldBackground.withValues(alpha: 0.88),
      child: child,
    );
  }
}

/// Settings tile preview — vivid gold with dark readable text area.
class BrightGoldThemePreview extends StatefulWidget {
  const BrightGoldThemePreview({
    super.key,
    this.borderRadius = BorderRadius.zero,
  });

  final BorderRadius borderRadius;

  @override
  State<BrightGoldThemePreview> createState() => _BrightGoldThemePreviewState();
}

class _BrightGoldThemePreviewState extends State<BrightGoldThemePreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _BrightGoldPreviewPainter(progress: _controller.value),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _BrightGoldPreviewPainter extends CustomPainter {
  _BrightGoldPreviewPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final pulse = (math.sin(progress * math.pi * 2) + 1) / 2;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFDE7),
            Color(0xFFFFD54F),
            Color(0xFFFFC107),
            Color(0xFFFFE082),
          ],
        ).createShader(rect),
    );

    final sweepX = progress * size.width * 1.3 - size.width * 0.15;
    canvas.drawRect(
      Rect.fromLTWH(sweepX, 0, size.width * 0.4, size.height),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.35 + pulse * 0.2),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(sweepX, 0, size.width * 0.4, size.height)),
    );
  }

  @override
  bool shouldRepaint(covariant _BrightGoldPreviewPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
