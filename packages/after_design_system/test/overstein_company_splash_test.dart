import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:after_design_system/after_design_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OversteinCompanySplash Apple-style hold', () {
    test('timing hold is at least 5 seconds', () {
      expect(
        OversteinCompanySplashTiming.hold.inMilliseconds,
        greaterThanOrEqualTo(5000),
      );
      expect(
        OversteinCompanySplashTiming.total,
        OversteinCompanySplashTiming.hold,
      );
    });

    testWidgets('holds static mark for full hold — never skips on seen prefs', (
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
      expect(completed, isFalse);
      expect(find.text('OVERSTEIN'), findsNothing); // painted via TextPainter
      expect(find.byType(Image), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      expect(completed, isFalse);

      await tester.pump(
        OversteinCompanySplashTiming.hold + const Duration(milliseconds: 100),
      );
      expect(completed, isTrue);
    });

    testWidgets('completes once after hold', (tester) async {
      SharedPreferences.setMockInitialValues({});
      var completions = 0;
      await tester.pumpWidget(
        AfterLaunchShell(
          child: OversteinCompanySplash(
            forceShow: true,
            onComplete: () => completions++,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      expect(completions, 0);
      await tester.pump(
        OversteinCompanySplashTiming.hold + const Duration(milliseconds: 50),
      );
      expect(completions, 1);
      await tester.pump(OversteinCompanySplashTiming.hardTimeout);
      expect(completions, 1);
    });
  });
}
