import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AfterUserBlob', () {
    test('toJson round-trips via fromJson', () {
      const blob = AfterUserBlob(
        appId: 'superhealth',
        userId: 'u1',
        updatedAtMillis: 42,
        payload: {'stores': {'a': '1'}},
      );
      final again = AfterUserBlob.fromJson(blob.toJson());
      expect(again.appId, 'superhealth');
      expect(again.userId, 'u1');
      expect(again.updatedAtMillis, 42);
      expect(again.payload['stores'], isA<Map<dynamic, dynamic>>());
    });

    test('fromJson tolerates missing payload', () {
      final blob = AfterUserBlob.fromJson({
        'appId': 'x',
        'userId': 'y',
        'updatedAtMillis': 1,
      });
      expect(blob.payload, isEmpty);
    });

    test('fromJson stringifies ids', () {
      final blob = AfterUserBlob.fromJson({
        'appId': 1,
        'userId': 2,
        'updatedAtMillis': 3,
        'payload': <String, dynamic>{},
      });
      expect(blob.appId, '1');
      expect(blob.userId, '2');
    });

    test('copyWith updates millis and payload', () {
      const blob = AfterUserBlob(
        appId: 'a',
        userId: 'b',
        updatedAtMillis: 1,
        payload: {},
      );
      final next = blob.copyWith(
        updatedAtMillis: 9,
        payload: {'k': 'v'},
      );
      expect(next.updatedAtMillis, 9);
      expect(next.payload['k'], 'v');
      expect(next.appId, 'a');
    });

    test('fromJson uses zero millis when absent', () {
      final blob = AfterUserBlob.fromJson({
        'appId': 'a',
        'userId': 'b',
        'payload': <String, dynamic>{},
      });
      expect(blob.updatedAtMillis, 0);
    });
  });

  group('InMemoryAfterUserBlobSync', () {
    test('push then pull returns same blob', () async {
      final sync = InMemoryAfterUserBlobSync();
      const blob = AfterUserBlob(
        appId: 'app',
        userId: 'u',
        updatedAtMillis: 10,
        payload: {'x': 1},
      );
      await sync.push(blob);
      final pulled = await sync.pull(appId: 'app', userId: 'u');
      expect(pulled?.updatedAtMillis, 10);
    });

    test('pull missing key returns null', () async {
      final sync = InMemoryAfterUserBlobSync();
      expect(await sync.pull(appId: 'a', userId: 'missing'), isNull);
    });

    test('unavailable pull throws AfterSyncException', () async {
      final sync = InMemoryAfterUserBlobSync(available: false);
      expect(
        () => sync.pull(appId: 'a', userId: 'u'),
        throwsA(isA<AfterSyncException>()),
      );
    });

    test('unavailable push throws AfterSyncException', () async {
      final sync = InMemoryAfterUserBlobSync(available: false);
      expect(
        () => sync.push(
          const AfterUserBlob(
            appId: 'a',
            userId: 'u',
            updatedAtMillis: 1,
            payload: {},
          ),
        ),
        throwsA(isA<AfterSyncException>()),
      );
    });

    test('clear empties store', () async {
      final sync = InMemoryAfterUserBlobSync();
      await sync.push(
        const AfterUserBlob(
          appId: 'a',
          userId: 'u',
          updatedAtMillis: 1,
          payload: {},
        ),
      );
      sync.clear();
      expect(await sync.pull(appId: 'a', userId: 'u'), isNull);
    });
  });

  group('PrefsAfterUserBlobSync', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('push then pull round-trips', () async {
      final prefs = await SharedPreferences.getInstance();
      final sync = PrefsAfterUserBlobSync(prefs);
      await sync.push(
        const AfterUserBlob(
          appId: 'health',
          userId: 'uid',
          updatedAtMillis: 99,
          payload: {'locale': 'tr'},
        ),
      );
      final pulled = await sync.pull(appId: 'health', userId: 'uid');
      expect(pulled?.payload['locale'], 'tr');
      expect(pulled?.updatedAtMillis, 99);
    });

    test('pull empty returns null', () async {
      final prefs = await SharedPreferences.getInstance();
      final sync = PrefsAfterUserBlobSync(prefs);
      expect(await sync.pull(appId: 'x', userId: 'y'), isNull);
    });

    test('corrupt json returns null', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('after_cloud_blob_x_y', '{not-json');
      final sync = PrefsAfterUserBlobSync(prefs);
      expect(await sync.pull(appId: 'x', userId: 'y'), isNull);
    });

    test('unavailable throws on pull', () async {
      final prefs = await SharedPreferences.getInstance();
      final sync = PrefsAfterUserBlobSync(prefs, available: false);
      expect(
        () => sync.pull(appId: 'a', userId: 'b'),
        throwsA(isA<AfterSyncException>()),
      );
    });

    test('unavailable throws on push', () async {
      final prefs = await SharedPreferences.getInstance();
      final sync = PrefsAfterUserBlobSync(prefs, available: false);
      expect(
        () => sync.push(
          const AfterUserBlob(
            appId: 'a',
            userId: 'b',
            updatedAtMillis: 1,
            payload: {},
          ),
        ),
        throwsA(isA<AfterSyncException>()),
      );
    });
  });
}
