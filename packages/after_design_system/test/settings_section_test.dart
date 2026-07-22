import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AfterSettingsSection matches Garage accordion chrome',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SuperGarageTheme.light,
        home: Scaffold(
          body: ListView(
            children: const [
              AfterSettingsSection(
                title: 'Profile',
                subtitle: 'Account',
                icon: Icons.person_rounded,
                child: Text('body'),
              ),
              AfterSettingsSectionGap(),
              AfterSettingsSection(
                title: 'Emergency',
                subtitle: 'ICE',
                icon: Icons.health_and_safety_rounded,
                headerBackgroundColor: AfterSettingsSection.emergencyRed,
                headerTextColor: Colors.white,
                child: Text('ice-body'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    expect(find.byType(CircleAvatar), findsNWidgets(2));
    expect(find.byType(ExpansionTile), findsNWidgets(2));
    expect(find.byType(SuperGarageCard), findsNWidgets(2));
    expect(find.byType(AfterSettingsSectionGap), findsOneWidget);
  });
}
