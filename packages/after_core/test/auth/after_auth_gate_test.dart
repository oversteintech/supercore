import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('resolveAfterAuthGateDestination', () {
    test('remembered prefs skip Login while stream loading', () {
      expect(
        resolveAfterAuthGateDestination(
          authStreamLoading: true,
          hasRememberedSession: true,
          isAuthenticated: false,
        ),
        AfterAuthGateDestination.mainShell,
      );
    });

    test('no remember + loading shows loading', () {
      expect(
        resolveAfterAuthGateDestination(
          authStreamLoading: true,
          hasRememberedSession: false,
          isAuthenticated: false,
        ),
        AfterAuthGateDestination.loading,
      );
    });

    test('authenticated session opens shell', () {
      expect(
        resolveAfterAuthGateDestination(
          hasAuthValue: true,
          isAuthenticated: true,
          hasRememberedSession: false,
        ),
        AfterAuthGateDestination.mainShell,
      );
    });

    test('unauthenticated without remember opens login', () {
      expect(
        resolveAfterAuthGateDestination(
          hasAuthValue: true,
          isAuthenticated: false,
          hasRememberedSession: false,
        ),
        AfterAuthGateDestination.login,
      );
    });

    test('unauthenticated with remember still opens shell', () {
      expect(
        resolveAfterAuthGateDestination(
          hasAuthValue: true,
          isAuthenticated: false,
          hasRememberedSession: true,
        ),
        AfterAuthGateDestination.mainShell,
      );
    });

    test('sticky previousStable while stream loading without remember', () {
      expect(
        resolveAfterAuthGateDestination(
          authStreamLoading: true,
          hasRememberedSession: false,
          isAuthenticated: false,
          previousStable: AfterAuthGateDestination.mainShell,
        ),
        AfterAuthGateDestination.mainShell,
      );
    });

    test('unsigned sessionLoading never sticks on mainShell', () {
      expect(
        resolveAfterAuthGateDestination(
          hasAuthValue: true,
          sessionLoading: true,
          isAuthenticated: false,
          hasRememberedSession: false,
          previousStable: AfterAuthGateDestination.mainShell,
        ),
        AfterAuthGateDestination.login,
      );
    });
  });

  group('resolveAfterAuthGateDestinationFromAsync', () {
    test('maps AsyncLoading + remember to mainShell', () {
      expect(
        resolveAfterAuthGateDestinationFromAsync(
          sessionAsync: const AsyncLoading<AfterAuthSession>(),
          hasRememberedSession: true,
        ),
        AfterAuthGateDestination.mainShell,
      );
    });
  });

  group('PrefsGoogleAuthRepository session restore', () {
    test('survives repository recreation after sign-in', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final auth = PrefsGoogleAuthRepository(
        prefs,
        prefsKeyPrefix: 'super_finance',
      );
      await auth.signInWithEmailPassword(
        const AfterEmailPasswordCredentials(
          email: 'keep@finance.app',
          password: 'secret',
        ),
      );
      expect(
        PrefsGoogleAuthRepository.hasRememberedSession(
          prefs,
          prefsKeyPrefix: 'super_finance',
        ),
        isTrue,
      );

      final restored = PrefsGoogleAuthRepository(
        prefs,
        prefsKeyPrefix: 'super_finance',
      );
      final session = await restored.hydrateFromPrefs();
      expect(session.isAuthenticated, isTrue);
      expect(session.user?.email, 'keep@finance.app');
    });
  });
}
