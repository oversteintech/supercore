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

  testWidgets('FamilyLoginScreen pumps Garage-parity chrome', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          afterSharedPreferencesProvider.overrideWithValue(prefs),
          afterAuthRepositoryProvider.overrideWithValue(
            FamilyMockAuthRepository(),
          ),
        ],
        child: const MaterialApp(
          home: FamilyLoginScreen(config: chrome),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('FamilySettingsScreen localizes chrome for Turkish',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          afterSharedPreferencesProvider.overrideWithValue(prefs),
          afterAuthRepositoryProvider.overrideWithValue(
            FamilyMockAuthRepository(),
          ),
        ],
        child: MaterialApp(
          home: FamilySettingsScreen(
            config: chrome,
            membership: const FamilyMembershipState(),
            onSetPlan: (_) async {},
            canUsePremiumThemes: true,
            localeCode: 'tr',
            embedded: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tema'), findsOneWidget);
    expect(find.text('Dil'), findsWidgets);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Theme'), findsNothing);
  });
}
