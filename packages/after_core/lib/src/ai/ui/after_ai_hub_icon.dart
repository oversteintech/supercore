import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Garage AI hub mark — orbiting dots around [Icons.hub_rounded].
///
/// Used on the AI panel title and (via design-system top bar) the shell AI
/// affordance so every Super App feels like SuperGarage Mate.
class AfterAiHubIcon extends StatefulWidget {
  const AfterAiHubIcon({
    this.color,
    this.size,
    super.key,
  });

  /// When set, hub / ring / dots use this color (e.g. white on primary).
  final Color? color;
  final double? size;

  @override
  State<AfterAiHubIcon> createState() => _AfterAiHubIconState();
}

class _AfterAiHubIconState extends State<AfterAiHubIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

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

  Color _spectrumColor(double t) {
    final scaled = (t % 1) * (_spectrum.length - 1);
    final index = scaled.floor().clamp(0, _spectrum.length - 2);
    final blend = scaled - index;
    return Color.lerp(_spectrum[index], _spectrum[index + 1], blend)!;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = widget.size ?? IconTheme.of(context).size ?? 24;
    final fixedColor = widget.color;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = Curves.easeInOut.transform(
          (math.sin(_controller.value * math.pi * 2) + 1) / 2,
        );
        final accent = fixedColor ?? _spectrumColor(_controller.value);
        final accentAlt =
            fixedColor ?? _spectrumColor(_controller.value + 0.33);
        final iconColor = fixedColor ??
            (ThemeData.estimateBrightnessForColor(scheme.surface) ==
                    Brightness.dark
                ? Colors.white
                : const Color(0xFF111827));
        final hubScale = 1 + pulse * 0.03;
        final ringOpacity = 0.14 + pulse * 0.12;
        final orbitAngle = _controller.value * 2 * math.pi;
        final orbitRadius = size * 0.42;

        return SizedBox(
          width: size + 12,
          height: size + 12,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Opacity(
                opacity: ringOpacity,
                child: Transform.scale(
                  scale: 0.96 + pulse * 0.04,
                  child: Container(
                    width: size + 10,
                    height: size + 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accent.withValues(alpha: 0.55),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              for (var i = 0; i < 3; i++)
                Transform.translate(
                  offset: Offset(
                    math.cos(orbitAngle + i * 2 * math.pi / 3) * orbitRadius,
                    math.sin(orbitAngle + i * 2 * math.pi / 3) * orbitRadius,
                  ),
                  child: Container(
                    width: 4.5,
                    height: 4.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i.isEven ? accent : accentAlt,
                      boxShadow: [
                        BoxShadow(
                          color: (i.isEven ? accent : accentAlt).withValues(
                            alpha: 0.42 + pulse * 0.2,
                          ),
                          blurRadius: 1.5 + pulse * 1.2,
                        ),
                      ],
                    ),
                  ),
                ),
              Transform.scale(
                scale: hubScale,
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) {
                    if (fixedColor != null) {
                      return LinearGradient(
                        colors: [fixedColor, fixedColor],
                      ).createShader(bounds);
                    }
                    return SweepGradient(
                      colors: _spectrum,
                      transform: GradientRotation(
                        _controller.value * math.pi * 2,
                      ),
                    ).createShader(bounds);
                  },
                  child: Icon(
                    Icons.hub_rounded,
                    color: iconColor,
                    size: size,
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
