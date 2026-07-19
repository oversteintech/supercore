import 'package:flutter/material.dart';

import 'colors.dart';

/// Soft layered shadows — Linear / Apple depth without heavy Material blobs.
abstract final class AfterShadows {
  static List<BoxShadow> none = const [];

  static List<BoxShadow> level1(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.35 : 0.06),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.2 : 0.03),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ];
  }

  static List<BoxShadow> level2(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.45 : 0.1),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.25 : 0.04),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> level3(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.55 : 0.14),
        blurRadius: 32,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.3 : 0.06),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> level4(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.65 : 0.18),
        blurRadius: 48,
        offset: const Offset(0, 20),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.35 : 0.08),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ];
  }

  /// Soft ice glow for AI / focus emphasis (use sparingly).
  static List<BoxShadow> accentGlow({double intensity = 1}) {
    return [
      BoxShadow(
        color: AfterColors.accent.withValues(alpha: 0.28 * intensity),
        blurRadius: 20 * intensity,
        spreadRadius: 0,
        offset: Offset.zero,
      ),
    ];
  }
}
