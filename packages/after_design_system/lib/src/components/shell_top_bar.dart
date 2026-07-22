import 'dart:math' as math;

import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';

import '../membership/after_user_plan_colors.dart';

/// Shared MainShell top bar for every Super App.
///
/// Layout (single source of truth):
/// ```
/// [ membership ]              App title              [ 🔔  ✨ ]
/// [ 📍 location ]
/// ```
/// Left: membership text with location directly under it.
/// Center: product title (true page center).
/// Right: notifications + theme-visible animated AI icon.
class AfterShellTopBar extends StatelessWidget {
  const AfterShellTopBar({
    super.key,
    this.plan = AfterUserPlan.free,
    this.title,
    this.membershipLabel,
    this.membershipBadge,
    this.locationLabel,
    this.onLocationTap,
    this.notificationUnreadCount = 0,
    this.onNotifications,
    this.onAi,
    this.aiLocked = false,
    this.locationTooltip = 'Location',
    this.notificationsTooltip = 'Notifications',
    this.aiTooltip = 'AI',
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

  /// Optional locality text under the membership row.
  final String? locationLabel;

  final VoidCallback? onLocationTap;
  final int notificationUnreadCount;
  final VoidCallback? onNotifications;
  final VoidCallback? onAi;
  final bool aiLocked;
  final String locationTooltip;
  final String notificationsTooltip;
  final String aiTooltip;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final fg = AfterUserPlanColors.headerForeground(plan, brightness);
    final muted = fg.withValues(alpha: 0.88);
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
                        child: _MembershipLocationBlock(
                          membershipBadge: membershipBadge,
                          membershipLabel:
                              hasMembership && membershipBadge == null
                                  ? resolvedLabel.toUpperCase()
                                  : null,
                          membershipColor: fg,
                          locationLabel: locationLabel,
                          locationColor: muted,
                          locationTooltip: locationTooltip,
                          onLocationTap: onLocationTap,
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
                        style: TextStyle(
                          color: fg,
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
                          child: Icon(Icons.notifications_rounded, color: fg),
                        ),
                      ),
                      IconButton(
                        tooltip: aiTooltip,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        onPressed: onAi,
                        icon: AfterAnimatedAiIcon(
                          color: fg,
                          locked: aiLocked,
                        ),
                      ),
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

class _MembershipLocationBlock extends StatelessWidget {
  const _MembershipLocationBlock({
    required this.membershipColor,
    required this.locationColor,
    required this.locationTooltip,
    this.membershipBadge,
    this.membershipLabel,
    this.locationLabel,
    this.onLocationTap,
  });

  final Widget? membershipBadge;
  final String? membershipLabel;
  final Color membershipColor;
  final String? locationLabel;
  final Color locationColor;
  final String locationTooltip;
  final VoidCallback? onLocationTap;

  @override
  Widget build(BuildContext context) {
    final maxLeft = MediaQuery.sizeOf(context).width * 0.36;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxLeft),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (membershipBadge != null)
            membershipBadge!
          else if (membershipLabel != null && membershipLabel!.isNotEmpty)
            Text(
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
            ),
          const SizedBox(height: 2),
          _LocationChip(
            label: locationLabel,
            color: locationColor,
            tooltip: locationTooltip,
            onTap: onLocationTap,
          ),
        ],
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({
    required this.color,
    required this.tooltip,
    this.label,
    this.onTap,
  });

  final String? label;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = label?.trim();
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on_rounded, size: 14, color: color),
              if (text != null && text.isNotEmpty) ...[
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                      height: 1.1,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Soft pulse / shimmer AI mark — uses [color] so it stays visible on every
/// membership header theme (free green, gold, dark, light, …).
class AfterAnimatedAiIcon extends StatefulWidget {
  const AfterAnimatedAiIcon({
    required this.color,
    this.size = 24,
    this.locked = false,
    super.key,
  });

  final Color color;
  final double size;
  final bool locked;

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
      duration: const Duration(milliseconds: 2200),
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
      builder: (context, _) {
        final t = _controller.value;
        final pulse = 0.92 + 0.08 * math.sin(t * math.pi * 2);
        final glow = 0.35 + 0.45 * (0.5 + 0.5 * math.sin(t * math.pi * 2));
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: pulse,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: widget.color.withValues(alpha: 0.22 + glow * 0.35),
                size: widget.size + 6,
              ),
            ),
            Transform.scale(
              scale: pulse,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: widget.color,
                size: widget.size,
              ),
            ),
            if (widget.locked)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    size: 10,
                    color: widget.color.withValues(alpha: 0.72),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
