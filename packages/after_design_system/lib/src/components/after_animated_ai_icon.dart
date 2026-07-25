import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Soft pulse AI mark — Garage hub ([Icons.hub_rounded]) with a rotating
/// spectrum sweep so the shell AI affordance stays colorful on every plan.
class AfterAnimatedAiIcon extends StatefulWidget {
  const AfterAnimatedAiIcon({
    this.color,
    this.size = 24,
    this.locked = false,
    super.key,
  });

  /// When set, forces a solid tint (tests / locked fallbacks). Null = spectrum.
  final Color? color;
  final double size;
  final bool locked;

  static const _spectrum = [
    Color(0xFF7C3AED),
    Color(0xFF2563EB),
    Color(0xFF0891B2),
    Color(0xFF059669),
    Color(0xFFD97706),
    Color(0xFFDB2777),
    Color(0xFF7C3AED),
  ];

  @override
  State<AfterAnimatedAiIcon> createState() => _AfterAnimatedAiIconState();
}

class _AfterAnimatedAiIconState extends State<AfterAnimatedAiIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _spectrumColor(double t) {
    final colors = AfterAnimatedAiIcon._spectrum;
    final scaled = (t % 1) * (colors.length - 1);
    final index = scaled.floor().clamp(0, colors.length - 2);
    final blend = scaled - index;
    return Color.lerp(colors[index], colors[index + 1], blend)!;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final pulse = 0.94 + 0.06 * math.sin(t * math.pi * 2);
        final orbit = t * math.pi * 2;
        final radius = widget.size * 0.38;
        final fixed = widget.color;
        final accent = fixed ?? _spectrumColor(t);
        final accentAlt = fixed ?? _spectrumColor(t + 0.33);
        return SizedBox(
          width: widget.size + 10,
          height: widget.size + 10,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                Transform.translate(
                  offset: Offset(
                    math.cos(orbit + i * 2 * math.pi / 3) * radius,
                    math.sin(orbit + i * 2 * math.pi / 3) * radius,
                  ),
                  child: Container(
                    width: 3.5,
                    height: 3.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i.isEven ? accent : accentAlt,
                      boxShadow: [
                        BoxShadow(
                          color: (i.isEven ? accent : accentAlt)
                              .withValues(alpha: 0.45),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              Transform.scale(
                scale: pulse,
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) {
                    if (fixed != null) {
                      return LinearGradient(
                        colors: [fixed, fixed],
                      ).createShader(bounds);
                    }
                    return SweepGradient(
                      colors: AfterAnimatedAiIcon._spectrum,
                      transform: GradientRotation(orbit),
                    ).createShader(bounds);
                  },
                  child: Icon(
                    Icons.hub_rounded,
                    color: Colors.white,
                    size: widget.size,
                  ),
                ),
              ),
              if (widget.locked)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 10,
                      color: (fixed ?? accent).withValues(alpha: 0.72),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
