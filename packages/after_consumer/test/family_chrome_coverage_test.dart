import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const chrome = FamilyChromeConfig(
    appName: 'Health',
    supportEmail: 's@overstein.com',
    accent: Color(0xFF0D9488),
  );

  testWidgets('FamilyShellHeader renders title, badge and profile', (
    tester,
  ) async {
    var profileTapped = false;
    var notifTapped = false;
    PlatformConfig.current = const AppPlatformManifest(
      appName: 'SuperHealth',
      appId: 'superhealth',
      packageName: 'com.overstein.superhealth',
      androidWidgetProvider: 'x',
      iosAppGroupId: 'x',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          afterSharedPreferencesProvider.overrideWithValue(
            await SharedPreferences.getInstance(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: FamilyShellHeader(
              plan: AfterUserPlan.premium,
              title: 'Health',
              onNotifications: () => notifTapped = true,
              onProfile: () => profileTapped = true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Health'), findsOneWidget);
    expect(find.text('SILVER'), findsOneWidget);
    expect(find.text('Kadıköy'), findsNothing);
    expect(find.byIcon(Icons.location_on_rounded), findsNothing);
    expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);
    expect(find.byType(FamilyAnimatedProfileAvatar), findsOneWidget);
    expect(find.byType(AfterAnimatedAiIcon), findsNothing);
    await tester.tap(find.byIcon(Icons.notifications_rounded));
    await tester.tap(find.byType(FamilyAnimatedProfileAvatar));
    expect(notifTapped, isTrue);
    expect(profileTapped, isTrue);
  });

  testWidgets('FamilyShellHeader resolves title from PlatformConfig', (
    tester,
  ) async {
    PlatformConfig.current = const AppPlatformManifest(
      appName: 'SuperSports',
      appId: 'supersports',
      packageName: 'com.overstein.supersports',
      androidWidgetProvider: 'x',
      iosAppGroupId: 'x',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          afterSharedPreferencesProvider.overrideWithValue(
            await SharedPreferences.getInstance(),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: FamilyShellHeader(plan: AfterUserPlan.free),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Sports'), findsOneWidget);
    expect(find.text('FREE'), findsOneWidget);
  });

  testWidgets('FamilyPlansSheet lists Free Silver Gold Business', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FamilyPlansSheet(
            config: chrome,
            membership: const FamilyMembershipState(),
            onSetPlan: (_) async {},
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Free'), findsWidgets);
    expect(find.text('Silver'), findsWidgets);
    expect(find.text('Gold'), findsWidgets);
    expect(find.text('Business'), findsWidgets);
  });

  testWidgets('FamilyProfileScreen shows settings shortcut', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final auth = PrefsGoogleAuthRepository(
      prefs,
      prefsKeyPrefix: 't',
      mockGoogleEmailForTests: 'p@g.com',
    );
    await auth.signInWithGoogle();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          afterSharedPreferencesProvider.overrideWithValue(prefs),
          afterAuthRepositoryProvider.overrideWithValue(auth),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: FamilyProfileScreen(
              config: chrome,
              membership: const FamilyMembershipState(),
              onOpenSettings: () {},
              onOpenAbout: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('FamilyMembershipPlansScreen pumps', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FamilyMembershipPlansScreen(
          config: chrome,
          membership: const FamilyMembershipState(
            plan: AfterUserPlan.superPlan,
          ),
          onSetPlan: (_) async {},
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Membership'), findsOneWidget);
  });

  test('FamilyPlanCatalog titles and summaries', () {
    expect(FamilyPlanCatalog.title(AfterUserPlan.free), 'Free');
    expect(FamilyPlanCatalog.title(AfterUserPlan.premium), 'Silver');
    expect(FamilyPlanCatalog.title(AfterUserPlan.superPlan), 'Gold');
    expect(FamilyPlanCatalog.title(AfterUserPlan.business), 'Business');
    expect(FamilyPlanCatalog.summary(AfterUserPlan.free), isNotEmpty);
    expect(FamilyPlanCatalog.highlight(AfterUserPlan.superPlan), isNotNull);
  });

  test('entity editor helpers', () {
    expect(familyFmtDate(DateTime(2026, 7, 20)), '2026-07-20');
    expect(
      familyParseDateOr('bad', DateTime(2020)).year,
      2020,
    );
    expect(
      familyParseDateOr('2026-01-02', DateTime(2020)).day,
      2,
    );
  });

  testWidgets('showEntityEditorSheet returns map', (tester) async {
    Map<String, String>? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showEntityEditorSheet(
                  context: context,
                  title: 'Add',
                  fields: const {'name': 'Aspirin', 'dosage': ''},
                  languageCode: 'en',
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final save = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save'),
    );
    save.onPressed!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(result?['name'], 'Aspirin');
  });
}
