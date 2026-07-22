import 'package:after_core/after_core.dart';
import 'package:after_firebase/after_firebase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirestoreAfterUserBlobSync without Firebase', () {
    test('isAvailable is false', () {
      expect(FirestoreAfterUserBlobSync().isAvailable, isFalse);
    });

    test('pull throws sync/unavailable', () async {
      expect(
        () => FirestoreAfterUserBlobSync().pull(appId: 'a', userId: 'u'),
        throwsA(
          isA<AfterSyncException>().having(
            (e) => e.code,
            'code',
            'sync/unavailable',
          ),
        ),
      );
    });

    test('push throws sync/unavailable', () async {
      expect(
        () => FirestoreAfterUserBlobSync().push(
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

    test('AfterUserBlob path fields preserved in model', () {
      const blob = AfterUserBlob(
        appId: 'superhealth',
        userId: 'uid',
        updatedAtMillis: 9,
        payload: {'stores': <String, dynamic>{}},
      );
      expect(blob.toJson()['appId'], 'superhealth');
      expect(blob.toJson()['userId'], 'uid');
    });

    test('cloud availability helper does not throw', () {
      expect(AfterFirebaseCloudAvailability.canUseCloud, isA<bool>());
    });
  });
}
