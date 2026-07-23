import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const chrome = FamilyChromeConfig(
    appName: 'SuperTest',
    supportEmail: 'test@overstein.com',
    accent: Color(0xFF10B981),
  );

  testWidgets('Forgot password opens dedicated After Core form page', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final auth = FamilyMockAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          afterSharedPreferencesProvider.overrideWithValue(prefs),
          afterAuthRepositoryProvider.overrideWithValue(auth),
        ],
        child: const MaterialApp(
          home: FamilyLoginScreen(config: chrome),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final forgot = find.text('Forgot password?');
    await tester.ensureVisible(forgot);
    await tester.tap(forgot);
    await tester.pump(); // deferred post-frame push
    await tester.pumpAndSettle();

    expect(find.byType(FamilyForgotPasswordScreen), findsOneWidget);
    expect(find.byType(AfterForgotPasswordForm), findsOneWidget);
    expect(find.text('Send reset link'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsNothing);
  });
}
