import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../premium_themes/overstein_brand_colors.dart';
import 'overstein_logo.dart';

/// Fixed OVERSTEIN company intro — slow premium illuminate, then hold.
///
/// Shared across every Super App — black screen, OS mark, no product branding.
///
/// **First install only:** after the intro completes once, [OversteinCompanySplashStore]
/// marks it seen and subsequent launches (app kill, phone reboot, etc.) skip
/// straight to [onComplete]. Pass [forceShow] only for tests / demos.
///
/// ANR contract (do not break):
/// - No Firebase / GMS / auth work from this widget
/// - No product branding / second act
/// - Motion stays on-UI-thread only (Ticker); no network / disk in paint
/// - Always completes via [onComplete] or [hardTimeout]
abstract final class OversteinCompanySplashTiming {
  /// End-to-end splash runtime (illuminate + hold).
  static const Duration hold = Duration(milliseconds: 5000);

  /// Alias used by cold-start / ANR tests.
  static const Duration total = hold;

  /// Slow dark → bright reveal occupies most of [total].
  static const Duration illuminate = Duration(milliseconds: 3600);

  /// Absolute ceiling so splash can never stick.
  static const Duration hardTimeout = Duration(milliseconds: 8000);
}

/// Persists first-install company splash completion across process death.
///
/// Prefer excluding this key from Android Auto Backup when backup is enabled,
/// so a restored backup cannot skip a true first install. SuperGarage disables
/// full backup (`fullBackupContent=false`).
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
  fontSize: 10,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.15,
  height: 1.35,
  decoration: TextDecoration.none,
);

/// Black-screen company card: slow illuminate + mark / wordmark / mission.
///
/// Shows only on first install (until [OversteinCompanySplashStore] marks seen).
class OversteinCompanySplash extends StatefulWidget {
  const OversteinCompanySplash({
    super.key,
    required this.onComplete,
    this.preferences,
    this.preferencesFuture,
    /// When true, always run the cinematic (tests / demos). Default: first install only.
    this.forceShow = false,
  });

  final VoidCallback onComplete;
  final SharedPreferences? preferences;
  final Future<SharedPreferences>? preferencesFuture;
  final bool forceShow;

  @override
  State<OversteinCompanySplash> createState() => _OversteinCompanySplashState();
}

class _OversteinCompanySplashState extends State<OversteinCompanySplash>
    with SingleTickerProviderStateMixin {
  var _completed = false;
  var _visible = false;
  Timer? _holdTimer;
  Timer? _hardTimeout;
  SharedPreferences? _prefs;
  final _startedAt = Stopwatch();

  late final AnimationController _controller;
  late final Animation<double> _illuminate;

  @override
  void initState() {
    super.initState();
    _startedAt.start();
    _controller = AnimationController(
      vsync: this,
      duration: OversteinCompanySplashTiming.total,
    );
    // Slow ease: dark → bright over most of the 5s, then rest at full.
    final illuminateEnd =
        OversteinCompanySplashTiming.illuminate.inMilliseconds /
        OversteinCompanySplashTiming.total.inMilliseconds;
    _illuminate = CurvedAnimation(
      parent: _controller,
      curve: Interval(0, illuminateEnd.clamp(0.5, 0.9), curve: Curves.easeInOutCubic),
    );
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

    final prefs = _prefs;
    final alreadySeen =
        !widget.forceShow && prefs != null && OversteinCompanySplashStore.hasSeen(prefs);
    if (alreadySeen) {
      // Returning launch — never re-show the company intro.
      _finish();
      return;
    }

    setState(() => _visible = true);
    unawaited(_controller.forward());

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
    _controller.dispose();
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _illuminate,
        builder: (context, child) {
          final t = _illuminate.value;
          // Cinematic dark → light: veil lifts slowly while mark gains presence.
          final presence = 0.18 + (0.82 * t);
          final veil = (1.0 - t) * 0.88;
          return Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: presence.clamp(0.0, 1.0),
                child: child,
              ),
              IgnorePointer(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: veil.clamp(0.0, 1.0)),
                ),
              ),
            ],
          );
        },
        child: const _StaticSplashBody(),
      ),
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
