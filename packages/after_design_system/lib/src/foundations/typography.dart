import 'package:flutter/material.dart';

/// Typography scale — Apple / Linear precision with After identity.
///
/// Uses the platform UI font by default (SF on Apple, Roboto on Android).
/// Super Apps MAY override [fontFamily] / [displayFontFamily] via [AfterTypography].
@immutable
class AfterTypography {
  const AfterTypography({
    this.fontFamily,
    this.displayFontFamily,
  });

  /// Body / UI font. `null` = platform default.
  final String? fontFamily;

  /// Optional display face for hero titles. Falls back to [fontFamily].
  final String? displayFontFamily;

  String? get _display => displayFontFamily ?? fontFamily;

  // Tracking inspired by SF Pro / Linear (slightly tight on display).
  TextStyle get displayLarge => TextStyle(
        fontFamily: _display,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.8,
      );

  TextStyle get displayMedium => TextStyle(
        fontFamily: _display,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.18,
        letterSpacing: -0.6,
      );

  TextStyle get displaySmall => TextStyle(
        fontFamily: _display,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.22,
        letterSpacing: -0.4,
      );

  TextStyle get titleLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.3,
      );

  TextStyle get titleMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.2,
      );

  TextStyle get titleSmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: -0.1,
      );

  TextStyle get bodyLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: -0.1,
      );

  TextStyle get bodyMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        letterSpacing: -0.05,
      );

  TextStyle get bodySmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  TextStyle get labelLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.1,
      );

  TextStyle get labelMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.2,
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

  TextTheme toTextTheme({required Color foreground, required Color muted}) {
    TextStyle paint(TextStyle style, {Color? color}) =>
        style.copyWith(color: color ?? foreground);

    return TextTheme(
      displayLarge: paint(displayLarge),
      displayMedium: paint(displayMedium),
      displaySmall: paint(displaySmall),
      headlineLarge: paint(displaySmall),
      headlineMedium: paint(titleLarge),
      headlineSmall: paint(titleMedium),
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
