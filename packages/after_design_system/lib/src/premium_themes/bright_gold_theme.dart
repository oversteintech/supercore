import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'premium_theme_shell.dart';
import 'theme.dart' show BrightGoldThemeEffects, SuperGarageColors;

/// Ultra-premium bright gold royal theme — shell, atmosphere & settings preview.
abstract final class BrightGoldTheme {
  /// Warm metallic gold only — no cool white/silver stops.
  static const frameGradient = <Color>[
    Color(0xFFF8E7C0),
    Color(0xFFE8C547),
    Color(0xFFD4A017),
    Color(0xFFB8860B),
    Color(0xFF8B6914),
    Color(0xFFC9A227),
    Color(0xFFE6C35C),
    Color(0xFFF8E7C0),
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
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
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
      _controller.value = 0.18;
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
        return CustomPaint(
          painter: _BrightGoldLuxuryPainter(
            progress: _reduceMotion ? 0.18 : _controller.value,
          ),
          isComplex: true,
          willChange: !_reduceMotion,
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

    // Champagne → deep antique gold base (never neon / banana yellow).
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF7ECD4),
            Color.lerp(
              const Color(0xFFE4C878),
              const Color(0xFFD4A84A),
              pulse * 0.45,
            )!,
            const Color(0xFFB8860B),
            Color.lerp(
              const Color(0xFFC9A227),
              const Color(0xFF8B6914),
              pulse * 0.35,
            )!,
            const Color(0xFFE8D5A0),
          ],
          stops: const [0.0, 0.28, 0.55, 0.78, 1.0],
        ).createShader(rect),
    );

    // Slow traveling metallic highlight — warm gold only.
    final sweepX = (progress * 1.15 - 0.12) * size.width;
    final shimmer = Rect.fromLTWH(
      sweepX - size.width * 0.28,
      0,
      size.width * 0.42,
      size.height,
    );
    canvas.drawRect(
      shimmer,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFFD4AF37).withValues(alpha: 0),
            const Color(0xFFF0D78C).withValues(alpha: 0.28 + pulse * 0.12),
            const Color(0xFFB8860B).withValues(alpha: 0.32 + pulse * 0.1),
            const Color(0xFFF0D78C).withValues(alpha: 0.28 + pulse * 0.12),
            Colors.transparent,
          ],
          stops: const [0.0, 0.26, 0.44, 0.5, 0.56, 1.0],
        ).createShader(shimmer),
    );

    // Soft diagonal depth band so the field reads as brushed metal.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(-0.8 + pulse * 0.2, -1),
          end: Alignment(0.9, 1),
          colors: [
            const Color(0xFF8B6914).withValues(alpha: 0.08),
            Colors.transparent,
            const Color(0xFFF5E6C0).withValues(alpha: 0.14),
            const Color(0xFFB8860B).withValues(alpha: 0.1),
          ],
          stops: const [0.0, 0.35, 0.62, 1.0],
        ).createShader(rect),
    );

    for (var i = 0; i < 10; i++) {
      final twinkle =
          (math.sin((progress * (0.4 + i * 0.025) + i * 0.17) * math.pi * 2) +
              1) /
          2;
      if (twinkle < 0.5) continue;
      final x = ((i * 0.137 + 0.05) % 1.0) * size.width;
      final y = ((i * 0.091 + 0.08) % 1.0) * size.height;
      canvas.drawCircle(
        Offset(x, y),
        0.9 + twinkle * 1.4,
        Paint()
          ..color = const Color(
            0xFFD4AF37,
          ).withValues(alpha: 0.12 + twinkle * 0.22),
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
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
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
      _controller.value = 0.3;
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
    if (_reduceMotion) {
      return const SizedBox.expand();
    }
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
    for (var i = 0; i < 12; i++) {
      final phase = (progress + i * 0.07) % 1.0;
      final alpha = (math.sin(phase * math.pi * 2) + 1) / 2;
      if (alpha < 0.45) continue;
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        0.7 + alpha * 1.3,
        Paint()
          ..color = const Color(
            0xFFD4AF37,
          ).withValues(alpha: 0.06 + alpha * 0.1),
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
    // Keep the tab body transparent so [BrightGoldLuxuryBackground] in the
    // app shell stays visible between cards. Opaque parchment fills hid the
    // metallic animation and made the theme read as a flat yellow screen.
    return child;
  }
}

/// Settings tile preview — vivid warm gold with dark readable text area.
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
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
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
      _controller.value = 0.22;
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
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _BrightGoldPreviewPainter(
              progress: _reduceMotion ? 0.22 : _controller.value,
            ),
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
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF7ECD4),
            Color.lerp(
              const Color(0xFFE4C878),
              const Color(0xFFD4A84A),
              pulse * 0.5,
            )!,
            const Color(0xFFB8860B),
            const Color(0xFFE8D5A0),
          ],
        ).createShader(rect),
    );

    final sweepX = progress * size.width * 1.15 - size.width * 0.1;
    canvas.drawRect(
      Rect.fromLTWH(sweepX, 0, size.width * 0.34, size.height),
      Paint()
        ..shader =
            LinearGradient(
              colors: [
                Colors.transparent,
                const Color(0xFFF0D78C).withValues(alpha: 0.26 + pulse * 0.12),
                const Color(0xFFB8860B).withValues(alpha: 0.28 + pulse * 0.1),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromLTWH(sweepX, 0, size.width * 0.34, size.height),
            ),
    );
  }

  @override
  bool shouldRepaint(covariant _BrightGoldPreviewPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
