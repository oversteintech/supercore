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
        SuperGarageTheme.darkNight,
        dark: true,
      );

  static ThemeData attach(ThemeData productTheme, {required bool dark}) {
    final after = dark
        ? AfterTheme.dark(typography: AfterTypography.garage)
        : AfterTheme.light(typography: AfterTypography.garage);
    // copyWith(extensions:) replaces the whole set — merge After + product.
    final merged = List<ThemeExtension<dynamic>>.from(
      productTheme.extensions.values,
    )..add(after);
    return productTheme.copyWith(extensions: merged);
  }

  static ThemeData forStyle(
    AfterThemeStyle style, {
    Color? accentOverride,
  }) {
    final resolved = style.canonical;
    if (accentOverride != null &&
        (resolved == AfterThemeStyle.light ||
            resolved == AfterThemeStyle.darkNight)) {
      return resolved == AfterThemeStyle.darkNight
          ? darkBase(accentOverride: accentOverride)
          : lightBase(accentOverride: accentOverride);
    }
    final product = AfterPremiumThemeResolver.themeData(resolved);
    return attach(
      product,
      dark: product.brightness == Brightness.dark,
    );
  }

  static ThemeData _mergeProduct(
    ThemeData after,
    ThemeData product, {
    required bool dark,
  }) {
    final afterExt = dark
        ? AfterTheme.dark(typography: AfterTypography.garage)
        : AfterTheme.light(typography: AfterTypography.garage);
    final merged = List<ThemeExtension<dynamic>>.from(
      product.extensions.values,
    )..add(afterExt);
    return after.copyWith(
      colorScheme: product.colorScheme,
      scaffoldBackgroundColor: product.scaffoldBackgroundColor,
      cardTheme: product.cardTheme,
      appBarTheme: product.appBarTheme,
      floatingActionButtonTheme: product.floatingActionButtonTheme,
      textTheme: product.textTheme,
      primaryTextTheme: product.primaryTextTheme,
      tabBarTheme: product.tabBarTheme,
      listTileTheme: product.listTileTheme,
      filledButtonTheme: product.filledButtonTheme,
      extensions: merged,
    );
  }
}
