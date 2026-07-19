import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AfterAuthUser', () {
    test('copyWith updates fields correctly', () {
      const user = AfterAuthUser(
        uid: '123',
        isAnonymous: true,
        email: 'test@example.com',
      );

      final updated = user.copyWith(uid: '456', isAnonymous: false);

      expect(updated.uid, '456');
      expect(updated.isAnonymous, false);
      expect(updated.email, 'test@example.com');
    });
  });

  group('AfterAuthSession', () {
    test('unauthenticated factory sets correct defaults', () {
      const session = AfterAuthSession.unauthenticated(installationId: 'inst-1');

      expect(session.isAuthenticated, false);
      expect(session.isLoading, false);
      expect(session.user, isNull);
      expect(session.installationId, 'inst-1');
    });

    test('loading factory sets correct defaults', () {
      const session = AfterAuthSession.loading(installationId: 'inst-1');

      expect(session.isAuthenticated, false);
      expect(session.isLoading, true);
      expect(session.user, isNull);
    });

    test('isAnonymous returns true when user is anonymous', () {
      const user = AfterAuthUser(uid: '123', isAnonymous: true);
      const session = AfterAuthSession(
        isAuthenticated: true,
        isLoading: false,
        user: user,
      );

      expect(session.isAnonymous, true);
    });

    test('isGuest returns true when not authenticated and not loading', () {
      const session = AfterAuthSession.unauthenticated();
      expect(session.isGuest, true);

      const loadingSession = AfterAuthSession.loading();
      expect(loadingSession.isGuest, false);
    });

    test('copyWith works with clear flags', () {
      const user = AfterAuthUser(uid: '123', isAnonymous: false);
      const session = AfterAuthSession(
        isAuthenticated: true,
        isLoading: false,
        user: user,
        accessToken: 'token',
        errorMessage: 'error',
      );

      final cleared = session.copyWith(
        clearUser: true,
        clearError: true,
        clearToken: true,
      );

      expect(cleared.user, isNull);
      expect(cleared.errorMessage, isNull);
      expect(cleared.accessToken, isNull);
    });
  });
}
