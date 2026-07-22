import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:after_design_system/after_design_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OversteinCompanySplash premium illuminate', () {
    test('timing total is 5 seconds', () {
      expect(
        OversteinCompanySplashTiming.hold.inMilliseconds,
        5000,
      );
      expect(
        OversteinCompanySplashTiming.total,
        OversteinCompanySplashTiming.hold,
      );
      expect(
        OversteinCompanySplashTiming.illuminate.inMilliseconds,
        lessThan(OversteinCompanySplashTiming.total.inMilliseconds),
      );
    });

    testWidgets('skips cinematic when already seen (returning launch)', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        OversteinCompanySplashStore.seenKey: true,
      });
      final prefs = await SharedPreferences.getInstance();
      var completed = false;

      await tester.pumpWidget(
        AfterLaunchShell(
          child: OversteinCompanySplash(
            preferences: prefs,
            onComplete: () => completed = true,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(completed, isTrue);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('first install holds full cinematic then marks seen', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      var completed = false;

      await tester.pumpWidget(
        AfterLaunchShell(
          child: OversteinCompanySplash(
            preferences: prefs,
            onComplete: () => completed = true,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(completed, isFalse);
      expect(find.byType(Image), findsOneWidget);

      await tester.pump(
        OversteinCompanySplashTiming.hold + const Duration(milliseconds: 100),
      );
      expect(completed, isTrue);
      expect(OversteinCompanySplashStore.hasSeen(prefs), isTrue);
    });

    testWidgets('forceShow runs cinematic even when already seen', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        OversteinCompanySplashStore.seenKey: true,
      });
      final prefs = await SharedPreferences.getInstance();
      var completions = 0;
      await tester.pumpWidget(
        AfterLaunchShell(
          child: OversteinCompanySplash(
            preferences: prefs,
            forceShow: true,
            onComplete: () => completions++,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      expect(completions, 0);
      expect(find.byType(Image), findsOneWidget);
      await tester.pump(
        OversteinCompanySplashTiming.hold + const Duration(milliseconds: 50),
      );
      expect(completions, 1);
      await tester.pump(OversteinCompanySplashTiming.hardTimeout);
      expect(completions, 1);
    });
  });
}
