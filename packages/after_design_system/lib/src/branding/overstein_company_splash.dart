import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../premium_themes/overstein_brand_colors.dart';
import 'overstein_animated_mark.dart';

/// Fixed OVERSTEIN company intro — the overstein.com animated OS mark (ring
/// draws in, letters rise, ring spins continuously), then hold.
///
/// Shared across every Super App — black screen, OS mark only (no wordmark,
/// mission line, or product branding).
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
  /// End-to-end splash runtime (mark entrance + hold).
  static const Duration hold = Duration(milliseconds: 5000);

  /// Alias used by cold-start / ANR tests.
  static const Duration total = hold;

  /// Ring draw + letter rise; the ring keeps spinning for the rest of [total].
  static const Duration illuminate = OversteinAnimatedMark.entranceDuration;

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

/// Black-screen company card: animated OS mark only.
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

    final prefs = _prefs;
    final alreadySeen =
        !widget.forceShow && prefs != null && OversteinCompanySplashStore.hasSeen(prefs);
    if (alreadySeen) {
      // Returning launch — never re-show the company intro.
      _finish();
      return;
    }

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

    return const Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(child: OversteinAnimatedMark()),
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
