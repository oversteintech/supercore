import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'after_auth.dart';

/// Stable auth destinations shared by every Super App AuthGate.
enum AfterAuthGateDestination {
  loading,
  login,
  mainShell,
}

/// Pure auth persistence decision (Garage-parity sticky + remember).
///
/// Product AuthGates map [AfterAuthGateDestination] onto their own screens
/// (profile tour, vehicle setup, etc.) after this returns [mainShell].
AfterAuthGateDestination resolveAfterAuthGateDestination({
  /// Riverpod [StreamProvider] still waiting for the first event.
  bool authStreamLoading = false,

  /// Stream already emitted at least one value.
  bool hasAuthValue = false,

  /// Stream failed before any value.
  bool authStreamError = false,

  /// Domain session still hydrating (e.g. Firebase / AppSession.isAuthLoading).
  bool sessionLoading = false,

  required bool isAuthenticated,

  /// Disk remembers a prior sign-in (PrefsGoogle uid / session_authenticated).
  required bool hasRememberedSession,

  AfterAuthGateDestination? previousStable,
}) {
  if (authStreamLoading && !hasAuthValue) {
    if (hasRememberedSession) return AfterAuthGateDestination.mainShell;
    if (previousStable != null) return previousStable;
    return AfterAuthGateDestination.loading;
  }

  if (authStreamError && !hasAuthValue) {
    if (hasRememberedSession) return AfterAuthGateDestination.mainShell;
    return AfterAuthGateDestination.login;
  }

  if (sessionLoading) {
    // Signed-in / remembered: keep sticky shell (or product destination mapped
    // as mainShell) while hydrating — never flash Login.
    if (isAuthenticated || hasRememberedSession) {
      if (previousStable != null) return previousStable;
      return AfterAuthGateDestination.mainShell;
    }
    // Unsigned while loading: never sticky MainShell (looked like "guest").
    if (previousStable == null) return AfterAuthGateDestination.loading;
    return AfterAuthGateDestination.login;
  }

  if (isAuthenticated) {
    return AfterAuthGateDestination.mainShell;
  }

  // Stream says signed-out — still honor disk remember so PrefsGoogle /
  // optimistic AppSession hydrate can catch up on relaunch.
  if (hasRememberedSession) {
    return AfterAuthGateDestination.mainShell;
  }
  return AfterAuthGateDestination.login;
}

/// Convenience for Super Apps that watch [afterAuthSessionProvider].
AfterAuthGateDestination resolveAfterAuthGateDestinationFromAsync({
  required AsyncValue<AfterAuthSession> sessionAsync,
  required bool hasRememberedSession,
  AfterAuthGateDestination? previousStable,
}) {
  final session = sessionAsync.asData?.value;
  return resolveAfterAuthGateDestination(
    authStreamLoading: sessionAsync.isLoading && !sessionAsync.hasValue,
    hasAuthValue: sessionAsync.hasValue,
    authStreamError: sessionAsync.hasError && !sessionAsync.hasValue,
    sessionLoading: session?.isLoading ?? false,
    isAuthenticated: session?.isAuthenticated ?? false,
    hasRememberedSession: hasRememberedSession,
    previousStable: previousStable,
  );
}
