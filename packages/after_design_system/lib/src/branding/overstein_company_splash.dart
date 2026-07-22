import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../premium_themes/overstein_brand_colors.dart';
import 'overstein_logo.dart';

/// Fixed OVERSTEIN company intro — Apple-style static hold (no motion).
///
/// Shared across every Super App — black screen, OS mark, no product branding.
///
/// Holds the static mark for [OversteinCompanySplashTiming.hold] on **every**
/// cold start (not skipped via prefs). Prefs backup on Android was restoring
/// "seen" and dismissing instantly — that looked like a broken fast animation.
///
/// ANR contract (do not break):
/// - No Firebase / GMS / auth work from this widget
/// - No product branding / second act
/// - No entrance / shimmer / slide / fade animation
/// - Always completes via [onComplete] or [hardTimeout]
abstract final class OversteinCompanySplashTiming {
  /// Minimum time the mark stays fully visible.
  static const Duration hold = Duration(milliseconds: 5500);

  /// Alias used by cold-start / ANR tests.
  static const Duration total = hold;

  /// Absolute ceiling so splash can never stick.
  static const Duration hardTimeout = Duration(milliseconds: 9000);
}

/// Legacy prefs helpers (kept for tests / migration). Splash no longer skips.
abstract final class OversteinCompanySplashStore {
  static const String seenKey = 'overstein_company_splash_seen_v4';

  static bool hasSeen(SharedPreferences prefs) =>
      prefs.getBool(seenKey) ?? false;

  static Future<void> markSeen(SharedPreferences prefs) =>
      prefs.setBool(seenKey, true);

  static Future<void> clearSeen(SharedPreferences prefs) =>
      prefs.remove(seenKey);
}

const _kSplashSilver = OversteinBrandColors.logoMetal;

const _kWordmarkStyle = TextStyle(
  color: _kSplashSilver,
  fontSize: 15,
  fontWeight: FontWeight.w500,
  letterSpacing: 3.8,
  height: 1.05,
  decoration: TextDecoration.none,
);

const _kMissionStyle = TextStyle(
  color: _kSplashSilver,
  fontSize: 12,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.15,
  height: 1.35,
  decoration: TextDecoration.none,
);

/// Black-screen company card: static mark + wordmark + mission for ≥5.5s.
class OversteinCompanySplash extends StatefulWidget {
  const OversteinCompanySplash({
    super.key,
    required this.onComplete,
    this.preferences,
    this.preferencesFuture,
    /// Ignored — hold always runs (kept for API compatibility).
    this.forceShow = false,
  });

  final VoidCallback onComplete;
  final SharedPreferences? preferences;
  final Future<SharedPreferences>? preferencesFuture;
  final bool forceShow;

  @override
  State<OversteinCompanySplash> createState() => _OversteinCompanySplashState();
}

class _OversteinCompanySplashState extends State<OversteinCompanySplash> {
  var _completed = false;
  var _visible = false;
  Timer? _holdTimer;
  Timer? _hardTimeout;
  SharedPreferences? _prefs;
  final _startedAt = Stopwatch();

  @override
  void initState() {
    super.initState();
    _startedAt.start();
    unawaited(_start());
  }

  Future<void> _start() async {
    try {
      _prefs = widget.preferences ??
          await (widget.preferencesFuture ?? SharedPreferences.getInstance());
    } on Object {
      _prefs = null;
    }
    if (!mounted || _completed) return;

    // Always show the static hold — never skip. (Prefs "seen" skip + Android
    // Auto Backup made the intro vanish in ~0–200ms and looked "animated".)
    setState(() => _visible = true);

    final remaining = OversteinCompanySplashTiming.hold - _startedAt.elapsed;
    _holdTimer = Timer(
      remaining.isNegative ? Duration.zero : remaining,
      _finish,
    );
    _hardTimeout = Timer(OversteinCompanySplashTiming.hardTimeout, _finish);
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _hardTimeout?.cancel();
    super.dispose();
  }

  void _finish() {
    if (_completed) return;
    _completed = true;
    _holdTimer?.cancel();
    _holdTimer = null;
    _hardTimeout?.cancel();
    _hardTimeout = null;

    final prefs = _prefs;
    if (prefs != null) {
      unawaited(OversteinCompanySplashStore.markSeen(prefs));
    }

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(),
      );
    }

    // Fully static — plain asset, no OversteinLogo entrance/shimmer/idle.
    return const Scaffold(
      backgroundColor: Colors.black,
      body: _StaticSplashBody(),
    );
  }
}

class _StaticSplashBody extends StatelessWidget {
  const _StaticSplashBody();

  @override
  Widget build(BuildContext context) {
    final code = ui.PlatformDispatcher.instance.locale.languageCode;
    final mission = switch (code) {
      'tr' => 'Yarını inşa ediyoruz',
      'de' => 'Wir bauen die Zukunft',
      'pt' => 'Construímos o amanhã',
      'fr' => 'Nous construisons demain',
      'es' => 'Construimos el mañana',
      'ar' => 'نبني الغد',
      'ja' => '明日を築く',
      'zh' => '我们建设明天',
      'ko' => '내일을 만듭니다',
      'ru' => 'Мы строим завтра',
      'it' => 'Costruiamo il domani',
      _ => 'We build tomorrow',
    };

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AfterBrandingAssets.oversteinLogoMark,
                package: AfterBrandingAssets.packageName,
                width: 104,
                height: 104,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.hexagon_outlined,
                  size: 75,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 26),
              const _SplashLabel('OVERSTEIN', style: _kWordmarkStyle),
              const SizedBox(height: 12),
              _SplashLabel(mission, style: _kMissionStyle),
            ],
          ),
        ),
      ),
    );
  }
}

const _launchTextStyle = TextStyle(
  inherit: false,
  color: Color(0xFFE8E8E8),
  fontSize: 14,
  fontWeight: FontWeight.w400,
  fontFamily: 'Roboto',
  decoration: TextDecoration.none,
  decorationColor: Color(0x00000000),
);

/// Black [MaterialApp] shell for splash / launch handoff frames.
class AfterLaunchShell extends StatelessWidget {
  const AfterLaunchShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          surface: Colors.black,
          primary: OversteinBrandColors.logoMetal,
        ),
      ),
      builder: (context, nestedChild) {
        return DefaultTextStyle(
          style: _launchTextStyle,
          child: nestedChild ?? const SizedBox.shrink(),
        );
      },
      home: child,
    );
  }
}

class _SplashLabel extends StatelessWidget {
  const _SplashLabel(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox(height: 18);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          maxLines: 2,
          ellipsis: '…',
        )..layout(maxWidth: maxWidth);
        return Semantics(
          label: text,
          child: SizedBox(
            width: maxWidth,
            height: painter.height,
            child: CustomPaint(painter: _SplashLabelPainter(painter)),
          ),
        );
      },
    );
  }
}

class _SplashLabelPainter extends CustomPainter {
  const _SplashLabelPainter(this.painter);

  final TextPainter painter;

  @override
  void paint(Canvas canvas, Size size) {
    final offset = Offset((size.width - painter.width) / 2, 0);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _SplashLabelPainter oldDelegate) {
    return oldDelegate.painter.text != painter.text ||
        oldDelegate.painter.width != painter.width;
  }
}
