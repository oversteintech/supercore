import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AfterTypography.garage matches SuperGarage hierarchy weights', () {
    final theme = AfterTypography.garage.toTextTheme(
      foreground: Colors.black,
      muted: Colors.grey,
    );
    expect(theme.headlineSmall?.fontWeight, FontWeight.w900);
    expect(theme.headlineSmall?.fontSize, 24);
    expect(theme.headlineSmall?.letterSpacing, -0.55);
    expect(theme.titleMedium?.fontWeight, FontWeight.w800);
    expect(theme.titleMedium?.fontSize, 16);
    expect(theme.titleMedium?.letterSpacing, -0.15);
    expect(theme.titleSmall?.fontWeight, FontWeight.w700);
    expect(theme.titleLarge?.fontWeight, FontWeight.w900);
    expect(theme.bodyMedium?.letterSpacing, 0);
  });

  test('AfterFrameworkTheme.forStyle attaches garage typography extension', () {
    final theme = AfterFrameworkTheme.forStyle(AfterThemeStyle.light);
    final after = theme.extension<AfterTheme>();
    expect(after, isNotNull);
    expect(after!.typography.titleMedium.fontSize, 16);
    expect(theme.textTheme.headlineSmall?.fontWeight, FontWeight.w900);
    expect(theme.textTheme.titleMedium?.fontWeight, FontWeight.w800);
  });

  test('FamilyTheme path keeps L1 heavier tracking than L0/L2', () {
    final theme = AfterFrameworkTheme.forStyle(
      AfterThemeStyle.forestGreen,
    );
    expect(
      theme.textTheme.headlineSmall!.letterSpacing!,
      lessThan(theme.textTheme.titleMedium!.letterSpacing!),
    );
  });
}
