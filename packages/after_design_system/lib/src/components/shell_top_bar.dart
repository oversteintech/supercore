import 'dart:math' as math;

import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';

import '../membership/after_user_plan_colors.dart';

/// Shared MainShell top bar for every Super App.
///
/// Layout (single source of truth):
/// ```
/// [ membership ]              App title              [ 🔔  👤 ]
/// ```
/// Left: membership text, vertically aligned with the centered app title.
/// Right: notifications + animated profile avatar (AI lives on the bottom tab).
class AfterShellTopBar extends StatelessWidget {
  const AfterShellTopBar({
    super.key,
    this.plan = AfterUserPlan.free,
    this.title,
    this.membershipLabel,
    this.membershipBadge,
    this.notificationUnreadCount = 0,
    this.onNotifications,
    this.profileAction,
    this.notificationsTooltip = 'Notifications',
    @Deprecated('Location removed from shell top bar; ignored.')
    String? locationLabel,
    @Deprecated('Location removed from shell top bar; ignored.')
    VoidCallback? onLocationTap,
    @Deprecated('Location removed from shell top bar; ignored.')
    this.locationTooltip = 'Location',
    @Deprecated('AI moved to the bottom tab; ignored.') VoidCallback? onAi,
  });

  /// Plan tint for header chrome + default badge label.
  final AfterUserPlan plan;

  /// Short product title (e.g. Garage / Health / Airport) — centered.
  final String? title;

  /// Membership text (FREE / SILVER / GOLD / …). Ignored when [membershipBadge]
  /// is provided.
  final String? membershipLabel;

  /// Optional custom badge widget (animated family badges, etc.).
  final Widget? membershipBadge;

  final int notificationUnreadCount;
  final VoidCallback? onNotifications;

  /// Trailing profile control (animated avatar). Replaces the former AI mark.
  final Widget? profileAction;
  final String locationTooltip;
  final String notificationsTooltip;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final fg = AfterUserPlanColors.headerForeground(plan, brightness);
    const titleColor = Colors.white;
    final notificationColor = AfterUserPlanColors.headerNotificationIcon(plan);
    final resolvedTitle = title?.trim();
    final resolvedLabel =
        (membershipLabel ?? AfterMembershipBadge.forPlan(plan)).trim();
    final hasTitle = resolvedTitle != null && resolvedTitle.isNotEmpty;
    final hasMembership = membershipBadge != null || resolvedLabel.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: AfterUserPlanColors.headerDecoration(plan, brightness),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 6, 6),
          child: SizedBox(
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _MembershipLabel(
                          membershipBadge: membershipBadge,
                          membershipLabel:
                              hasMembership && membershipBadge == null
                                  ? resolvedLabel.toUpperCase()
                                  : null,
                          membershipColor: fg,
                        ),
                      ),
                    ),
                    const SizedBox(width: 88),
                  ],
                ),
                if (hasTitle)
                  IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 72),
                      child: Text(
                        resolvedTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: titleColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: notificationsTooltip,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        onPressed: onNotifications,
                        icon: Badge(
                          isLabelVisible: notificationUnreadCount > 0,
                          label: Text(
                            notificationUnreadCount > 9
                                ? '9+'
                                : '$notificationUnreadCount',
                          ),
                          child: Icon(
                            Icons.notifications_rounded,
                            color: notificationColor,
                          ),
                        ),
                      ),
                      if (profileAction != null) profileAction!,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MembershipLabel extends StatelessWidget {
  const _MembershipLabel({
    required this.membershipColor,
    this.membershipBadge,
    this.membershipLabel,
  });

  final Widget? membershipBadge;
  final String? membershipLabel;
  final Color membershipColor;

  @override
  Widget build(BuildContext context) {
    final maxLeft = MediaQuery.sizeOf(context).width * 0.36;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxLeft),
      child: Align(
        alignment: Alignment.centerLeft,
        child: membershipBadge ??
            (membershipLabel != null && membershipLabel!.isNotEmpty
                ? Text(
                    membershipLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: membershipColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.45,
                      height: 1.1,
                    ),
                  )
                : const SizedBox.shrink()),
      ),
    );
  }
}

/// Soft pulse AI mark — Garage hub ([Icons.hub_rounded]) with a rotating
/// spectrum sweep so the shell AI affordance stays colorful on every plan.
class AfterAnimatedAiIcon extends StatefulWidget {
  const AfterAnimatedAiIcon({
    this.color,
    this.size = 24,
    this.locked = false,
    super.key,
  });

  /// When set, forces a solid tint (tests / locked fallbacks). Null = spectrum.
  final Color? color;
  final double size;
  final bool locked;

  static const _spectrum = [
    Color(0xFF7C3AED),
    Color(0xFF2563EB),
    Color(0xFF0891B2),
    Color(0xFF059669),
    Color(0xFFD97706),
    Color(0xFFDB2777),
    Color(0xFF7C3AED),
  ];

  @override
  State<AfterAnimatedAiIcon> createState() => _AfterAnimatedAiIconState();
}

class _AfterAnimatedAiIconState extends State<AfterAnimatedAiIcon>
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

  Color _spectrumColor(double t) {
    final colors = AfterAnimatedAiIcon._spectrum;
    final scaled = (t % 1) * (colors.length - 1);
    final index = scaled.floor().clamp(0, colors.length - 2);
    final blend = scaled - index;
    return Color.lerp(colors[index], colors[index + 1], blend)!;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final pulse = 0.94 + 0.06 * math.sin(t * math.pi * 2);
        final orbit = t * math.pi * 2;
        final radius = widget.size * 0.38;
        final fixed = widget.color;
        final accent = fixed ?? _spectrumColor(t);
        final accentAlt = fixed ?? _spectrumColor(t + 0.33);
        return SizedBox(
          width: widget.size + 10,
          height: widget.size + 10,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                Transform.translate(
                  offset: Offset(
                    math.cos(orbit + i * 2 * math.pi / 3) * radius,
                    math.sin(orbit + i * 2 * math.pi / 3) * radius,
                  ),
                  child: Container(
                    width: 3.5,
                    height: 3.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i.isEven ? accent : accentAlt,
                      boxShadow: [
                        BoxShadow(
                          color: (i.isEven ? accent : accentAlt)
                              .withValues(alpha: 0.45),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              Transform.scale(
                scale: pulse,
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) {
                    if (fixed != null) {
                      return LinearGradient(
                        colors: [fixed, fixed],
                      ).createShader(bounds);
                    }
                    return SweepGradient(
                      colors: AfterAnimatedAiIcon._spectrum,
                      transform: GradientRotation(orbit),
                    ).createShader(bounds);
                  },
                  child: Icon(
                    Icons.hub_rounded,
                    color: Colors.white,
                    size: widget.size,
                  ),
                ),
              ),
              if (widget.locked)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 10,
                      color: (fixed ?? accent).withValues(alpha: 0.72),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
