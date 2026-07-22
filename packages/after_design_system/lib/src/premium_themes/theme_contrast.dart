import 'dart:math' as math;

import 'package:flutter/material.dart';

/// WCAG-aware contrast helpers for readable text on arbitrary backgrounds.
abstract final class ThemeContrast {
  static const _darkText = Color(0xFF0B1220);
  static const _lightText = Color(0xFFF8FAFC);

  /// Returns high-contrast foreground for [background] (picks light or dark by ratio).
  static Color readableOn(
    Color background, {
    bool muted = false,
    Color? light,
    Color? dark,
  }) {
    final lightCandidate = light ?? _lightText;
    final darkCandidate = dark ?? _darkText;
    final lightRatio = contrastRatio(lightCandidate, background);
    final darkRatio = contrastRatio(darkCandidate, background);
    final base = darkRatio >= lightRatio ? darkCandidate : lightCandidate;
    return muted ? base.withValues(alpha: 0.72) : base;
  }

  static double contrastRatio(Color foreground, Color background) {
    final l1 = foreground.computeLuminance();
    final l2 = background.computeLuminance();
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  static bool meetsMinimumContrast(
    Color foreground,
    Color background, {
    double ratio = 4.5,
  }) {
    return contrastRatio(foreground, background) >= ratio;
  }

  static Color bestForegroundOn(
    Color background,
    ColorScheme scheme, {
    bool selected = false,
  }) {
    final candidates = <Color>[
      if (selected) scheme.onPrimaryContainer,
      scheme.onSurface,
      readableOn(background),
      _darkText,
      _lightText,
      scheme.onPrimary,
    ];

    Color best = _lightText;
    var bestRatio = 0.0;
    for (final candidate in candidates) {
      final ratio = contrastRatio(candidate, background);
      if (ratio > bestRatio) {
        bestRatio = ratio;
        best = candidate;
      }
    }
    return best;
  }

  static ({Color background, Color foreground}) chipPair({
    required ColorScheme scheme,
    required bool selected,
    Color? unselectedBackground,
    Color? selectedBackground,
  }) {
    final background = selected
        ? (selectedBackground ?? scheme.primaryContainer)
        : (unselectedBackground ?? scheme.surfaceContainerHigh);
    return (
      background: background,
      foreground: bestForegroundOn(background, scheme, selected: selected),
    );
  }
}

extension ThemeContrastScheme on ColorScheme {
  Color textOn(Color background, {bool muted = false}) =>
      ThemeContrast.readableOn(background, muted: muted);

  Color get tagBackground => surfaceContainerHighest;

  Color get tagForeground => ThemeContrast.readableOn(tagBackground);

  Color get tagForegroundMuted =>
      ThemeContrast.readableOn(tagBackground, muted: true);
}
