import 'package:after_core/after_core.dart';
import 'package:after_firebase/after_firebase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseAfterAuthRepository without Firebase', () {
    late FirebaseAfterAuthRepository auth;

    setUp(() {
      AfterFirebaseBootstrap.resetForTests();
      auth = FirebaseAfterAuthRepository();
    });

    test('isAvailable is false', () {
      expect(auth.isAvailable, isFalse);
    });

    test('getCurrentSession is unauthenticated', () async {
      final session = await auth.getCurrentSession();
      expect(session.isAuthenticated, isFalse);
    });

    test('watchAuthSession yields unauthenticated', () async {
      final session = await auth.watchAuthSession().first;
      expect(session.isAuthenticated, isFalse);
    });

    test('signInWithEmailPassword throws unavailable', () async {
      expect(
        () => auth.signInWithEmailPassword(
          const AfterEmailPasswordCredentials(
            email: 'a@b.com',
            password: 'x',
          ),
        ),
        throwsA(isA<AfterAuthException>()),
      );
    });

    test('signInWithGoogle throws unavailable without mock path needing auth',
        () async {
      expect(
        () => auth.signInWithGoogle(),
        throwsA(isA<AfterAuthException>()),
      );
    });

    test('signOut is no-op safe', () async {
      await auth.signOut();
      expect((await auth.getCurrentSession()).isAuthenticated, isFalse);
    });

    test('getAccessToken returns null', () async {
      expect(await auth.getAccessToken(), isNull);
    });
  });
}
