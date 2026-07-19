import 'package:flutter/widgets.dart';

/// 4pt spacing scale (Linear / Apple-adjacent density).
abstract final class AfterSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double massive = 48;
  static const double hero = 64;

  /// Page inset — compact phones.
  static const EdgeInsets pagePaddingCompact = EdgeInsets.fromLTRB(14, 10, 14, 28);

  /// Page inset — default.
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(16, 12, 16, 28);

  /// Page inset — wide.
  static const EdgeInsets pagePaddingWide = EdgeInsets.fromLTRB(20, 12, 20, 28);

  /// Section gap between vertical blocks.
  static const double sectionGap = 16;
  static const double sectionGapCompact = 12;

  /// Content max widths (mirror SuperGarage ResponsiveLayout).
  static const double contentMaxCompact = 520;
  static const double contentMaxDefault = 640;
  static const double contentMaxWide = 760;

  static EdgeInsets pagePaddingForWidth(double width) {
    if (width < 360) return pagePaddingCompact;
    if (width < 420) return pagePadding;
    return pagePaddingWide;
  }

  static double contentMaxWidthFor(double width) {
    if (width < 360) return width;
    if (width < 420) return contentMaxCompact;
    if (width >= 720) return contentMaxWide;
    return contentMaxDefault;
  }

  static double sectionGapForWidth(double width) =>
      width < 420 ? sectionGapCompact : sectionGap;
}
