import 'package:flutter/material.dart';

import 'dark_night_theme.dart';
import 'blossom_pink.dart';
import 'racing_theme_effects.dart';
import 'safari_savanna.dart';
import 'silver_grey.dart';
import 'theme.dart';

/// Disables premium theme motion overlays for focused workflows (forms, signing).
ThemeData themeWithoutDecorativeMotion(ThemeData theme) {
  final updated = theme.extensions.values
      .map(_disableDecorativeMotion)
      .toList(growable: false);
  return theme.copyWith(extensions: updated);
}

ThemeExtension<dynamic> _disableDecorativeMotion(ThemeExtension<dynamic> ext) {
  if (ext is DiamondThemeEffects) {
    return ext.copyWith(enabled: false);
  }
  if (ext is BrightGoldThemeEffects) {
    return ext.copyWith(enabled: false);
  }
  if (ext is DarkNightThemeEffects) {
    return ext.copyWith(enabled: false);
  }
  if (ext is SafariSavannaThemeEffects) {
    return ext.copyWith(enabled: false);
  }
  if (ext is BlossomPinkThemeEffects) {
    return ext.copyWith(enabled: false);
  }
  if (ext is SilverGreyThemeEffects) {
    return ext.copyWith(enabled: false);
  }
  if (ext is RacingThemeEffects) {
    return ext.copyWith(red: false, blue: false);
  }
  return ext;
}

/// Opaque, animation-free shell for document workflows above animated theme layers.
class ThemeStaticScope extends StatelessWidget {
  const ThemeStaticScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final staticTheme = themeWithoutDecorativeMotion(Theme.of(context));
    return Theme(
      data: staticTheme,
      child: ColoredBox(
        color: staticTheme.colorScheme.surface,
        child: child,
      ),
    );
  }
}

/// Route with no enter/exit transition.
class InstantMaterialPageRoute<T> extends PageRouteBuilder<T> {
  InstantMaterialPageRoute({
    required WidgetBuilder builder,
    super.settings,
    super.fullscreenDialog,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) =>
             builder(context),
         transitionDuration: Duration.zero,
         reverseTransitionDuration: Duration.zero,
       );
}
