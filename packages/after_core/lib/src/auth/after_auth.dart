/// Identity providers supported by After Core.
enum AfterAuthProvider {
  anonymous,
  emailPassword,
  magicLink,
  google,
  apple,
  phone,
  custom,
}

/// Authenticated user snapshot (provider-agnostic).
class AfterAuthUser {
  const AfterAuthUser({
    required this.uid,
    required this.isAnonymous,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.emailVerified = false,
    this.providers = const [],
    this.claims = const {},
  });

  final String uid;
  final bool isAnonymous;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool emailVerified;
  final List<AfterAuthProvider> providers;
  final Map<String, Object?> claims;

  AfterAuthUser copyWith({
    String? uid,
    bool? isAnonymous,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool? emailVerified,
    List<AfterAuthProvider>? providers,
    Map<String, Object?>? claims,
  }) {
    return AfterAuthUser(
      uid: uid ?? this.uid,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      providers: providers ?? this.providers,
      claims: claims ?? this.claims,
    );
  }
}

/// Session state for UI gates.
class AfterAuthSession {
  const AfterAuthSession({
    required this.isAuthenticated,
    required this.isLoading,
    this.user,
    this.installationId,
    this.accessToken,
    this.errorMessage,
  });

  const AfterAuthSession.unauthenticated({this.installationId})
      : isAuthenticated = false,
        isLoading = false,
        user = null,
        accessToken = null,
        errorMessage = null;

  const AfterAuthSession.loading({this.installationId})
      : isAuthenticated = false,
        isLoading = true,
        user = null,
        accessToken = null,
        errorMessage = null;

  final bool isAuthenticated;
  final bool isLoading;
  final AfterAuthUser? user;
  final String? installationId;
  final String? accessToken;
  final String? errorMessage;

  bool get isAnonymous => user?.isAnonymous ?? false;
  bool get isGuest => !isAuthenticated && !isLoading;

  AfterAuthSession copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    AfterAuthUser? user,
    String? installationId,
    String? accessToken,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
    bool clearToken = false,
  }) {
    return AfterAuthSession(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      installationId: installationId ?? this.installationId,
      accessToken: clearToken ? null : (accessToken ?? this.accessToken),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AfterEmailPasswordCredentials {
  const AfterEmailPasswordCredentials({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

/// Auth port — Super Apps implement with Firebase / Supabase / custom.
abstract class AfterAuthRepository {
  Stream<AfterAuthSession> watchAuthSession();

  Future<AfterAuthSession> getCurrentSession();

  Future<AfterAuthUser> signInAnonymously({required String installationId});

  Future<AfterAuthUser> signInWithEmailPassword(
    AfterEmailPasswordCredentials credentials,
  );

  Future<AfterAuthUser> signUpWithEmailPassword(
    AfterEmailPasswordCredentials credentials,
  );

  Future<void> sendMagicLink({required String email});

  Future<AfterAuthUser> completeMagicLinkSignIn({required String url});

  Future<AfterAuthUser> signInWithGoogle();

  Future<AfterAuthUser> signInWithApple();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> sendEmailVerification();

  Future<AfterAuthUser?> reloadCurrentUser();

  Future<void> signOut();

  Future<void> deleteAccount();

  /// Optional bearer token for API calls.
  Future<String?> getAccessToken();

  bool get isAvailable;
}

/// Stub for tests / offline shells.
class NoOpAfterAuthRepository implements AfterAuthRepository {
  AfterAuthSession _session = const AfterAuthSession.unauthenticated();

  @override
  bool get isAvailable => false;

  @override
  Stream<AfterAuthSession> watchAuthSession() async* {
    yield _session;
  }

  @override
  Future<AfterAuthSession> getCurrentSession() async => _session;

  @override
  Future<AfterAuthUser> signInAnonymously({required String installationId}) {
    throw UnimplementedError('Auth backend not configured');
  }

  @override
  Future<AfterAuthUser> signInWithEmailPassword(
    AfterEmailPasswordCredentials credentials,
  ) {
    throw UnimplementedError('Auth backend not configured');
  }

  @override
  Future<AfterAuthUser> signUpWithEmailPassword(
    AfterEmailPasswordCredentials credentials,
  ) {
    throw UnimplementedError('Auth backend not configured');
  }

  @override
  Future<void> sendMagicLink({required String email}) {
    throw UnimplementedError('Auth backend not configured');
  }

  @override
  Future<AfterAuthUser> completeMagicLinkSignIn({required String url}) {
    throw UnimplementedError('Auth backend not configured');
  }

  @override
  Future<AfterAuthUser> signInWithGoogle() {
    throw UnimplementedError('Auth backend not configured');
  }

  @override
  Future<AfterAuthUser> signInWithApple() {
    throw UnimplementedError('Auth backend not configured');
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<AfterAuthUser?> reloadCurrentUser() async => _session.user;

  @override
  Future<void> signOut() async {
    _session = AfterAuthSession.unauthenticated(
      installationId: _session.installationId,
    );
  }

  @override
  Future<void> deleteAccount() async => signOut();

  @override
  Future<String?> getAccessToken() async => null;
}
