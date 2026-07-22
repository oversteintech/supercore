import 'package:flutter/material.dart';

import '../foundations/typography.dart';
import 'overstein_brand_colors.dart';
import 'dark_night_theme.dart';
import 'racing_theme_effects.dart';
import 'safari_savanna.dart';
import 'blossom_pink.dart';
import 'silver_grey.dart';
import 'theme_contrast.dart';

export 'premium_theme_shell.dart';
export 'premium_frame_style.dart';
export 'bright_gold_theme.dart';
export 'diamond_theme_effects.dart';
export 'theme_contrast.dart';
export 'overstein_brand_colors.dart';
export 'royal_theme_effects.dart';
export 'racing_theme_effects.dart';
export 'forest_woodland.dart';
export 'blossom_pink.dart';
export 'silver_grey.dart';
export 'dark_night_theme.dart';

/// Shared Super Garage brand colors used across light/dark themes and dashboard.
abstract final class SuperGarageColors {
  // Light â€” neutral white / gray
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurfaceMuted = Color(0xFFF3F4F6);
  static const lightAccent = Color(0xFF525252);
  static const lightAccentMid = Color(0xFF737373);
  static const lightAccentSoft = Color(0xFF9CA3AF);
  static const garageIconBg = Color(0xFFF3F4F6);
  static const garageHeroMuted = Color(0xFFE5E7EB);

  // Dark â€” OVERSTEIN graphite / steel palette
  static const darkBackground = OversteinBrandColors.graphite;
  static const darkSurface = Color(0xFF222831);
  static const darkSurfaceHigh = Color(0xFF2A313B);
  static const darkSurfaceHighest = Color(0xFF333A46);
  static const darkBorder = Color(0xFF3F4652);
  static const darkMuted = Color(0xFFB0B8C4);
  static const darkForeground = Color(0xFFF3F4F6);
  static const darkHeroMuted = Color(0xFFD1D5DB);
  static const darkIcon = Color(0xFF9CA3AF);
  static const darkIconBg = Color(0xFF272D36);
  static const darkHeroStart = Color(0xFF242A33);
  static const darkHeroEnd = Color(0xFF1A1F26);

  /// Ice / white-blue accents â€” never navy or black-blue.
  static const iceBlueSoft = Color(0xFFE0F2FE);
  static const iceBlue = Color(0xFFBAE6FD);
  static const iceBlueBright = Color(0xFF7DD3FC);
  static const iceBlueMid = Color(0xFF93C5FD);
  static const iceBluePale = Color(0xFFF0F9FF);

  // Yaris blue â€” crisp white base with vivid blue accents (light theme).
  static const yarisBackground = Color(0xFFF5FAFF);
  static const yarisSurface = Color(0xFFFFFFFF);
  static const yarisSurfaceLow = Color(0xFFEFF6FF);
  static const yarisSurface2 = Color(0xFFE3EEFB);
  static const yarisSurface3 = Color(0xFFD6E6FA);
  static const yarisBlue = Color(0xFF1565E6);
  static const yarisBlueBright = Color(0xFF2979FF);
  static const yarisBlueDeep = Color(0xFF0D47A1);
  static const yarisBorder = Color(0xFFBBD4F5);
  static const yarisMuted = Color(0xFF4B6A93);
  static const yarisForeground = Color(0xFF0B2545);

  // Blossom pink â€” blush white, pearl gray & rose accents (Premium).
  static const blossomBackground = Color(0xFFFFFBFD);
  static const blossomSurface = Color(0xFFFFFFFF);
  static const blossomMistGray = Color(0xFFF8F9FB);
  static const blossomCloudGray = Color(0xFFF3F4F6);
  static const blossomPearlGray = Color(0xFFE5E7EB);
  static const blossomSurfaceLow = Color(0xFFFFF5FA);
  static const blossomSurface2 = Color(0xFFFFE8F3);
  static const blossomSurface3 = Color(0xFFFFD6E8);
  static const blossomPink = Color(0xFFEC4899);
  static const blossomPinkBright = Color(0xFFF472B6);
  static const blossomPinkDeep = Color(0xFFDB2777);
  static const blossomBorder = Color(0xFFF9A8D4);
  static const blossomMuted = Color(0xFF9D5C7A);
  static const blossomGrayMuted = Color(0xFF6B7280);
  static const blossomForeground = Color(0xFF4A1D35);

  // Africa savanna â€” golden grass, ochre soil & sunset (Premium).
  static const africaBackground = Color(0xFF24160C);
  static const africaSurface = Color(0xFF3D2814);
  static const africaSurfaceHigh = Color(0xFF4E3218);
  static const africaSurfaceHighest = Color(0xFF5F3E1C);
  static const africaGold = Color(0xFFFFD54F);
  static const africaGoldBright = Color(0xFFFFEB3B);
  static const africaGrass = Color(0xFFE8C547);
  static const africaBrown = Color(0xFF9A6B35);
  static const africaBrownDeep = Color(0xFF4A2F14);
  static const africaOchre = Color(0xFFCD853F);
  static const africaForeground = Color(0xFFFFFDE7);
  static const africaMuted = Color(0xFFE6D4A8);
  static const africaBorder = Color(0xFFB8863A);

  // Africa safari â€” desert heat, warm safari tour (Premium).
  static const safariBackground = Color(0xFF2C1810);
  static const safariSurface = Color(0xFF4E342E);
  static const safariSurfaceHigh = Color(0xFF5D4037);
  static const safariSurfaceHighest = Color(0xFF6D4C41);
  static const safariGold = Color(0xFFFFC107);
  static const safariOrange = Color(0xFFFF8F00);
  static const safariRed = Color(0xFFE64A19);
  static const safariBrown = Color(0xFFBF360C);
  static const safariForeground = Color(0xFFFFF8E1);
  static const safariMuted = Color(0xFFE6CBA8);
  static const safariBorder = Color(0xFFFFAB40);

  // Wild primal forest â€” deep canopy, moss, mist & fireflies (Premium).
  static const forestBackground = Color(0xFF060A06);
  static const forestSurface = Color(0xCC101810);
  static const forestSurfaceHigh = Color(0xD9182418);
  static const forestSurfaceHighest = Color(0xE3223020);
  static const forestGreen = Color(0xFF2D5030);
  static const forestGreenBright = Color(0xFF5A9E52);
  static const forestMoss = Color(0xFF6B8F58);
  static const forestSunlight = Color(0xFF7A9480);
  static const forestSunlightBright = Color(0xFF9CB8A0);
  static const forestBark = Color(0xFF2A1F14);
  static const forestBarkDeep = Color(0xFF120C08);
  static const forestForeground = Color(0xFFE6EDE0);
  static const forestMuted = Color(0xFFA8B8A0);
  static const forestBorder = Color(0xFF3D5A3A);

  // Silver grey â€” light brushed aluminium, chrome highlights & cool steel (Premium).
  static const silverGreyBackground = Color(0xFFD4DAE2);
  static const silverGreySurface = Color(0xFFDBE1E8);
  static const silverGreySurfaceHigh = Color(0xFFD0D7E0);
  static const silverGreySurfaceHighest = Color(0xFFC2CAD4);
  static const silverGreySteel = Color(0xFF9CA3AF);
  static const silverGreyBright = Color(0xFF6B7280);
  static const silverGreyChrome = Color(0xFF4B5563);
  static const silverGreyAccent = Color(0xFF8B9AAB);
  static const silverGreyAccentBright = Color(0xFF64748B);
  static const silverGreyForeground = Color(0xFF111827);
  static const silverGreyMuted = Color(0xFF4B5563);
  static const silverGreyBorder = Color(0xFFD1D5DB);

  // Bright gold â€” ultra-premium saturated gold yellow royal IAP theme.
  static const goldBackground = Color(0xFFFFF3C4);
  static const goldSurface = Color(0xFFFFFBEB);
  static const goldSurfaceHigh = Color(0xFFFFE082);
  static const goldSurfaceHighest = Color(0xFFFFD54F);
  static const goldBright = Color(0xFFFFC400);
  static const goldShine = Color(0xFFFFEA00);
  static const goldDeep = Color(0xFFB8860B);
  static const goldForeground = Color(0xFF2A1F00);
  static const goldMuted = Color(0xFF6B4F12);
  static const goldBorder = Color(0xFFD4A017);

  // Diamond â€” crystalline sparkle royal membership IAP theme.
  static const diamondBackground = Color(0xFF050D18);
  static const diamondSurface = Color(0xFF142538);
  static const diamondSurfaceHigh = Color(0xFF1C3050);
  static const diamondSurfaceHighest = Color(0xFF243C60);
  static const diamondIce = Color(0xFFE1F5FE);
  static const diamondBright = Color(0xFF81D4FA);
  static const diamondSparkle = Color(0xFFFFFFFF);
  static const diamondAccent = Color(0xFF4FC3F7);
  static const diamondForeground = Color(0xFFF5FBFF);
  static const diamondMuted = Color(0xFFB3E5FC);
  static const diamondBorder = Color(0xFF64B5F6);

  // Royal (Super membership flagship) â€” supersonic midnight, cyan & afterburner orange.
  static const royalBackground = Color(0xFF020814);
  static const royalSurface = Color(0xFF0A1628);
  static const royalSurfaceHigh = Color(0xFF122238);
  static const royalSurfaceHighest = Color(0xFF1A2E48);
  static const royalPurpleDeep = Color(0xFF003D8F);
  static const royalViolet = Color(0xFF00B4FF);
  static const royalIndigo = Color(0xFF001F4D);
  static const royalGold = Color(0xFFFF6B00);
  static const royalGoldSoft = Color(0xFFFFB347);
  static const royalForeground = Color(0xFFE8F4FF);
  static const royalMuted = Color(0xFF7EB8DA);
  static const royalBorder = Color(0xFF00D4FF);
}

class SuperGarageTheme {
  /// Primary content cards (`Card` / `SuperGarageCard`).
  static const double cardRadius = 18;

  /// Inputs, buttons, chips, nav pills.
  static const double controlRadius = 16;

  /// Dialogs and large modal surfaces.
  static const double dialogRadius = 22;

  /// Bottom sheets / snackbars (slightly softer than cards).
  static const double sheetRadius = 18;

  // 8pt spacing grid
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;

  static const double sectionGap = 16;

  static const double iconSm = 18;
  static const double iconMd = 22;
  static const double iconLg = 24;

  static const double minTapTarget = 48;

  static const double _cardRadius = cardRadius;
  static const double _dialogRadius = dialogRadius;

  static const Color lightBackground = SuperGarageColors.lightBackground;
  static const Color darkBackground = SuperGarageColors.darkBackground;

  static ThemeData get light => _build(
    scheme: _lightScheme,
    background: lightBackground,
    brightness: Brightness.light,
  );

  static ThemeData get dark => _build(
    scheme: _darkScheme,
    background: darkBackground,
    brightness: Brightness.dark,
  );

  /// Aggressive Ducati-style red â€” Premium only.
  static ThemeData get racingRed => _build(
    scheme: _racingRedScheme,
    background: SuperGarageColors.darkBackground,
    brightness: Brightness.dark,
    variant: _ThemeVariant.racing,
    racingRedFrame: true,
  );

  /// Yaris blue â€” bright white base with vivid blue accents â€” Premium only.
  static ThemeData get racingBlue => _build(
    scheme: _racingBlueScheme,
    background: SuperGarageColors.yarisBackground,
    brightness: Brightness.light,
    variant: _ThemeVariant.racing,
    racingBlueFrame: true,
  );

  /// Dark Night â€” deep matte black with subtle charcoal frames â€” Premium only.
  static ThemeData get darkNight => _build(
    scheme: _darkNightScheme,
    background: Colors.transparent,
    brightness: Brightness.dark,
    variant: _ThemeVariant.darkNight,
  );

  /// Africa safari â€” warm desert yellows, oranges & coffee browns â€” Premium only.
  static ThemeData get africaSafari => _build(
    scheme: _africaSafariScheme,
    background: Colors.transparent,
    brightness: Brightness.dark,
    variant: _ThemeVariant.safari,
  );

  /// Wild primal forest â€” deep greens, drifting mist & fireflies â€” Premium only.
  static ThemeData get forestGreen => _build(
    scheme: _forestGreenScheme,
    background: SuperGarageColors.forestBackground,
    brightness: Brightness.dark,
    variant: _ThemeVariant.woodland,
  );

  /// Brushed silver grey â€” light aluminium surfaces â€” Premium only.
  static ThemeData get silverGrey => _build(
    scheme: _silverGreyScheme,
    background: SuperGarageColors.silverGreyBackground,
    brightness: Brightness.light,
    variant: _ThemeVariant.silverGrey,
  );

  /// Blossom pink â€” blush white & rose glow â€” Premium only.
  static ThemeData get blossomPink => _build(
    scheme: _blossomPinkScheme,
    background: Colors.transparent,
    brightness: Brightness.light,
    variant: _ThemeVariant.blossom,
  );

  /// Shiny bright gold â€” royal membership IAP (Super-tier price).
  static ThemeData get brightGold => _build(
    scheme: _brightGoldScheme,
    background: SuperGarageColors.goldBackground,
    brightness: Brightness.light,
    variant: _ThemeVariant.brightGold,
  );

  /// Diamond crystalline â€” royal membership IAP (Super-tier price).
  static ThemeData get diamond => _build(
    scheme: _diamondScheme,
    background: SuperGarageColors.diamondBackground,
    brightness: Brightness.dark,
    variant: _ThemeVariant.diamond,
  );

  /// Super membership flagship â€” supersonic cyan, orange & midnight.
  static ThemeData get royal => _build(
    scheme: _royalScheme,
    background: Colors.transparent,
    brightness: Brightness.dark,
    variant: _ThemeVariant.racing,
  );

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF111111),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE5E7EB),
    onPrimaryContainer: Color(0xFF111111),
    secondary: Color(0xFF525252),
    onSecondary: Color(0xFFFFFFFF),
    tertiary: Color(0xFF737373),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF111111),
    onSurfaceVariant: Color(0xFF525252),
    outline: Color(0xFFD1D5DB),
    outlineVariant: Color(0xFFE5E7EB),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF111111),
    onInverseSurface: Color(0xFFF9FAFB),
    inversePrimary: Color(0xFFE5E7EB),
    surfaceTint: Color(0xFF111111),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF9FAFB),
    surfaceContainer: Color(0xFFF3F4F6),
    surfaceContainerHigh: Color(0xFFE5E7EB),
    surfaceContainerHighest: Color(0xFFD1D5DB),
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: OversteinBrandColors.silverBright,
    onPrimary: SuperGarageColors.darkBackground,
    primaryContainer: SuperGarageColors.darkSurfaceHighest,
    onPrimaryContainer: SuperGarageColors.darkForeground,
    secondary: SuperGarageColors.iceBlueMid,
    onSecondary: SuperGarageColors.darkBackground,
    tertiary: SuperGarageColors.iceBlueBright,
    onTertiary: SuperGarageColors.darkForeground,
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    surface: SuperGarageColors.darkBackground,
    onSurface: SuperGarageColors.darkForeground,
    onSurfaceVariant: SuperGarageColors.darkMuted,
    outline: Color(0xFF4A515C),
    outlineVariant: SuperGarageColors.darkBorder,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: SuperGarageColors.darkForeground,
    onInverseSurface: SuperGarageColors.darkBackground,
    inversePrimary: SuperGarageColors.darkSurfaceHighest,
    surfaceTint: SuperGarageColors.darkBackground,
    surfaceContainerLowest: Color(0xFF14181E),
    surfaceContainerLow: Color(0xFF1E232A),
    surfaceContainer: SuperGarageColors.darkSurface,
    surfaceContainerHigh: SuperGarageColors.darkSurfaceHigh,
    surfaceContainerHighest: SuperGarageColors.darkSurfaceHighest,
  );

  static const ColorScheme _racingRedScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFE10600),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF5C2020),
    onPrimaryContainer: Color(0xFFFFDAD4),
    secondary: Color(0xFFE10600),
    onSecondary: Color(0xFFFFFFFF),
    tertiary: Color(0xFFFFAB00),
    onTertiary: SuperGarageColors.darkBackground,
    error: Color(0xFFFF3B30),
    onError: Color(0xFFFFFFFF),
    surface: SuperGarageColors.darkBackground,
    onSurface: SuperGarageColors.darkForeground,
    onSurfaceVariant: SuperGarageColors.darkMuted,
    outline: Color(0xFFE10600),
    outlineVariant: SuperGarageColors.darkBorder,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: SuperGarageColors.darkForeground,
    onInverseSurface: SuperGarageColors.darkBackground,
    inversePrimary: Color(0xFFE10600),
    surfaceTint: SuperGarageColors.darkBackground,
    surfaceContainerLowest: Color(0xFF262A32),
    surfaceContainerLow: Color(0xFF303640),
    surfaceContainer: SuperGarageColors.darkSurface,
    surfaceContainerHigh: SuperGarageColors.darkSurfaceHigh,
    surfaceContainerHighest: SuperGarageColors.darkSurfaceHighest,
  );

  static const ColorScheme _racingBlueScheme = ColorScheme(
    brightness: Brightness.light,
    primary: SuperGarageColors.yarisBlue,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: SuperGarageColors.yarisSurface2,
    onPrimaryContainer: SuperGarageColors.yarisBlueDeep,
    secondary: SuperGarageColors.yarisBlueBright,
    onSecondary: Color(0xFFFFFFFF),
    tertiary: SuperGarageColors.yarisBlueDeep,
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    surface: SuperGarageColors.yarisSurface,
    onSurface: SuperGarageColors.yarisForeground,
    onSurfaceVariant: SuperGarageColors.yarisMuted,
    outline: SuperGarageColors.yarisBlue,
    outlineVariant: SuperGarageColors.yarisBorder,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: SuperGarageColors.yarisForeground,
    onInverseSurface: SuperGarageColors.yarisSurface,
    inversePrimary: SuperGarageColors.yarisBlueBright,
    surfaceTint: SuperGarageColors.yarisSurface,
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: SuperGarageColors.yarisSurfaceLow,
    surfaceContainer: SuperGarageColors.yarisSurface2,
    surfaceContainerHigh: SuperGarageColors.yarisSurface3,
    surfaceContainerHighest: Color(0xFFC7DCF7),
  );

  static const ColorScheme _blossomPinkScheme = ColorScheme(
    brightness: Brightness.light,
    primary: SuperGarageColors.blossomPink,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: SuperGarageColors.blossomSurface2,
    onPrimaryContainer: SuperGarageColors.blossomPinkDeep,
    secondary: SuperGarageColors.blossomPearlGray,
    onSecondary: SuperGarageColors.blossomForeground,
    tertiary: SuperGarageColors.blossomPinkBright,
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    surface: SuperGarageColors.blossomSurface,
    onSurface: SuperGarageColors.blossomForeground,
    onSurfaceVariant: SuperGarageColors.blossomGrayMuted,
    outline: SuperGarageColors.blossomPink,
    outlineVariant: SuperGarageColors.blossomBorder,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: SuperGarageColors.blossomForeground,
    onInverseSurface: SuperGarageColors.blossomSurface,
    inversePrimary: SuperGarageColors.blossomPinkBright,
    surfaceTint: SuperGarageColors.blossomSurface,
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: SuperGarageColors.blossomMistGray,
    surfaceContainer: SuperGarageColors.blossomCloudGray,
    surfaceContainerHigh: SuperGarageColors.blossomSurface2,
    surfaceContainerHighest: SuperGarageColors.blossomSurface3,
  );

  static const ColorScheme _darkNightScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: DarkNightColors.silverBright,
    onPrimary: DarkNightColors.voidBlack,
    primaryContainer: DarkNightColors.surfaceHighest,
    onPrimaryContainer: DarkNightColors.foreground,
    secondary: DarkNightColors.silver,
    onSecondary: DarkNightColors.voidBlack,
    tertiary: DarkNightColors.graphite,
    onTertiary: DarkNightColors.foreground,
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    surface: DarkNightColors.matteBlack,
    onSurface: DarkNightColors.foreground,
    onSurfaceVariant: DarkNightColors.muted,
    outline: DarkNightColors.border,
    outlineVariant: DarkNightColors.charcoal,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: DarkNightColors.foreground,
    onInverseSurface: DarkNightColors.voidBlack,
    inversePrimary: DarkNightColors.charcoal,
    surfaceTint: DarkNightColors.matteBlack,
    surfaceContainerLowest: DarkNightColors.voidBlack,
    surfaceContainerLow: DarkNightColors.matteBlack,
    surfaceContainer: DarkNightColors.surface,
    surfaceContainerHigh: DarkNightColors.surfaceHigh,
    surfaceContainerHighest: DarkNightColors.surfaceHighest,
  );

  static const ColorScheme _africaSafariScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: SuperGarageColors.safariGold,
    onPrimary: SuperGarageColors.safariBackground,
    primaryContainer: SuperGarageColors.safariBrown,
    onPrimaryContainer: SuperGarageColors.safariForeground,
    secondary: SuperGarageColors.safariOrange,
    onSecondary: SuperGarageColors.safariBackground,
    tertiary: SuperGarageColors.safariRed,
    onTertiary: SuperGarageColors.safariForeground,
    error: Color(0xFFFF6B6B),
    onError: Color(0xFFFFFFFF),
    surface: SuperGarageColors.safariBackground,
    onSurface: SuperGarageColors.safariForeground,
    onSurfaceVariant: SuperGarageColors.safariMuted,
    outline: SuperGarageColors.safariBorder,
    outlineVariant: SuperGarageColors.safariBrown,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: SuperGarageColors.safariForeground,
    onInverseSurface: SuperGarageColors.safariBackground,
    inversePrimary: SuperGarageColors.safariBrown,
    surfaceTint: SuperGarageColors.safariBackground,
    surfaceContainerLowest: Color(0xFF1A1008),
    surfaceContainerLow: Color(0xFF24160C),
    surfaceContainer: SuperGarageColors.safariSurface,
    surfaceContainerHigh: SuperGarageColors.safariSurfaceHigh,
    surfaceContainerHighest: SuperGarageColors.safariSurfaceHighest,
  );

  static const ColorScheme _forestGreenScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: SuperGarageColors.forestGreenBright,
    onPrimary: SuperGarageColors.forestBarkDeep,
    primaryContainer: SuperGarageColors.forestGreen,
    onPrimaryContainer: SuperGarageColors.forestSunlightBright,
    secondary: SuperGarageColors.forestSunlight,
    onSecondary: SuperGarageColors.forestBarkDeep,
    tertiary: SuperGarageColors.forestBark,
    onTertiary: SuperGarageColors.forestSunlightBright,
    error: Color(0xFFEF5350),
    onError: Color(0xFFFFFFFF),
    surface: SuperGarageColors.forestSurface,
    onSurface: SuperGarageColors.forestForeground,
    onSurfaceVariant: SuperGarageColors.forestMuted,
    outline: SuperGarageColors.forestMoss,
    outlineVariant: SuperGarageColors.forestBorder,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: SuperGarageColors.forestSunlightBright,
    onInverseSurface: SuperGarageColors.forestBarkDeep,
    inversePrimary: SuperGarageColors.forestGreen,
    surfaceTint: SuperGarageColors.forestBackground,
    surfaceContainerLowest: Color(0xFF080E08),
    surfaceContainerLow: SuperGarageColors.forestSurface,
    surfaceContainer: SuperGarageColors.forestSurface,
    surfaceContainerHigh: SuperGarageColors.forestSurfaceHigh,
    surfaceContainerHighest: SuperGarageColors.forestSurfaceHighest,
  );

  static const ColorScheme _silverGreyScheme = ColorScheme(
    brightness: Brightness.light,
    primary: SuperGarageColors.silverGreyChrome,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: SuperGarageColors.silverGreySurfaceHighest,
    onPrimaryContainer: SuperGarageColors.silverGreyForeground,
    secondary: SuperGarageColors.silverGreyAccent,
    onSecondary: Color(0xFFFFFFFF),
    tertiary: SuperGarageColors.silverGreySteel,
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    surface: SuperGarageColors.silverGreyBackground,
    onSurface: SuperGarageColors.silverGreyForeground,
    onSurfaceVariant: SuperGarageColors.silverGreyMuted,
    outline: SuperGarageColors.silverGreySteel,
    outlineVariant: SuperGarageColors.silverGreyBorder,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: SuperGarageColors.silverGreyForeground,
    onInverseSurface: SuperGarageColors.silverGreyBackground,
    inversePrimary: SuperGarageColors.silverGreySurfaceHighest,
    surfaceTint: SuperGarageColors.silverGreyBackground,
    surfaceContainerLowest: Color(0xFFE2E7EC),
    surfaceContainerLow: SuperGarageColors.silverGreySurface,
    surfaceContainer: SuperGarageColors.silverGreySurfaceHigh,
    surfaceContainerHigh: SuperGarageColors.silverGreySurfaceHighest,
    surfaceContainerHighest: Color(0xFFCCD3DC),
  );

  static const ColorScheme _brightGoldScheme = ColorScheme(
    brightness: Brightness.light,
    primary: SuperGarageColors.goldDeep,
    onPrimary: Colors.white,
    primaryContainer: SuperGarageColors.goldBright,
    onPrimaryContainer: SuperGarageColors.goldForeground,
    secondary: SuperGarageColors.goldShine,
    onSecondary: SuperGarageColors.goldForeground,
    tertiary: SuperGarageColors.goldMuted,
    onTertiary: Colors.white,
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    surface: SuperGarageColors.goldSurface,
    onSurface: SuperGarageColors.goldForeground,
    onSurfaceVariant: SuperGarageColors.goldMuted,
    outline: SuperGarageColors.goldBorder,
    outlineVariant: Color(0xFFE6B800),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: SuperGarageColors.goldForeground,
    onInverseSurface: SuperGarageColors.goldBackground,
    inversePrimary: SuperGarageColors.goldBright,
    surfaceTint: Colors.transparent,
    surfaceContainerLowest: Color(0xFFFFFBEB),
    surfaceContainerLow: SuperGarageColors.goldSurface,
    surfaceContainer: SuperGarageColors.goldSurfaceHigh,
    surfaceContainerHigh: SuperGarageColors.goldSurfaceHighest,
    surfaceContainerHighest: Color(0xFFFFC107),
  );

  static const ColorScheme _diamondScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: SuperGarageColors.diamondIce,
    onPrimary: SuperGarageColors.diamondBackground,
    primaryContainer: SuperGarageColors.diamondAccent,
    onPrimaryContainer: SuperGarageColors.diamondForeground,
    secondary: SuperGarageColors.diamondBright,
    onSecondary: SuperGarageColors.diamondBackground,
    secondaryContainer: SuperGarageColors.diamondSurfaceHigh,
    onSecondaryContainer: SuperGarageColors.diamondIce,
    tertiary: SuperGarageColors.diamondSparkle,
    onTertiary: SuperGarageColors.diamondBackground,
    error: Color(0xFFEF5350),
    onError: Color(0xFFFFFFFF),
    surface: SuperGarageColors.diamondBackground,
    onSurface: SuperGarageColors.diamondForeground,
    onSurfaceVariant: SuperGarageColors.diamondMuted,
    outline: SuperGarageColors.diamondBorder,
    outlineVariant: Color(0xFF2A4560),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: SuperGarageColors.diamondForeground,
    onInverseSurface: SuperGarageColors.diamondBackground,
    inversePrimary: SuperGarageColors.diamondAccent,
    surfaceTint: SuperGarageColors.diamondBackground,
    surfaceContainerLowest: Color(0xFF060E18),
    surfaceContainerLow: SuperGarageColors.diamondBackground,
    surfaceContainer: SuperGarageColors.diamondSurface,
    surfaceContainerHigh: SuperGarageColors.diamondSurfaceHigh,
    surfaceContainerHighest: SuperGarageColors.diamondSurfaceHighest,
  );

  static const ColorScheme _royalScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: SuperGarageColors.royalGold,
    onPrimary: SuperGarageColors.royalBackground,
    primaryContainer: SuperGarageColors.royalPurpleDeep,
    onPrimaryContainer: SuperGarageColors.royalForeground,
    secondary: SuperGarageColors.royalGoldSoft,
    onSecondary: SuperGarageColors.royalBackground,
    tertiary: SuperGarageColors.royalViolet,
    onTertiary: SuperGarageColors.royalForeground,
    error: Color(0xFFFF5252),
    onError: Color(0xFFFFFFFF),
    surface: SuperGarageColors.royalBackground,
    onSurface: SuperGarageColors.royalForeground,
    onSurfaceVariant: SuperGarageColors.royalMuted,
    outline: SuperGarageColors.royalBorder,
    outlineVariant: Color(0xFF0E4A6E),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: SuperGarageColors.royalForeground,
    onInverseSurface: SuperGarageColors.royalBackground,
    inversePrimary: SuperGarageColors.royalGold,
    surfaceTint: SuperGarageColors.royalBackground,
    surfaceContainerLowest: Color(0xFF01050C),
    surfaceContainerLow: SuperGarageColors.royalBackground,
    surfaceContainer: SuperGarageColors.royalSurface,
    surfaceContainerHigh: SuperGarageColors.royalSurfaceHigh,
    surfaceContainerHighest: SuperGarageColors.royalSurfaceHighest,
  );

  static ThemeData _build({
    required ColorScheme scheme,
    required Color background,
    required Brightness brightness,
    _ThemeVariant variant = _ThemeVariant.standard,
    bool racingRedFrame = false,
    bool racingBlueFrame = false,
  }) {
    final isRacing = variant == _ThemeVariant.racing;
    final isDiamond = variant == _ThemeVariant.diamond;
    final isBrightGold = variant == _ThemeVariant.brightGold;
    final isSilverGrey = variant == _ThemeVariant.silverGrey;
    final isWoodland = variant == _ThemeVariant.woodland;
    final isDarkNight = variant == _ThemeVariant.darkNight;
    final isSafari = variant == _ThemeVariant.safari;
    final isBlossom = variant == _ThemeVariant.blossom;
    final isPremiumIap = isDiamond || isBrightGold;
    final isAnimatedAccent =
        isRacing ||
        isSilverGrey ||
        isWoodland ||
        isDarkNight ||
        isSafari ||
        isBlossom ||
        isPremiumIap;
    final resolvedScheme = scheme.copyWith(surfaceTint: Colors.transparent);
    final themeScheme = isBrightGold
        ? resolvedScheme
        : resolvedScheme.copyWith(
            onSurface: brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            onSurfaceVariant: brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.72)
                : Colors.black.withValues(alpha: 0.62),
          );
    final fieldFill = isSilverGrey || isWoodland || isDarkNight || isSafari
        ? resolvedScheme.surfaceContainerHigh
        : brightness == Brightness.light
        ? resolvedScheme.surfaceContainer
        : resolvedScheme.surfaceContainerLow;
    final panelFill = isBrightGold
        ? SuperGarageColors.goldSurface
        : isDiamond
        ? SuperGarageColors.diamondSurface
        : isSilverGrey || isWoodland || isDarkNight || isSafari || isBlossom
        ? (isBlossom
              ? SuperGarageColors.blossomSurface.withValues(alpha: 0.94)
              : isSilverGrey
              ? SuperGarageColors.silverGreySurface.withValues(alpha: 0.96)
              : resolvedScheme.surfaceContainer)
        : brightness == Brightness.light
        ? resolvedScheme.surface
        : resolvedScheme.surfaceContainerLow;
    final barFill = isDiamond
        ? SuperGarageColors.diamondSurface
        : isBrightGold
        ? SuperGarageColors.goldSurface
        : isSilverGrey || isWoodland || isDarkNight || isSafari || isBlossom
        ? resolvedScheme.surfaceContainerLow
        : background;
    final scaffoldFill =
        isPremiumIap ||
            isWoodland ||
            isDarkNight ||
            isSafari ||
            isBlossom ||
            isSilverGrey ||
            background == Colors.transparent
        ? Colors.transparent
        : background;
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(controlRadius),
      borderSide: BorderSide(color: resolvedScheme.outlineVariant),
    );
    final inputFocusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(controlRadius),
      borderSide: BorderSide(color: resolvedScheme.primary, width: 2),
    );
    final baseText = brightness == Brightness.dark
        ? Typography.whiteMountainView
        : Typography.blackMountainView;
    // Single source of truth: AfterTypography.garage (family-wide parity).
    // L0 brand chrome  â†’ titleMedium (~16)  â€” MainShellHeader
    // L1 page titles   â†’ headlineSmall (~24) â€” AppBar / MainTabAppBar
    // L2 sections      â†’ titleMedium (~16)
    // L3 subsections   â†’ titleSmall (~14)
    // In-page TabBar   â†’ titleSmall (must stay below L1 page titles)
    final garageText = AfterTypography.garage.toTextTheme(
      foreground: themeScheme.onSurface,
      muted: themeScheme.onSurfaceVariant,
    );
    final shellTitleTextStyle = garageText.titleLarge;
    final appTitleTextStyle = garageText.headlineSmall;
    final sectionTitleTextStyle = garageText.titleMedium;
    final subsectionTitleTextStyle = garageText.titleSmall;
    final bodyTextStyle = garageText.bodyMedium;
    final labelTextStyle = garageText.labelLarge;
    final labelMediumTextStyle = garageText.labelMedium;
    final tabLabelTextStyle = subsectionTitleTextStyle?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.05,
    );
    final tabUnselectedTextStyle = subsectionTitleTextStyle?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    );

    const buttonMinimumSize = Size(minTapTarget, minTapTarget);
    const buttonPadding = EdgeInsets.symmetric(
      horizontal: spaceMd,
      vertical: 14,
    );
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(controlRadius),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldFill,
      colorScheme: themeScheme,
      textTheme: garageText.copyWith(
        headlineSmall: appTitleTextStyle,
        titleLarge: shellTitleTextStyle,
        titleMedium: sectionTitleTextStyle,
        titleSmall: subsectionTitleTextStyle,
        bodyMedium: bodyTextStyle,
        labelLarge: labelTextStyle,
        labelMedium: labelMediumTextStyle,
      ),
      primaryTextTheme: baseText.apply(
        bodyColor: resolvedScheme.onPrimary,
        displayColor: resolvedScheme.onPrimary,
      ),
      cardTheme: CardThemeData(
        color: panelFill,
        elevation: isPremiumIap ? 0 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: BorderSide(
            color: isDiamond
                ? SuperGarageColors.diamondBorder.withValues(alpha: 0.55)
                : isBrightGold
                ? SuperGarageColors.goldBorder.withValues(alpha: 0.55)
                : isBlossom
                ? SuperGarageColors.blossomBorder.withValues(alpha: 0.65)
                : brightness == Brightness.light
                ? resolvedScheme.outline.withValues(alpha: 0.45)
                : resolvedScheme.outlineVariant,
            width: isPremiumIap || isBlossom ? 1.1 : 1,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: barFill,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 44,
        foregroundColor: themeScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: isDiamond
            ? appTitleTextStyle?.copyWith(
                color: SuperGarageColors.diamondIce,
              )
            : isBrightGold
            ? appTitleTextStyle?.copyWith(
                color: SuperGarageColors.goldForeground,
              )
            : isBlossom
            ? appTitleTextStyle?.copyWith(
                color: SuperGarageColors.blossomPinkDeep,
              )
            : appTitleTextStyle?.copyWith(
                color: themeScheme.onSurface,
              ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDiamond
            ? SuperGarageColors.diamondSurfaceHigh
            : isBrightGold
            ? SuperGarageColors.goldSurfaceHigh
            : isBlossom
            ? SuperGarageColors.blossomMistGray
            : panelFill,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_dialogRadius),
          side: BorderSide(
            color: isDiamond
                ? SuperGarageColors.diamondBorder.withValues(alpha: 0.65)
                : isBrightGold
                ? SuperGarageColors.goldBorder.withValues(alpha: 0.65)
                : resolvedScheme.outlineVariant,
            width: isPremiumIap ? 1.2 : 1,
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: tabLabelTextStyle,
        unselectedLabelStyle: tabUnselectedTextStyle,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelColor: isDiamond
            ? SuperGarageColors.diamondIce
            : isBrightGold
            ? SuperGarageColors.goldForeground
            : isBlossom
            ? SuperGarageColors.blossomPinkDeep
            : themeScheme.onSurface,
        unselectedLabelColor: themeScheme.onSurfaceVariant,
        indicatorColor: isDiamond
            ? SuperGarageColors.diamondBright
            : isBrightGold
            ? SuperGarageColors.goldDeep
            : isBlossom
            ? SuperGarageColors.blossomPink
            : resolvedScheme.primary,
        dividerColor: isDiamond
            ? SuperGarageColors.diamondBorder.withValues(alpha: 0.35)
            : isBrightGold
            ? SuperGarageColors.goldBorder.withValues(alpha: 0.35)
            : isBlossom
            ? SuperGarageColors.blossomPearlGray.withValues(alpha: 0.8)
            : null,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDiamond
            ? SuperGarageColors.diamondSurfaceHighest
            : isBrightGold
            ? SuperGarageColors.goldSurfaceHighest
            : null,
        contentTextStyle: isDiamond
            ? TextStyle(color: SuperGarageColors.diamondForeground)
            : isBrightGold
            ? TextStyle(color: SuperGarageColors.goldForeground)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sheetRadius),
          side: isDiamond
              ? BorderSide(
                  color: SuperGarageColors.diamondBorder.withValues(alpha: 0.5),
                )
              : isBrightGold
              ? BorderSide(
                  color: SuperGarageColors.goldBorder.withValues(alpha: 0.5),
                )
              : BorderSide.none,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDiamond
            ? SuperGarageColors.diamondIce
            : isBrightGold
            ? SuperGarageColors.goldBright
            : isSilverGrey
            ? Color.lerp(
                SuperGarageColors.silverGreySurface,
                SuperGarageColors.silverGreySurfaceHighest,
                0.5,
              )
            : isBlossom
            ? SuperGarageColors.blossomPinkBright
            : resolvedScheme.primaryContainer,
        foregroundColor: isDiamond
            ? SuperGarageColors.diamondBackground
            : isBrightGold
            ? SuperGarageColors.goldBackground
            : isSilverGrey
            ? SuperGarageColors.silverGreyForeground
            : isBlossom
            ? SuperGarageColors.blossomSurface
            : resolvedScheme.onPrimaryContainer,
        elevation: isPremiumIap || isBlossom
            ? 3
            : isSilverGrey
            ? 4
            : 2,
        // Material Extended FAB: stadium pill, compact height (not a chunky control).
        shape: StadiumBorder(
          side: isSilverGrey
              ? BorderSide(
                  color: Color.lerp(
                    SuperGarageColors.silverGreyBorder,
                    SuperGarageColors.silverGreyChrome,
                    0.5,
                  )!,
                  width: 1.8,
                )
              : BorderSide.none,
        ),
        sizeConstraints: const BoxConstraints.tightFor(
          width: minTapTarget,
          height: minTapTarget,
        ),
        extendedSizeConstraints: const BoxConstraints(
          minHeight: minTapTarget,
          maxHeight: minTapTarget,
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: spaceMd),
        extendedIconLabelSpacing: spaceSm,
        extendedTextStyle: labelMediumTextStyle?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMd,
          vertical: 14,
        ),
        labelStyle: TextStyle(color: themeScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: themeScheme.onSurfaceVariant),
        prefixIconColor: resolvedScheme.adaptiveIcon,
        suffixIconColor: resolvedScheme.adaptiveIcon,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputFocusedBorder,
      ),
      chipTheme: () {
        final chipBackground = fieldFill;
        final chipSelectedBackground = resolvedScheme.primaryContainer;
        final chipSelectedForeground = ThemeContrast.readableOn(
          chipSelectedBackground,
        );
        final chipUnselectedForeground = ThemeContrast.readableOn(
          chipBackground,
        );

        return ChipThemeData(
          backgroundColor: chipBackground,
          selectedColor: chipSelectedBackground,
          disabledColor: fieldFill,
          checkmarkColor: chipSelectedForeground,
          labelStyle: TextStyle(color: chipUnselectedForeground),
          secondaryLabelStyle: TextStyle(color: chipSelectedForeground),
          side: BorderSide(color: resolvedScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: spaceSm, vertical: 2),
        );
      }(),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isBrightGold
              ? SuperGarageColors.goldDeep
              : isDiamond
              ? SuperGarageColors.diamondIce
              : isSilverGrey
              ? Color.lerp(
                  SuperGarageColors.silverGreySurfaceHighest,
                  SuperGarageColors.silverGreySteel,
                  0.125,
                )
              : isBlossom
              ? SuperGarageColors.blossomPink
              : resolvedScheme.primary,
          foregroundColor: isBrightGold
              ? Colors.white
              : isDiamond
              ? SuperGarageColors.diamondBackground
              : isSilverGrey
              ? SuperGarageColors.silverGreyForeground
              : resolvedScheme.onPrimary,
          disabledBackgroundColor: isDiamond
              ? SuperGarageColors.diamondSurfaceHigh
              : isBrightGold
              ? SuperGarageColors.goldSurfaceHigh
              : null,
          disabledForegroundColor: isDiamond
              ? SuperGarageColors.diamondIce.withValues(alpha: 0.72)
              : isBrightGold
              ? SuperGarageColors.goldBright.withValues(alpha: 0.72)
              : null,
          elevation: isPremiumIap
              ? 2
              : isSilverGrey
              ? 4
              : isBlossom
              ? 3
              : 0,
          shadowColor: isDiamond
              ? SuperGarageColors.diamondAccent.withValues(alpha: 0.45)
              : isBrightGold
              ? SuperGarageColors.goldBright.withValues(alpha: 0.45)
              : isSilverGrey
              ? SuperGarageColors.silverGreySteel.withValues(alpha: 0.28)
              : isBlossom
              ? SuperGarageColors.blossomPinkBright.withValues(alpha: 0.4)
              : null,
          minimumSize: buttonMinimumSize,
          padding: buttonPadding,
          shape: isSilverGrey
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(controlRadius),
                  side: BorderSide(
                    color: Color.lerp(
                      SuperGarageColors.silverGreyBorder,
                      SuperGarageColors.silverGreyChrome,
                      0.5,
                    )!,
                    width: 1.8,
                  ),
                )
              : isBlossom
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(controlRadius),
                  side: BorderSide(
                    color: SuperGarageColors.blossomPearlGray.withValues(
                      alpha: 0.7,
                    ),
                  ),
                )
              : controlShape,
          textStyle: isSilverGrey
              ? const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.25,
                )
              : isBlossom
              ? const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.2)
              : null,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: themeScheme.onSurface,
          side: BorderSide(
            color: brightness == Brightness.light
                ? resolvedScheme.outline.withValues(alpha: 0.6)
                : isAnimatedAccent
                ? resolvedScheme.primary
                : resolvedScheme.outline,
            width: 1.2,
          ),
          minimumSize: buttonMinimumSize,
          padding: buttonPadding,
          shape: controlShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: buttonMinimumSize,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceSm,
            vertical: spaceSm,
          ),
          shape: controlShape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(minTapTarget, minTapTarget),
          iconSize: iconMd,
        ),
      ),
      iconTheme: IconThemeData(
        color: resolvedScheme.adaptiveIcon,
        size: iconMd,
      ),
      primaryIconTheme: IconThemeData(
        color: resolvedScheme.onPrimary,
        size: iconMd,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: resolvedScheme.adaptiveIcon,
        textColor: themeScheme.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: spaceMd),
        minVerticalPadding: spaceSm,
        minTileHeight: minTapTarget,
        horizontalTitleGap: spaceMd,
        shape: controlShape,
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        expansionAnimationStyle: AnimationStyle.noAnimation,
      ),
      dividerTheme: DividerThemeData(
        color: resolvedScheme.outlineVariant,
        thickness: 1,
        space: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: panelFill,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(sheetRadius),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: panelFill,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          side: BorderSide(color: resolvedScheme.outlineVariant),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(panelFill),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(controlRadius),
              side: BorderSide(color: resolvedScheme.outlineVariant),
            ),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: panelFill,
        indicatorColor: isSilverGrey
            ? resolvedScheme.primaryContainer
            : isAnimatedAccent
            ? resolvedScheme.primary
            : resolvedScheme.primaryContainer,
        elevation: isBlossom
            ? 5
            : brightness == Brightness.light
            ? 2
            : 0,
        shadowColor: isBlossom
            ? SuperGarageColors.blossomPink.withValues(alpha: 0.21)
            : resolvedScheme.shadow.withValues(alpha: 0.08),
        height: 74,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: iconMd,
            color: states.contains(WidgetState.selected)
                ? (isSilverGrey
                      ? resolvedScheme.onPrimaryContainer
                      : isAnimatedAccent
                      ? resolvedScheme.onPrimary
                      : resolvedScheme.adaptiveIcon)
                : resolvedScheme.adaptiveIconMuted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) {
            // Selected labels sit on the bar fill â€” never onPrimary (pill).
            final bar = panelFill.a >= 0.99
                ? panelFill
                : Color.alphaBlend(panelFill, themeScheme.surface);
            final selectedLabel =
                ThemeContrast.meetsMinimumContrast(
                  resolvedScheme.primary,
                  bar,
                  ratio: 3.0,
                )
                ? resolvedScheme.primary
                : ThemeContrast.readableOn(bar);
            return TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w600,
              color: states.contains(WidgetState.selected)
                  ? selectedLabel
                  : themeScheme.onSurfaceVariant,
            );
          },
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: fieldFill,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: spaceMd,
            vertical: 14,
          ),
          border: inputBorder,
          enabledBorder: inputBorder,
          focusedBorder: inputFocusedBorder,
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(panelFill),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(controlRadius),
              side: BorderSide(color: resolvedScheme.outlineVariant),
            ),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: themeScheme.onSurface,
        unselectedItemColor: themeScheme.onSurfaceVariant,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      extensions: [
        if (isDiamond) const DiamondThemeEffects(enabled: true),
        if (isBrightGold) const BrightGoldThemeEffects(enabled: true),
        if (isDarkNight) const DarkNightThemeEffects(enabled: true),
        if (isSafari) const SafariSavannaThemeEffects(enabled: true),
        if (isBlossom) const BlossomPinkThemeEffects(enabled: true),
        if (isSilverGrey) const SilverGreyThemeEffects(enabled: true),
        if (racingRedFrame || racingBlueFrame)
          RacingThemeEffects(red: racingRedFrame, blue: racingBlueFrame),
      ],
    );
  }
}

enum _ThemeVariant {
  standard,
  racing,
  silverGrey,
  woodland,
  darkNight,
  safari,
  blossom,
  diamond,
  brightGold,
}

/// Theme extension â€” only attached to the Bright Gold theme.
@immutable
class BrightGoldThemeEffects extends ThemeExtension<BrightGoldThemeEffects> {
  const BrightGoldThemeEffects({this.enabled = false});

  final bool enabled;

  static BrightGoldThemeEffects? of(BuildContext context) {
    return Theme.of(context).extension<BrightGoldThemeEffects>();
  }

  static bool isActive(BuildContext context) => of(context)?.enabled ?? false;

  @override
  BrightGoldThemeEffects copyWith({bool? enabled}) {
    return BrightGoldThemeEffects(enabled: enabled ?? this.enabled);
  }

  @override
  BrightGoldThemeEffects lerp(BrightGoldThemeEffects? other, double t) {
    if (other == null) return this;
    return BrightGoldThemeEffects(
      enabled: t < 0.5 ? enabled : other.enabled,
    );
  }
}

/// Theme extension â€” only attached to the Diamond theme.
@immutable
class DiamondThemeEffects extends ThemeExtension<DiamondThemeEffects> {
  const DiamondThemeEffects({this.enabled = false});

  final bool enabled;

  static DiamondThemeEffects? of(BuildContext context) {
    return Theme.of(context).extension<DiamondThemeEffects>();
  }

  static bool isActive(BuildContext context) => of(context)?.enabled ?? false;

  @override
  DiamondThemeEffects copyWith({bool? enabled}) {
    return DiamondThemeEffects(enabled: enabled ?? this.enabled);
  }

  @override
  DiamondThemeEffects lerp(DiamondThemeEffects? other, double t) {
    if (other == null) return this;
    return DiamondThemeEffects(
      enabled: t < 0.5 ? enabled : other.enabled,
    );
  }
}

/// Icon and foreground colors that stay black in light mode and white in dark mode.
extension AdaptiveIconColors on ColorScheme {
  Color get adaptiveIcon =>
      brightness == Brightness.dark ? Colors.white : Colors.black;

  Color get adaptiveIconMuted => brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.68)
      : Colors.black.withValues(alpha: 0.62);

  /// Primary readable text on themed surfaces (not gradient heroes).
  Color get adaptiveForeground =>
      brightness == Brightness.dark ? Colors.white : Colors.black;

  Color get adaptiveForegroundMuted => brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.72)
      : Colors.black.withValues(alpha: 0.62);
}

/// Tints black-on-transparent PNG assets for dark surfaces.
class AdaptiveMonochromeAsset extends StatelessWidget {
  const AdaptiveMonochromeAsset({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return child;
    }
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(
        SuperGarageColors.darkForeground,
        BlendMode.srcIn,
      ),
      child: child,
    );
  }
}
