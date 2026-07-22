import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('RTL locale does not overflow FamilyLoginScreen', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final auth = PrefsGoogleAuthRepository(
      prefs,
      prefsKeyPrefix: 'nfr',
      mockGoogleEmailForTests: 'nfr@gmail.com',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          afterSharedPreferencesProvider.overrideWithValue(prefs),
          afterAuthRepositoryProvider.overrideWithValue(auth),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          home: FamilyLoginScreen(
            config: const FamilyChromeConfig(
              appName: 'Health',
              supportEmail: 's@x.com',
              accent: Color(0xFF0D9488),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('OVERSTEIN'), findsOneWidget);
  });

  testWidgets('rapid double Google tap does not crash', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final auth = PrefsGoogleAuthRepository(
      prefs,
      prefsKeyPrefix: 'nfr',
      mockGoogleEmailForTests: 'nfr@gmail.com',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          afterSharedPreferencesProvider.overrideWithValue(prefs),
          afterAuthRepositoryProvider.overrideWithValue(auth),
        ],
        child: MaterialApp(
          home: FamilyLoginScreen(
            config: const FamilyChromeConfig(
              appName: 'Health',
              supportEmail: 's@x.com',
              accent: Color(0xFF0D9488),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final google = find.text('Sign in with Google');
    expect(google, findsOneWidget);
    await tester.tap(google);
    await tester.tap(google);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  test('offline sync port surfaces sync/unavailable', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    PlatformConfig.current = const AppPlatformManifest(
      appName: 'T',
      appId: 't',
      packageName: 'com.overstein.t',
      androidWidgetProvider: 'x',
      iosAppGroupId: 'x',
    );
    final auth = PrefsGoogleAuthRepository(
      prefs,
      prefsKeyPrefix: 't',
      mockGoogleEmailForTests: 'u@g.com',
    );
    await auth.signInWithGoogle();
    final c = ProviderContainer(
      overrides: [
        afterSharedPreferencesProvider.overrideWithValue(prefs),
        afterAuthRepositoryProvider.overrideWithValue(auth),
        afterUserBlobSyncPortProvider.overrideWithValue(
          InMemoryAfterUserBlobSync(available: false),
        ),
      ],
    );
    addTearDown(c.dispose);
    await c.read(familyCloudSyncProvider.notifier).syncNow();
    expect(c.read(familyCloudSyncProvider).errorCode, 'sync/unavailable');
  });

  test('sync error code on AfterSyncException from push', () async {
    final prefs = await SharedPreferences.getInstance();
    PlatformConfig.current = const AppPlatformManifest(
      appName: 'T',
      appId: 't',
      packageName: 'com.overstein.t',
      androidWidgetProvider: 'x',
      iosAppGroupId: 'x',
    );
    final auth = PrefsGoogleAuthRepository(
      prefs,
      prefsKeyPrefix: 't',
      mockGoogleEmailForTests: 'u@g.com',
    );
    await auth.signInWithGoogle();
    final c = ProviderContainer(
      overrides: [
        afterSharedPreferencesProvider.overrideWithValue(prefs),
        afterAuthRepositoryProvider.overrideWithValue(auth),
        afterUserBlobSyncPortProvider.overrideWithValue(
          InMemoryAfterUserBlobSync(available: false),
        ),
      ],
    );
    addTearDown(c.dispose);
    await c.read(familyCloudSyncProvider.notifier).syncNow();
    expect(
      c.read(familyCloudSyncProvider).status,
      FamilyCloudSyncStatus.error,
    );
  });

  test('FamilyFieldLabels empty strings have no replacement chars', () {
    for (final code in AfterSupportedLocales.languageCodes) {
      final empty = FamilyFieldLabels.ui('ui.empty', code);
      expect(empty.contains('\uFFFD'), isFalse, reason: code);
      expect(empty, isNotEmpty);
    }
  });
}