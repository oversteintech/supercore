import 'dart:typed_data';

import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AfterStorageManifestEntry', () {
    test('round-trips JSON including numeric sizeBytes', () {
      final entry = AfterStorageManifestEntry.fromJson({
        'kind': 'vehicle_photo',
        'storagePath': 'users/u1/vehicles/v1/photo.jpg',
        'localId': 'v1',
        'sizeBytes': 12.0,
        'contentSha256': 'abc',
      });
      expect(entry.sizeBytes, 12);
      expect(entry.toJson()['storagePath'], contains('vehicles'));
      final again = AfterStorageManifestEntry.fromJson(entry.toJson());
      expect(again.contentSha256, 'abc');
    });
  });

  group('AfterCloudBackupSnapshot', () {
    test('export / import preserves payload + media', () {
      final snap = AfterCloudBackupSnapshot(
        appId: 'superGarage',
        userId: 'u1',
        updatedAtMillis: 100,
        payload: {
          'stores': {'family_x': '1'},
        },
        mediaManifest: const [
          AfterStorageManifestEntry(
            kind: 'profile_photo',
            storagePath: 'users/u1/profile.jpg',
            localId: 'profile',
          ),
        ],
      );
      final json = snap.toExportJson();
      expect(json['format'], 'after.cloud_backup.v1');
      final restored = AfterCloudBackupSnapshot.fromExportJson(json);
      expect(restored.appId, 'superGarage');
      expect(restored.mediaManifest.single.kind, 'profile_photo');
      expect(restored.payload['stores'], isA<Map>());
    });

    test('toBlob embeds mediaManifest', () {
      final blob = const AfterCloudBackupSnapshot(
        appId: 'a',
        userId: 'u',
        updatedAtMillis: 1,
        payload: {'x': 1},
        mediaManifest: [
          AfterStorageManifestEntry(
            kind: 'document',
            storagePath: 'p',
            localId: 'd1',
          ),
        ],
      ).toBlob();
      expect(blob.payload['mediaManifest'], isA<List>());
    });
  });

  group('InMemoryAfterUserMediaSync', () {
    test('upload download delete', () async {
      final port = InMemoryAfterUserMediaSync();
      await port.upload(
        storagePath: 'a/b.jpg',
        data: AfterUserMediaBytes(
          bytes: Uint8List.fromList([1, 2, 3]),
          contentType: 'image/jpeg',
        ),
      );
      final got = await port.download(storagePath: 'a/b.jpg');
      expect(got?.bytes, [1, 2, 3]);
      await port.delete(storagePath: 'a/b.jpg');
      expect(await port.download(storagePath: 'a/b.jpg'), isNull);
    });

    test('unavailable throws', () async {
      final port = InMemoryAfterUserMediaSync(available: false);
      expect(
        () => port.upload(
          storagePath: 'x',
          data: AfterUserMediaBytes(bytes: Uint8List(0)),
        ),
        throwsA(isA<AfterSyncException>()),
      );
    });
  });

  group('afterHasCloudBackupIdentity', () {
    test('requires signed-in non-anonymous uid', () {
      expect(
        afterHasCloudBackupIdentity(
          isAuthenticated: true,
          isAnonymous: false,
          uid: 'u1',
        ),
        isTrue,
      );
      expect(
        afterHasCloudBackupIdentity(
          isAuthenticated: true,
          isAnonymous: true,
          uid: 'u1',
        ),
        isFalse,
      );
      expect(
        afterHasCloudBackupIdentity(
          isAuthenticated: false,
          isAnonymous: false,
          uid: 'u1',
        ),
        isFalse,
      );
    });
  });

  group('AfterPrefsMigration', () {
    test('copies legacy locale into AfterSettingsKeys', () async {
      SharedPreferences.setMockInitialValues({
        'locale': 'tr',
        'theme_mode': 'dark',
      });
      final prefs = await SharedPreferences.getInstance();
      final n = await AfterPrefsMigration.migrateSharedSettings(prefs);
      expect(n, greaterThanOrEqualTo(2));
      expect(prefs.getString(AfterSettingsKeys.locale), 'tr');
      expect(prefs.getString(AfterSettingsKeys.themeMode), 'dark');
      // Second pass is a no-op.
      expect(await AfterPrefsMigration.migrateSharedSettings(prefs), 0);
    });
  });
}
