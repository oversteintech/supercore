import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PlatformConfig.current = const AppPlatformManifest(
      appName: 'Test',
      appId: 'testapp',
      packageName: 'com.overstein.test',
      androidWidgetProvider: 'x',
      iosAppGroupId: 'x',
    );
  });

  testWidgets('theme promo badge does not overflow on narrow width (tr)', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    const surface = Size(320, 1200);
    await tester.binding.setSurfaceSize(surface);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          afterSharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MediaQuery(
          data: const MediaQueryData(
            size: surface,
            // Membership / avatar shimmer would block pumpAndSettle.
            disableAnimations: true,
          ),
          child: MaterialApp(
            home: Scaffold(
              body: FamilySettingsScreen(
                config: const FamilyChromeConfig(
                  appName: 'Test',
                  supportEmail: 't@overstein.com',
                  accent: Color(0xFF1565C0),
                ),
                membership: const FamilyMembershipState(
                  plan: AfterUserPlan.free,
                ),
                onSetPlan: (_) async {},
                localeCode: 'tr',
                canUsePremiumThemes: false,
                premiumThemePromo: (style) {
                  if (style == AfterThemeStyle.brightGold ||
                      style == AfterThemeStyle.diamond ||
                      style == AfterThemeStyle.silverGrey ||
                      style == AfterThemeStyle.blossomPink) {
                    return const FamilyThemePromo(
                      badge: 'Kısa süre ücretsiz',
                      subtitle:
                          'Şimdi kullan. Kampanya sonrası ücretli tema olacak.',
                      struckPrice: '₺299,00',
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Expand Theme section.
    await tester.tap(find.text('Tema'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Expand premium accordion if present.
    final premium = find.textContaining('Premium');
    if (premium.evaluate().isNotEmpty) {
      await tester.ensureVisible(premium.first);
      await tester.tap(premium.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    }

    final exceptions = <FlutterErrorDetails>[];
    final old = FlutterError.onError;
    FlutterError.onError = exceptions.add;
    await tester.pump();
    FlutterError.onError = old;

    expect(
      exceptions.where((e) => e.toString().contains('OVERFLOW')),
      isEmpty,
      reason: exceptions.map((e) => e.toString()).join('\n'),
    );

    final badgeFinder = find.text('Kısa süre ücretsiz');
    expect(badgeFinder, findsWidgets);

    final subtitleFinder = find.textContaining('Şimdi kullan');
    expect(subtitleFinder, findsWidgets);

    final badgeTop = tester.getTopLeft(badgeFinder.first).dy;
    final subtitleBottom = tester.getBottomLeft(subtitleFinder.first).dy;
    expect(
      badgeTop,
      greaterThanOrEqualTo(subtitleBottom - 0.5),
      reason: 'promo badge must sit below the theme description',
    );
  });

  test('AfterSettingsMenuMetrics keep a single divider height', () {
    expect(AfterSettingsMenuMetrics.dividerHeight, 1);
    expect(AfterSettingsSectionGap.height, 12);
    expect(AfterSettingsMenuMetrics.minVerticalPadding, 10);
  });
}
