import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'premium_frame_style.dart';
import 'premium_theme_shell.dart';

/// Blush pink, pearl gray & white palette for the Blossom Pink premium theme.
abstract final class BlossomPinkColors {
  static const blushWhite = Color(0xFFFFFBFD);
  static const snowWhite = Color(0xFFFFFFFF);
  static const mistGray = Color(0xFFF8F9FB);
  static const cloudGray = Color(0xFFF3F4F6);
  static const pearlGray = Color(0xFFE5E7EB);
  static const softGray = Color(0xFF9CA3AF);
  static const grayText = Color(0xFF6B7280);
  static const petalLight = Color(0xFFFFE8F3);
  static const petalMid = Color(0xFFFBCFE8);
  static const petalDeep = Color(0xFFF9A8D4);
  static const rose = Color(0xFFF472B6);
  static const roseBright = Color(0xFFEC4899);
  static const roseDeep = Color(0xFFDB2777);
  static const sparkle = Color(0xFFFFFFFF);
  static const plumText = Color(0xFF4A1D35);

  static const borderGradient = <Color>[
    snowWhite,
    cloudGray,
    petalLight,
    petalMid,
    rose,
    roseBright,
    pearlGray,
    snowWhite,
    petalLight,
  ];

  static const buttonGradient = <Color>[
    snowWhite,
    petalLight,
    rose,
    roseBright,
    roseDeep,
    petalMid,
    cloudGray,
    snowWhite,
  ];
}

/// Theme extension — attached only to Blossom Pink theme.
@immutable
class BlossomPinkThemeEffects extends ThemeExtension<BlossomPinkThemeEffects> {
  const BlossomPinkThemeEffects({this.enabled = false});

  final bool enabled;

  static BlossomPinkThemeEffects? of(BuildContext context) {
    return Theme.of(context).extension<BlossomPinkThemeEffects>();
  }

  static bool isActive(BuildContext context) => of(context)?.enabled ?? false;

  @override
  BlossomPinkThemeEffects copyWith({bool? enabled}) {
    return BlossomPinkThemeEffects(enabled: enabled ?? this.enabled);
  }

  @override
  BlossomPinkThemeEffects lerp(BlossomPinkThemeEffects? other, double t) {
    if (other == null) return this;
    return BlossomPinkThemeEffects(
      enabled: t < 0.5 ? enabled : other.enabled,
    );
  }
}

class _BlossomSparkle {
  const _BlossomSparkle({
    required this.nx,
    required this.ny,
    required this.radius,
    required this.phase,
    this.isGray = false,
  });

  final double nx;
  final double ny;
  final double radius;
  final double phase;
  final bool isGray;
}

class _BlossomPetal {
  const _BlossomPetal({
    required this.nx,
    required this.ny,
    required this.size,
    required this.phase,
    required this.rotation,
  });

  final double nx;
  final double ny;
  final double size;
  final double phase;
  final double rotation;
}

const _sparkles = <_BlossomSparkle>[
  _BlossomSparkle(nx: 0.08, ny: 0.06, radius: 0.016, phase: 0),
  _BlossomSparkle(nx: 0.22, ny: 0.11, radius: 0.011, phase: 0.35, isGray: true),
  _BlossomSparkle(nx: 0.38, ny: 0.05, radius: 0.014, phase: 0.7),
  _BlossomSparkle(nx: 0.55, ny: 0.09, radius: 0.012, phase: 1.1, isGray: true),
  _BlossomSparkle(nx: 0.71, ny: 0.14, radius: 0.015, phase: 1.5),
  _BlossomSparkle(nx: 0.86, ny: 0.08, radius: 0.010, phase: 1.9),
  _BlossomSparkle(nx: 0.14, ny: 0.28, radius: 0.013, phase: 2.3, isGray: true),
  _BlossomSparkle(nx: 0.48, ny: 0.24, radius: 0.012, phase: 2.7),
  _BlossomSparkle(nx: 0.64, ny: 0.32, radius: 0.014, phase: 3.1),
  _BlossomSparkle(nx: 0.82, ny: 0.26, radius: 0.011, phase: 3.5, isGray: true),
  _BlossomSparkle(nx: 0.30, ny: 0.44, radius: 0.010, phase: 3.9),
  _BlossomSparkle(nx: 0.58, ny: 0.48, radius: 0.012, phase: 4.3),
  _BlossomSparkle(nx: 0.12, ny: 0.62, radius: 0.009, phase: 4.7, isGray: true),
  _BlossomSparkle(nx: 0.76, ny: 0.58, radius: 0.011, phase: 5.1),
];

const _petals = <_BlossomPetal>[
  _BlossomPetal(nx: 0.18, ny: 0.20, size: 0.028, phase: 0.2, rotation: 0.4),
  _BlossomPetal(nx: 0.72, ny: 0.18, size: 0.022, phase: 0.9, rotation: 1.1),
  _BlossomPetal(nx: 0.44, ny: 0.36, size: 0.024, phase: 1.6, rotation: 2),
  _BlossomPetal(nx: 0.88, ny: 0.42, size: 0.020, phase: 2.3, rotation: 0.8),
  _BlossomPetal(nx: 0.26, ny: 0.54, size: 0.026, phase: 3, rotation: 1.7),
  _BlossomPetal(nx: 0.60, ny: 0.68, size: 0.021, phase: 3.8, rotation: 2.4),
];

class BlossomAtmospherePainter extends CustomPainter {
  BlossomAtmospherePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final pulse = (math.sin(progress * math.pi * 2) + 1) / 2;
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BlossomPinkColors.blushWhite,
            Color.lerp(
              BlossomPinkColors.mistGray,
              BlossomPinkColors.petalLight,
              0.4 + pulse * 0.2,
            )!,
            Color.lerp(
              BlossomPinkColors.cloudGray,
              BlossomPinkColors.petalMid,
              0.3 + pulse * 0.25,
            )!,
            Color.lerp(
              BlossomPinkColors.petalLight,
              BlossomPinkColors.snowWhite,
              0.55 + pulse * 0.15,
            )!,
            BlossomPinkColors.blushWhite,
          ],
          stops: [0.0, 0.22 + pulse * 0.04, 0.48, 0.78, 1.0],
        ).createShader(rect),
    );

    final blobPaint = Paint()..style = PaintingStyle.fill;
    _drawBlob(
      canvas,
      size,
      nx: 0.88,
      ny: 0.10 + pulse * 0.03,
      rx: size.width * 0.30,
      ry: size.height * 0.24,
      color: BlossomPinkColors.petalMid.withValues(alpha: 0.38),
      paint: blobPaint,
    );
    _drawBlob(
      canvas,
      size,
      nx: 0.10,
      ny: 0.82 - pulse * 0.02,
      rx: size.width * 0.34,
      ry: size.height * 0.26,
      color: BlossomPinkColors.pearlGray.withValues(alpha: 0.42),
      paint: blobPaint,
    );
    _drawBlob(
      canvas,
      size,
      nx: 0.52,
      ny: 0.52,
      rx: size.width * 0.24,
      ry: size.height * 0.20,
      color: BlossomPinkColors.rose.withValues(alpha: 0.14),
      paint: blobPaint,
    );
    _drawBlob(
      canvas,
      size,
      nx: 0.30,
      ny: 0.22,
      rx: size.width * 0.18,
      ry: size.height * 0.14,
      color: BlossomPinkColors.cloudGray.withValues(alpha: 0.55),
      paint: blobPaint,
    );

    for (final petal in _petals.take(4)) {
      final drift = math.sin((progress + petal.phase) * math.pi * 2);
      final cx = (petal.nx + drift * 0.012) * size.width;
      final cy =
          (petal.ny + math.cos((progress + petal.phase) * math.pi * 2) * 0.01) *
          size.height;
      final s = petal.size * size.shortestSide;
      _drawPetal(
        canvas,
        Offset(cx, cy),
        s,
        petal.rotation + progress * math.pi * 2,
        BlossomPinkColors.petalDeep.withValues(alpha: 0.16 + pulse * 0.12),
      );
    }

    for (final sparkle in _sparkles.take(8)) {
      final twinkle =
          (math.sin(progress * math.pi * 2 + sparkle.phase) + 1) / 2;
      final cx = sparkle.nx * size.width;
      final cy = sparkle.ny * size.height;
      final r = sparkle.radius * size.shortestSide * (0.65 + twinkle * 0.55);
      final color = sparkle.isGray
          ? BlossomPinkColors.pearlGray.withValues(alpha: 0.35 + twinkle * 0.45)
          : BlossomPinkColors.sparkle.withValues(alpha: 0.22 + twinkle * 0.58);
      canvas.drawCircle(Offset(cx, cy), r, Paint()..color = color);
    }
  }

  void _drawBlob(
    Canvas canvas,
    Size size, {
    required double nx,
    required double ny,
    required double rx,
    required double ry,
    required Color color,
    required Paint paint,
  }) {
    paint.color = color;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(nx * size.width, ny * size.height),
        width: rx * 2,
        height: ry * 2,
      ),
      paint,
    );
  }

  void _drawPetal(
    Canvas canvas,
    Offset center,
    double size,
    double rotation,
    Color color,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    final path = Path()
      ..moveTo(0, -size)
      ..quadraticBezierTo(size * 0.9, -size * 0.2, 0, size)
      ..quadraticBezierTo(-size * 0.9, -size * 0.2, 0, -size)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BlossomAtmospherePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Floating petal & sparkle overlay above page content.
class BlossomThemeAtmosphere extends StatefulWidget {
  const BlossomThemeAtmosphere({required this.child, super.key});

  final Widget child;

  @override
  State<BlossomThemeAtmosphere> createState() => _BlossomThemeAtmosphereState();
}

class _BlossomThemeAtmosphereState extends State<BlossomThemeAtmosphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!BlossomPinkThemeEffects.isActive(context)) {
      return widget.child;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _BlossomDustPainter(progress: _controller.value),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _BlossomDustPainter extends CustomPainter {
  _BlossomDustPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 10; i++) {
      final phase = progress + i * 0.13;
      final nx = (i * 0.11 + phase * 0.03) % 1.0;
      final ny = (i * 0.17 + phase * 0.02) % 1.0;
      final twinkle = (math.sin(phase * math.pi * 4) + 1) / 2;
      if (twinkle < 0.3) continue;

      final driftX = math.sin(phase * math.pi * 2) * 8;
      final driftY = math.cos(phase * math.pi * 2) * 6;
      final center = Offset(
        nx * size.width + driftX,
        ny * size.height + driftY,
      );
      _drawHeart(
        canvas,
        center,
        lerpDouble(3.5, 7.0, twinkle)!,
        (i.isEven ? BlossomPinkColors.rose : BlossomPinkColors.pearlGray)
            .withValues(alpha: 0.12 + twinkle * 0.22),
      );
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Color color) {
    final path = Path()
      ..moveTo(center.dx, center.dy + size * 0.3)
      ..cubicTo(
        center.dx - size,
        center.dy - size * 0.5,
        center.dx - size * 0.2,
        center.dy - size,
        center.dx,
        center.dy - size * 0.35,
      )
      ..cubicTo(
        center.dx + size * 0.2,
        center.dy - size,
        center.dx + size,
        center.dy - size * 0.5,
        center.dx,
        center.dy + size * 0.3,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BlossomDustPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Animated pink–white–gray border frame.
class BlossomSparkleFrame extends StatefulWidget {
  const BlossomSparkleFrame({
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.prominent = false,
    this.style,
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final bool prominent;
  final PremiumFrameStyle? style;

  PremiumFrameStyle get resolvedStyle =>
      style ?? PremiumFrameStyleX.fromProminent(prominent);

  @override
  State<BlossomSparkleFrame> createState() => _BlossomSparkleFrameState();
}

class _BlossomSparkleFrameState extends State<BlossomSparkleFrame>
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
  void didUpdateWidget(covariant BlossomSparkleFrame oldWidget) {
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
    if (!BlossomPinkThemeEffects.isActive(context)) {
      return widget.child;
    }

    final style = widget.resolvedStyle;
    final scale = style.glowScale;
    final borderPad = 1.7 + style.padExtra * 1.1;
    final innerRadius = BorderRadius.only(
      topLeft: _shrink(widget.borderRadius.topLeft, borderPad),
      topRight: _shrink(widget.borderRadius.topRight, borderPad),
      bottomLeft: _shrink(widget.borderRadius.bottomLeft, borderPad),
      bottomRight: _shrink(widget.borderRadius.bottomRight, borderPad),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = (math.sin(_controller.value * math.pi * 2) + 1) / 2;
        final glowAlpha = (0.08 + pulse * 0.12) * scale;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: SweepGradient(
              colors: BlossomPinkColors.borderGradient,
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
            boxShadow: [
              BoxShadow(
                color: BlossomPinkColors.rose.withValues(alpha: glowAlpha),
                blurRadius: (7 + pulse * 5) + style.padExtra * 6,
                spreadRadius: 0.2 + style.padExtra * 0.4,
              ),
              if (!style.isMenu)
                BoxShadow(
                  color: BlossomPinkColors.pearlGray.withValues(
                    alpha: (0.08 + pulse * 0.08) * scale,
                  ),
                  blurRadius: 16,
                ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(borderPad),
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

/// Extra shimmer + scale on primary CTAs (optional drop-in).
class BlossomMajorFilledButton extends StatefulWidget {
  const BlossomMajorFilledButton({
    required this.onPressed,
    required this.child,
    this.icon,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Widget? icon;

  @override
  State<BlossomMajorFilledButton> createState() =>
      _BlossomMajorFilledButtonState();
}

class _BlossomMajorFilledButtonState extends State<BlossomMajorFilledButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final useBlossom = BlossomPinkThemeEffects.isActive(context);

    if (!useBlossom) {
      final icon = widget.icon;
      if (icon != null) {
        return FilledButton.icon(
          onPressed: widget.onPressed,
          icon: icon,
          label: widget.child,
        );
      }
      return FilledButton(onPressed: widget.onPressed, child: widget.child);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pulse = enabled
            ? Curves.easeInOut.transform(_controller.value)
            : 0.0;
        final scale = 1 + pulse * 0.03;
        final shimmer = -1 + pulse * 2;

        return Transform.scale(
          scale: scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: BlossomPinkColors.roseBright.withValues(
                    alpha: 0.22 + pulse * 0.28,
                  ),
                  blurRadius: 16 + pulse * 12,
                  spreadRadius: pulse * 1.5,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: widget.icon != null
                        ? FilledButton.icon(
                            onPressed: widget.onPressed,
                            icon: widget.icon ?? const SizedBox.shrink(),
                            label: widget.child,
                          )
                        : FilledButton(
                            onPressed: widget.onPressed,
                            child: widget.child,
                          ),
                  ),
                  if (enabled)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Transform.translate(
                          offset: Offset(shimmer * 140, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.22),
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Subtle premium inset around tab/page bodies.
class BlossomPageChrome extends StatelessWidget {
  const BlossomPageChrome({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!BlossomPinkThemeEffects.isActive(context)) {
      return child;
    }

    return ColoredBox(
      color: BlossomPinkColors.mistGray.withValues(alpha: 0.55),
      child: child,
    );
  }
}

/// Settings tile preview — soft pink blush background.
class BlossomPinkPreview extends StatelessWidget {
  const BlossomPinkPreview({this.borderRadius, super.key});

  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: const _BlossomPreviewBody(),
    );
  }
}

class _BlossomPreviewBody extends StatefulWidget {
  const _BlossomPreviewBody();

  @override
  State<_BlossomPreviewBody> createState() => _BlossomPreviewBodyState();
}

class _BlossomPreviewBodyState extends State<_BlossomPreviewBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
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
      builder: (context, child) {
        return CustomPaint(
          painter: BlossomAtmospherePainter(progress: _controller.value),
          child: child,
        );
      },
      child: const SizedBox.expand(),
    );
  }
}

/// Full-app shell when the Blossom Pink premium theme is active.
class BlossomAnimatedBackground extends StatefulWidget {
  const BlossomAnimatedBackground({super.key});

  @override
  State<BlossomAnimatedBackground> createState() =>
      _BlossomAnimatedBackgroundState();
}

class _BlossomAnimatedBackgroundState extends State<BlossomAnimatedBackground>
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
          painter: BlossomAtmospherePainter(progress: _controller.value),
          isComplex: true,
          willChange: true,
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class BlossomPinkAppShell extends StatelessWidget {
  const BlossomPinkAppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PremiumThemeAppShell(
      backgroundColor: BlossomPinkColors.blushWhite,
      background: const BlossomAnimatedBackground(),
      child: child,
    );
  }
}

extension BlossomPremiumFrameX on Widget {
  Widget withBlossomPremiumFrame({
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(20)),
    bool prominent = false,
  }) {
    return Builder(
      builder: (context) {
        if (!BlossomPinkThemeEffects.isActive(context)) return this;
        return BlossomSparkleFrame(
          borderRadius: borderRadius,
          prominent: prominent,
          child: this,
        );
      },
    );
  }
}

/// App bar glow strip — blossom palette.
class BlossomAppBarGlow extends StatefulWidget {
  const BlossomAppBarGlow({this.height = 2, super.key});

  final double height;

  @override
  State<BlossomAppBarGlow> createState() => _BlossomAppBarGlowState();
}

class _BlossomAppBarGlowState extends State<BlossomAppBarGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
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
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                BlossomPinkColors.pearlGray.withValues(alpha: 0.2),
                BlossomPinkColors.rose.withValues(alpha: 0.55),
                BlossomPinkColors.snowWhite.withValues(alpha: 0.65),
                BlossomPinkColors.pearlGray.withValues(alpha: 0.2),
              ],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
          ),
        );
      },
    );
  }
}

/// Wraps an app bar with blossom glow when theme is active.
class BlossomAppBarChrome extends StatelessWidget
    implements PreferredSizeWidget {
  const BlossomAppBarChrome({required this.appBar, super.key});

  final PreferredSizeWidget appBar;

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height + 2);

  @override
  Widget build(BuildContext context) {
    if (!BlossomPinkThemeEffects.isActive(context)) {
      return appBar;
    }

    return SizedBox(
      height: preferredSize.height,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: appBar.preferredSize.height,
            child: appBar,
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 2,
            child: BlossomAppBarGlow(),
          ),
        ],
      ),
    );
  }
}
