import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'family_auth_chrome.dart';
import 'family_chrome.dart';
import 'family_session_effects.dart';
import '../launch/after_launch_consent_gate.dart';

/// Back-compat aliases — auth gate logic lives in after_core.
typedef FamilyAuthGateDestination = AfterAuthGateDestination;

/// Feeds [resolveAfterAuthGateDestinationFromAsync] (after_core).
AfterAuthGateDestination resolveFamilyAuthGateDestination({
  required AsyncValue<AfterAuthSession> sessionAsync,
  required bool hasRememberedSession,
  AfterAuthGateDestination? previousStable,
}) {
  return resolveAfterAuthGateDestinationFromAsync(
    sessionAsync: sessionAsync,
    hasRememberedSession: hasRememberedSession,
    previousStable: previousStable,
  );
}

/// Shared AuthGate: consent → sticky login/shell from after_core auth gate.
class FamilyAuthGate extends ConsumerStatefulWidget {
  const FamilyAuthGate({
    required this.appName,
    required this.appId,
    required this.chrome,
    required this.home,
    this.authConfig,
    this.onContinueAsGuest,
    super.key,
  });

  final String appName;

  /// Prefs key prefix — same as [AfterFirebaseBootstrap.overrides] `appId`.
  final String appId;
  final FamilyChromeConfig chrome;
  final FamilyAuthChromeConfig? authConfig;
  final Widget home;
  final Future<void> Function()? onContinueAsGuest;

  @override
  ConsumerState<FamilyAuthGate> createState() => _FamilyAuthGateState();
}

class _FamilyAuthGateState extends ConsumerState<FamilyAuthGate> {
  AfterAuthGateDestination? _stableDestination;

  bool _hasRemembered(SharedPreferences prefs) {
    return PrefsGoogleAuthRepository.hasRememberedSession(
      prefs,
      prefsKeyPrefix: widget.appId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(afterAuthSessionProvider);
    final prefs = ref.watch(afterSharedPreferencesProvider);
    final remembered = _hasRemembered(prefs);

    final destination = resolveAfterAuthGateDestinationFromAsync(
      sessionAsync: sessionAsync,
      hasRememberedSession: remembered,
      previousStable: _stableDestination,
    );
    if (destination != AfterAuthGateDestination.loading) {
      _stableDestination = destination;
    }

    return AfterLaunchConsentGate(
      appName: widget.appName,
      child: switch (destination) {
        AfterAuthGateDestination.loading => const Scaffold(
            body: Center(child: AfterLoading()),
          ),
        AfterAuthGateDestination.login => FamilyLoginScreen(
            config: widget.chrome,
            authConfig: widget.authConfig ??
                FamilyAuthChromeConfig(
                  appName: widget.chrome.appName,
                  supportEmail: widget.chrome.supportEmail,
                  accent: widget.chrome.accent,
                  tagline: widget.chrome.tagline,
                  aiTitle: widget.chrome.aiTitle,
                  headerTitle: widget.chrome.headerTitle,
                ),
            onContinueAsGuest: widget.onContinueAsGuest,
          ),
        AfterAuthGateDestination.mainShell => FamilySessionEffects(
            child: widget.home,
          ),
      },
    );
  }
}
