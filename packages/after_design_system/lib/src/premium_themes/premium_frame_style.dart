/// Intensity for premium theme border/sweep frames.
///
/// Use [menu] on major shell chrome only (header, bottom nav, tab title bars).
/// Keep [soft] for routine cards and [showcase] for dashboard heroes / hub CTAs.
/// Speeds stay slow so motion reads as premium atmosphere, not decoration noise.
enum PremiumFrameStyle {
  /// Whisper-level, very slow — major menus / shell chrome only.
  menu,

  /// Mild, slow card frame (default when a theme frames surfaces).
  soft,

  /// Noticeable but still calm — garage hub / hero showcases.
  showcase,
}

extension PremiumFrameStyleX on PremiumFrameStyle {
  bool get isMenu => this == PremiumFrameStyle.menu;
  bool get isShowcase => this == PremiumFrameStyle.showcase;

  /// Maps legacy `prominent` flag used across ShowcaseFrame widgets.
  static PremiumFrameStyle fromProminent(bool prominent) {
    return prominent ? PremiumFrameStyle.showcase : PremiumFrameStyle.soft;
  }

  /// Border rotation period. Faster themes slow down; already-slow themes stay calm.
  int borderMs({
    required int showcaseMs,
    required int softMs,
    required int menuMs,
  }) {
    return switch (this) {
      PremiumFrameStyle.menu => menuMs,
      PremiumFrameStyle.soft => softMs,
      PremiumFrameStyle.showcase => showcaseMs,
    };
  }

  /// 0–1 multiplier for glow / blur / pad extras (menu is lightest).
  double get glowScale => switch (this) {
    PremiumFrameStyle.menu => 0.42,
    PremiumFrameStyle.soft => 0.72,
    PremiumFrameStyle.showcase => 1.0,
  };

  double get padExtra => switch (this) {
    PremiumFrameStyle.menu => 0.0,
    PremiumFrameStyle.soft => 0.4,
    PremiumFrameStyle.showcase => 1.0,
  };
}
