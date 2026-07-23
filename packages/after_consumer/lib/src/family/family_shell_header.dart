import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'family_animated_profile_avatar.dart';
import 'family_avatar_options.dart';
import 'family_membership_badge.dart';
import 'family_profile_identity.dart';

/// Garage-parity MainShell top bar for every consumer Super App.
///
/// Delegates to shared [AfterShellTopBar]:
/// membership (left, aligned with title) · centered app title ·
/// notifications + animated profile avatar (right).
class FamilyShellHeader extends ConsumerWidget {
  const FamilyShellHeader({
    super.key,
    this.plan = AfterUserPlan.free,
    this.title,
    this.membershipLabel,
    this.notificationUnreadCount = 0,
    this.onNotifications,
    this.onProfile,
    this.profileAction,
    this.notificationsTooltip = 'Notifications',
    this.profileTooltip = 'Profile',
    @Deprecated('Location removed from shell top bar; ignored.')
    String? locationLabel,
    @Deprecated('Location removed from shell top bar; ignored.')
    VoidCallback? onLocationTap,
    @Deprecated('Location removed from shell top bar; ignored.')
    this.locationTooltip = 'Location',
    @Deprecated('AI moved to the bottom tab; ignored.') VoidCallback? onAi,
    @Deprecated('AI moved to the bottom tab; ignored.') bool aiLocked = false,
    @Deprecated('AI moved to the bottom tab; ignored.') String aiTooltip = 'AI',
  });

  final AfterUserPlan plan;

  /// Short shell title (`Garage` / `Health` / …). Defaults from [PlatformConfig].
  final String? title;

  /// Override badge text; defaults to [AfterMembershipBadge.forPlan].
  final String? membershipLabel;

  final int notificationUnreadCount;
  final VoidCallback? onNotifications;

  /// Opens profile / settings when the trailing avatar is tapped.
  final VoidCallback? onProfile;

  /// Optional custom profile control (tests only). Prefer the default
  /// [FamilyAnimatedProfileAvatar] from [familyProfileIdentityProvider].
  final Widget? profileAction;
  final String locationTooltip;
  final String notificationsTooltip;
  final String profileTooltip;

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
    final identity = ref.watch(familyProfileIdentityProvider);
    final avatar = familyAvatarForId(identity.avatarId);
    final resolvedProfile = profileAction ??
        IconButton(
          tooltip: profileTooltip,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          onPressed: onProfile,
          icon: FamilyAnimatedProfileAvatar(
            avatar: avatar,
            imageBytes: identity.activePhotoBytes,
            radius: 16,
          ),
        );

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
      notificationUnreadCount: notificationUnreadCount,
      onNotifications: onNotifications,
      profileAction: resolvedProfile,
      notificationsTooltip: notificationsTooltip,
    );
  }
}
