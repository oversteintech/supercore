import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'radius.dart';
import 'typography.dart';

/// Theme extension carrying After tokens into [ThemeData].
@immutable
class AfterTheme extends ThemeExtension<AfterTheme> {
  const AfterTheme({
    required this.colors,
    required this.typography,
  });

  final AfterColorScheme colors;
  final AfterTypography typography;

  static AfterTheme light({AfterTypography typography = const AfterTypography()}) =>
      AfterTheme(colors: AfterColorScheme.light, typography: typography);

  static AfterTheme dark({AfterTypography typography = const AfterTypography()}) =>
      AfterTheme(colors: AfterColorScheme.dark, typography: typography);

  @override
  AfterTheme copyWith({
    AfterColorScheme? colors,
    AfterTypography? typography,
  }) {
    return AfterTheme(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
    );
  }

  @override
  AfterTheme lerp(ThemeExtension<AfterTheme>? other, double t) {
    if (other is! AfterTheme) return this;
    return t < 0.5 ? this : other;
  }
}

extension AfterThemeContext on BuildContext {
  AfterTheme get afterTheme =>
      Theme.of(this).extension<AfterTheme>() ?? AfterTheme.light();

  AfterColorScheme get afterColors => afterTheme.colors;

  AfterTypography get afterTypography => afterTheme.typography;
}

/// Builds Material 3 [ThemeData] wired to After tokens.
abstract final class AfterThemeData {
  static ThemeData light({
    AfterTypography typography = const AfterTypography(),
    Color? accentOverride,
  }) {
    return _build(
      scheme: AfterColorScheme.light.copyWith(
        accent: accentOverride,
      ),
      typography: typography,
    );
  }

  static ThemeData dark({
    AfterTypography typography = const AfterTypography(),
    Color? accentOverride,
  }) {
    return _build(
      scheme: AfterColorScheme.dark.copyWith(
        accent: accentOverride,
      ),
      typography: typography,
    );
  }

  static ThemeData _build({
    required AfterColorScheme scheme,
    required AfterTypography typography,
  }) {
    final colorScheme = ColorScheme(
      brightness: scheme.brightness,
      primary: scheme.accent,
      onPrimary: scheme.onAccent,
      secondary: AfterColors.steel,
      onSecondary: scheme.brightness == Brightness.dark
          ? AfterColors.graphite950
          : Colors.white,
      surface: scheme.surface,
      onSurface: scheme.foreground,
      error: AfterColors.danger,
      onError: Colors.white,
      outline: scheme.border,
      outlineVariant: scheme.borderSubtle,
      surfaceContainerHighest: scheme.surfaceMuted,
    );

    final textTheme = typography.toTextTheme(
      foreground: scheme.foreground,
      muted: scheme.muted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scheme.background,
      canvasColor: scheme.background,
      dividerColor: scheme.borderSubtle,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      extensions: [AfterTheme(colors: scheme, typography: typography)],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: scheme.background.withValues(alpha: 0.92),
        foregroundColor: scheme.foreground,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: typography.titleMedium.copyWith(color: scheme.foreground),
        systemOverlayStyle: scheme.isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AfterRadius.mdAll,
          side: BorderSide(color: scheme.border.withValues(alpha: 0.85)),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AfterRadius.lgAll),
        titleTextStyle: typography.titleLarge.copyWith(color: scheme.foreground),
        contentTextStyle: typography.bodyMedium.copyWith(color: scheme.muted),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AfterRadius.lg)),
        ),
        showDragHandle: true,
        dragHandleColor: scheme.subtle,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AfterRadius.smAll,
          borderSide: BorderSide(color: scheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AfterRadius.smAll,
          borderSide: BorderSide(color: scheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AfterRadius.smAll,
          borderSide: BorderSide(color: scheme.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AfterRadius.smAll,
          borderSide: const BorderSide(color: AfterColors.danger),
        ),
        hintStyle: typography.bodyMedium.copyWith(color: scheme.subtle),
        labelStyle: typography.labelMedium.copyWith(color: scheme.muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: scheme.accent,
          foregroundColor: scheme.onAccent,
          disabledBackgroundColor: scheme.border,
          disabledForegroundColor: scheme.subtle,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AfterRadius.smAll),
          textStyle: typography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.foreground,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: BorderSide(color: scheme.border),
          shape: RoundedRectangleBorder(borderRadius: AfterRadius.smAll),
          textStyle: typography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.accent,
          textStyle: typography.labelLarge,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: scheme.surface.withValues(alpha: 0.94),
        indicatorColor: scheme.accentSoft,
        labelTextStyle: WidgetStatePropertyAll(
          typography.labelSmall.copyWith(color: scheme.muted),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? scheme.accent : scheme.muted,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.surfaceElevated,
        contentTextStyle: typography.bodyMedium.copyWith(color: scheme.foreground),
        shape: RoundedRectangleBorder(borderRadius: AfterRadius.smAll),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.accent,
        linearTrackColor: scheme.border,
        circularTrackColor: scheme.border,
      ),
    );
  }
}
