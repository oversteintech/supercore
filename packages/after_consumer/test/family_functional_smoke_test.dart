import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PlatformConfig.current = const AppPlatformManifest(
      appName: 'Health',
      appId: 'superhealth',
      packageName: 'com.overstein.superhealth',
      androidWidgetProvider: 'x',
      iosAppGroupId: 'x',
    );
  });

  const chrome = FamilyChromeConfig(
    appName: 'Health',
    supportEmail: 'support@overstein.com',
    accent: Color(0xFF0D9488),
  );

  Future<ProviderContainer> boot() async {
    final prefs = await SharedPreferences.getInstance();
    final auth = PrefsGoogleAuthRepository(
      prefs,
      prefsKeyPrefix: 'superhealth',
      mockGoogleEmailForTests: 'member@gmail.com',
    );
    return ProviderContainer(
      overrides: [
        ...AfterStandardOverrides.create(
          preferences: prefs,
          userAgent: 'SuperHealth/test',
        ),
        afterAuthRepositoryProvider.overrideWithValue(auth),
      ],
    );
  }

  testWidgets('Google mock login then settings shows sync tile', (tester) async {
    final container = await boot();
    addTearDown(container.dispose);
    await container.read(afterAuthRepositoryProvider).signInWithGoogle();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: FamilySettingsScreen(
            config: chrome,
            membership: const FamilyMembershipState(
              plan: AfterUserPlan.free,
            ),
            onSetPlan: (_) async {},
            localeCode: 'en',
            onLocale: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // ListView lazily builds sections; Cloud sync is below the fold after
    // accordion settings chrome - scroll before asserting.
    await tester.scrollUntilVisible(
      find.text('Cloud sync'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Cloud sync'), findsOneWidget);
    await tester.tap(find.text('Cloud sync'));
    await tester.pumpAndSettle();
    expect(find.text('Sync now'), findsOneWidget);
    await tester.tap(find.text('Sync now'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
  });

  testWidgets('locale change with Global delegates does not red-screen', (
    tester,
  ) async {
    final container = await boot();
    addTearDown(container.dispose);
    var locale = 'en';

    Widget app() {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: Locale(locale),
          supportedLocales: AfterSupportedLocales.locales,
          localeResolutionCallback: AfterSupportedLocales.resolutionCallback,
          localizationsDelegates: AfterSupportedLocales.localizationsDelegates,
          home: FamilySettingsScreen(
            config: chrome,
            membership: const FamilyMembershipState(
              plan: AfterUserPlan.free,
            ),
            onSetPlan: (_) async {},
            localeCode: locale,
            onLocale: (code) => locale = code,
          ),
        ),
      );
    }

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Simulate settings picker applying Turkish (MaterialApp must have Global*
    // delegates or this rebuild red-screens).
    locale = 'tr';
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Dil'), findsWidgets);
  });

  testWidgets('CRUD list add flow uses localized labels', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final auth = PrefsGoogleAuthRepository(
      prefs,
      prefsKeyPrefix: 'superhealth',
      mockGoogleEmailForTests: 'member@gmail.com',
    );
    await auth.signInWithGoogle();
    final listProvider = familyMapListProvider('family_meds_test');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...AfterStandardOverrides.create(
            preferences: prefs,
            userAgent: 'SuperHealth/test',
          ),
          afterAuthRepositoryProvider.overrideWithValue(auth),
        ],
        child: MaterialApp(
          home: FamilyCrudListPage(
            title: 'Medications',
            listProvider: listProvider,
            fieldKeys: const ['name', 'dosage', 'schedule'],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Dosage'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Aspirin');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Aspirin'), findsOneWidget);
  });

  test('auth restore + sync push functional path', () async {
    final container = await boot();
    addTearDown(container.dispose);
    await container.read(afterAuthRepositoryProvider).signInWithGoogle();
    final prefs = container.read(afterSharedPreferencesProvider);
    await prefs.setString('family_smoke', '1');
    await container.read(familyCloudSyncProvider.notifier).markLocalDirty();
    await container.read(familyCloudSyncProvider.notifier).syncNow();
    expect(
      container.read(familyCloudSyncProvider).status,
      FamilyCloudSyncStatus.idle,
    );
  });
}
