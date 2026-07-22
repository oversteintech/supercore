import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';

/// Tier-aware membership badge for header, settings, and upgrade UI.
class FamilyMembershipPlanBadge extends StatelessWidget {
  const FamilyMembershipPlanBadge({
    required this.plan,
    required this.label,
    this.pill = true,
    this.fontSize = 12,
    this.showIcon = true,
    this.displayContext = AfterMembershipBadgeContext.surface,
    super.key,
  });

  final AfterUserPlan plan;
  final String label;
  final bool pill;
  final double fontSize;
  final bool showIcon;
  final AfterMembershipBadgeContext displayContext;

  @override
  Widget build(BuildContext context) {
    if (displayContext == AfterMembershipBadgeContext.header) {
      return switch (plan) {
        AfterUserPlan.premium => AnimatedPremiumMembershipBadge(
          label: label,
          fontSize: fontSize,
          letterSpacing: 0.35,
          pill: false,
          showIcon: showIcon,
        ),
        AfterUserPlan.superPlan => AnimatedSuperMembershipBadge(
          label: label,
          fontSize: fontSize,
          letterSpacing: 0.35,
          pill: false,
          showIcon: showIcon,
          darkHeaderText: true,
        ),
        AfterUserPlan.superadmin => AnimatedSuperMembershipBadge(
          label: label,
          fontSize: fontSize,
          letterSpacing: 0.35,
          pill: false,
          showIcon: showIcon,
        ),
        AfterUserPlan.business => AnimatedBusinessMembershipBadge(
          label: label,
          fontSize: fontSize,
          letterSpacing: 0.35,
          pill: false,
          showIcon: showIcon,
        ),
        AfterUserPlan.free => AnimatedFreeMembershipBadge(
          label: label,
          fontSize: fontSize,
          letterSpacing: 0.35,
          pill: false,
          showIcon: showIcon,
          // Grass-green header needs light type, not green-on-green.
          lightOnHeader: true,
        ),
      };
    }

    return switch (plan) {
      AfterUserPlan.free => _FreeMembershipBadge(
        label: label,
        fontSize: fontSize,
        pill: pill,
        showIcon: showIcon,
      ),
      AfterUserPlan.premium => AnimatedPremiumMembershipBadge(
        label: label,
        fontSize: fontSize,
        letterSpacing: pill ? 0.2 : 0.35,
        pill: pill,
        showIcon: showIcon,
      ),
      AfterUserPlan.business => _BusinessMembershipBadge(
        label: label,
        fontSize: fontSize,
        pill: pill,
        showIcon: showIcon,
      ),
      AfterUserPlan.superPlan => AnimatedSuperMembershipBadge(
        label: label,
        fontSize: fontSize,
        letterSpacing: pill ? 0.2 : 0.35,
        pill: pill,
        showIcon: showIcon,
      ),
      AfterUserPlan.superadmin => _SuperAdminMembershipBadge(
        label: label,
        fontSize: fontSize,
        pill: pill,
        showIcon: showIcon,
      ),
    };
  }
}

/// Shining silver sweep for Premium plan.
class AnimatedPremiumMembershipBadge extends StatefulWidget {
  const AnimatedPremiumMembershipBadge({
    required this.label,
    this.fontSize = 11,
    this.letterSpacing = 0.35,
    this.fontWeight = FontWeight.w800,
    this.pill = false,
    this.showIcon = true,
    super.key,
  });

  final String label;
  final double fontSize;
  final double letterSpacing;
  final FontWeight fontWeight;
  final bool pill;
  final bool showIcon;

  @override
  State<AnimatedPremiumMembershipBadge> createState() =>
      _AnimatedPremiumMembershipBadgeState();
}

class _AnimatedPremiumMembershipBadgeState
    extends State<AnimatedPremiumMembershipBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = (math.sin(_controller.value * math.pi * 2) + 1) / 2;
        final label = widget.label.toUpperCase();
        final headerMode = !widget.pill;
        final sweepColors = headerMode
            ? const [
                AfterUserPlanColors.premiumSilverDeep,
                Color(0xFF374151),
                Color(0xFF1F2937),
                Color(0xFF111827),
                Color(0xFF1F2937),
                Color(0xFF374151),
                AfterUserPlanColors.premiumSilverDeep,
              ]
            : const [
                AfterUserPlanColors.premiumSilverDeep,
                AfterUserPlanColors.premiumSilverMid,
                AfterUserPlanColors.premiumSilverBright,
                AfterUserPlanColors.premiumSilverLight,
                AfterUserPlanColors.premiumSilverBright,
                AfterUserPlanColors.premiumSilverMid,
                AfterUserPlanColors.premiumSilverDeep,
              ];

        final text = ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return SweepGradient(
              center: Alignment.center,
              colors: sweepColors,
              transform: GradientRotation(_controller.value * math.pi * 2),
            ).createShader(bounds);
          },
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: headerMode ? Colors.black : Colors.white,
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              letterSpacing: widget.letterSpacing,
              shadows: [
                Shadow(
                  color: AfterUserPlanColors.premiumSilverMid.withValues(
                    alpha: 0.24 + pulse * 0.34,
                  ),
                  blurRadius: 6 + pulse * 8,
                ),
              ],
            ),
          ),
        );

        if (!widget.pill) {
          return text;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AfterUserPlanColors.premiumSilverBright.withValues(
                  alpha: 0.18 + pulse * 0.08,
                ),
                AfterUserPlanColors.premiumSilverMid.withValues(
                  alpha: 0.12 + pulse * 0.06,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AfterUserPlanColors.premiumSilverMid.withValues(
                alpha: 0.42 + pulse * 0.24,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AfterUserPlanColors.premiumSilverMid.withValues(
                  alpha: 0.16 + pulse * 0.18,
                ),
                blurRadius: 8 + pulse * 6,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showIcon) ...[
                Icon(
                  AfterUserPlanColors.badgeIcon(AfterUserPlan.premium),
                  size: widget.fontSize + 2,
                  color: AfterUserPlanColors.premiumSilverDeep,
                ),
                const SizedBox(width: 5),
              ],
              text,
            ],
          ),
        );
      },
    );
  }
}

/// Shining gold sweep for Super plan.
class AnimatedSuperMembershipBadge extends StatefulWidget {
  const AnimatedSuperMembershipBadge({
    required this.label,
    this.fontSize = 11,
    this.letterSpacing = 0.35,
    this.fontWeight = FontWeight.w800,
    this.pill = false,
    this.showIcon = true,
    this.darkHeaderText = false,
    super.key,
  });

  final String label;
  final double fontSize;
  final double letterSpacing;
  final FontWeight fontWeight;
  final bool pill;
  final bool showIcon;
  final bool darkHeaderText;

  @override
  State<AnimatedSuperMembershipBadge> createState() =>
      _AnimatedSuperMembershipBadgeState();
}

class _AnimatedSuperMembershipBadgeState
    extends State<AnimatedSuperMembershipBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = (math.sin(_controller.value * math.pi * 2) + 1) / 2;
        final label = widget.label.toUpperCase();
        final headerMode = widget.darkHeaderText && !widget.pill;
        final sweepColors = headerMode
            ? const [
                AfterUserPlanColors.superGoldDeep,
                Color(0xFF5C4A00),
                Color(0xFF1F2937),
                Color(0xFF111827),
                Color(0xFF1F2937),
                Color(0xFF5C4A00),
                AfterUserPlanColors.superGoldDeep,
              ]
            : const [
                AfterUserPlanColors.superGoldDeep,
                AfterUserPlanColors.superGoldMid,
                AfterUserPlanColors.superGoldBright,
                AfterUserPlanColors.superGoldLight,
                AfterUserPlanColors.superGoldBright,
                AfterUserPlanColors.superGoldMid,
                AfterUserPlanColors.superGoldDeep,
              ];

        final text = ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return SweepGradient(
              center: Alignment.center,
              colors: sweepColors,
              transform: GradientRotation(_controller.value * math.pi * 2),
            ).createShader(bounds);
          },
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: headerMode ? Colors.black : Colors.white,
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              letterSpacing: widget.letterSpacing,
              shadows: [
                Shadow(
                  color: AfterUserPlanColors.superGoldBright.withValues(
                    alpha: 0.28 + pulse * 0.42,
                  ),
                  blurRadius: 8 + pulse * 10,
                ),
              ],
            ),
          ),
        );

        if (!widget.pill) {
          return text;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AfterUserPlanColors.superGoldBright.withValues(
                  alpha: 0.16 + pulse * 0.08,
                ),
                AfterUserPlanColors.superGoldMid.withValues(
                  alpha: 0.12 + pulse * 0.06,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AfterUserPlanColors.superGoldBright.withValues(
                alpha: 0.42 + pulse * 0.28,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AfterUserPlanColors.superGoldBright.withValues(
                  alpha: 0.18 + pulse * 0.22,
                ),
                blurRadius: 10 + pulse * 8,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showIcon) ...[
                Icon(
                  AfterUserPlanColors.badgeIcon(AfterUserPlan.superPlan),
                  size: widget.fontSize + 2,
                  color: AfterUserPlanColors.superGoldDeep,
                ),
                const SizedBox(width: 5),
              ],
              text,
            ],
          ),
        );
      },
    );
  }
}

/// Shining green sweep for Free plan (header).
class AnimatedFreeMembershipBadge extends StatefulWidget {
  const AnimatedFreeMembershipBadge({
    required this.label,
    this.fontSize = 11,
    this.letterSpacing = 0.35,
    this.fontWeight = FontWeight.w800,
    this.pill = false,
    this.showIcon = true,
    this.lightOnHeader = false,
    super.key,
  });

  final String label;
  final double fontSize;
  final double letterSpacing;
  final FontWeight fontWeight;
  final bool pill;
  final bool showIcon;

  /// When true (top-bar grass green), use light shimmer for contrast.
  final bool lightOnHeader;

  @override
  State<AnimatedFreeMembershipBadge> createState() =>
      _AnimatedFreeMembershipBadgeState();
}

class _AnimatedFreeMembershipBadgeState
    extends State<AnimatedFreeMembershipBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = widget.lightOnHeader
        ? const [
            Color(0xFFE8F5E9),
            Colors.white,
            Color(0xFFC8E6C9),
            Colors.white,
            Color(0xFFE8F5E9),
          ]
        : isDark
        ? const [
            Color(0xFF1B5E20),
            AfterUserPlanColors.freeGreen,
            AfterUserPlanColors.freeGreenBright,
            Color(0xFFE8F5E9),
            AfterUserPlanColors.freeGreenBright,
            AfterUserPlanColors.freeGreen,
            Color(0xFF1B5E20),
          ]
        : const [
            AfterUserPlanColors.freeGreenDeep,
            AfterUserPlanColors.freeGreen,
            AfterUserPlanColors.freeGreenBright,
            AfterUserPlanColors.freeGreenLight,
            AfterUserPlanColors.freeGreenBright,
            AfterUserPlanColors.freeGreen,
            AfterUserPlanColors.freeGreenDeep,
          ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = (math.sin(_controller.value * math.pi * 2) + 1) / 2;
        final label = widget.label.toUpperCase();
        final text = ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return SweepGradient(
              center: Alignment.center,
              colors: colors,
              transform: GradientRotation(_controller.value * math.pi * 2),
            ).createShader(bounds);
          },
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              letterSpacing: widget.letterSpacing,
              shadows: [
                Shadow(
                  color:
                      (widget.lightOnHeader
                              ? Colors.black
                              : AfterUserPlanColors.freeGreen)
                          .withValues(alpha: 0.2 + pulse * 0.3),
                  blurRadius: 6 + pulse * 8,
                ),
              ],
            ),
          ),
        );

        if (!widget.pill) {
          return text;
        }

        return _FreeMembershipBadge(
          label: label,
          fontSize: widget.fontSize,
          pill: true,
          showIcon: widget.showIcon,
        );
      },
    );
  }
}

/// Shining teal sweep for Business plan (header).
class AnimatedBusinessMembershipBadge extends StatefulWidget {
  const AnimatedBusinessMembershipBadge({
    required this.label,
    this.fontSize = 11,
    this.letterSpacing = 0.35,
    this.fontWeight = FontWeight.w900,
    this.pill = false,
    this.showIcon = true,
    super.key,
  });

  final String label;
  final double fontSize;
  final double letterSpacing;
  final FontWeight fontWeight;
  final bool pill;
  final bool showIcon;

  @override
  State<AnimatedBusinessMembershipBadge> createState() =>
      _AnimatedBusinessMembershipBadgeState();
}

class _AnimatedBusinessMembershipBadgeState
    extends State<AnimatedBusinessMembershipBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark
        ? const [
            AfterUserPlanColors.businessEmeraldDark,
            AfterUserPlanColors.businessEmerald,
            Color(0xFF6EE7B7),
            Colors.white,
            Color(0xFF6EE7B7),
            AfterUserPlanColors.businessEmerald,
            AfterUserPlanColors.businessEmeraldDark,
          ]
        : const [
            AfterUserPlanColors.businessNavy,
            AfterUserPlanColors.businessTeal,
            AfterUserPlanColors.businessEmerald,
            Color(0xFF6EE7B7),
            AfterUserPlanColors.businessEmerald,
            AfterUserPlanColors.businessTeal,
            AfterUserPlanColors.businessNavy,
          ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = (math.sin(_controller.value * math.pi * 2) + 1) / 2;
        final label = widget.label.toUpperCase();
        final text = ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return SweepGradient(
              center: Alignment.center,
              colors: colors,
              transform: GradientRotation(_controller.value * math.pi * 2),
            ).createShader(bounds);
          },
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              letterSpacing: widget.letterSpacing,
              shadows: [
                Shadow(
                  color: AfterUserPlanColors.businessTeal.withValues(
                    alpha: 0.22 + pulse * 0.34,
                  ),
                  blurRadius: 6 + pulse * 8,
                ),
              ],
            ),
          ),
        );

        if (!widget.pill) {
          return text;
        }

        return _BusinessMembershipBadge(
          label: label,
          fontSize: widget.fontSize,
          pill: true,
          showIcon: widget.showIcon,
        );
      },
    );
  }
}

class _FreeMembershipBadge extends StatelessWidget {
  const _FreeMembershipBadge({
    required this.label,
    required this.fontSize,
    required this.pill,
    this.showIcon = true,
  });

  final String label;
  final double fontSize;
  final bool pill;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? AfterUserPlanColors.freeGreenBright
        : AfterUserPlanColors.freeGreen;
    final border = isDark
        ? AfterUserPlanColors.freeGreen
        : AfterUserPlanColors.freeGreenDeep;
    final text = label.toUpperCase();

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Icon(
            AfterUserPlanColors.badgeIcon(AfterUserPlan.free),
            size: fontSize + 2,
            color: color,
          ),
          const SizedBox(width: 5),
        ],
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.35,
            color: color,
          ),
        ),
      ],
    );

    if (!pill) {
      return content;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border.withValues(alpha: 0.35)),
      ),
      child: content,
    );
  }
}

class _BusinessMembershipBadge extends StatelessWidget {
  const _BusinessMembershipBadge({
    required this.label,
    required this.fontSize,
    required this.pill,
    this.showIcon = true,
  });

  final String label;
  final double fontSize;
  final bool pill;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? const Color(0xFF5EEAD4)
        : AfterUserPlanColors.businessTeal;
    final accent = isDark
        ? const Color(0xFF047857)
        : AfterUserPlanColors.businessNavy;
    final text = label.toUpperCase();

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Icon(
            AfterUserPlanColors.badgeIcon(AfterUserPlan.business),
            size: fontSize + 3,
            color: color,
          ),
          const SizedBox(width: 5),
        ],
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.45,
            color: color,
          ),
        ),
      ],
    );

    if (!pill) {
      return content;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.2),
      ),
      child: content,
    );
  }
}

class _SuperAdminMembershipBadge extends StatelessWidget {
  const _SuperAdminMembershipBadge({
    required this.label,
    required this.fontSize,
    required this.pill,
    this.showIcon = true,
  });

  final String label;
  final double fontSize;
  final bool pill;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return AnimatedSuperMembershipBadge(
      label: label,
      fontSize: fontSize,
      letterSpacing: pill ? 0.2 : 0.35,
      pill: pill,
      showIcon: showIcon,
    );
  }
}
