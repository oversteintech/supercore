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
    AfterUserBlobSyncPort? blob,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        afterSharedPreferencesProvider.overrideWithValue(prefs),
        afterAuthRepositoryProvider.overrideWithValue(auth),
        afterUserBlobSyncPortProvider.overrideWithValue(
          blob ?? InMemoryAfterUserBlobSync(),
        ),
        afterUserMediaSyncPortProvider.overrideWithValue(
          InMemoryAfterUserMediaSync(),
        ),
      ],
    );
  }

  group('AfterCloudBackupController', () {
    test('syncNow errors when unauthenticated', () async {
      final auth = PrefsGoogleAuthRepository(
        await SharedPreferences.getInstance(),
        prefsKeyPrefix: 't',
      );
      final c = await containerWith(auth: auth);
      addTearDown(c.dispose);
      await c.read(afterCloudBackupProvider.notifier).syncNow();
      expect(c.read(afterCloudBackupProvider).errorCode, 'unauthenticated');
    });

    test('exportSnapshot writes after.cloud_backup.v1 JSON', () async {
      final prefs = await SharedPreferences.getInstance();
      final auth = PrefsGoogleAuthRepository(
        prefs,
        prefsKeyPrefix: 't',
        mockGoogleEmailForTests: 'u@g.com',
      );
      await auth.signInWithGoogle();
      await prefs.setString('family_demo', '1');
      final c = await containerWith(auth: auth);
      addTearDown(c.dispose);
      final json =
          await c.read(afterCloudBackupProvider.notifier).exportSnapshot();
      expect(json, contains('after.cloud_backup.v1'));
      expect(c.read(afterCloudBackupProvider).lastExportJson, isNotNull);
    });

    test('push / pull round-trip via syncNow', () async {
      final prefs = await SharedPreferences.getInstance();
      final auth = PrefsGoogleAuthRepository(
        prefs,
        prefsKeyPrefix: 't',
        mockGoogleEmailForTests: 'u@g.com',
      );
      await auth.signInWithGoogle();
      final memory = InMemoryAfterUserBlobSync();
      final c = await containerWith(auth: auth, blob: memory);
      addTearDown(c.dispose);
      await prefs.setString('family_item', 'hello');
      await c.read(afterCloudBackupProvider.notifier).markLocalDirty();
      await c.read(afterCloudBackupProvider.notifier).syncNow();
      expect(
        c.read(afterCloudBackupProvider).status,
        AfterCloudBackupStatus.idle,
      );
      final uid = (await auth.getCurrentSession()).user!.uid;
      final remote = await memory.pull(appId: 'testapp', userId: uid);
      expect(remote, isNotNull);
      expect(remote!.payload['stores'], isA<Map>());
    });
  });
}
