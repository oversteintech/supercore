import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PlatformConfig.current = const AppPlatformManifest(
      appName: 'Test',
      appId: 'testapp',
      packageName: 'com.overstein.test',
      androidWidgetProvider: 'x',
      iosAppGroupId: 'x',
    );
  });

  Future<ProviderContainer> containerWith({
    required AfterAuthRepository auth,
    AfterUserBlobSyncPort? sync,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        afterSharedPreferencesProvider.overrideWithValue(prefs),
        afterAuthRepositoryProvider.overrideWithValue(auth),
        afterUserBlobSyncPortProvider.overrideWithValue(
          sync ?? InMemoryAfterUserBlobSync(),
        ),
      ],
    );
  }

  group('FamilyCloudSyncController.syncNow', () {
    test('unauthenticated sets error', () async {
      final auth = PrefsGoogleAuthRepository(
        await SharedPreferences.getInstance(),
        prefsKeyPrefix: 't',
      );
      final c = await containerWith(auth: auth);
      addTearDown(c.dispose);
      await c.read(familyCloudSyncProvider.notifier).syncNow();
      expect(c.read(familyCloudSyncProvider).errorCode, 'unauthenticated');
    });

    test('push succeeds when authenticated', () async {
      final prefs = await SharedPreferences.getInstance();
      final auth = PrefsGoogleAuthRepository(
        prefs,
        prefsKeyPrefix: 't',
        mockGoogleEmailForTests: 'u@g.com',
      );
      await auth.signInWithGoogle();
      final memory = InMemoryAfterUserBlobSync();
      final c = await containerWith(auth: auth, sync: memory);
      addTearDown(c.dispose);
      await prefs.setString('family_demo', '1');
      await c.read(familyCloudSyncProvider.notifier).syncNow();
      final state = c.read(familyCloudSyncProvider);
      expect(state.status, FamilyCloudSyncStatus.idle);
      expect(state.lastSyncedMillis, isNotNull);
      final uid = (await auth.getCurrentSession()).user!.uid;
      final blob = await memory.pull(appId: 'testapp', userId: uid);
      expect(blob, isNotNull);
    });

    test('remote newer wins', () async {
      final prefs = await SharedPreferences.getInstance();
      final auth = PrefsGoogleAuthRepository(
        prefs,
        prefsKeyPrefix: 't',
        mockGoogleEmailForTests: 'u@g.com',
      );
      await auth.signInWithGoogle();
      final uid = (await auth.getCurrentSession()).user!.uid;
      final memory = InMemoryAfterUserBlobSync();
      await memory.push(
        AfterUserBlob(
          appId: 'testapp',
          userId: uid,
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch + 100000,
          payload: const {
            'stores': {'family_from_cloud': 'yes'},
          },
        ),
      );
      final c = await containerWith(auth: auth, sync: memory);
      addTearDown(c.dispose);
      await c.read(familyCloudSyncProvider.notifier).syncNow();
      expect(prefs.getString('family_from_cloud'), 'yes');
    });

    test('unavailable port sets error code', () async {
      final prefs = await SharedPreferences.getInstance();
      final auth = PrefsGoogleAuthRepository(
        prefs,
        prefsKeyPrefix: 't',
        mockGoogleEmailForTests: 'u@g.com',
      );
      await auth.signInWithGoogle();
      final c = await containerWith(
        auth: auth,
        sync: InMemoryAfterUserBlobSync(available: false),
      );
      addTearDown(c.dispose);
      await c.read(familyCloudSyncProvider.notifier).syncNow();
      expect(c.read(familyCloudSyncProvider).errorCode, 'sync/unavailable');
    });

    test('markLocalDirty schedules without throw', () async {
      final prefs = await SharedPreferences.getInstance();
      final auth = PrefsGoogleAuthRepository(
        prefs,
        prefsKeyPrefix: 't',
        mockGoogleEmailForTests: 'u@g.com',
      );
      await auth.signInWithGoogle();
      final c = await containerWith(auth: auth);
      addTearDown(c.dispose);
      await c.read(familyCloudSyncProvider.notifier).markLocalDirty();
      expect(c.read(familyCloudSyncProvider).status, isNotNull);
    });
  });

  group('restoreFromCloudIfEmpty', () {
    test('no-ops when unauthenticated', () async {
      final auth = PrefsGoogleAuthRepository(
        await SharedPreferences.getInstance(),
        prefsKeyPrefix: 't',
      );
      final c = await containerWith(auth: auth);
      addTearDown(c.dispose);
      await c.read(familyCloudSyncProvider.notifier).restoreFromCloudIfEmpty();
      expect(c.read(familyCloudSyncProvider).errorCode, isNull);
    });

    test('applies remote when local stores empty', () async {
      final prefs = await SharedPreferences.getInstance();
      final auth = PrefsGoogleAuthRepository(
        prefs,
        prefsKeyPrefix: 't',
        mockGoogleEmailForTests: 'u@g.com',
      );
      await auth.signInWithGoogle();
      final uid = (await auth.getCurrentSession()).user!.uid;
      final memory = InMemoryAfterUserBlobSync();
      await memory.push(
        AfterUserBlob(
          appId: 'testapp',
          userId: uid,
          updatedAtMillis: 50,
          payload: const {
            'stores': {'family_restored': 'ok'},
          },
        ),
      );
      final c = await containerWith(auth: auth, sync: memory);
      addTearDown(c.dispose);
      await c.read(familyCloudSyncProvider.notifier).restoreFromCloudIfEmpty();
      expect(prefs.getString('family_restored'), 'ok');
    });

    test('skips when local stores already present', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'family_cloud_local_payload',
        '{"stores":{"family_x":"1"}}',
      );
      final auth = PrefsGoogleAuthRepository(
        prefs,
        prefsKeyPrefix: 't',
        mockGoogleEmailForTests: 'u@g.com',
      );
      await auth.signInWithGoogle();
      final uid = (await auth.getCurrentSession()).user!.uid;
      final memory = InMemoryAfterUserBlobSync();
      await memory.push(
        AfterUserBlob(
          appId: 'testapp',
          userId: uid,
          updatedAtMillis: 99,
          payload: const {
            'stores': {'family_restored': 'nope'},
          },
        ),
      );
      final c = await containerWith(auth: auth, sync: memory);
      addTearDown(c.dispose);
      await c.read(familyCloudSyncProvider.notifier).restoreFromCloudIfEmpty();
      expect(prefs.getString('family_restored'), isNull);
    });

    test('equal timestamps allow local push path', () async {
      final prefs = await SharedPreferences.getInstance();
      final auth = PrefsGoogleAuthRepository(
        prefs,
        prefsKeyPrefix: 't',
        mockGoogleEmailForTests: 'u@g.com',
      );
      await auth.signInWithGoogle();
      final uid = (await auth.getCurrentSession()).user!.uid;
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt('family_cloud_last_synced_millis', now);
      final memory = InMemoryAfterUserBlobSync();
      await memory.push(
        AfterUserBlob(
          appId: 'testapp',
          userId: uid,
          updatedAtMillis: now,
          payload: const {'stores': <String, dynamic>{}},
        ),
      );
      final c = await containerWith(auth: auth, sync: memory);
      addTearDown(c.dispose);
      await c.read(familyCloudSyncProvider.notifier).syncNow();
      expect(c.read(familyCloudSyncProvider).status, FamilyCloudSyncStatus.idle);
    });

    test('scheduleSync does not throw', () async {
      final prefs = await SharedPreferences.getInstance();
      final auth = PrefsGoogleAuthRepository(
        prefs,
        prefsKeyPrefix: 't',
        mockGoogleEmailForTests: 'u@g.com',
      );
      await auth.signInWithGoogle();
      final c = await containerWith(auth: auth);
      addTearDown(c.dispose);
      c.read(familyCloudSyncProvider.notifier).scheduleSync();
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
  });
}