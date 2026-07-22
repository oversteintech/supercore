import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'premium_frame_style.dart';

/// Animated racing-red / hybrid-blue card frames — Premium SILVER themes.
class RacingThemeEffects extends ThemeExtension<RacingThemeEffects> {
  const RacingThemeEffects({
    this.red = false,
    this.blue = false,
  });

  final bool red;
  final bool blue;

  static RacingThemeEffects? of(BuildContext context) {
    return context
        .findAncestorWidgetOfExactType<Theme>()
        ?.data
        .extension<RacingThemeEffects>();
  }

  static bool isActive(BuildContext context) {
    final ext = of(context);
    return ext?.red == true || ext?.blue == true;
  }

  static bool isRedActive(BuildContext context) => of(context)?.red == true;

  static bool isBlueActive(BuildContext context) => of(context)?.blue == true;

  @override
  RacingThemeEffects copyWith({bool? red, bool? blue}) {
    return RacingThemeEffects(
      red: red ?? this.red,
      blue: blue ?? this.blue,
    );
  }

  @override
  RacingThemeEffects lerp(RacingThemeEffects? other, double t) {
    if (other == null) return this;
    return RacingThemeEffects(
      red: t < 0.5 ? red : other.red,
      blue: t < 0.5 ? blue : other.blue,
    );
  }
}

abstract final class RacingFramePalette {
  static const redGradient = [
    Color(0xFFFF1744),
    Color(0xFFE10600),
    Color(0xFFFFFFFF),
    Color(0xFFFF5252),
    Color(0xFFFFAB00),
    Color(0xFFE10600),
  ];

  static const blueGradient = [
    Color(0xFF00E5FF),
    Color(0xFF2979FF),
    Color(0xFFFFFFFF),
    Color(0xFF64B5F6),
    Color(0xFF1565E6),
    Color(0xFF0D47A1),
  ];

  /// Bold Red / Hybrid Blue frame sweep — intentionally slow for premium feel.
  static const redBorderMs = 5600;
  static const redPulseMs = 3200;

  static const blueBorderMs = 6400;
  static const bluePulseMs = 3600;
}

class RacingShowcaseFrame extends StatefulWidget {
  const RacingShowcaseFrame({
    required this.child,
    required this.borderRadius,
    this.prominent = false,
    this.style,
    this.forceRed = false,
    this.forceBlue = false,
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final bool prominent;
  final PremiumFrameStyle? style;
  final bool forceRed;
  final bool forceBlue;

  PremiumFrameStyle get resolvedStyle =>
      style ?? PremiumFrameStyleX.fromProminent(prominent);

  @override
  State<RacingShowcaseFrame> createState() => _RacingShowcaseFrameState();
}

class _RacingShowcaseFrameState extends State<RacingShowcaseFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _isRed {
    if (widget.forceRed) return true;
    if (widget.forceBlue) return false;
    return RacingThemeEffects.isRedActive(context);
  }

  Duration get _duration {
    final base = _isRed
        ? RacingFramePalette.redBorderMs
        : RacingFramePalette.blueBorderMs;
    return Duration(
      milliseconds: widget.resolvedStyle.borderMs(
        showcaseMs: base + 3600,
        softMs: base + 6400,
        menuMs: 16000,
      ),
    );
  }

  List<Color> get _gradient =>
      _isRed ? RacingFramePalette.redGradient : RacingFramePalette.blueGradient;

  Color get _glowColor =>
      _isRed ? const Color(0xFFE10600) : const Color(0xFF2979FF);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(RacingShowcaseFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.forceRed != widget.forceRed ||
        oldWidget.forceBlue != widget.forceBlue ||
        oldWidget.resolvedStyle != widget.resolvedStyle) {
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
    final active =
        widget.forceRed ||
        widget.forceBlue ||
        RacingThemeEffects.isActive(context);
    if (!active) {
      return widget.child;
    }

    final style = widget.resolvedStyle;
    final scale = style.glowScale;
    final pad = (_isRed ? 2.4 : 2.2) + style.padExtra * 1.2;
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
        final glow =
            (_isRed ? (0.10 + pulse * 0.14) : (0.08 + pulse * 0.12)) * scale;
        final blur = ((_isRed ? 8.0 : 7.0) + pulse * 6) + style.padExtra * 6;
        final spread = (0.2 + style.padExtra * 0.35) * scale;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: SweepGradient(
              colors: _gradient,
              stops: const [0.0, 0.16, 0.28, 0.48, 0.68, 1.0],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
            boxShadow: [
              BoxShadow(
                color: _glowColor.withValues(alpha: glow),
                blurRadius: blur,
                spreadRadius: spread,
              ),
              if (!style.isMenu)
                BoxShadow(
                  color:
                      (_isRed
                              ? const Color(0xFFFFAB00)
                              : const Color(0xFF00E5FF))
                          .withValues(alpha: (0.06 + pulse * 0.10) * scale),
                  blurRadius: 20,
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
