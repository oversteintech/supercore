import 'package:flutter/material.dart';

import 'package:after_core/after_core.dart';

/// Where a membership badge is drawn — affects contrast rules.
enum AfterMembershipBadgeContext {
  /// Settings cards, upgrade sheet, feature tour.
  surface,

  /// Plan-tinted shell header gradient.
  header,
}

/// Membership badge and surface colors — keep header + subscription UI in sync.
///
/// Top-bar / tools-menu headers use saturated tier colors (not pastel washes):
/// Free = grass green, Premium = true silver, Super = real gold,
/// Business = dark emerald.
abstract final class AfterUserPlanColors {
  /// Free — çimen yeşili (grass green).
  static const freeGreen = Color(0xFF4CAF50);
  static const freeGreenDeep = Color(0xFF2E7D32);
  static const freeGreenLight = Color(0xFFC8E6C9);
  static const freeGreenBright = Color(0xFF66BB6A);

  /// Premium / Silver — gerçek gümüş (chrome silver).
  static const premiumSilverBright = Color(0xFFF5F5F5);
  static const premiumSilverMid = Color(0xFFC0C0C0);
  static const premiumSilverDeep = Color(0xFF8E8E93);
  static const premiumSilverLight = Color(0xFFFFFFFF);
  static const premiumSilverShine = Color(0xFFE0E0E0);

  /// Business — koyu zümrüt.
  static const businessTeal = Color(0xFF065F46);
  static const businessNavy = Color(0xFF022C22);
  static const businessEmerald = Color(0xFF047857);
  static const businessEmeraldDark = Color(0xFF064E3B);

  /// Super / Gold — gerçek altın.
  static const superGoldBright = Color(0xFFFFD700);
  static const superGoldMid = Color(0xFFD4AF37);
  static const superGoldDeep = Color(0xFFB8860B);
  static const superGoldLight = Color(0xFFFFEC8B);

  /// Super-admin shell accent — cool purple (distinct from Super gold).
  static const adminPurpleDeep = Color(0xFF4A148C);
  static const adminPurple = Color(0xFF6A1B9A);
  static const adminPurpleBright = Color(0xFF7B1FA2);
  static const adminPurpleLight = Color(0xFFCE93D8);

  static bool usesShiningGold(AfterUserPlan plan) => plan == AfterUserPlan.superPlan;

  static bool usesShiningSilver(AfterUserPlan plan) => plan == AfterUserPlan.premium;

  static Color accent(AfterUserPlan plan) => switch (plan) {
    AfterUserPlan.free => freeGreen,
    AfterUserPlan.premium => premiumSilverMid,
    AfterUserPlan.business => businessEmeraldDark,
    AfterUserPlan.superPlan => superGoldBright,
    AfterUserPlan.superadmin => adminPurpleBright,
  };

  /// Plan accent tuned for the active [ColorScheme] (borders, upsell copy, icons).
  static Color accentOnScheme(AfterUserPlan plan, ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    return switch (plan) {
      AfterUserPlan.free => isDark ? freeGreenBright : freeGreenDeep,
      AfterUserPlan.premium => isDark ? premiumSilverShine : premiumSilverDeep,
      AfterUserPlan.business =>
        isDark ? const Color(0xFF34D399) : businessEmeraldDark,
      AfterUserPlan.superPlan => isDark ? superGoldBright : superGoldDeep,
      AfterUserPlan.superadmin => isDark ? adminPurpleLight : adminPurple,
    };
  }

  static Color borderAccentOnScheme(
    AfterUserPlan plan,
    ColorScheme scheme, {
    bool emphasized = false,
  }) {
    final base = accentOnScheme(plan, scheme);
    if (emphasized) return base;
    final isDark = scheme.brightness == Brightness.dark;
    return base.withValues(alpha: isDark ? 0.62 : 0.48);
  }

  static Color onAccent(AfterUserPlan plan) => switch (plan) {
    AfterUserPlan.superPlan => const Color(0xFF1A1200),
    AfterUserPlan.superadmin => Colors.white,
    AfterUserPlan.premium => const Color(0xFF1F2937),
    AfterUserPlan.free => Colors.white,
    _ => Colors.white,
  };

  static IconData badgeIcon(AfterUserPlan plan) => switch (plan) {
    AfterUserPlan.free => Icons.garage_outlined,
    AfterUserPlan.premium => Icons.workspace_premium_rounded,
    AfterUserPlan.business => Icons.business_center_rounded,
    AfterUserPlan.superPlan => Icons.military_tech_rounded,
    AfterUserPlan.superadmin => Icons.verified_rounded,
  };

  /// App title in shell header — plan accent.
  static Color title(AfterUserPlan plan, ColorScheme scheme) => accent(plan);

  static Color headerBackground(AfterUserPlan plan, ColorScheme scheme) {
    return switch (plan) {
      AfterUserPlan.free => freeGreen,
      AfterUserPlan.premium => premiumSilverMid,
      AfterUserPlan.superPlan => superGoldBright,
      AfterUserPlan.superadmin => adminPurple,
      AfterUserPlan.business => businessEmeraldDark,
    };
  }

  static Color headerForeground(AfterUserPlan plan, Brightness brightness) {
    return switch (plan) {
      AfterUserPlan.business || AfterUserPlan.superadmin || AfterUserPlan.free => Colors.white,
      AfterUserPlan.superPlan => const Color(0xFF1A1200),
      AfterUserPlan.premium => const Color(0xFF1F2937),
    };
  }

  /// Notification bell on the shell header.
  /// Gold tier → black (contrast on gold chrome); all other tiers → gold yellow.
  static Color headerNotificationIcon(AfterUserPlan plan) => switch (plan) {
        AfterUserPlan.superPlan => const Color(0xFF1A1200),
        _ => superGoldBright,
      };

  /// Location pin (+ label) on the shell header.
  /// Free / Business → white (contrast on green/emerald chrome); otherwise black.
  static Color headerLocationIcon(AfterUserPlan plan) => switch (plan) {
        AfterUserPlan.free || AfterUserPlan.business => Colors.white,
        _ => const Color(0xFF111111),
      };

  /// Static badge colors on the plan-colored header (no shiny sweep on same tint).
  static Color headerBadgeIcon(AfterUserPlan plan, Brightness brightness) {
    return switch (plan) {
      AfterUserPlan.superadmin => adminPurpleLight,
      _ => headerForeground(plan, brightness),
    };
  }

  static Color headerBadgeText(AfterUserPlan plan, Brightness brightness) =>
      headerForeground(plan, brightness);

  static BoxDecoration headerDecoration(AfterUserPlan plan, Brightness brightness) {
    return switch (plan) {
      AfterUserPlan.free => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: brightness == Brightness.light
              ? const [
                  Color(0xFF66BB6A),
                  freeGreen,
                  Color(0xFF388E3C),
                  freeGreenDeep,
                ]
              : const [
                  Color(0xFF1B5E20),
                  freeGreenDeep,
                  Color(0xFF1B3A1F),
                  Color(0xFF0D2818),
                ],
          stops: const [0.0, 0.35, 0.7, 1.0],
        ),
      ),
      AfterUserPlan.premium => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: brightness == Brightness.light
              ? const [
                  Color(0xFFFFFFFF),
                  premiumSilverShine,
                  premiumSilverMid,
                  premiumSilverDeep,
                ]
              : const [
                  Color(0xFFB0B0B5),
                  Color(0xFF8E8E93),
                  Color(0xFF6E6E73),
                  Color(0xFF48484A),
                ],
          stops: const [0.0, 0.3, 0.65, 1.0],
        ),
      ),
      AfterUserPlan.superPlan => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: brightness == Brightness.light
              ? const [
                  superGoldLight,
                  superGoldBright,
                  superGoldMid,
                  superGoldDeep,
                ]
              : const [
                  Color(0xFFE6C200),
                  superGoldMid,
                  superGoldDeep,
                  Color(0xFF7A5A00),
                ],
          stops: const [0.0, 0.3, 0.65, 1.0],
        ),
      ),
      AfterUserPlan.superadmin => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7B1FA2),
            adminPurple,
            adminPurpleDeep,
            Color(0xFF311B92),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      ),
      AfterUserPlan.business => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            businessEmerald,
            businessEmeraldDark,
            businessTeal,
            businessNavy,
          ],
          stops: [0.0, 0.4, 0.75, 1.0],
        ),
      ),
    };
  }

  static Color tileBackground(AfterUserPlan plan, ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final tintAlpha = isDark ? 0.22 : 0.11;
    final tint = switch (plan) {
      AfterUserPlan.superPlan => superGoldBright.withValues(alpha: tintAlpha),
      AfterUserPlan.superadmin => adminPurple.withValues(alpha: tintAlpha),
      AfterUserPlan.premium =>
        (isDark ? premiumSilverShine : premiumSilverMid).withValues(
          alpha: tintAlpha,
        ),
      AfterUserPlan.business =>
        (isDark ? const Color(0xFF34D399) : businessEmerald).withValues(
          alpha: tintAlpha,
        ),
      _ => accent(plan).withValues(alpha: tintAlpha * 0.95),
    };
    final base = isDark ? scheme.surfaceContainer : scheme.surfaceContainerLow;
    return Color.alphaBlend(tint, base);
  }

  static String compactBadgeLabel(AfterUserPlan plan) =>
      AfterMembershipBadge.forPlan(plan);
}
