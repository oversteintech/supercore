import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// Polished light aluminium & chrome — cool silver, readable dark text.
abstract final class SilverGreyColors {
  static const background = Color(0xFFD4DAE2);
  static const backgroundDeep = Color(0xFFC8D0DA);
  static const surface = Color(0xFFDBE1E8);
  static const surfaceHigh = Color(0xFFD0D7E0);
  static const surfaceHighest = Color(0xFFC2CAD4);
  static const steel = Color(0xFF9CA3AF);
  static const silver = Color(0xFF6B7280);
  static const silverBright = Color(0xFF4B5563);
  static const chrome = Color(0xFF374151);
  static const coolAccent = Color(0xFF8B9AAB);
  static const coolAccentBright = Color(0xFF64748B);
  static const foreground = Color(0xFF111827);
  static const muted = Color(0xFF4B5563);
  static const border = Color(0xFFD1D5DB);

  static const frameGradient = <Color>[
    Color(0xFFFFFFFF),
    Color(0xFFE5E7EB),
    Color(0xFFB8BEC6),
    Color(0xFF9CA3AF),
    Color(0xFF6B7280),
    Color(0xFF9CA3AF),
    Color(0xFFE5E7EB),
    Color(0xFFFFFFFF),
  ];
}

@immutable
class SilverGreyThemeEffects extends ThemeExtension<SilverGreyThemeEffects> {
  const SilverGreyThemeEffects({this.enabled = false});

  final bool enabled;

  static bool isActive(BuildContext context) {
    return Theme.of(context).extension<SilverGreyThemeEffects>()?.enabled ==
        true;
  }

  @override
  SilverGreyThemeEffects copyWith({bool? enabled}) {
    return SilverGreyThemeEffects(enabled: enabled ?? this.enabled);
  }

  @override
  SilverGreyThemeEffects lerp(SilverGreyThemeEffects? other, double t) {
    if (other == null) return this;
    return SilverGreyThemeEffects(enabled: t < 0.5 ? enabled : other.enabled);
  }
}

class BrushedMetalPainter extends CustomPainter {
  const BrushedMetalPainter({this.opacity = 1.0, this.progress = 0});

  final double opacity;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            SilverGreyColors.background,
            SilverGreyColors.surface,
            SilverGreyColors.surfaceHigh,
          ],
        ).createShader(Offset.zero & size),
    );

    final linePaint = Paint()..style = PaintingStyle.stroke;
    for (var i = -2; i < 28; i++) {
      final t = i / 28;
      linePaint
        ..strokeWidth = 0.7
        ..color = SilverGreyColors.steel.withValues(
          alpha: (0.04 + (i.isEven ? 0.05 : 0.02)) * opacity,
        );
      canvas.drawLine(
        Offset(-size.width * 0.05, size.height * (t + 0.04)),
        Offset(size.width * 1.05, size.height * (t + 0.22)),
        linePaint,
      );
    }

    // Traveling chrome sheen across brushed metal.
    final sheenX = ((progress * 1.35) % 1.4) - 0.2;
    final sheenRect = Rect.fromLTWH(
      size.width * sheenX,
      0,
      size.width * 0.28,
      size.height,
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.07 * opacity),
            Colors.white.withValues(alpha: 0.16 * opacity),
            Colors.white.withValues(alpha: 0.07 * opacity),
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
        ).createShader(sheenRect),
    );

    final glow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              SilverGreyColors.coolAccent.withValues(alpha: 0.06 * opacity),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(
                size.width * (0.78 + math.sin(progress * math.pi * 2) * 0.04),
                size.height * (0.12 + math.cos(progress * math.pi * 2) * 0.03),
              ),
              radius: size.shortestSide * 0.42,
            ),
          );
    canvas.drawRect(Offset.zero & size, glow);
  }

  @override
  bool shouldRepaint(BrushedMetalPainter oldDelegate) =>
      oldDelegate.opacity != opacity || oldDelegate.progress != progress;
}

class SilverGreyAnimatedBackground extends StatefulWidget {
  const SilverGreyAnimatedBackground({super.key});

  @override
  State<SilverGreyAnimatedBackground> createState() =>
      _SilverGreyAnimatedBackgroundState();
}

class _SilverGreyAnimatedBackgroundState
    extends State<SilverGreyAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 14000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: SilverGreyColors.background,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: BrushedMetalPainter(progress: _controller.value),
            isComplex: true,
            willChange: true,
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class SilverGreyBackground extends StatelessWidget {
  const SilverGreyBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const SilverGreyAnimatedBackground();
  }
}

class SilverGreyPreview extends StatelessWidget {
  const SilverGreyPreview({this.borderRadius = BorderRadius.zero, super.key});

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: const CustomPaint(
        painter: BrushedMetalPainter(),
        isComplex: true,
        willChange: false,
      ),
    );
  }
}

/// Animated chrome sweep frame — used on cards & CTAs when Silver Grey is active.
class SilverShowcaseFrame extends StatefulWidget {
  const SilverShowcaseFrame({
    required this.child,
    required this.borderRadius,
    this.prominent = true,
    this.style,
    this.forceShow = false,
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final bool prominent;
  final PremiumFrameStyle? style;

  /// Settings / preview tiles — animate even when theme isn't active.
  final bool forceShow;

  PremiumFrameStyle get resolvedStyle =>
      style ?? PremiumFrameStyleX.fromProminent(prominent);

  @override
  State<SilverShowcaseFrame> createState() => _SilverShowcaseFrameState();
}

class _SilverShowcaseFrameState extends State<SilverShowcaseFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Duration get _duration => Duration(
    milliseconds: widget.resolvedStyle.borderMs(
      showcaseMs: 10000,
      softMs: 14000,
      menuMs: 18000,
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant SilverShowcaseFrame oldWidget) {
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
    if (!widget.forceShow && !SilverGreyThemeEffects.isActive(context)) {
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
        final glow = (0.08 + pulse * 0.14) * scale;
        final blur = (6.0 + pulse * 6) + style.padExtra * 6;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: SweepGradient(
              colors: SilverGreyColors.frameGradient,
              stops: const [0.0, 0.12, 0.28, 0.42, 0.58, 0.72, 0.86, 1.0],
              transform: GradientRotation(spin),
            ),
            boxShadow: [
              BoxShadow(
                color: SilverGreyColors.steel.withValues(alpha: glow),
                blurRadius: blur,
                spreadRadius: (0.12 + pulse * 0.18) * scale,
              ),
              if (!style.isMenu)
                BoxShadow(
                  color: SilverGreyColors.coolAccent.withValues(
                    alpha: (0.04 + pulse * 0.06) * scale,
                  ),
                  blurRadius: 14 + pulse * 8,
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

/// Drop-in primary CTA with full chrome frame when Silver Grey is active.
class SilverGreyKeyButton extends StatelessWidget {
  const SilverGreyKeyButton({
    required this.onPressed,
    required this.child,
    this.icon,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final iconWidget = icon;
    final button = iconWidget != null
        ? FilledButton.icon(
            onPressed: onPressed,
            icon: iconWidget,
            label: child,
          )
        : FilledButton(onPressed: onPressed, child: child);

    if (!SilverGreyThemeEffects.isActive(context)) {
      return button;
    }

    return SilverShowcaseFrame(
      borderRadius: BorderRadius.circular(16),
      style: PremiumFrameStyle.soft,
      child: button,
    );
  }
}

class SilverGreyAppShell extends StatelessWidget {
  const SilverGreyAppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PremiumThemeAppShell(
      backgroundColor: SilverGreyColors.background,
      background: const SilverGreyAnimatedBackground(),
      child: child,
    );
  }
}
