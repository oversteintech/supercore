import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'dark_night_theme.dart';
import 'blossom_pink.dart';
import 'racing_theme_effects.dart';
import 'safari_savanna.dart';
import 'silver_grey.dart';
import 'theme.dart'
    show
        BrightGoldThemeEffects,
        DiamondThemeEffects,
        SuperGarageColors,
        SuperGarageTheme;
import 'bright_gold_theme.dart' show BrightGoldPageChrome;
import 'diamond_gem_icon.dart';
import 'premium_frame_style.dart';
import 'premium_theme_shell.dart';
import 'royal_theme_effects.dart' show RoyalShowcaseFrame;

/// Animated crystalline border — no-op unless Diamond theme is active.
class DiamondSparkleFrame extends StatefulWidget {
  const DiamondSparkleFrame({
    required this.child,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(SuperGarageTheme.cardRadius),
    ),
    this.prominent = false,
    this.style,
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final bool prominent;

  /// When set, overrides [prominent]. Prefer [PremiumFrameStyle.menu] on shell chrome.
  final PremiumFrameStyle? style;

  PremiumFrameStyle get resolvedStyle =>
      style ?? PremiumFrameStyleX.fromProminent(prominent);

  @override
  State<DiamondSparkleFrame> createState() => _DiamondSparkleFrameState();
}

class _DiamondSparkleFrameState extends State<DiamondSparkleFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _themeActive = false;

  static const _gradient = [
    SuperGarageColors.diamondIce,
    SuperGarageColors.diamondSparkle,
    SuperGarageColors.diamondBright,
    SuperGarageColors.diamondAccent,
    Color(0xFF81D4FA),
    Color(0xFFB3E5FC),
    SuperGarageColors.diamondIce,
  ];

  static const _innerGradient = [
    Color(0xFF4FC3F7),
    SuperGarageColors.diamondIce,
    SuperGarageColors.diamondBright,
    SuperGarageColors.diamondSparkle,
    Color(0xFF29B6F6),
    SuperGarageColors.diamondAccent,
    Color(0xFF4FC3F7),
  ];

  Duration get _borderDuration => Duration(
    milliseconds: widget.resolvedStyle.borderMs(
      // Vehicle-photo showcase stays calm — dual sweeps are tiring when fast.
      showcaseMs: 32000,
      softMs: 26000,
      menuMs: 36000,
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _borderDuration);
  }

  @override
  void didUpdateWidget(covariant DiamondSparkleFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resolvedStyle != widget.resolvedStyle) {
      _controller.duration = _borderDuration;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncThemeAnimation();
  }

  void _syncThemeAnimation() {
    final active = DiamondThemeEffects.isActive(context);
    if (active == _themeActive) {
      return;
    }
    _themeActive = active;
    if (active) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!DiamondThemeEffects.isActive(context)) {
      return widget.child;
    }

    final style = widget.resolvedStyle;
    final showcase = style.isShowcase;
    final scale = style.glowScale;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = (math.sin(_controller.value * math.pi * 2) + 1) / 2;
        final borderPad =
            (1.6 + style.padExtra * 1.2) +
            pulse * (0.18 + style.padExtra * 0.35);
        final innerRadius = BorderRadius.only(
          topLeft: _shrink(widget.borderRadius.topLeft, borderPad),
          topRight: _shrink(widget.borderRadius.topRight, borderPad),
          bottomLeft: _shrink(widget.borderRadius.bottomLeft, borderPad),
          bottomRight: _shrink(widget.borderRadius.bottomRight, borderPad),
        );
        final glowAlpha =
            (0.05 + pulse * 0.05 + (showcase ? 0.03 : 0.01)) * scale;
        final rotation = _controller.value * 2 * math.pi;
        // Same direction, slightly lagged — avoids eye-fatiguing counter-spin.
        final innerRotation = (_controller.value * 0.55) * 2 * math.pi;

        return RepaintBoundary(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              boxShadow: [
                BoxShadow(
                  color: SuperGarageColors.diamondAccent.withValues(
                    alpha: glowAlpha * 0.45,
                  ),
                  blurRadius: (10 + pulse * 6) + style.padExtra * 8,
                  spreadRadius: 0.2 + style.padExtra * 0.5,
                ),
              ],
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                gradient: SweepGradient(
                  colors: _gradient,
                  stops: const [0.0, 0.14, 0.28, 0.42, 0.58, 0.72, 1.0],
                  transform: GradientRotation(rotation),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(borderPad),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: innerRadius,
                    gradient: SweepGradient(
                      colors: _innerGradient
                          .map(
                            (color) => color.withValues(
                              alpha: showcase
                                  ? 0.92
                                  : (style.isMenu ? 0.55 : 0.72),
                            ),
                          )
                          .toList(),
                      stops: const [0.0, 0.16, 0.34, 0.5, 0.66, 0.84, 1.0],
                      transform: GradientRotation(innerRotation),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(0.9),
                    child: ClipRRect(
                      borderRadius: _shrinkBorderRadius(innerRadius, 0.9),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }

  BorderRadius _shrinkBorderRadius(BorderRadius radius, double amount) {
    return BorderRadius.only(
      topLeft: _shrink(radius.topLeft, amount),
      topRight: _shrink(radius.topRight, amount),
      bottomLeft: _shrink(radius.bottomLeft, amount),
      bottomRight: _shrink(radius.bottomRight, amount),
    );
  }

  Radius _shrink(Radius radius, double amount) {
    return Radius.elliptical(
      math.max(radius.x - amount, 0),
      math.max(radius.y - amount, 0),
    );
  }
}

/// Subtle full-screen crystalline atmosphere — decorative overlay only.
class DiamondAtmosphereOverlay extends StatefulWidget {
  const DiamondAtmosphereOverlay({super.key});

  @override
  State<DiamondAtmosphereOverlay> createState() =>
      _DiamondAtmosphereOverlayState();
}

class _DiamondAtmosphereOverlayState extends State<DiamondAtmosphereOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
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

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: DiamondAtmospherePreviewPainter(
            progress: _controller.value,
          ),
          isComplex: true,
          willChange: true,
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

/// Drop-in [Card] with diamond sparkle border when the theme is active.
class SuperGarageCard extends StatelessWidget {
  const SuperGarageCard({
    required this.child,
    this.margin,
    this.color,
    this.shape,
    this.clipBehavior = Clip.none,
    this.prominent = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final ShapeBorder? shape;
  final Clip clipBehavior;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = theme.cardTheme;
    final resolvedShape =
        shape ??
        cardTheme.shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SuperGarageTheme.cardRadius),
        );
    final borderRadiusGeometry = resolvedShape is RoundedRectangleBorder
        ? resolvedShape.borderRadius
        : const BorderRadius.all(Radius.circular(18));
    final borderRadius = borderRadiusGeometry.resolve(
      Directionality.of(context),
    );

    final isDiamond = DiamondThemeEffects.isActive(context);
    var cardShape = resolvedShape;
    if ((isDiamond || SilverGreyThemeEffects.isActive(context)) &&
        resolvedShape is RoundedRectangleBorder) {
      cardShape = resolvedShape.copyWith(side: BorderSide.none);
    }

    final card = Card(
      margin: margin ?? cardTheme.margin ?? EdgeInsets.zero,
      color: color ?? cardTheme.color,
      shape: cardShape,
      clipBehavior: clipBehavior,
      elevation: cardTheme.elevation ?? 0,
      child: child,
    );

    // Frames only on opt-in surfaces (`prominent`) or hub
    // [withDiamondPremiumFrame] call sites — shell chrome stays static.
    if (!prominent) {
      return card;
    }

    if (DiamondThemeEffects.isActive(context)) {
      return DiamondSparkleFrame(
        borderRadius: borderRadius,
        style: PremiumFrameStyle.showcase,
        child: card,
      );
    }

    if (SilverGreyThemeEffects.isActive(context)) {
      return SilverShowcaseFrame(
        borderRadius: borderRadius,
        style: PremiumFrameStyle.showcase,
        child: card,
      );
    }

    if (RacingThemeEffects.isActive(context)) {
      return RacingShowcaseFrame(
        borderRadius: borderRadius,
        style: PremiumFrameStyle.showcase,
        child: card,
      );
    }

    if (BlossomPinkThemeEffects.isActive(context)) {
      return BlossomSparkleFrame(
        borderRadius: borderRadius,
        style: PremiumFrameStyle.showcase,
        child: card,
      );
    }

    if (SafariSavannaThemeEffects.isActive(context)) {
      return SafariShowcaseFrame(
        borderRadius: borderRadius,
        style: PremiumFrameStyle.showcase,
        child: card,
      );
    }

    if (DarkNightThemeEffects.isActive(context)) {
      return DarkNightShowcaseFrame(
        borderRadius: borderRadius,
        style: PremiumFrameStyle.showcase,
        child: card,
      );
    }

    if (BrightGoldThemeEffects.isActive(context)) {
      return RoyalShowcaseFrame(
        borderRadius: borderRadius,
        style: PremiumFrameStyle.showcase,
        child: card,
      );
    }

    return card;
  }
}

/// Premium [Scaffold] — transparent body lets the diamond shell background show.
class SuperGarageScaffold extends StatelessWidget {
  const SuperGarageScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.persistentFooterAlignment = AlignmentDirectional.centerEnd,
    this.drawer,
    this.onDrawerChanged,
    this.endDrawer,
    this.onEndDrawerChanged,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.restorationId,
    this.staticSurface = false,
  });

  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final List<Widget>? persistentFooterButtons;
  final AlignmentDirectional persistentFooterAlignment;
  final Widget? drawer;
  final DrawerCallback? onDrawerChanged;
  final Widget? endDrawer;
  final DrawerCallback? onEndDrawerChanged;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final String? restorationId;
  final bool staticSurface;

  @override
  Widget build(BuildContext context) {
    final useStaticSurface = staticSurface;
    final isDiamond =
        !useStaticSurface && DiamondThemeEffects.isActive(context);
    final isBrightGold =
        !useStaticSurface && BrightGoldThemeEffects.isActive(context);
    final isBlossom =
        !useStaticSurface && BlossomPinkThemeEffects.isActive(context);
    final isPremiumIap = isDiamond || isBrightGold;
    final scheme = Theme.of(context).colorScheme;

    final resolvedAppBar = isPremiumIap && appBar != null
        ? _PremiumAppBarWithGlow(appBar: appBar!, goldPalette: isBrightGold)
        : isBlossom && appBar != null
        ? BlossomAppBarChrome(appBar: appBar!)
        : appBar;

    final resolvedBody = body;

    return Scaffold(
      key: key,
      appBar: resolvedAppBar,
      body: resolvedBody,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      persistentFooterButtons: persistentFooterButtons,
      persistentFooterAlignment: persistentFooterAlignment,
      drawer: drawer,
      onDrawerChanged: onDrawerChanged,
      endDrawer: endDrawer,
      onEndDrawerChanged: onEndDrawerChanged,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      backgroundColor: useStaticSurface || !(isPremiumIap || isBlossom)
          ? backgroundColor ?? scheme.surface
          : Colors.transparent,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
      primary: primary,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      restorationId: restorationId,
    );
  }
}

class _PremiumAppBarWithGlow extends StatelessWidget
    implements PreferredSizeWidget {
  const _PremiumAppBarWithGlow({
    required this.appBar,
    required this.goldPalette,
  });

  final PreferredSizeWidget appBar;
  final bool goldPalette;

  static const _glowHeight = 2.0;

  @override
  Size get preferredSize =>
      Size.fromHeight(appBar.preferredSize.height + _glowHeight);

  @override
  Widget build(BuildContext context) {
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _glowHeight,
            child: _PremiumAppBarGlow(
              height: _glowHeight,
              goldPalette: goldPalette,
            ),
          ),
          if (!goldPalette) ...[
            const Positioned(
              left: 12,
              bottom: -4,
              child: DiamondGemIcon(size: 10),
            ),
            const Positioned(
              right: 12,
              bottom: -4,
              child: DiamondGemIcon(size: 10, prominent: true),
            ),
          ],
        ],
      ),
    );
  }
}

class _PremiumAppBarGlow extends StatefulWidget {
  const _PremiumAppBarGlow({
    required this.height,
    required this.goldPalette,
  });

  final double height;
  final bool goldPalette;

  @override
  State<_PremiumAppBarGlow> createState() => _PremiumAppBarGlowState();
}

class _PremiumAppBarGlowState extends State<_PremiumAppBarGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.goldPalette ? 12000 : 14000),
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
        final colors = widget.goldPalette
            ? [
                SuperGarageColors.goldDeep.withValues(alpha: 0.08),
                SuperGarageColors.goldBright.withValues(alpha: 0.6),
                SuperGarageColors.goldShine.withValues(alpha: 0.4),
                SuperGarageColors.goldDeep.withValues(alpha: 0.08),
              ]
            : [
                SuperGarageColors.diamondAccent.withValues(alpha: 0.05),
                SuperGarageColors.diamondSparkle.withValues(alpha: 0.55),
                SuperGarageColors.diamondBright.withValues(alpha: 0.35),
                SuperGarageColors.diamondAccent.withValues(alpha: 0.05),
              ];

        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              stops: const [0, 0.35, 0.65, 1],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
          ),
        );
      },
    );
  }
}

/// Subtle premium inset around tab/page bodies — background only, no full-page frame.
class DiamondPageChrome extends StatelessWidget {
  const DiamondPageChrome({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (BlossomPinkThemeEffects.isActive(context)) {
      return BlossomPageChrome(child: child);
    }

    if (DiamondThemeEffects.isActive(context)) {
      return ColoredBox(
        color: SuperGarageColors.diamondBackground.withValues(alpha: 0.92),
        child: child,
      );
    }

    if (BrightGoldThemeEffects.isActive(context)) {
      return BrightGoldPageChrome(child: child);
    }

    return child;
  }
}

/// Animated crystalline facet background — diamond theme shell only.
class DiamondCrystallineBackground extends StatefulWidget {
  const DiamondCrystallineBackground({super.key});

  @override
  State<DiamondCrystallineBackground> createState() =>
      _DiamondCrystallineBackgroundState();
}

class _DiamondCrystallineBackgroundState
    extends State<DiamondCrystallineBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
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
          painter: _DiamondCrystallinePainter(progress: _controller.value),
          isComplex: true,
          willChange: true,
        );
      },
    );
  }
}

class _DiamondCrystallinePainter extends CustomPainter {
  _DiamondCrystallinePainter({required this.progress});

  final double progress;
  static final _gemRandom = math.Random(19);

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
          colors: const [
            Color(0xFF061018),
            SuperGarageColors.diamondBackground,
            Color(0xFF0E2240),
            SuperGarageColors.diamondBackground,
          ],
          stops: [0, 0.35 + pulse * 0.08, 0.72, 1],
        ).createShader(rect),
    );

    final facetPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (var i = 0; i < 14; i++) {
      final phase = progress + i * 0.08;
      final x1 = size.width * ((i * 0.11 + phase * 0.05) % 1.0);
      final y1 = size.height * 0.06;
      final x2 = size.width * ((0.18 + i * 0.09 + phase * 0.04) % 1.0);
      final y2 = size.height * 0.94;
      facetPaint.color = SuperGarageColors.diamondBorder.withValues(
        alpha: 0.05 + (i.isEven ? pulse * 0.06 : 0.03),
      );
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), facetPaint);
    }

    final gemRandom = _gemRandom;
    for (var i = 0; i < 10; i++) {
      final gx = gemRandom.nextDouble() * size.width;
      final gy = gemRandom.nextDouble() * size.height;
      final phase = (progress + i * 0.11) % 1.0;
      final twinkle = (math.sin(phase * math.pi * 2) + 1) / 2;
      if (twinkle < 0.4) continue;
      drawFacetedDiamond(
        canvas,
        center: Offset(gx, gy),
        radius: 3 + twinkle * 5,
        progress: phase,
        pulse: twinkle,
        prominent: twinkle > 0.75,
      );
    }

    final glow = RadialGradient(
      center: Alignment(
        math.sin(progress * math.pi * 2) * 0.4,
        -0.3,
      ),
      radius: 0.95,
      colors: [
        SuperGarageColors.diamondAccent.withValues(alpha: 0.14 + pulse * 0.06),
        Colors.transparent,
      ],
    );
    canvas.drawRect(rect, Paint()..shader = glow.createShader(rect));
  }

  @override
  bool shouldRepaint(covariant _DiamondCrystallinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Single-pass diamond shell background (crystalline + atmosphere + sparkles).
class DiamondUnifiedBackground extends StatefulWidget {
  const DiamondUnifiedBackground({super.key});

  @override
  State<DiamondUnifiedBackground> createState() =>
      _DiamondUnifiedBackgroundState();
}

class _DiamondUnifiedBackgroundState extends State<DiamondUnifiedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
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
        final progress = _controller.value;
        return CustomPaint(
          painter: _DiamondUnifiedShellPainter(
            crystallineProgress: progress,
            atmosphereProgress: progress,
            sparkleProgress: (progress * 2) % 1.0,
          ),
          isComplex: true,
          willChange: true,
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _DiamondUnifiedShellPainter extends CustomPainter {
  const _DiamondUnifiedShellPainter({
    required this.crystallineProgress,
    required this.atmosphereProgress,
    required this.sparkleProgress,
  });

  final double crystallineProgress;
  final double atmosphereProgress;
  final double sparkleProgress;

  @override
  void paint(Canvas canvas, Size size) {
    _DiamondCrystallinePainter(progress: crystallineProgress).paint(
      canvas,
      size,
    );
    DiamondAtmospherePreviewPainter(progress: atmosphereProgress).paint(
      canvas,
      size,
    );
    _DiamondGlobalSparklePainter(progress: sparkleProgress).paint(
      canvas,
      size,
    );
  }

  @override
  bool shouldRepaint(covariant _DiamondUnifiedShellPainter oldDelegate) {
    return oldDelegate.crystallineProgress != crystallineProgress ||
        oldDelegate.atmosphereProgress != atmosphereProgress ||
        oldDelegate.sparkleProgress != sparkleProgress;
  }
}

/// Full-app wrapper when diamond theme is active — single animated background layer.
class DiamondAppShell extends StatelessWidget {
  const DiamondAppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PremiumThemeAppShell(
      backgroundColor: SuperGarageColors.diamondBackground,
      background: const DiamondUnifiedBackground(),
      child: child,
    );
  }
}

/// Sparkles across the entire UI — diamond theme signature effect.
class DiamondGlobalSparkleOverlay extends StatefulWidget {
  const DiamondGlobalSparkleOverlay({super.key});

  @override
  State<DiamondGlobalSparkleOverlay> createState() =>
      _DiamondGlobalSparkleOverlayState();
}

class _DiamondGlobalSparkleOverlayState
    extends State<DiamondGlobalSparkleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
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
          return CustomPaint(
            painter: _DiamondGlobalSparklePainter(progress: _controller.value),
            isComplex: true,
            willChange: true,
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _DiamondGlobalSparklePainter extends CustomPainter {
  _DiamondGlobalSparklePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final sweepX = (progress * 1.3 - 0.15) * size.width;
    final shimmer = Rect.fromLTWH(
      sweepX - size.width * 0.25,
      0,
      size.width * 0.45,
      size.height,
    );
    canvas.drawRect(
      shimmer,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            SuperGarageColors.diamondSparkle.withValues(alpha: 0),
            SuperGarageColors.diamondSparkle.withValues(alpha: 0.12),
            SuperGarageColors.diamondBright.withValues(alpha: 0.18),
            SuperGarageColors.diamondSparkle.withValues(alpha: 0.12),
            Colors.transparent,
          ],
          stops: const [0.0, 0.28, 0.46, 0.5, 0.54, 1.0],
        ).createShader(shimmer),
    );

    for (var i = 0; i < 28; i++) {
      final twinkle =
          (math.sin((progress * (0.85 + i * 0.03) + i * 0.17) * math.pi * 2) +
              1) /
          2;
      if (twinkle < 0.3) continue;
      final x = ((i * 0.113 + 0.04) % 1.0) * size.width;
      final y = ((i * 0.079 + 0.06) % 1.0) * size.height;
      final starSize = 1.0 + twinkle * (i.isEven ? 2.8 : 1.6);

      if (i % 5 == 0) {
        drawFacetedDiamond(
          canvas,
          center: Offset(x, y),
          radius: starSize * 1.1,
          progress: progress,
          pulse: twinkle,
          prominent: true,
        );
      } else {
        _drawSparkleStar(canvas, Offset(x, y), starSize, twinkle);
      }
    }
  }

  void _drawSparkleStar(
    Canvas canvas,
    Offset center,
    double size,
    double twinkle,
  ) {
    final paint = Paint()
      ..color = SuperGarageColors.diamondSparkle.withValues(
        alpha: 0.35 + twinkle * 0.6,
      )
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;
    for (var a = 0; a < 4; a++) {
      final angle = a * math.pi / 2 + twinkle * 0.2;
      final dx = math.cos(angle) * size;
      final dy = math.sin(angle) * size;
      canvas.drawLine(center, center + Offset(dx, dy), paint);
      canvas.drawCircle(center, size * 0.22, paint..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant _DiamondGlobalSparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Settings tile / picker preview — royal-level motion with diamond glints.
class DiamondThemePreview extends StatefulWidget {
  const DiamondThemePreview({
    super.key,
    this.borderRadius = BorderRadius.zero,
  });

  final BorderRadius borderRadius;

  @override
  State<DiamondThemePreview> createState() => _DiamondThemePreviewState();
}

class _DiamondThemePreviewState extends State<DiamondThemePreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
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
            painter: DiamondAtmospherePreviewPainter(
              progress: _controller.value,
            ),
            isComplex: true,
            willChange: true,
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _DiamondPreviewParticle {
  const _DiamondPreviewParticle({
    required this.nx,
    required this.ny,
    required this.phase,
    required this.speed,
    required this.size,
    required this.tone,
    this.gem = false,
  });

  final double nx;
  final double ny;
  final double phase;
  final double speed;
  final double size;
  final int tone;
  final bool gem;
}

const _diamondPreviewParticles = <_DiamondPreviewParticle>[
  _DiamondPreviewParticle(
    nx: 0.08,
    ny: 0.14,
    phase: 0.02,
    speed: 1.05,
    size: 2.4,
    tone: 0,
    gem: true,
  ),
  _DiamondPreviewParticle(
    nx: 0.22,
    ny: 0.28,
    phase: 0.31,
    speed: 0.92,
    size: 1.6,
    tone: 1,
  ),
  _DiamondPreviewParticle(
    nx: 0.38,
    ny: 0.10,
    phase: 0.58,
    speed: 1.18,
    size: 2.8,
    tone: 2,
    gem: true,
  ),
  _DiamondPreviewParticle(
    nx: 0.52,
    ny: 0.22,
    phase: 0.74,
    speed: 0.86,
    size: 1.4,
    tone: 0,
  ),
  _DiamondPreviewParticle(
    nx: 0.68,
    ny: 0.16,
    phase: 0.19,
    speed: 1.12,
    size: 2.2,
    tone: 1,
    gem: true,
  ),
  _DiamondPreviewParticle(
    nx: 0.84,
    ny: 0.30,
    phase: 0.47,
    speed: 0.98,
    size: 1.8,
    tone: 2,
  ),
  _DiamondPreviewParticle(
    nx: 0.12,
    ny: 0.52,
    phase: 0.63,
    speed: 1.08,
    size: 2,
    tone: 0,
    gem: true,
  ),
  _DiamondPreviewParticle(
    nx: 0.28,
    ny: 0.64,
    phase: 0.11,
    speed: 0.84,
    size: 1.5,
    tone: 1,
  ),
  _DiamondPreviewParticle(
    nx: 0.46,
    ny: 0.48,
    phase: 0.88,
    speed: 1.22,
    size: 3,
    tone: 2,
    gem: true,
  ),
  _DiamondPreviewParticle(
    nx: 0.62,
    ny: 0.58,
    phase: 0.36,
    speed: 0.94,
    size: 1.7,
    tone: 0,
  ),
  _DiamondPreviewParticle(
    nx: 0.78,
    ny: 0.50,
    phase: 0.52,
    speed: 1.15,
    size: 2.5,
    tone: 1,
    gem: true,
  ),
  _DiamondPreviewParticle(
    nx: 0.92,
    ny: 0.62,
    phase: 0.24,
    speed: 0.88,
    size: 1.3,
    tone: 2,
  ),
  _DiamondPreviewParticle(
    nx: 0.06,
    ny: 0.78,
    phase: 0.71,
    speed: 1.02,
    size: 2.1,
    tone: 0,
    gem: true,
  ),
  _DiamondPreviewParticle(
    nx: 0.24,
    ny: 0.86,
    phase: 0.43,
    speed: 0.96,
    size: 1.6,
    tone: 1,
  ),
  _DiamondPreviewParticle(
    nx: 0.44,
    ny: 0.76,
    phase: 0.17,
    speed: 1.28,
    size: 2.6,
    tone: 2,
    gem: true,
  ),
  _DiamondPreviewParticle(
    nx: 0.58,
    ny: 0.88,
    phase: 0.59,
    speed: 0.82,
    size: 1.4,
    tone: 0,
  ),
  _DiamondPreviewParticle(
    nx: 0.72,
    ny: 0.74,
    phase: 0.83,
    speed: 1.10,
    size: 2.3,
    tone: 1,
    gem: true,
  ),
  _DiamondPreviewParticle(
    nx: 0.88,
    ny: 0.82,
    phase: 0.29,
    speed: 0.90,
    size: 1.9,
    tone: 2,
  ),
  _DiamondPreviewParticle(
    nx: 0.34,
    ny: 0.38,
    phase: 0.66,
    speed: 1.06,
    size: 1.2,
    tone: 1,
  ),
  _DiamondPreviewParticle(
    nx: 0.56,
    ny: 0.34,
    phase: 0.95,
    speed: 1.20,
    size: 1.5,
    tone: 0,
  ),
];

/// Heavy crystalline atmosphere for theme picker tiles.
class DiamondAtmospherePreviewPainter extends CustomPainter {
  DiamondAtmospherePreviewPainter({required this.progress});

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
            const Color(0xFF040A14),
            Color.lerp(
              SuperGarageColors.diamondBackground,
              const Color(0xFF142848),
              pulse * 0.45,
            )!,
            Color.lerp(
              const Color(0xFF0E2240),
              SuperGarageColors.diamondSurfaceHigh,
              pulse * 0.35,
            )!,
            const Color(0xFF050C18),
          ],
          stops: [0.0, 0.26 + pulse * 0.06, 0.62 + pulse * 0.04, 1.0],
        ).createShader(rect),
    );

    _drawIceShimmerSweep(canvas, size, progress);

    final facetPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    for (var i = 0; i < 16; i++) {
      final phase = progress * 1.15 + i * 0.07;
      final x1 = size.width * ((i * 0.09 + phase * 0.06) % 1.0);
      final y1 = size.height * 0.04;
      final x2 = size.width * ((0.14 + i * 0.08 + phase * 0.05) % 1.0);
      final y2 = size.height * 0.96;
      facetPaint.color = SuperGarageColors.diamondBorder.withValues(
        alpha: 0.04 + (i.isEven ? pulse * 0.09 : 0.04),
      );
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), facetPaint);
    }

    for (final particle in _diamondPreviewParticles) {
      final twinkle =
          (math.sin(
                (progress * particle.speed + particle.phase) * math.pi * 2,
              ) +
              1) /
          2;
      if (twinkle < 0.18) continue;

      final driftX =
          math.sin((progress + particle.phase) * math.pi * 2) * 0.014;
      final driftY =
          math.cos((progress + particle.phase) * math.pi * 2) * 0.012;
      final center = Offset(
        (particle.nx + driftX) * size.width,
        (particle.ny + driftY) * size.height,
      );
      final color = switch (particle.tone) {
        0 => SuperGarageColors.diamondIce,
        1 => SuperGarageColors.diamondSparkle,
        _ => SuperGarageColors.diamondAccent,
      };

      if (particle.gem) {
        drawFacetedDiamond(
          canvas,
          center: center,
          radius: particle.size * (0.75 + twinkle * 0.85),
          progress: progress + particle.phase,
          pulse: twinkle,
          prominent: twinkle > 0.62,
        );
      } else {
        _drawDiamondGlint(
          canvas,
          center,
          particle.size * (0.8 + twinkle * 1.1),
          color.withValues(alpha: 0.22 + twinkle * 0.72),
        );
      }
    }

    for (var i = 0; i < 22; i++) {
      final px = (i * 0.113 + progress * 0.19) % 1.0;
      final py = (i * 0.071 + progress * 0.14) % 1.0;
      final flicker = (math.sin((progress + i * 0.17) * math.pi * 4) + 1) / 2;
      if (flicker < 0.32) continue;
      _drawDiamondGlint(
        canvas,
        Offset(px * size.width, py * size.height),
        lerpDouble(1.0, 3.8, flicker)!,
        Color.lerp(
          SuperGarageColors.diamondBright,
          SuperGarageColors.diamondSparkle,
          flicker,
        )!.withValues(alpha: 0.18 + flicker * 0.62),
      );
    }

    final glowCenter = Offset(
      size.width * (0.72 + math.sin(progress * math.pi * 2) * 0.06),
      size.height * (0.18 + math.cos(progress * math.pi * 2) * 0.04),
    );
    canvas.drawCircle(
      glowCenter,
      size.shortestSide * (0.42 + pulse * 0.1),
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                SuperGarageColors.diamondAccent.withValues(
                  alpha: 0.20 + pulse * 0.14,
                ),
                SuperGarageColors.diamondBright.withValues(alpha: 0.08),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(
                center: glowCenter,
                radius: size.shortestSide * 0.55,
              ),
            ),
    );

    final secondaryGlow = Offset(
      size.width * (0.22 + math.cos(progress * math.pi * 2 + 1.2) * 0.05),
      size.height * (0.78 + math.sin(progress * math.pi * 2 + 0.8) * 0.04),
    );
    canvas.drawCircle(
      secondaryGlow,
      size.shortestSide * 0.28,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                SuperGarageColors.diamondSparkle.withValues(
                  alpha: 0.10 + pulse * 0.08,
                ),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(
                center: secondaryGlow,
                radius: size.shortestSide * 0.32,
              ),
            ),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.42),
              ],
              stops: const [0.50, 1.0],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.5, size.height * 0.52),
                radius: size.shortestSide * math.sqrt(2) * 0.56,
              ),
            ),
    );
  }

  void _drawIceShimmerSweep(Canvas canvas, Size size, double progress) {
    final sweepX = (progress * 1.45 - 0.18) * size.width;
    final shimmerRect = Rect.fromLTWH(
      sweepX - size.width * 0.38,
      0,
      size.width * 0.58,
      size.height,
    );
    canvas.drawRect(
      shimmerRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            SuperGarageColors.diamondAccent.withValues(alpha: 0),
            SuperGarageColors.diamondBright.withValues(alpha: 0.12),
            SuperGarageColors.diamondSparkle.withValues(alpha: 0.16),
            SuperGarageColors.diamondBright.withValues(alpha: 0.12),
            Colors.transparent,
          ],
          stops: const [0.0, 0.22, 0.42, 0.5, 0.58, 1.0],
        ).createShader(shimmerRect),
    );
  }

  @override
  bool shouldRepaint(covariant DiamondAtmospherePreviewPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

void _drawDiamondGlint(Canvas canvas, Offset center, double size, Color color) {
  final paint = Paint()..color = color;
  canvas.drawCircle(center, size * 0.32, paint);

  final path = Path()
    ..moveTo(center.dx, center.dy - size)
    ..lineTo(center.dx, center.dy + size)
    ..moveTo(center.dx - size, center.dy)
    ..lineTo(center.dx + size, center.dy);
  canvas.drawPath(
    path,
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(size * 0.22, 0.7)
      ..strokeCap = StrokeCap.round,
  );
  paint.style = PaintingStyle.fill;
}

extension DiamondPremiumFrameX on Widget {
  /// Wraps with the active premium theme's showcase/soft frame.
  ///
  /// Shell chrome (header, bottom nav, tab titles) stays unframed — use this
  /// for hub / hero cards only.
  Widget withDiamondPremiumFrame({
    BorderRadius borderRadius = const BorderRadius.all(
      Radius.circular(SuperGarageTheme.cardRadius),
    ),
    bool prominent = false,
    PremiumFrameStyle? style,
  }) {
    final resolved = style ?? PremiumFrameStyleX.fromProminent(prominent);
    if (style == null && !prominent) {
      return this;
    }
    return _wrapPremiumFrame(
      borderRadius: borderRadius,
      style: resolved == PremiumFrameStyle.menu
          ? PremiumFrameStyle.soft
          : resolved,
    );
  }

  /// Slow, whisper-level frame for major menus / shell chrome only.
  Widget withPremiumMenuFrame({
    BorderRadius borderRadius = BorderRadius.zero,
  }) {
    return _wrapPremiumFrame(
      borderRadius: borderRadius,
      style: PremiumFrameStyle.menu,
    );
  }

  Widget _wrapPremiumFrame({
    required BorderRadius borderRadius,
    required PremiumFrameStyle style,
  }) {
    return Builder(
      builder: (context) {
        if (RacingThemeEffects.isActive(context)) {
          return RacingShowcaseFrame(
            borderRadius: borderRadius,
            style: style,
            child: this,
          );
        }
        if (BlossomPinkThemeEffects.isActive(context)) {
          return BlossomSparkleFrame(
            borderRadius: borderRadius,
            style: style,
            child: this,
          );
        }
        if (DiamondThemeEffects.isActive(context)) {
          return DiamondSparkleFrame(
            borderRadius: borderRadius,
            style: style,
            child: this,
          );
        }
        if (BrightGoldThemeEffects.isActive(context)) {
          return RoyalShowcaseFrame(
            borderRadius: borderRadius,
            style: style,
            child: this,
          );
        }
        if (SilverGreyThemeEffects.isActive(context)) {
          return SilverShowcaseFrame(
            borderRadius: borderRadius,
            style: style,
            child: this,
          );
        }
        if (SafariSavannaThemeEffects.isActive(context)) {
          return SafariShowcaseFrame(
            borderRadius: borderRadius,
            style: style,
            child: this,
          );
        }
        if (DarkNightThemeEffects.isActive(context)) {
          return DarkNightShowcaseFrame(
            borderRadius: borderRadius,
            style: style,
            child: this,
          );
        }
        return this;
      },
    );
  }
}
