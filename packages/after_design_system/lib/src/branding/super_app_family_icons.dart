/// Shared Full HD Super App family icons hosted in SuperCore
/// (`after_design_system`).
///
/// Source of truth: `assets/branding/super_app_icons/super_*.svg` (+ `_hd.png`).
/// Apps consume them with `package: 'after_design_system'` — do not fork copies.
library;

/// Canonical file stems for the metallic black family board.
enum SuperAppFamilyIconId {
  garage,
  finance,
  supermarket,
  health,
  home,
  sports,
  news,
  pets,
}

extension SuperAppFamilyIconIdX on SuperAppFamilyIconId {
  /// File stem without prefix (`garage`, `supermarket`, …).
  String get fileStem => name;

  /// Human label for docs / debug.
  String get displayName => switch (this) {
        SuperAppFamilyIconId.garage => 'SuperGarage',
        SuperAppFamilyIconId.finance => 'SuperFinance',
        SuperAppFamilyIconId.supermarket => 'SuperMarket',
        SuperAppFamilyIconId.health => 'SuperHealth',
        SuperAppFamilyIconId.home => 'SuperHome',
        SuperAppFamilyIconId.sports => 'SuperSports',
        SuperAppFamilyIconId.news => 'SuperNews',
        SuperAppFamilyIconId.pets => 'SuperPets',
      };

  /// Flutter package that owns the asset bytes.
  static const packageName = 'after_design_system';
}

/// Asset path helpers for the Super App icon family.
abstract final class SuperAppFamilyIcons {
  static const package = SuperAppFamilyIconIdX.packageName;

  static const all = SuperAppFamilyIconId.values;

  /// Full HD SVG (1920×1920 viewBox, photo-accurate).
  static String svgPath(SuperAppFamilyIconId id) =>
      'assets/branding/super_app_icons/super_${id.fileStem}.svg';

  /// Full HD PNG master (1920×1920).
  static String hdPngPath(SuperAppFamilyIconId id) =>
      'assets/branding/super_app_icons/super_${id.fileStem}_hd.png';

  /// Resolve a family icon from a Flutter package name (`super_garage`, …).
  static SuperAppFamilyIconId? byPackageName(String packageName) {
    return switch (packageName) {
      'super_garage' || 'supergarage' => SuperAppFamilyIconId.garage,
      'super_finance' || 'superfinance' => SuperAppFamilyIconId.finance,
      'super_supermarket' ||
      'supermarket' ||
      'super_retail' ||
      'superretail' =>
        SuperAppFamilyIconId.supermarket,
      'super_health' || 'superhealth' => SuperAppFamilyIconId.health,
      'super_home' || 'superhome' => SuperAppFamilyIconId.home,
      'super_sports' || 'supersports' => SuperAppFamilyIconId.sports,
      'super_news' || 'supernews' => SuperAppFamilyIconId.news,
      'super_pets' || 'super_pet' || 'superpet' => SuperAppFamilyIconId.pets,
      _ => null,
    };
  }
}
