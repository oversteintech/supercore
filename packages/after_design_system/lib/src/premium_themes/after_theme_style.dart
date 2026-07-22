import 'package:flutter/material.dart';

import 'theme.dart';

/// Selectable theme styles shared by every Super App (Garage flagship pack).
enum AfterThemeStyle {
  system,
  light,
  dark,
  racingRed,
  racingBlue,
  darkNight,
  forestGreen,
  silverGrey,
  blossomPink,
  brightGold,
  diamond,
  royal,
}

extension AfterThemeStyleAccess on AfterThemeStyle {
  bool get isRoyalTheme =>
      this == AfterThemeStyle.brightGold || this == AfterThemeStyle.diamond;

  bool get isPremiumOnly => isSilverPremiumOnly || isRoyalTheme;

  bool get isSilverPremiumOnly =>
      this == AfterThemeStyle.racingRed ||
      this == AfterThemeStyle.racingBlue ||
      this == AfterThemeStyle.darkNight ||
      this == AfterThemeStyle.forestGreen ||
      this == AfterThemeStyle.silverGrey ||
      this == AfterThemeStyle.blossomPink;

  bool get isComingSoonRoyalTheme => this == AfterThemeStyle.royal;

  ThemeMode get materialThemeMode => switch (this) {
        AfterThemeStyle.system => ThemeMode.system,
        AfterThemeStyle.light => ThemeMode.light,
        AfterThemeStyle.dark => ThemeMode.dark,
        AfterThemeStyle.racingRed => ThemeMode.dark,
        AfterThemeStyle.racingBlue => ThemeMode.light,
        AfterThemeStyle.darkNight => ThemeMode.dark,
        AfterThemeStyle.forestGreen => ThemeMode.dark,
        AfterThemeStyle.silverGrey => ThemeMode.light,
        AfterThemeStyle.blossomPink => ThemeMode.light,
        AfterThemeStyle.brightGold => ThemeMode.light,
        AfterThemeStyle.diamond => ThemeMode.dark,
        AfterThemeStyle.royal => ThemeMode.dark,
      };

  bool get isDarkNamed =>
      this == AfterThemeStyle.dark ||
      this == AfterThemeStyle.racingRed ||
      this == AfterThemeStyle.darkNight ||
      this == AfterThemeStyle.forestGreen ||
      this == AfterThemeStyle.diamond ||
      this == AfterThemeStyle.royal;

}

abstract final class AfterThemeStyles {
  static AfterThemeStyle fromStorage(String? raw) {
    for (final v in AfterThemeStyle.values) {
      if (v.name == raw) return v;
    }
    return AfterThemeStyle.system;
  }
}

/// Resolves [AfterThemeStyle] into Material [ThemeData] + shell backgrounds.
abstract final class AfterPremiumThemeResolver {
  static ThemeData themeData(AfterThemeStyle style) {
    return switch (style) {
      AfterThemeStyle.racingRed => SuperGarageTheme.racingRed,
      AfterThemeStyle.racingBlue => SuperGarageTheme.racingBlue,
      AfterThemeStyle.darkNight => SuperGarageTheme.darkNight,
      AfterThemeStyle.forestGreen => SuperGarageTheme.forestGreen,
      AfterThemeStyle.silverGrey => SuperGarageTheme.silverGrey,
      AfterThemeStyle.blossomPink => SuperGarageTheme.blossomPink,
      AfterThemeStyle.brightGold => SuperGarageTheme.brightGold,
      AfterThemeStyle.diamond => SuperGarageTheme.diamond,
      AfterThemeStyle.royal => SuperGarageTheme.royal,
      AfterThemeStyle.dark => SuperGarageTheme.dark,
      AfterThemeStyle.system || AfterThemeStyle.light => SuperGarageTheme.light,
    };
  }
}
