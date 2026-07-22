import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../location/after_current_locality.dart';
import 'family_membership_badge.dart';

/// Garage-parity MainShell top bar for every consumer Super App.
///
/// Delegates to shared [AfterShellTopBar]:
/// membership (left) · location under it · centered app title ·
/// notifications + animated AI (right).
///
/// When [locationLabel] is omitted, resolves city via
/// [afterCurrentLocalityProvider] (same path Garage uses).
class FamilyShellHeader extends ConsumerWidget {
  const FamilyShellHeader({
    super.key,
    this.plan = AfterUserPlan.free,
    this.title,
    this.membershipLabel,
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

  final AfterUserPlan plan;

  /// Short shell title (`Garage` / `Health` / …). Defaults from [PlatformConfig].
  final String? title;

  /// Override badge text; defaults to [AfterMembershipBadge.forPlan].
  final String? membershipLabel;

  /// Optional explicit locality. When null, watches [afterCurrentLocalityProvider].
  final String? locationLabel;
  final VoidCallback? onLocationTap;
  final int notificationUnreadCount;
  final VoidCallback? onNotifications;
  final VoidCallback? onAi;
  final bool aiLocked;
  final String locationTooltip;
  final String notificationsTooltip;
  final String aiTooltip;

  String get _resolvedTitle {
    final explicit = title?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    try {
      final name = PlatformConfig.current.appName.trim();
      if (name.toLowerCase().startsWith('super') && name.length > 5) {
        return name.substring(5).trim();
      }
      return name;
    } on Object {
      return '';
    }
  }

  String get _resolvedBadge =>
      (membershipLabel ?? AfterMembershipBadge.forPlan(plan)).trim();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedTitle = _resolvedTitle;
    final badgeLabel = _resolvedBadge;
    final resolvedLocation = locationLabel ??
        ref.watch(afterCurrentLocalityProvider).asData?.value?.label;

    return AfterShellTopBar(
      plan: plan,
      title: resolvedTitle.isEmpty ? null : resolvedTitle,
      membershipLabel: badgeLabel,
      membershipBadge: badgeLabel.isEmpty
          ? null
          : FamilyMembershipPlanBadge(
              plan: plan,
              label: badgeLabel,
              pill: false,
              fontSize: 11,
              showIcon: false,
              displayContext: AfterMembershipBadgeContext.header,
            ),
      locationLabel: resolvedLocation,
      onLocationTap: onLocationTap ??
          () {
            ref.read(afterCurrentLocalityProvider.notifier).refresh();
          },
      notificationUnreadCount: notificationUnreadCount,
      onNotifications: onNotifications,
      onAi: onAi,
      aiLocked: aiLocked,
      locationTooltip: locationTooltip,
      notificationsTooltip: notificationsTooltip,
      aiTooltip: aiTooltip,
    );
  }
}
