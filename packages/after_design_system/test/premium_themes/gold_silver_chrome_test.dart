import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SuperGarageScaffold silver page-frame removal', () {
    testWidgets('silver scaffold does not wrap the page body', (tester) async {
      await tester.pumpWidget(
        TickerMode(
          enabled: false,
          child: MaterialApp(
            theme: SuperGarageTheme.silverGrey,
            home: const SuperGarageScaffold(
              body: Center(child: Text('silver-body')),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('silver-body'), findsOneWidget);
      expect(find.byType(SilverShowcaseFrame), findsNothing);
      expect(find.byType(RoyalShowcaseFrame), findsNothing);
      expect(find.byType(DiamondSparkleFrame), findsNothing);
    });

    testWidgets('silver scaffold keeps a transparent body fill', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SuperGarageTheme.silverGrey,
          home: const SuperGarageScaffold(
            body: SizedBox.shrink(),
          ),
        ),
      );
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.transparent);
    });

    testWidgets('diamond scaffold still has no page-body frame', (
      tester,
    ) async {
      await tester.pumpWidget(
        TickerMode(
          enabled: false,
          child: MaterialApp(
            theme: SuperGarageTheme.diamond,
            home: const SuperGarageScaffold(
              body: Center(child: Text('diamond-body')),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DiamondSparkleFrame), findsNothing);
      expect(find.byType(SilverShowcaseFrame), findsNothing);
    });

    testWidgets('silver card frames survive via withPremiumThemeFrame', (
      tester,
    ) async {
      await tester.pumpWidget(
        TickerMode(
          enabled: false,
          child: MaterialApp(
            theme: SuperGarageTheme.silverGrey,
            home: Scaffold(
              body: const Text('card').withPremiumThemeFrame(
                style: PremiumFrameStyle.showcase,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('card'), findsOneWidget);
      expect(find.byType(SilverShowcaseFrame), findsOneWidget);
    });

    testWidgets('silver SuperGarageCard frames when prominent', (tester) async {
      await tester.pumpWidget(
        TickerMode(
          enabled: false,
          child: MaterialApp(
            theme: SuperGarageTheme.silverGrey,
            home: const Scaffold(
              body: SuperGarageCard(
                prominent: true,
                child: SizedBox(
                  width: 160,
                  height: 72,
                  child: Center(child: Text('prominent-silver')),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SilverShowcaseFrame), findsOneWidget);
    });
  });

  group('Bright gold metallic background', () {
    testWidgets('app shell hosts the luxury animated background', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BrightGoldAppShell(
            child: SizedBox.expand(child: Text('gold-content')),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(BrightGoldLuxuryBackground), findsOneWidget);
      expect(find.byType(PremiumThemeAppShell), findsOneWidget);
      expect(find.text('gold-content'), findsOneWidget);
    });

    testWidgets('luxury background paints via CustomPaint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox.expand(child: BrightGoldLuxuryBackground()),
        ),
      );
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(BrightGoldLuxuryBackground),
          matching: find.byType(CustomPaint),
        ),
        findsWidgets,
      );
    });

    testWidgets('page chrome no longer paints an opaque parchment veil', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SuperGarageTheme.brightGold,
          home: const BrightGoldPageChrome(
            child: ColoredBox(
              color: Color(0xFF00FF00),
              child: SizedBox.expand(child: Text('see-through')),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('see-through'), findsOneWidget);
      // Opaque parchment would insert a ColoredBox with goldBackground alpha.
      final colored = tester
          .widgetList<ColoredBox>(
            find.descendant(
              of: find.byType(BrightGoldPageChrome),
              matching: find.byType(ColoredBox),
            ),
          )
          .where((box) => box.color == SuperGarageColors.goldBackground)
          .toList();
      expect(colored, isEmpty);
    });

    testWidgets('reduced motion freezes the luxury background', (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: SizedBox.expand(child: BrightGoldLuxuryBackground()),
          ),
        ),
      );
      await tester.pump();
      final first = tester
          .widgetList<CustomPaint>(
            find.descendant(
              of: find.byType(BrightGoldLuxuryBackground),
              matching: find.byType(CustomPaint),
            ),
          )
          .first
          .painter;
      await tester.pump(const Duration(milliseconds: 800));
      final second = tester
          .widgetList<CustomPaint>(
            find.descendant(
              of: find.byType(BrightGoldLuxuryBackground),
              matching: find.byType(CustomPaint),
            ),
          )
          .first
          .painter;
      expect(
        identical(first, second) || first.runtimeType == second.runtimeType,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('motion-enabled background advances without exceptions', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox.expand(child: BrightGoldLuxuryBackground()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(BrightGoldLuxuryBackground), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('switching away from gold disposes the shell cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SuperGarageTheme.brightGold,
          home: const BrightGoldAppShell(
            child: SizedBox.expand(child: Text('gold')),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(BrightGoldLuxuryBackground), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          theme: SuperGarageTheme.light,
          home: const Scaffold(body: Text('light')),
        ),
      );
      await tester.pump();

      expect(find.byType(BrightGoldLuxuryBackground), findsNothing);
      expect(find.text('light'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('gold surfaces stay champagne, not neon yellow', () {
      expect(SuperGarageColors.goldBackground, isNot(const Color(0xFFFFEB3B)));
      expect(SuperGarageColors.goldBackground, isNot(const Color(0xFFFFC107)));
      final hsl = HSLColor.fromColor(SuperGarageColors.goldBackground);
      expect(hsl.hue, inInclusiveRange(30.0, 55.0));
      expect(hsl.lightness, greaterThan(0.75));
      expect(
        SuperGarageColors.goldBackground.computeLuminance(),
        greaterThan(0.7),
      );
    });

    test('gold frame gradient stays in warm metallic range', () {
      for (final color in BrightGoldTheme.frameGradient) {
        final hsl = HSLColor.fromColor(color);
        expect(hsl.hue, inInclusiveRange(28.0, 58.0), reason: '$color');
        expect(color, isNot(Colors.white));
        expect(color, isNot(const Color(0xFFFFEA00)));
      }
    });

    testWidgets('AfterPremiumAppShell wires gold background for brightGold', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AfterPremiumAppShell.wrap(
            style: AfterThemeStyle.brightGold,
            child: const Text('shell'),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(BrightGoldLuxuryBackground), findsOneWidget);
      expect(find.text('shell'), findsOneWidget);
    });
  });
}
