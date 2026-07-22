import 'dart:typed_data';

import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression suite for the Garage-parity family CRUD / profile bugs:
/// - `_dependents.isEmpty` red screen after Save on entity editor
/// - controller dispose while sheet still unmounting
/// - profile identity persistence / photo caps
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PlatformConfig.current = const AppPlatformManifest(
      appName: 'Sports',
      appId: 'supersports',
      packageName: 'com.overstein.supersports',
      androidWidgetProvider: 'x',
      iosAppGroupId: 'x',
    );
  });

  Future<(SharedPreferences, PrefsGoogleAuthRepository)> signedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final auth = PrefsGoogleAuthRepository(
      prefs,
      prefsKeyPrefix: 'sports',
      mockGoogleEmailForTests: 'athlete@gmail.com',
    );
    await auth.signInWithGoogle();
    return (prefs, auth);
  }

  Future<void> pumpCrud(
    WidgetTester tester, {
    required SharedPreferences prefs,
    required PrefsGoogleAuthRepository auth,
    required NotifierProvider<FamilyMapListController, List<FamilyMapRecord>>
        listProvider,
    List<String> fieldKeys = const ['name', 'notes'],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...AfterStandardOverrides.create(
            preferences: prefs,
            userAgent: 'SuperSports/test',
          ),
          afterAuthRepositoryProvider.overrideWithValue(auth),
        ],
        child: MaterialApp(
          home: FamilyCrudListPage(
            title: 'Workouts',
            listProvider: listProvider,
            fieldKeys: fieldKeys,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // ─── 1–4: entity editor sheet lifecycle (dependents / dispose) ───────────

  testWidgets('1 entity editor Save does not throw dependents assertion', (
    tester,
  ) async {
    Map<String, String>? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showEntityEditorSheet(
                  context: context,
                  title: 'Add workout',
                  fields: const {'name': '', 'notes': ''},
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
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Tempo run');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(result?['name'], 'Tempo run');
    expect(find.text('Save'), findsNothing);
  });

  testWidgets('2 entity editor dismiss by drag/barrier leaves no exception', (
    tester,
  ) async {
    Map<String, String>? result = const {'sentinel': '1'};
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showEntityEditorSheet(
                  context: context,
                  title: 'Add',
                  fields: const {'name': 'x'},
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
    await tester.pumpAndSettle();
    // Close sheet via root navigator pop (barrier dismiss equivalent).
    Navigator.of(tester.element(find.text('Save'))).pop();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(result, isNull);
  });

  testWidgets('3 entity editor returns edited multi-field map', (tester) async {
    Map<String, String>? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showEntityEditorSheet(
                  context: context,
                  title: 'Edit',
                  fields: const {'name': 'Old', 'dosage': '5mg'},
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
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'New name');
    await tester.enterText(fields.at(1), '10mg');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(result, {'name': 'New name', 'dosage': '10mg'});
  });

  testWidgets('4 rapid open-save cycles never red-screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                await showEntityEditorSheet(
                  context: context,
                  title: 'Add',
                  fields: const {'name': ''},
                  languageCode: 'en',
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'item_$i');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'cycle $i');
    }
  });

  // ─── 5–8: FamilyCrudListPage add / edit / delete ─────────────────────────

  testWidgets('5 CRUD add Save persists item without red screen', (
    tester,
  ) async {
    final (prefs, auth) = await signedIn();
    final listProvider = familyMapListProvider('family_crud_add_reg');

    await pumpCrud(
      tester,
      prefs: prefs,
      auth: auth,
      listProvider: listProvider,
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Intervals');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Intervals'), findsOneWidget);
    expect(
      ProviderScope.containerOf(
        tester.element(find.byType(FamilyCrudListPage)),
      ).read(listProvider),
      hasLength(1),
    );
  });

  testWidgets('6 CRUD edit existing item does not red-screen', (tester) async {
    final (prefs, auth) = await signedIn();
    final listProvider = familyMapListProvider(
      'family_crud_edit_reg',
      seed: const [
        FamilyMapRecord(id: 'w1', fields: {'name': 'Easy', 'notes': ''}),
      ],
    );

    await pumpCrud(
      tester,
      prefs: prefs,
      auth: auth,
      listProvider: listProvider,
    );

    await tester.tap(find.text('Easy'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Easy long');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Easy long'), findsOneWidget);
  });

  testWidgets('7 CRUD delete confirm removes item without red screen', (
    tester,
  ) async {
    final (prefs, auth) = await signedIn();
    final listProvider = familyMapListProvider(
      'family_crud_del_reg',
      seed: const [
        FamilyMapRecord(id: 'w1', fields: {'name': 'Trash me'}),
      ],
    );

    await pumpCrud(
      tester,
      prefs: prefs,
      auth: auth,
      listProvider: listProvider,
      fieldKeys: const ['name'],
    );

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Trash me'), findsNothing);
  });

  testWidgets('8 CRUD delete cancel keeps item', (tester) async {
    final (prefs, auth) = await signedIn();
    final listProvider = familyMapListProvider(
      'family_crud_del_cancel_reg',
      seed: const [
        FamilyMapRecord(id: 'w1', fields: {'name': 'Keep me'}),
      ],
    );

    await pumpCrud(
      tester,
      prefs: prefs,
      auth: auth,
      listProvider: listProvider,
      fieldKeys: const ['name'],
    );

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Keep me'), findsOneWidget);
  });

  // ─── 9–12: profile identity unit + field editors ─────────────────────────

  test('9 profile identity photo cap and active photo', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [afterSharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    final n = container.read(familyProfileIdentityProvider.notifier);

    for (var i = 0; i < FamilyProfileIdentity.maxProfilePhotos; i++) {
      final ok = await n.addProfilePhoto(Uint8List.fromList([i, 2, 3]));
      expect(ok, isTrue, reason: 'photo $i');
    }
    expect(
      await n.addProfilePhoto(Uint8List.fromList([9, 9, 9])),
      isFalse,
    );
    expect(
      container.read(familyProfileIdentityProvider).photoIds,
      hasLength(FamilyProfileIdentity.maxProfilePhotos),
    );

    final ids = container.read(familyProfileIdentityProvider).photoIds;
    await n.setActiveProfilePhoto(ids.first);
    expect(
      container.read(familyProfileIdentityProvider).activePhotoId,
      ids.first,
    );
    await n.removeProfilePhotoAt(0);
    expect(
      container.read(familyProfileIdentityProvider).photoIds,
      hasLength(FamilyProfileIdentity.maxProfilePhotos - 1),
    );
    await n.clearProfilePhotos();
    expect(container.read(familyProfileIdentityProvider).photoIds, isEmpty);
  });

  test('10 profile identity clearAll resets avatar defaults', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [afterSharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    final n = container.read(familyProfileIdentityProvider.notifier);
    await n.setAvatarId('avatar_8');
    await n.updateFields(displayName: 'X', username: 'xuser');
    await n.addProfilePhoto(Uint8List.fromList([1]));
    await n.clearAll();

    final id = container.read(familyProfileIdentityProvider);
    expect(id.avatarId, 'avatar_1');
    expect(id.displayName, isNull);
    expect(id.username, isNull);
    expect(id.photoIds, isEmpty);
  });

  testWidgets('11 profile display-name editor Save does not red-screen', (
    tester,
  ) async {
    final (prefs, auth) = await signedIn();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...AfterStandardOverrides.create(
            preferences: prefs,
            userAgent: 'SuperSports/test',
          ),
          afterAuthRepositoryProvider.overrideWithValue(auth),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                return TextButton(
                  onPressed: () => editFamilyProfileDisplayName(
                    context,
                    ref,
                    'Old Name',
                  ),
                  child: const Text('edit'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'New Name');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final container = ProviderScope.containerOf(
      tester.element(find.text('edit')),
    );
    expect(
      container.read(familyProfileIdentityProvider).displayName,
      'New Name',
    );
  });

  testWidgets('12 profile section avatar tap opens picker without crash', (
    tester,
  ) async {
    final (prefs, auth) = await signedIn();
    const chrome = FamilyChromeConfig(
      appName: 'Sports',
      supportEmail: 's@overstein.com',
      accent: Color(0xFF0284C7),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...AfterStandardOverrides.create(
            preferences: prefs,
            userAgent: 'SuperSports/test',
          ),
          afterAuthRepositoryProvider.overrideWithValue(auth),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: FamilyProfileSection(
              config: chrome,
              membership: const FamilyMembershipState(),
              animateAvatar: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(FamilyAnimatedProfileAvatar));
    // Picker tiles use perpetual orbit animations — avoid pumpAndSettle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text('Avatar'), findsOneWidget);
    expect(find.text('Profile photo'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });

  // ─── 13–14: map record + avatar option helpers (unit) ────────────────────

  test('13 FamilyMapRecord title and json round-trip', () {
    const a = FamilyMapRecord(
      id: '1',
      fields: {'name': 'Run', 'notes': 'am'},
    );
    expect(a.title, 'Run');
    final json = a.toJson();
    final b = FamilyMapRecord.fromJson(json);
    expect(b.id, '1');
    expect(b.fields['notes'], 'am');
    expect(
      const FamilyMapRecord(id: 'x', fields: {'title': 'T'}).title,
      'T',
    );
  });

  test('14 familyAvatarForId falls back to first preset', () {
    expect(familyAvatarForId('avatar_3').id, 'avatar_3');
    expect(familyAvatarForId('missing').id, familyAvatarOptions.first.id);
    expect(familyAvatarOptions, hasLength(8));
  });
}
