import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('FamilyAuthGateDestination aliases after_core', () {
    expect(
      FamilyAuthGateDestination.mainShell,
      AfterAuthGateDestination.mainShell,
    );
  });

  test('resolveFamilyAuthGateDestination delegates to after_core', () {
    expect(
      resolveFamilyAuthGateDestination(
        sessionAsync: const AsyncLoading<AfterAuthSession>(),
        hasRememberedSession: true,
      ),
      AfterAuthGateDestination.mainShell,
    );
  });

  test('PrefsGoogle remember still works for family apps', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final auth = PrefsGoogleAuthRepository(
      prefs,
      prefsKeyPrefix: 'super_health',
    );
    await auth.signInWithEmailPassword(
      const AfterEmailPasswordCredentials(
        email: 'keep@health.app',
        password: 'x',
      ),
    );
    expect(
      PrefsGoogleAuthRepository.hasRememberedSession(
        prefs,
        prefsKeyPrefix: 'super_health',
      ),
      isTrue,
    );
  });
}
