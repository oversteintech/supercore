import 'package:after_design_system/src/components/after_animated_ai_icon.dart';
import 'package:after_design_system/src/components/after_animated_live_tab_icon.dart';
import 'package:after_design_system/src/components/after_animated_refresh_icon_button.dart';
import 'package:after_design_system/src/components/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AfterAnimatedLiveTabIcon pulses while unselected', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: AfterAnimatedLiveTabIcon(selected: false)),
        ),
      ),
    );
    await tester.pump();
    expect(find.byIcon(Icons.sensors_outlined), findsOneWidget);

    final before = tester
        .widgetList<Opacity>(find.byType(Opacity))
        .map((o) => o.opacity)
        .toList();
    await tester.pump(const Duration(milliseconds: 450));
    final after = tester
        .widgetList<Opacity>(find.byType(Opacity))
        .map((o) => o.opacity)
        .toList();
    expect(before, isNotEmpty);
    expect(after, isNot(equals(before)));
  });

  testWidgets('AfterNavigationBar auto-upgrades hub and sensors icons', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AfterNavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            destinations: const [
              AfterNavDestination(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
              ),
              AfterNavDestination(
                icon: Icons.sensors_outlined,
                selectedIcon: Icons.sensors,
                label: 'Live',
              ),
              AfterNavDestination(
                icon: Icons.hub_outlined,
                selectedIcon: Icons.hub_rounded,
                label: 'AI',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(AfterAnimatedLiveTabIcon), findsOneWidget);
    expect(find.byType(AfterAnimatedAiIcon), findsOneWidget);
  });

  testWidgets('AfterAnimatedRefreshIconButton spins on press', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AfterAnimatedRefreshIconButton(
            onPressed: () async {
              pressed = true;
              await Future<void>.delayed(const Duration(milliseconds: 50));
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(pressed, isTrue);
  });
}
