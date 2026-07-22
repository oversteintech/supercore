import 'dart:async';

import 'package:after_core/after_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:after_firebase/src/after_firebase_cloud_availability.dart';

/// Firebase Auth implementation of [AfterAuthRepository].
///
/// Google Sign-In uses the platform plugin (idToken → credential).
/// CI / tests may set [mockGoogleEmailForTests] to skip the plugin.
class FirebaseAfterAuthRepository implements AfterAuthRepository {
  FirebaseAfterAuthRepository({
    this.googleServerClientId,
    this.googleIosClientId,
    this.mockGoogleEmailForTests,
    firebase.FirebaseAuth? auth,
  }) : _auth = auth;

  final String? googleServerClientId;
  final String? googleIosClientId;
  final String? mockGoogleEmailForTests;
  final firebase.FirebaseAuth? _auth;

  var _googleReady = false;
  Future<void>? _googleInit;

  firebase.FirebaseAuth? get _safeAuth {
    if (_auth != null) return _auth;
    if (!AfterFirebaseCloudAvailability.canUseCloud) return null;
    try {
      return firebase.FirebaseAuth.instance;
    } on Object {
      return null;
    }
  }

  @override
  bool get isAvailable => _safeAuth != null;

  AfterAuthUser _mapUser(firebase.User user) {
    final providers = <AfterAuthProvider>[];
    for (final info in user.providerData) {
      providers.add(switch (info.providerId) {
        'google.com' => AfterAuthProvider.google,
        'apple.com' => AfterAuthProvider.apple,
        'password' => AfterAuthProvider.emailPassword,
        _ => AfterAuthProvider.custom,
      });
    }
    if (user.isAnonymous) {
      providers.add(AfterAuthProvider.anonymous);
    }
    final email = user.email;
    return AfterAuthUser(
      uid: user.uid,
      isAnonymous: user.isAnonymous,
      email: email,
      displayName: user.displayName ?? email?.split('@').first ?? 'Member',
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
      emailVerified: user.emailVerified,
      providers: providers.isEmpty ? [AfterAuthProvider.custom] : providers,
      claims: AfterSuperAdmin.isSuperAdminEmail(email)
          ? const {'superadmin': true, 'role': 'superadmin'}
          : const {},
    );
  }

  AfterAuthSession _sessionFrom(firebase.User? user) {
    if (user == null) {
      return const AfterAuthSession.unauthenticated();
    }
    return AfterAuthSession(
      isAuthenticated: true,
      isLoading: false,
      user: _mapUser(user),
    );
  }

  @override
  Stream<AfterAuthSession> watchAuthSession() {
    final auth = _safeAuth;
    if (auth == null) {
      return Stream.value(const AfterAuthSession.unauthenticated());
    }
    return auth.authStateChanges().map(_sessionFrom);
  }

  @override
  Future<AfterAuthSession> getCurrentSession() async {
    return _sessionFrom(_safeAuth?.currentUser);
  }

  Future<AfterAuthUser> _requireUser(firebase.UserCredential credential) async {
    final user = credential.user;
    if (user == null) {
      throw const AfterAuthException(
        'Sign-in failed — no user returned.',
        code: 'auth/no-user',
      );
    }
    return _mapUser(user);
  }

  @override
  Future<AfterAuthUser> signInAnonymously({
    required String installationId,
  }) async {
    final auth = _safeAuth;
    if (auth == null) {
      throw const AfterAuthException(
        'Firebase Auth is not available.',
        code: 'auth/unavailable',
      );
    }
    return _requireUser(await auth.signInAnonymously());
  }

  @override
  Future<AfterAuthUser> signInWithEmailPassword(
    AfterEmailPasswordCredentials credentials,
  ) async {
    final auth = _safeAuth;
    if (auth == null) {
      throw const AfterAuthException(
        'Firebase Auth is not available.',
        code: 'auth/unavailable',
      );
    }
    try {
      return await _requireUser(
        await auth.signInWithEmailAndPassword(
          email: credentials.email.trim(),
          password: credentials.password,
        ),
      );
    } on firebase.FirebaseAuthException catch (e) {
      throw AfterAuthException(
        e.message ?? 'Email sign-in failed',
        code: e.code,
      );
    }
  }

  @override
  Future<AfterAuthUser> signUpWithEmailPassword(
    AfterEmailPasswordCredentials credentials,
  ) async {
    final auth = _safeAuth;
    if (auth == null) {
      throw const AfterAuthException(
        'Firebase Auth is not available.',
        code: 'auth/unavailable',
      );
    }
    try {
      return await _requireUser(
        await auth.createUserWithEmailAndPassword(
          email: credentials.email.trim(),
          password: credentials.password,
        ),
      );
    } on firebase.FirebaseAuthException catch (e) {
      throw AfterAuthException(
        e.message ?? 'Email sign-up failed',
        code: e.code,
      );
    }
  }

  @override
  Future<void> sendMagicLink({required String email}) async {
    throw const AfterAuthException(
      'Magic link is not configured for this Firebase project.',
      code: 'auth/not-implemented',
    );
  }

  @override
  Future<AfterAuthUser> completeMagicLinkSignIn({required String url}) {
    throw const AfterAuthException(
      'Magic link is not configured for this Firebase project.',
      code: 'auth/not-implemented',
    );
  }

  Future<void> _ensureGoogleInitialized() {
    return _googleInit ??= () async {
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
    }();
  }

  @override
  Future<AfterAuthUser> signInWithGoogle() async {
    final mock = mockGoogleEmailForTests?.trim();
    if (mock != null && mock.isNotEmpty) {
      // Deterministic CI path — still requires Firebase when available so
      // UID matches Firestore; otherwise use anonymous-linked email session
      // via custom token is not available — sign in anonymously then update.
      final auth = _safeAuth;
      if (auth == null) {
        throw const AfterAuthException(
          'Firebase Auth is not available for Google mock sign-in.',
          code: 'auth/unavailable',
        );
      }
      // Emulator / CI: email-password with fixed password for mock Google.
      try {
        return await signInWithEmailPassword(
          AfterEmailPasswordCredentials(
            email: mock,
            password: 'after-firebase-mock-google',
          ),
        );
      } on AfterAuthException {
        return signUpWithEmailPassword(
          AfterEmailPasswordCredentials(
            email: mock,
            password: 'after-firebase-mock-google',
          ),
        );
      }
    }

    final auth = _safeAuth;
    if (auth == null) {
      throw const AfterAuthException(
        'Firebase Auth is not available.',
        code: 'auth/unavailable',
      );
    }

    try {
      if (kIsWeb) {
        final provider = firebase.GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile');
        return _requireUser(await auth.signInWithPopup(provider));
      }

      await _ensureGoogleInitialized();
      if (!_googleReady || !GoogleSignIn.instance.supportsAuthenticate()) {
        throw const AfterAuthException(
          'Google Sign-In is not available. Register package + SHA-1.',
          code: 'auth/google-misconfigured',
        );
      }

      final lightweight =
          GoogleSignIn.instance.attemptLightweightAuthentication();
      GoogleSignInAccount? account;
      if (lightweight != null) {
        account = await lightweight;
      }
      account ??= await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile', 'openid'],
      );

      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AfterAuthException(
          'Google account did not return an ID token.',
          code: 'auth/google-no-token',
        );
      }

      final credential = firebase.GoogleAuthProvider.credential(
        idToken: idToken,
      );
      return _requireUser(await auth.signInWithCredential(credential));
    } on AfterException {
      rethrow;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        throw const AfterAuthException(
          'Google Sign-In was canceled.',
          code: 'auth/google-canceled',
        );
      }
      if (e.code == GoogleSignInExceptionCode.clientConfigurationError ||
          e.code == GoogleSignInExceptionCode.providerConfigurationError) {
        throw AfterAuthException(
          'Google Sign-In is misconfigured for this app. '
          'Add OAuth clients for this package in Google Cloud Console.',
          code: 'auth/google-misconfigured',
          cause: e,
        );
      }
      throw AfterAuthException(
        'Google Sign-In failed: ${e.code.name}',
        code: 'auth/google-failed',
        cause: e,
      );
    } on firebase.FirebaseAuthException catch (e) {
      throw AfterAuthException(
        e.message ?? 'Google Sign-In failed',
        code: e.code,
      );
    } on Object catch (e, st) {
      if (kDebugMode) {
        debugPrint('Google Sign-In failed: $e\n$st');
      }
      throw AfterAuthException(
        'Google Sign-In failed: $e',
        code: 'auth/google-failed',
        cause: e,
      );
    }
  }

  @override
  Future<AfterAuthUser> signInWithApple() async {
    throw const AfterAuthException(
      'Apple Sign-In via Firebase is not wired in after_firebase yet.',
      code: 'auth/not-implemented',
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final auth = _safeAuth;
    if (auth == null) return;
    await auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _safeAuth?.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  @override
  Future<AfterAuthUser?> reloadCurrentUser() async {
    final user = _safeAuth?.currentUser;
    if (user == null) return null;
    await user.reload();
    final refreshed = _safeAuth?.currentUser;
    return refreshed == null ? null : _mapUser(refreshed);
  }

  @override
  Future<void> signOut() async {
    try {
      if (_googleReady) {
        await GoogleSignIn.instance.signOut();
      }
    } on Object {
      // best-effort
    }
    await _safeAuth?.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    final user = _safeAuth?.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  @override
  Future<String?> getAccessToken() async {
    return _safeAuth?.currentUser?.getIdToken();
  }
}
