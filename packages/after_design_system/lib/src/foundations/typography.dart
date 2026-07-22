import 'package:flutter/material.dart';

/// Typography scale — **SuperGarage flagship parity**.
///
/// Sizes/weights/tracking match [SuperGarageTheme] MountainView hierarchy:
/// - L0 brand chrome → [titleMedium] (~16, w800)
/// - L1 page titles → [headlineSmall] / page style (~24, w900)
/// - L2 sections → [titleMedium]
/// - L3 subsections → [titleSmall] (~14, w700)
///
/// Platform UI font by default (SF / Roboto). Override via [fontFamily].
@immutable
class AfterTypography {
  const AfterTypography({
    this.fontFamily,
    this.displayFontFamily,
  });

  /// Garage-identical token pack (default for every Super App).
  static const garage = AfterTypography();

  /// Body / UI font. `null` = platform default.
  final String? fontFamily;

  /// Optional display face for hero titles. Falls back to [fontFamily].
  final String? displayFontFamily;

  String? get _display => displayFontFamily ?? fontFamily;

  // —— Display (rare heroes; keep above L1 page titles) ——

  TextStyle get displayLarge => TextStyle(
        fontFamily: _display,
        fontSize: 34,
        fontWeight: FontWeight.w900,
        height: 1.1,
        letterSpacing: -0.8,
      );

  TextStyle get displayMedium => TextStyle(
        fontFamily: _display,
        fontSize: 28,
        fontWeight: FontWeight.w900,
        height: 1.12,
        letterSpacing: -0.65,
      );

  TextStyle get displaySmall => TextStyle(
        fontFamily: _display,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        height: 1.05,
        letterSpacing: -0.4,
      );

  /// L0 shell / brand-adjacent large title (Garage `titleLarge`).
  TextStyle get titleLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        height: 1.05,
        letterSpacing: -0.4,
      );

  /// L0 brand chrome + L2 section (Garage `titleMedium`).
  TextStyle get titleMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        height: 1.15,
        letterSpacing: -0.15,
      );

  /// L3 subsection / in-page tabs (Garage `titleSmall`).
  TextStyle get titleSmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.1,
      );

  /// L1 page title (Garage `headlineSmall`).
  TextStyle get pageTitle => TextStyle(
        fontFamily: _display,
        fontSize: 24,
        fontWeight: FontWeight.w900,
        height: 1.08,
        letterSpacing: -0.55,
      );

  TextStyle get bodyLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.35,
        letterSpacing: 0,
      );

  TextStyle get bodyMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.35,
        letterSpacing: 0,
      );

  TextStyle get bodySmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0,
      );

  TextStyle get labelLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: 0.1,
      );

  TextStyle get labelMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.15,
      );

  TextStyle get labelSmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 0.3,
      );

  TextStyle get mono => TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
      );

  /// Material [TextTheme] aligned with SuperGarage hierarchy tokens.
  TextTheme toTextTheme({required Color foreground, required Color muted}) {
    TextStyle paint(TextStyle style, {Color? color}) =>
        style.copyWith(color: color ?? foreground);

    return TextTheme(
      displayLarge: paint(displayLarge),
      displayMedium: paint(displayMedium),
      displaySmall: paint(displaySmall),
      headlineLarge: paint(displayMedium),
      headlineMedium: paint(titleLarge),
      headlineSmall: paint(pageTitle),
      titleLarge: paint(titleLarge),
      titleMedium: paint(titleMedium),
      titleSmall: paint(titleSmall),
      bodyLarge: paint(bodyLarge),
      bodyMedium: paint(bodyMedium),
      bodySmall: paint(bodySmall, color: muted),
      labelLarge: paint(labelLarge),
      labelMedium: paint(labelMedium, color: muted),
      labelSmall: paint(labelSmall, color: muted),
    );
  }
}
