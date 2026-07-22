import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';

/// Builds Garage-parity themes with optional product accent override.
abstract final class FamilyTheme {
  static ThemeData withAccent(ThemeData base, Color accent) {
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: accent,
        secondary: base.colorScheme.secondary,
      ),
    );
  }

  static ThemeData forStyle(
    AfterThemeStyle style, {
    Color? accent,
  }) {
    final base = AfterFrameworkTheme.forStyle(
      style,
      accentOverride: accent,
    );
    if (accent == null) return base;
    return withAccent(base, accent);
  }

  static ThemeMode themeModeFor(AfterThemeStyle style) =>
      style.materialThemeMode;
}
