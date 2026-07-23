import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AfterForgotPassword helpers', () {
    test('isValidEmail accepts and rejects correctly', () {
      expect(AfterForgotPassword.isValidEmail('a@b.co'), isTrue);
      expect(AfterForgotPassword.isValidEmail('  user@example.com '), isTrue);
      expect(AfterForgotPassword.isValidEmail(''), isFalse);
      expect(AfterForgotPassword.isValidEmail('no-at'), isFalse);
      expect(AfterForgotPassword.isValidEmail('a@b'), isFalse);
    });

    test('normalizeEmail trims whitespace', () {
      expect(
        AfterForgotPassword.normalizeEmail('  me@garage.app  '),
        'me@garage.app',
      );
    });

    test('sendResetEmail rejects invalid email before calling auth', () async {
      final auth = _RecordingAuth();
      await expectLater(
        () => AfterForgotPassword.sendResetEmail(
          auth: auth,
          email: 'bad',
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(auth.emails, isEmpty);
    });

    test('sendResetEmail forwards normalized email to auth', () async {
      final auth = _RecordingAuth();
      await AfterForgotPassword.sendResetEmail(
        auth: auth,
        email: '  reset@overstein.com ',
      );
      expect(auth.emails, ['reset@overstein.com']);
    });
  });

  group('AfterForgotPasswordForm', () {
    testWidgets('shows email field and no password field', (tester) async {
      final auth = _RecordingAuth();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            afterAuthRepositoryProvider.overrideWithValue(auth),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AfterForgotPasswordForm(
                copy: AfterForgotPasswordCopy.english(),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Send reset link'), findsOneWidget);
      expect(find.text('Password'), findsNothing);
      expect(find.byIcon(Icons.lock_rounded), findsNothing);
    });

    testWidgets('prefills initial email and sends via auth repo', (tester) async {
      final auth = _RecordingAuth();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            afterAuthRepositoryProvider.overrideWithValue(auth),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AfterForgotPasswordForm(
                copy: AfterForgotPasswordCopy.english(),
                initialEmail: 'driver@garage.app',
              ),
            ),
          ),
        ),
      );

      expect(find.text('driver@garage.app'), findsOneWidget);
      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();

      expect(auth.emails, ['driver@garage.app']);
      expect(
        find.text('Password reset email sent. Check your inbox.'),
        findsOneWidget,
      );
    });

    testWidgets('blocks send when resetAvailable is false', (tester) async {
      final auth = _RecordingAuth();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            afterAuthRepositoryProvider.overrideWithValue(auth),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AfterForgotPasswordForm(
                copy: AfterForgotPasswordCopy.english(),
                initialEmail: 'a@b.co',
                resetAvailable: false,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();
      expect(auth.emails, isEmpty);
      expect(
        find.text('Password reset is unavailable in this build.'),
        findsOneWidget,
      );
    });

    testWidgets('uses custom onSend when provided', (tester) async {
      final sent = <String>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            afterAuthRepositoryProvider.overrideWithValue(_RecordingAuth()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AfterForgotPasswordForm(
                copy: AfterForgotPasswordCopy.english(),
                initialEmail: 'custom@app.com',
                onSend: (email) async => sent.add(email),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();
      expect(sent, ['custom@app.com']);
    });
  });
}

class _RecordingAuth extends NoOpAfterAuthRepository {
  final List<String> emails = <String>[];

  @override
  bool get isAvailable => true;

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    emails.add(email);
  }
}
