import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AfterThemeData light builds and exposes extension', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AfterThemeData.light(),
        home: Builder(
          builder: (context) {
            final colors = context.afterColors;
            expect(colors.brightness, Brightness.light);
            expect(colors.accent, isNotNull);
            return AfterButton(label: 'Go', onPressed: () {});
          },
        ),
      ),
    );
    expect(find.text('Go'), findsOneWidget);
  });

  test('spacing scale is 4pt based', () {
    expect(AfterSpacing.sm, 8);
    expect(AfterSpacing.lg, 16);
    expect(AfterRadius.surface, AfterRadius.md);
  });

  test('chart series has six colors', () {
    expect(AfterColors.chartSeries, hasLength(6));
  });
}
