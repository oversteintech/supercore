/// Semantic elevation levels (paired with [AfterShadows]).
abstract final class AfterElevations {
  /// Flat on-surface (hairline border only).
  static const double level0 = 0;

  /// Raised card / popover.
  static const double level1 = 1;

  /// Floating action / sticky bar.
  static const double level2 = 2;

  /// Modal dialog.
  static const double level3 = 3;

  /// Toast / critical overlay.
  static const double level4 = 4;
}
