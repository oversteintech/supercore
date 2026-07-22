import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Asset paths for OVERSTEIN OS branding (package: after_design_system).
abstract final class AfterBrandingAssets {
  static const oversteinLogoMark = 'assets/branding/overstein_logo_mark.png';
  static const packageName = 'after_design_system';
}

/// Canonical OVERSTEIN OS monogram — transparent mark on any surface.
class OversteinLogo extends StatelessWidget {
  const OversteinLogo({
    super.key,
    required this.size,
    this.entrance = 1,
    this.shimmer = 0,
    this.idlePhase = 0,
    this.glowStrength = 1,
  });

  final double size;
  final double entrance;
  final double shimmer;
  final double idlePhase;
  final double glowStrength;

  @override
  Widget build(BuildContext context) {
    final enterT = Curves.easeOutCubic.transform(entrance.clamp(0.0, 1.0));
    final idlePulse = math.sin(idlePhase * math.pi * 2);
    final scale =
        (0.96 + 0.04 * enterT) * (entrance >= 0.98 ? 1 + 0.004 * idlePulse : 1);
    final sweep = entrance < 0.98
        ? shimmer.clamp(0.0, 1.0)
        : 0.08 + 0.35 * ((idlePulse + 1) / 2);

    return Opacity(
      opacity: enterT * glowStrength.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: scale,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.hardEdge,
            children: [
              Image.asset(
                AfterBrandingAssets.oversteinLogoMark,
                package: AfterBrandingAssets.packageName,
                width: size,
                height: size,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => Icon(
                  Icons.hexagon_outlined,
                  size: size * 0.72,
                  color: Colors.white70,
                ),
              ),
              if (shimmer > 0.01)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _OversteinLogoShimmerPainter(progress: sweep),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OversteinLogoShimmerPainter extends CustomPainter {
  const _OversteinLogoShimmerPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.clamp(0.0, 1.0);
    final bandCenter = -size.width * 0.55 + size.width * 1.55 * t;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final shimmer = Paint()
      ..blendMode = BlendMode.softLight
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.02),
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.02),
          Colors.transparent,
        ],
        stops: const [0.0, 0.36, 0.46, 0.5, 0.54, 0.64, 1.0],
      ).createShader(rect.shift(Offset(bandCenter - size.width * 0.5, 0)));

    canvas.drawRect(rect, shimmer);
  }

  @override
  bool shouldRepaint(covariant _OversteinLogoShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
