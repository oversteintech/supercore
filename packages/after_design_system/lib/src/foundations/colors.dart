import 'package:flutter/material.dart';

/// After Design System color tokens.
///
/// Visual identity: cool graphite surfaces, luminous ice accent (AI signal),
/// steel neutrals — premium, precise, never purple-default or warm-cream.
abstract final class AfterColors {
  // ── Brand / AI accent ─────────────────────────────────────────────
  /// Primary AI accent — luminous ice.
  static const accent = Color(0xFF38BDF8);
  static const accentBright = Color(0xFF7DD3FC);
  static const accentSoft = Color(0xFFBAE6FD);
  static const accentMuted = Color(0xFF0EA5E9);
  static const accentDeep = Color(0xFF0284C7);
  static const accentGlow = Color(0x4038BDF8);

  // ── OVERSTEIN graphite (dark core) ────────────────────────────────
  static const graphite950 = Color(0xFF0B0C0F);
  static const graphite900 = Color(0xFF121418);
  static const graphite850 = Color(0xFF1A1D22);
  static const graphite800 = Color(0xFF222831);
  static const graphite700 = Color(0xFF2A313B);
  static const graphite600 = Color(0xFF333A46);
  static const graphite500 = Color(0xFF3F4652);
  static const steel = Color(0xFF8A919D);
  static const silver = Color(0xFFB8BEC9);
  static const silverBright = Color(0xFFF1F3F7);

  // ── Light surfaces ────────────────────────────────────────────────
  static const lightBackground = Color(0xFFFAFBFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceMuted = Color(0xFFF3F4F6);
  static const lightSurfaceElevated = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE5E7EB);
  static const lightBorderStrong = Color(0xFFD1D5DB);
  static const lightForeground = Color(0xFF0F1419);
  static const lightMuted = Color(0xFF6B7280);
  static const lightSubtle = Color(0xFF9CA3AF);

  // ── Dark surfaces ─────────────────────────────────────────────────
  static const darkBackground = graphite900;
  static const darkSurface = graphite850;
  static const darkSurfaceElevated = graphite800;
  static const darkSurfaceHigh = graphite700;
  static const darkBorder = Color(0xFF3F4652);
  static const darkBorderSubtle = Color(0x293F4652);
  static const darkForeground = Color(0xFFF3F4F6);
  static const darkMuted = Color(0xFFB0B8C4);
  static const darkSubtle = Color(0xFF8A919D);

  // ── Semantic ──────────────────────────────────────────────────────
  static const success = Color(0xFF22C55E);
  static const successSoft = Color(0x3322C55E);
  static const warning = Color(0xFFF59E0B);
  static const warningSoft = Color(0x33F59E0B);
  static const danger = Color(0xFFEF4444);
  static const dangerSoft = Color(0x33EF4444);
  static const info = accent;
  static const infoSoft = accentGlow;

  // ── Chart series (ordered, colorblind-aware enough for product UI) ─
  static const chart1 = accent;
  static const chart2 = Color(0xFF34D399);
  static const chart3 = Color(0xFFFBBF24);
  static const chart4 = Color(0xFFA78BFA);
  static const chart5 = Color(0xFFF472B6);
  static const chart6 = Color(0xFF94A3B8);

  static const List<Color> chartSeries = [
    chart1,
    chart2,
    chart3,
    chart4,
    chart5,
    chart6,
  ];
}

/// Resolved palette for a brightness mode.
@immutable
class AfterColorScheme {
  const AfterColorScheme({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceElevated,
    required this.border,
    required this.borderSubtle,
    required this.foreground,
    required this.muted,
    required this.subtle,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
  });

  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceElevated;
  final Color border;
  final Color borderSubtle;
  final Color foreground;
  final Color muted;
  final Color subtle;
  final Color accent;
  final Color onAccent;
  final Color accentSoft;

  bool get isDark => brightness == Brightness.dark;

  static const light = AfterColorScheme(
    brightness: Brightness.light,
    background: AfterColors.lightBackground,
    surface: AfterColors.lightSurface,
    surfaceMuted: AfterColors.lightSurfaceMuted,
    surfaceElevated: AfterColors.lightSurfaceElevated,
    border: AfterColors.lightBorder,
    borderSubtle: AfterColors.lightBorder,
    foreground: AfterColors.lightForeground,
    muted: AfterColors.lightMuted,
    subtle: AfterColors.lightSubtle,
    accent: AfterColors.accentMuted,
    onAccent: Colors.white,
    accentSoft: Color(0x1A0284C7),
  );

  static const dark = AfterColorScheme(
    brightness: Brightness.dark,
    background: AfterColors.darkBackground,
    surface: AfterColors.darkSurface,
    surfaceMuted: AfterColors.graphite800,
    surfaceElevated: AfterColors.darkSurfaceElevated,
    border: AfterColors.darkBorder,
    borderSubtle: AfterColors.darkBorderSubtle,
    foreground: AfterColors.darkForeground,
    muted: AfterColors.darkMuted,
    subtle: AfterColors.darkSubtle,
    accent: AfterColors.accent,
    onAccent: AfterColors.graphite950,
    accentSoft: AfterColors.accentGlow,
  );

  AfterColorScheme copyWith({
    Brightness? brightness,
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceElevated,
    Color? border,
    Color? borderSubtle,
    Color? foreground,
    Color? muted,
    Color? subtle,
    Color? accent,
    Color? onAccent,
    Color? accentSoft,
  }) {
    return AfterColorScheme(
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      foreground: foreground ?? this.foreground,
      muted: muted ?? this.muted,
      subtle: subtle ?? this.subtle,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentSoft: accentSoft ?? this.accentSoft,
    );
  }
}
