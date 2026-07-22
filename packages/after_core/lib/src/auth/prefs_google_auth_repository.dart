import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../errors/after_exception.dart';
import 'after_auth.dart';
import 'after_super_admin.dart';

/// Prefs-backed auth with real Google Sign-In for Super App skeletons.
///
/// Email/password remains local (any password) so demos and tests work without
/// Firebase. Google uses the platform [GoogleSignIn] plugin and persists the
/// returned account email — required for [AfterSuperAdmin] elevation.
///
/// Configure each app in Google Cloud Console with its
/// `com.overstein.<appid>` package / bundle id and signing SHA-1.
class PrefsGoogleAuthRepository implements AfterAuthRepository {
  PrefsGoogleAuthRepository(
    this._prefs, {
    required this.prefsKeyPrefix,
    this.googleServerClientId,
    this.googleIosClientId,
    this.mockGoogleEmailForTests,
    this.softGoogleFallbackOnMisconfig = false,
  }) {
    restoreFromPrefs();
  }

  final SharedPreferences _prefs;

  /// e.g. `supersports` → keys `supersports.auth.uid` …
  final String prefsKeyPrefix;

  /// Optional OAuth web / server client id (Android id token audience).
  final String? googleServerClientId;

  /// Optional iOS OAuth client id.
  final String? googleIosClientId;

  /// When non-null (tests only), [signInWithGoogle] skips the plugin.
  final String? mockGoogleEmailForTests;

  /// When true (placeholder Firebase / local fallback), Google Console
  /// misconfiguration yields a local demo Google session instead of a hard fail.
  final bool softGoogleFallbackOnMisconfig;

  final _controller = StreamController<AfterAuthSession>.broadcast();
  AfterAuthSession _session = const AfterAuthSession.unauthenticated();
  var _googleReady = false;
  Future<void>? _googleInit;

  String get _uidKey => '$prefsKeyPrefix.auth.uid';
  String get _emailKey => '$prefsKeyPrefix.auth.email';
  String get _nameKey => '$prefsKeyPrefix.auth.name';
  String get _providerKey => '$prefsKeyPrefix.auth.provider';

  void restoreFromPrefs() {
    final storedUid = _prefs.getString(_uidKey);
    final storedEmail = _prefs.getString(_emailKey);
    final storedName = _prefs.getString(_nameKey);
    if (storedUid == null) return;
    final providerRaw = _prefs.getString(_providerKey);
    final provider = switch (providerRaw) {
      'google' => AfterAuthProvider.google,
      'apple' => AfterAuthProvider.apple,
      _ => AfterAuthProvider.emailPassword,
    };
    _session = AfterAuthSession(
      isAuthenticated: true,
      isLoading: false,
      user: AfterAuthUser(
        uid: storedUid,
        isAnonymous: false,
        email: storedEmail,
        displayName: storedName ?? storedEmail?.split('@').first ?? 'Member',
        emailVerified: true,
        providers: [provider],
        claims: _claimsFor(storedEmail),
      ),
      accessToken: 'local-token-$storedUid',
    );
  }

  Map<String, Object?> _claimsFor(String? email) {
    if (!AfterSuperAdmin.isSuperAdminEmail(email)) return const {};
    return const {'superadmin': true, 'role': 'superadmin'};
  }

  void _emit(AfterAuthSession session) {
    _session = session;
    _controller.add(session);
  }

  Future<AfterAuthUser> _persistSignedIn({
    required String email,
    required String displayName,
    required AfterAuthProvider provider,
  }) async {
    final normalized = email.trim().toLowerCase();
    final uid = _prefs.getString(_uidKey) ?? const Uuid().v4();
    await _prefs.setString(_uidKey, uid);
    await _prefs.setString(_emailKey, normalized);
    await _prefs.setString(_nameKey, displayName);
    await _prefs.setString(_providerKey, provider.name);
    final user = AfterAuthUser(
      uid: uid,
      isAnonymous: false,
      email: normalized,
      displayName: displayName,
      emailVerified: true,
      providers: [provider],
      claims: _claimsFor(normalized),
    );
    _emit(
      AfterAuthSession(
        isAuthenticated: true,
        isLoading: false,
        user: user,
        accessToken: 'local-token-$uid',
      ),
    );
    return user;
  }

  Future<void> _ensureGoogleInitialized() {
    return _googleInit ??= () async {
      try {
        final server = googleServerClientId?.trim();
        final ios = googleIosClientId?.trim();
        if (server != null && server.isNotEmpty) {
          await GoogleSignIn.instance.initialize(
            serverClientId: server,
            clientId: (ios != null && ios.isNotEmpty) ? ios : null,
          );
        } else if (ios != null && ios.isNotEmpty) {
          await GoogleSignIn.instance.initialize(clientId: ios);
        } else {
          await GoogleSignIn.instance.initialize();
        }
        _googleReady = true;
      } on Object {
        _googleInit = null;
        rethrow;
      }
    }();
  }

  @override
  bool get isAvailable => true;

  @override
  Stream<AfterAuthSession> watchAuthSession() async* {
    yield _session;
    yield* _controller.stream;
  }

  @override
  Future<AfterAuthSession> getCurrentSession() async => _session;

  @override
  Future<AfterAuthUser> signInAnonymously({required String installationId}) {
    return _persistSignedIn(
      email: 'guest@$installationId.afterartificial.app',
      displayName: 'Guest',
      provider: AfterAuthProvider.anonymous,
    );
  }

  @override
  Future<AfterAuthUser> signInWithEmailPassword(
    AfterEmailPasswordCredentials credentials,
  ) {
    final email = credentials.email.trim();
    if (email.isEmpty) {
      throw const AfterAuthException(
        'Email is required.',
        code: 'auth/invalid-email',
      );
    }
    return _persistSignedIn(
      email: email,
      displayName: email.split('@').first,
      provider: AfterAuthProvider.emailPassword,
    );
  }

  @override
  Future<AfterAuthUser> signUpWithEmailPassword(
    AfterEmailPasswordCredentials credentials,
  ) {
    return signInWithEmailPassword(credentials);
  }

  @override
  Future<void> sendMagicLink({required String email}) async {}

  @override
  Future<AfterAuthUser> completeMagicLinkSignIn({required String url}) {
    return _persistSignedIn(
      email: 'magic@link.afterartificial.app',
      displayName: 'Magic Link User',
      provider: AfterAuthProvider.magicLink,
    );
  }

  Future<AfterAuthUser> _softGoogleSession() {
    final email = 'google.demo@$prefsKeyPrefix.afterartificial.app';
    if (kDebugMode) {
      debugPrint(
        'PrefsGoogleAuth: soft Google fallback for $prefsKeyPrefix '
        '(OAuth client not configured)',
      );
    }
    return _persistSignedIn(
      email: email,
      displayName: 'Google',
      provider: AfterAuthProvider.google,
    );
  }

  bool _isGoogleMisconfigured(Object error) {
    if (error is GoogleSignInException) {
      return error.code == GoogleSignInExceptionCode.clientConfigurationError ||
          error.code == GoogleSignInExceptionCode.providerConfigurationError;
    }
    final text = error.toString().toLowerCase();
    return text.contains('clientconfigurationerror') ||
        text.contains('providerconfigurationerror');
  }

  @override
  Future<AfterAuthUser> signInWithGoogle() async {
    final mockEmail = mockGoogleEmailForTests?.trim();
    if (mockEmail != null && mockEmail.isNotEmpty) {
      return _persistSignedIn(
        email: mockEmail,
        displayName: mockEmail.split('@').first,
        provider: AfterAuthProvider.google,
      );
    }

    try {
      await _ensureGoogleInitialized();
      if (!_googleReady || !GoogleSignIn.instance.supportsAuthenticate()) {
        if (softGoogleFallbackOnMisconfig) return _softGoogleSession();
        throw const AfterAuthException(
          'Google Sign-In is not available on this device. '
          'Register the app package and SHA-1 in Google Cloud Console.',
          code: 'auth/google-misconfigured',
        );
      }

      final lightweight =
          GoogleSignIn.instance.attemptLightweightAuthentication();
      if (lightweight != null) {
        final silent = await lightweight;
        if (silent != null && silent.email.trim().isNotEmpty) {
          return _persistSignedIn(
            email: silent.email,
            displayName: silent.displayName ?? silent.email.split('@').first,
            provider: AfterAuthProvider.google,
          );
        }
      }

      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile', 'openid'],
      );
      final email = account.email.trim();
      if (email.isEmpty) {
        throw const AfterAuthException(
          'Google account did not return an email address.',
          code: 'auth/google-no-email',
        );
      }
      return _persistSignedIn(
        email: email,
        displayName: account.displayName ?? email.split('@').first,
        provider: AfterAuthProvider.google,
      );
    } on AfterException catch (error) {
      if (softGoogleFallbackOnMisconfig &&
          error.code == 'auth/google-misconfigured') {
        return _softGoogleSession();
      }
      rethrow;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled ||
          error.code == GoogleSignInExceptionCode.interrupted) {
        throw const AfterAuthException(
          'Google Sign-In was canceled.',
          code: 'auth/google-canceled',
        );
      }
      if (softGoogleFallbackOnMisconfig) return _softGoogleSession();
      if (_isGoogleMisconfigured(error)) {
        throw AfterAuthException(
          'Google Sign-In is misconfigured for this app. '
          'Add OAuth clients for this package in Google Cloud Console.',
          code: 'auth/google-misconfigured',
          cause: error,
        );
      }
      throw AfterAuthException(
        'Google Sign-In failed: ${error.code.name}',
        code: 'auth/google-failed',
        cause: error,
      );
    } on Object catch (error, stack) {
      if (kDebugMode) {
        debugPrint('Google Sign-In failed: $error\n$stack');
      }
      if (softGoogleFallbackOnMisconfig) return _softGoogleSession();
      throw AfterAuthException(
        'Google Sign-In failed: $error',
        code: 'auth/google-failed',
        cause: error,
      );
    }
  }

  @override
  Future<AfterAuthUser> signInWithApple() {
    return _persistSignedIn(
      email: 'member@icloud.com',
      displayName: 'Apple Member',
      provider: AfterAuthProvider.apple,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<AfterAuthUser?> reloadCurrentUser() async => _session.user;

  @override
  Future<void> signOut() async {
    try {
      if (_googleReady) {
        await GoogleSignIn.instance.signOut();
      }
    } on Object {
      // Best-effort; local session still clears.
    }
    await _prefs.remove(_uidKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_nameKey);
    await _prefs.remove(_providerKey);
    _emit(const AfterAuthSession.unauthenticated());
  }

  @override
  Future<void> deleteAccount() => signOut();

  @override
  Future<String?> getAccessToken() async => _session.accessToken;
}
