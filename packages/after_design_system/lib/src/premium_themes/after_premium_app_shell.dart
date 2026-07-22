import 'package:flutter/material.dart';

import 'after_theme_style.dart';
import 'theme.dart';

/// Builds [PremiumThemeAppShell] for a named [AfterThemeStyle].
abstract final class AfterPremiumAppShell {
  static Widget wrap({
    required AfterThemeStyle style,
    required Widget child,
  }) {
    final (Color bgColor, Widget bg, List<Widget> overlays) = switch (style) {
      AfterThemeStyle.silverGrey => (
          SilverGreyColors.background,
          const SilverGreyAnimatedBackground(),
          const <Widget>[],
        ),
      AfterThemeStyle.forestGreen => (
          SuperGarageColors.forestBackground,
          const WildForestAnimatedBackground(),
          const <Widget>[],
        ),
      AfterThemeStyle.darkNight => (
          DarkNightColors.voidBlack,
          const DarkNightAnimatedBackground(),
          const <Widget>[],
        ),
      AfterThemeStyle.blossomPink => (
          BlossomPinkColors.blushWhite,
          const BlossomAnimatedBackground(),
          const <Widget>[],
        ),
      AfterThemeStyle.diamond => (
          SuperGarageColors.diamondBackground,
          const DiamondUnifiedBackground(),
          const <Widget>[],
        ),
      AfterThemeStyle.brightGold => (
          SuperGarageColors.goldBackground,
          const BrightGoldLuxuryBackground(),
          const <Widget>[BrightGoldDustOverlay()],
        ),
      AfterThemeStyle.royal => (
          SuperGarageColors.royalBackground,
          const RoyalAnimatedBackground(),
          const <Widget>[],
        ),
      _ => (
          Colors.transparent,
          const SizedBox.shrink(),
          const <Widget>[],
        ),
    };

    return PremiumThemeAppShell(
      backgroundColor: bgColor,
      background: bg,
      foregroundOverlays: overlays,
      child: child,
    );
  }
}
