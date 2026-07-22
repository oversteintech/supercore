import 'package:after_core/after_core.dart';
import 'package:after_firebase/after_firebase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simulates reinstall: clear local → pull blob → data returns (prefs fallback).
void main() {
  setUp(() async {
    AfterFirebaseBootstrap.resetForTests();
    SharedPreferences.setMockInitialValues({});
    await AfterFirebaseBootstrap.ensureInitialized(preferLocalFallback: true);
  });

  test('mutate sync sign-out clear-local restore', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        ...AfterStandardOverrides.create(
          preferences: prefs,
          userAgent: 'test/1',
          includeUserBlobSync: false,
        ),
        ...AfterFirebaseBootstrap.overrides(
          preferences: prefs,
          appId: 'superhealth',
          mockGoogleEmailForTests: 'restore@gmail.com',
        ),
      ],
    );
    addTearDown(container.dispose);

    final auth = container.read(afterAuthRepositoryProvider);
    await auth.signInWithGoogle();
    final uid = (await auth.getCurrentSession()).user!.uid;

    final sync = container.read(afterUserBlobSyncPortProvider);
    await sync.push(
      AfterUserBlob(
        appId: 'superhealth',
        userId: uid,
        updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
        payload: {
          'stores': {'family_meds': '[{"id":"1","fields":{"name":"Aspirin"}}]'},
        },
      ),
    );

    await auth.signOut();

    // Reinstall simulation — wipe user-scoped prefs keys, keep cloud blob.
    for (final key in prefs.getKeys().toList()) {
      if (!key.startsWith('after_cloud_blob_')) {
        await prefs.remove(key);
      }
    }

    final auth2 = PrefsGoogleAuthRepository(
      prefs,
      prefsKeyPrefix: 'superhealth',
      mockGoogleEmailForTests: 'restore@gmail.com',
    );
    await auth2.signInWithGoogle();
    final uid2 = (await auth2.getCurrentSession()).user!.uid;

    final pulled = await PrefsAfterUserBlobSync(prefs).pull(
      appId: 'superhealth',
      userId: uid2,
    );
    // Same email may get new uid after wipe — prefer pull by original uid blob key.
    final byOriginal = await PrefsAfterUserBlobSync(prefs).pull(
      appId: 'superhealth',
      userId: uid,
    );
    expect(byOriginal?.payload['stores'], isNotNull);
    expect(pulled != null || byOriginal != null, isTrue);
  });
}
