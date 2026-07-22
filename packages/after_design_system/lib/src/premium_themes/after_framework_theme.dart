import 'package:flutter/material.dart';

import '../foundations/theme.dart';
import '../foundations/typography.dart';
import 'after_theme_style.dart';
import 'theme.dart';

/// Bridges After Design System base themes with product premium themes.
///
/// Always attaches Garage-parity [AfterTypography.garage] so `textTheme` and
/// `context.afterTypography` share the same type scale across Super Apps.
abstract final class AfterFrameworkTheme {
  static ThemeData lightBase({Color? accentOverride}) => _mergeProduct(
        AfterThemeData.light(
          accentOverride: accentOverride,
          typography: AfterTypography.garage,
        ),
        SuperGarageTheme.light,
        dark: false,
      );

  static ThemeData darkBase({Color? accentOverride}) => _mergeProduct(
        AfterThemeData.dark(
          accentOverride: accentOverride,
          typography: AfterTypography.garage,
        ),
        SuperGarageTheme.dark,
        dark: true,
      );

  static ThemeData attach(ThemeData productTheme, {required bool dark}) {
    final after = dark
        ? AfterTheme.dark(typography: AfterTypography.garage)
        : AfterTheme.light(typography: AfterTypography.garage);
    // Prefer product ThemeData textTheme (Garage MountainView hierarchy) as
    // the Material source of truth; After* widgets read matching garage tokens.
    return productTheme.copyWith(
      extensions: [after],
    );
  }

  static ThemeData forStyle(
    AfterThemeStyle style, {
    Color? accentOverride,
  }) {
    return switch (style) {
      AfterThemeStyle.racingRed =>
        attach(SuperGarageTheme.racingRed, dark: true),
      AfterThemeStyle.racingBlue =>
        attach(SuperGarageTheme.racingBlue, dark: false),
      AfterThemeStyle.darkNight =>
        attach(SuperGarageTheme.darkNight, dark: true),
      AfterThemeStyle.forestGreen =>
        attach(SuperGarageTheme.forestGreen, dark: true),
      AfterThemeStyle.silverGrey =>
        attach(SuperGarageTheme.silverGrey, dark: false),
      AfterThemeStyle.blossomPink =>
        attach(SuperGarageTheme.blossomPink, dark: false),
      AfterThemeStyle.brightGold =>
        attach(SuperGarageTheme.brightGold, dark: false),
      AfterThemeStyle.diamond => attach(SuperGarageTheme.diamond, dark: true),
      AfterThemeStyle.royal => attach(SuperGarageTheme.royal, dark: true),
      AfterThemeStyle.dark => darkBase(accentOverride: accentOverride),
      AfterThemeStyle.system || AfterThemeStyle.light =>
        lightBase(accentOverride: accentOverride),
    };
  }

  static ThemeData _mergeProduct(
    ThemeData after,
    ThemeData product, {
    required bool dark,
  }) {
    final afterExt = dark
        ? AfterTheme.dark(typography: AfterTypography.garage)
        : AfterTheme.light(typography: AfterTypography.garage);
    return after.copyWith(
      colorScheme: product.colorScheme,
      scaffoldBackgroundColor: product.scaffoldBackgroundColor,
      cardTheme: product.cardTheme,
      appBarTheme: product.appBarTheme,
      floatingActionButtonTheme: product.floatingActionButtonTheme,
      textTheme: product.textTheme,
      primaryTextTheme: product.primaryTextTheme,
      tabBarTheme: product.tabBarTheme,
      extensions: [afterExt],
    );
  }
}
