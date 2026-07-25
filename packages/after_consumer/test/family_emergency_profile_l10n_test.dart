import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ConsentPendingController extends FamilyEmergencyProfileController {
  @override
  Future<FamilyEmergencyProfile> build() async {
    return const FamilyEmergencyProfile(consentAccepted: false);
  }
}

class _ConsentAcceptedController extends FamilyEmergencyProfileController {
  @override
  Future<FamilyEmergencyProfile> build() async {
    return const FamilyEmergencyProfile(consentAccepted: true);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FamilyUiStrings emergency keys', () {
    test('every supported locale has real emergency_consent_cta', () {
      final enCta = FamilyUiStrings.t('emergency_consent_cta', 'en');
      final enBlood = FamilyUiStrings.t('emergency_blood_type', 'en');

      for (final code in AfterSupportedLocales.languageCodes) {
        final cta = FamilyUiStrings.t('emergency_consent_cta', code);
        expect(cta, isNotEmpty, reason: '$code consent CTA empty');
        expect(
          cta.startsWith('['),
          isFalse,
          reason: '$code consent CTA looks like a stub: $cta',
        );

        if (code == 'en') continue;

        final blood = FamilyUiStrings.t('emergency_blood_type', code);
        expect(
          cta != enCta || blood != enBlood,
          isTrue,
          reason:
              '$code must differ from English on consent CTA or blood type',
        );
      }
    });

    test('Turkish differs from English for consent CTA and privacy title', () {
      expect(
        FamilyUiStrings.t('emergency_consent_cta', 'tr'),
        'Anladım — profili oluştur',
      );
      expect(
        FamilyUiStrings.t('emergency_privacy_title', 'tr'),
        'Acil profil gizliliği',
      );
      expect(
        FamilyUiStrings.t('emergency_consent_cta', 'en'),
        'I understand — set up profile',
      );
      expect(
        FamilyUiStrings.t('emergency_consent_cta', 'tr'),
        isNot(equals(FamilyUiStrings.t('emergency_consent_cta', 'en'))),
      );
      expect(
        FamilyUiStrings.t('emergency_blood_type', 'tr'),
        'Kan grubu',
      );
      expect(
        FamilyUiStrings.t('emergency_not_set', 'tr'),
        'Belirtilmedi',
      );
      expect(FamilyUiStrings.t('save', 'tr'), 'Kaydet');
    });

    test('unsupported locale falls back to English emergency copy', () {
      expect(
        FamilyUiStrings.t('emergency_consent_cta', 'xx'),
        FamilyUiStrings.t('emergency_consent_cta', 'en'),
      );
    });
  });

  group('FamilyEmergencyProfileSection localization', () {
    testWidgets('consent gate shows Turkish strings for tr locale', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            familyEmergencyProfileProvider.overrideWith(
              _ConsentPendingController.new,
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FamilyEmergencyProfileSection(localeCode: 'tr'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Anladım — profili oluştur'), findsOneWidget);
      expect(find.text('Acil profil gizliliği'), findsOneWidget);
      expect(find.text('I understand — set up profile'), findsNothing);
      expect(find.text('Emergency profile privacy'), findsNothing);
    });

    testWidgets('consent gate shows English strings for en locale', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            familyEmergencyProfileProvider.overrideWith(
              _ConsentPendingController.new,
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FamilyEmergencyProfileSection(localeCode: 'en'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('I understand — set up profile'), findsOneWidget);
      expect(find.text('Emergency profile privacy'), findsOneWidget);
      expect(find.text('Anladım — profili oluştur'), findsNothing);
    });

    testWidgets('accepted form shows Turkish field labels', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            familyEmergencyProfileProvider.overrideWith(
              _ConsentAcceptedController.new,
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FamilyEmergencyProfileSection(localeCode: 'tr'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kan grubu'), findsOneWidget);
      expect(find.text('Acil iletişim'), findsOneWidget);
      expect(find.text('Alerjiler'), findsOneWidget);
      expect(find.text('Tıbbi durumlar'), findsOneWidget);
      expect(find.text('İlaçlar'), findsOneWidget);
      expect(find.text('Acil notlar'), findsOneWidget);
      expect(find.text('Belirtilmedi'), findsWidgets);
      expect(find.text('Blood type'), findsNothing);
      expect(find.text('Not set'), findsNothing);
    });
  });
}
