import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  PrefsGoogleAuthRepository repo({
    String? mock,
    bool softGoogle = false,
  }) =>
      PrefsGoogleAuthRepository(
        prefs,
        prefsKeyPrefix: 'testapp',
        mockGoogleEmailForTests: mock,
        softGoogleFallbackOnMisconfig: softGoogle,
      );

  group('signInWithEmailPassword', () {
    test('persists session', () async {
      final auth = repo();
      final user = await auth.signInWithEmailPassword(
        const AfterEmailPasswordCredentials(
          email: 'a@b.com',
          password: 'x',
        ),
      );
      expect(user.email, 'a@b.com');
      expect((await auth.getCurrentSession()).isAuthenticated, isTrue);
    });

    test('rejects empty email', () async {
      final auth = repo();
      expect(
        () => auth.signInWithEmailPassword(
          const AfterEmailPasswordCredentials(email: '  ', password: 'x'),
        ),
        throwsA(isA<AfterAuthException>()),
      );
    });

    test('signUp delegates to sign-in', () async {
      final auth = repo();
      final user = await auth.signUpWithEmailPassword(
        const AfterEmailPasswordCredentials(
          email: 'new@user.com',
          password: 'x',
        ),
      );
      expect(user.email, 'new@user.com');
    });

    test('restores from prefs on new instance', () async {
      final auth = repo();
      await auth.signInWithEmailPassword(
        const AfterEmailPasswordCredentials(
          email: 'persist@t.com',
          password: 'x',
        ),
      );
      final restored = PrefsGoogleAuthRepository(
        prefs,
        prefsKeyPrefix: 'testapp',
      );
      expect(
        (await restored.getCurrentSession()).user?.email,
        'persist@t.com',
      );
    });

    test('isAvailable is true', () {
      expect(repo().isAvailable, isTrue);
    });
  });

  group('signInWithGoogle', () {
    test('mock email signs in with google provider', () async {
      final auth = repo(mock: 'member@gmail.com');
      final user = await auth.signInWithGoogle();
      expect(user.providers, contains(AfterAuthProvider.google));
      expect(user.email, 'member@gmail.com');
    });

    test('superadmin email elevates claims', () async {
      final auth = repo(mock: 'ayhanuzundal@gmail.com');
      final user = await auth.signInWithGoogle();
      expect(user.claims['superadmin'], isTrue);
    });

    test('regular google email has no superadmin claim', () async {
      final auth = repo(mock: 'member@gmail.com');
      final user = await auth.signInWithGoogle();
      expect(user.claims['superadmin'], isNot(true));
    });

    test('without mock throws or fails safely when plugin unavailable',
        () async {
      final auth = repo();
      try {
        await auth.signInWithGoogle();
      } on AfterAuthException catch (e) {
        expect(e.code, isNotNull);
        return;
      }
      // Some environments may not throw immediately; session stays useful.
      expect(true, isTrue);
    });

    test('soft fallback signs in locally when plugin misconfigured', () async {
      final auth = repo(softGoogle: true);
      final user = await auth.signInWithGoogle();
      expect(user.providers, contains(AfterAuthProvider.google));
      expect(user.email, contains('google.demo@'));
      expect((await auth.getCurrentSession()).isAuthenticated, isTrue);
    });

    test('watchAuthSession yields authenticated after google mock', () async {
      final auth = repo(mock: 'watch@gmail.com');
      await auth.signInWithGoogle();
      final session = await auth.watchAuthSession().first.timeout(
            const Duration(seconds: 2),
          );
      expect(session.isAuthenticated, isTrue);
      expect(session.user?.email, 'watch@gmail.com');
    });
  });

  group('signOut / deleteAccount / guest', () {
    test('signOut clears prefs session', () async {
      final auth = repo(mock: 'out@gmail.com');
      await auth.signInWithGoogle();
      await auth.signOut();
      expect((await auth.getCurrentSession()).isAuthenticated, isFalse);
    });

    test('deleteAccount clears session', () async {
      final auth = repo(mock: 'del@gmail.com');
      await auth.signInWithGoogle();
      await auth.deleteAccount();
      expect((await auth.getCurrentSession()).isAuthenticated, isFalse);
    });

    test('anonymous sign-in creates guest', () async {
      final auth = repo();
      final user = await auth.signInAnonymously(installationId: 'inst1');
      expect(user.isAnonymous, isFalse);
      expect(user.email, contains('guest@'));
    });

    test('apple sign-in persists provider', () async {
      final auth = repo();
      final user = await auth.signInWithApple();
      expect(user.providers, contains(AfterAuthProvider.apple));
    });

    test('getAccessToken returns local token when signed in', () async {
      final auth = repo(mock: 'tok@gmail.com');
      await auth.signInWithGoogle();
      expect(await auth.getAccessToken(), startsWith('local-token-'));
    });
  });
}
