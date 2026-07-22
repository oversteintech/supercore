import 'dart:typed_data';

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

  const chrome = FamilyChromeConfig(
    appName: 'Health',
    supportEmail: 's@overstein.com',
    accent: Color(0xFF0D9488),
  );

  test('FamilyProfileIdentityController persists avatar and fields', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        afterSharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(familyProfileIdentityProvider.notifier);
    await notifier.setAvatarId('avatar_3');
    await notifier.updateFields(
      displayName: 'Ayşe Yılmaz',
      username: 'ayse',
      email: 'ayse@example.com',
      phoneNumber: '+905551112233',
    );
    await notifier.addProfilePhoto(Uint8List.fromList([1, 2, 3, 4]));

    final identity = container.read(familyProfileIdentityProvider);
    expect(identity.avatarId, 'avatar_3');
    expect(identity.displayName, 'Ayşe Yılmaz');
    expect(identity.username, 'ayse');
    expect(identity.email, 'ayse@example.com');
    expect(identity.phoneNumber, '+905551112233');
    expect(identity.photoIds, hasLength(1));
    expect(identity.activePhotoBytes, isNotNull);
    expect(familyAvatarForId(identity.avatarId).id, 'avatar_3');
  });

  test('seedFromRegistration fills identity', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        afterSharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(familyProfileIdentityProvider.notifier)
        .seedFromRegistration(
          firstName: 'Ali',
          lastName: 'Demir',
          username: 'alidemir',
          email: 'ali@example.com',
          phoneNumber: '+90555',
        );

    final identity = container.read(familyProfileIdentityProvider);
    expect(identity.displayName, 'Ali Demir');
    expect(identity.username, 'alidemir');
    expect(identity.firstName, 'Ali');
    expect(
      identity.resolvedDisplayName(authDisplayName: 'other'),
      'Ali Demir',
    );
  });

  testWidgets('FamilyProfileSection shows animated avatar and fields', (
    tester,
  ) async {
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

    expect(find.text('Display name'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.byType(FamilyAnimatedProfileAvatar), findsOneWidget);
  });
}
