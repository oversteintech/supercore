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
