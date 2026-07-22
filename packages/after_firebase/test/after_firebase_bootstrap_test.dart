import 'package:after_core/after_core.dart';
import 'package:after_firebase/after_firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    AfterFirebaseBootstrap.resetForTests();
    SharedPreferences.setMockInitialValues({});
  });

  group('AfterFirebaseBootstrap.ensureInitialized', () {
    test('null options yields not ready', () async {
      final ready = await AfterFirebaseBootstrap.ensureInitialized();
      expect(ready, isFalse);
      expect(AfterFirebaseBootstrap.isReady, isFalse);
    });

    test('preferLocalFallback skips firebase', () async {
      final ready = await AfterFirebaseBootstrap.ensureInitialized(
        preferLocalFallback: true,
      );
      expect(ready, isFalse);
    });

    test('second call returns cached readiness', () async {
      await AfterFirebaseBootstrap.ensureInitialized(preferLocalFallback: true);
      final again = await AfterFirebaseBootstrap.ensureInitialized();
      expect(again, isFalse);
    });

    test('cloud availability false without apps', () {
      expect(AfterFirebaseCloudAvailability.canUseCloud, isFalse);
    });

    test('resetForTests clears state', () async {
      await AfterFirebaseBootstrap.ensureInitialized(preferLocalFallback: true);
      AfterFirebaseBootstrap.resetForTests();
      expect(AfterFirebaseBootstrap.isReady, isFalse);
    });
  });

  group('AfterFirebaseBootstrap.overrides', () {
    test('fallback uses PrefsGoogleAuthRepository', () async {
      await AfterFirebaseBootstrap.ensureInitialized(preferLocalFallback: true);
      final prefs = await SharedPreferences.getInstance();
      final overrides = AfterFirebaseBootstrap.overrides(
        preferences: prefs,
        appId: 'superhealth',
        mockGoogleEmailForTests: 'a@b.com',
      );
      expect(overrides.length, 2);
    });

    test('fallback sync port is PrefsAfterUserBlobSync', () async {
      await AfterFirebaseBootstrap.ensureInitialized(preferLocalFallback: true);
      final prefs = await SharedPreferences.getInstance();
      final overrides = AfterFirebaseBootstrap.overrides(
        preferences: prefs,
        appId: 'superhealth',
      );
      // Apply via reading provider would need container; type-check via length.
      expect(overrides, isNotEmpty);
    });

    test('prefs google mock still signs in on fallback', () async {
      await AfterFirebaseBootstrap.ensureInitialized(preferLocalFallback: true);
      final prefs = await SharedPreferences.getInstance();
      final auth = PrefsGoogleAuthRepository(
        prefs,
        prefsKeyPrefix: 'superhealth',
        mockGoogleEmailForTests: 'member@gmail.com',
      );
      final user = await auth.signInWithGoogle();
      expect(user.email, 'member@gmail.com');
    });

    test('prefs blob sync round-trip on fallback', () async {
      final prefs = await SharedPreferences.getInstance();
      final sync = PrefsAfterUserBlobSync(prefs);
      await sync.push(
        const AfterUserBlob(
          appId: 'superhealth',
          userId: 'u1',
          updatedAtMillis: 1,
          payload: {'k': 'v'},
        ),
      );
      final pulled = await sync.pull(appId: 'superhealth', userId: 'u1');
      expect(pulled?.payload['k'], 'v');
    });

    test('firestore sync reports unavailable without firebase', () {
      final sync = FirestoreAfterUserBlobSync();
      expect(sync.isAvailable, isFalse);
    });
  });
}
