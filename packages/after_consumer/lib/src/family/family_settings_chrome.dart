import 'dart:async';

import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'family_animated_profile_avatar.dart';
import 'family_auth_chrome.dart';
import 'family_avatar_picker.dart';
import 'family_chrome.dart';
import 'family_membership_controller.dart';
import 'family_profile_field_editors.dart';
import 'family_profile_identity.dart';
import 'family_ui_strings.dart';

/// Domain / product sections injected into the shared settings shell.
@immutable
class FamilySettingsPlugins {
  const FamilySettingsPlugins({
    this.aboveTheme,
    this.belowTheme,
    this.insideProfile,
    this.belowProfile,
  });

  final List<Widget> Function(BuildContext context, WidgetRef ref)? aboveTheme;
  final List<Widget> Function(BuildContext context, WidgetRef ref)? belowTheme;

  /// Widgets rendered **inside** the Profile accordion (personal fields, etc.).
  /// When set, [FamilyProfileSection] hides its default field editors to avoid
  /// duplicates — use for Garage-parity personal rows.
  final List<Widget> Function(BuildContext context, WidgetRef ref)?
      insideProfile;

  /// Widgets rendered **below** the Profile accordion (e.g. garage visibility).
  final List<Widget> Function(BuildContext context, WidgetRef ref)? belowProfile;
}

/// Shared profile card — Garage-parity account header + avatar + fields.
class FamilyProfileSection extends ConsumerWidget {
  const FamilyProfileSection({
    required this.config,
    required this.membership,
    this.onOpenMembership,
    this.showFieldEditors = true,
    this.animateAvatar = true,
    this.embeddedInSection = false,
    this.localeCode,
    super.key,
  });

  final FamilyChromeConfig config;
  final FamilyMembershipState membership;
  final VoidCallback? onOpenMembership;
  final bool showFieldEditors;
  final bool animateAvatar;

  /// When true (inside [AfterSettingsSection]), skip the nested card chrome.
  final bool embeddedInSection;
  final String? localeCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale =
        localeCode ?? Localizations.localeOf(context).languageCode;
    String s(String key, {Map<String, String> args = const {}}) =>
        FamilyUiStrings.t(key, locale, args: args);
    final session = ref.watch(afterAuthSessionProvider).asData?.value;
    final user = session?.user;
    final identity = ref.watch(familyProfileIdentityProvider);
    final photoBytes = ref.watch(familyActiveProfilePhotoBytesProvider);
    final name = identity.resolvedDisplayName(
      authDisplayName: user?.displayName,
      authEmail: user?.email,
    );
    final email = identity.email?.trim().isNotEmpty == true
        ? identity.email!
        : (user?.email ?? 'guest');
    final avatar = familyAvatarForId(identity.avatarId);
    final phone = identity.phoneNumber?.trim().isNotEmpty == true
        ? identity.phoneNumber!
        : (user?.phoneNumber ?? '-');
    final birth = identity.birthDate;
    final birthLabel = birth == null
        ? '-'
        : '${birth.year.toString().padLeft(4, '0')}-'
            '${birth.month.toString().padLeft(2, '0')}-'
            '${birth.day.toString().padLeft(2, '0')}';
    final photoCount = identity.photoIds.length;

    final content = Padding(
      padding: embeddedInSection
          ? EdgeInsets.zero
          : const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => unawaited(showFamilyAvatarPicker(context)),
                borderRadius: BorderRadius.circular(999),
                child: FamilyAnimatedProfileAvatar(
                  avatar: avatar,
                  imageBytes: photoBytes,
                  radius: 28,
                  animate: animateAvatar,
                  showEditBadge: true,
                  editBadgeColor: theme.colorScheme.primary,
                  editBadgeIconColor: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: config.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        membership.badge,
                        style: TextStyle(
                          color: config.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onOpenMembership != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onOpenMembership,
                icon: const Icon(Icons.workspace_premium_outlined),
                label: Text(s('membership')),
              ),
            ),
          ],
          if (showFieldEditors) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            _FamilyProfileFieldTile(
              icon: Icons.badge_outlined,
              title: s('full_name'),
              value: name,
              onTap: () => unawaited(
                editFamilyProfileDisplayName(context, ref, name),
              ),
            ),
            const Divider(height: 1),
            _FamilyProfileFieldTile(
              icon: Icons.phone_rounded,
              title: s('phone'),
              value: phone,
              onTap: () => unawaited(
                editFamilyProfilePhoneNumber(
                  context,
                  ref,
                  identity.phoneNumber ?? user?.phoneNumber,
                ),
              ),
            ),
            const Divider(height: 1),
            _FamilyProfileFieldTile(
              icon: Icons.cake_outlined,
              title: s('birth_date'),
              value: birthLabel,
              onTap: () => unawaited(
                editFamilyProfileBirthDate(context, ref, identity.birthDate),
              ),
            ),
            const Divider(height: 1),
            _FamilyProfileFieldTile(
              icon: Icons.photo_library_outlined,
              title: s('profile_photos'),
              value: s(
                'profile_photo_count',
                args: {'count': '$photoCount'},
              ),
              trailingIcon: Icons.chevron_right_rounded,
              onTap: () => unawaited(showFamilyAvatarPicker(context)),
            ),
            const Divider(height: 1),
            _FamilyProfileFieldTile(
              icon: Icons.email_rounded,
              title: s('email'),
              value: email,
              onTap: () => unawaited(
                editFamilyProfileEmail(context, ref, email),
              ),
            ),
            const Divider(height: 1),
            _FamilyProfileFieldTile(
              icon: Icons.alternate_email_rounded,
              title: s('username'),
              value: () {
                final u = identity.username?.trim() ?? '';
                if (u.isEmpty) return '-';
                return '@$u';
              }(),
              onTap: () => unawaited(
                editFamilyProfileUsername(
                  context,
                  ref,
                  identity.username,
                ),
              ),
            ),
            if (user?.uid != null) ...[
              const Divider(height: 1),
              _FamilyProfileFieldTile(
                icon: Icons.fingerprint_rounded,
                title: s('member_id'),
                value: user!.uid,
                trailingIcon: Icons.content_copy_rounded,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: user.uid));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s('member_id_copied'))),
                  );
                },
              ),
            ],
          ],
        ],
      ),
    );

    if (embeddedInSection) return content;
    return SuperGarageCard(child: content);
  }
}

class _FamilyProfileFieldTile extends StatelessWidget {
  const _FamilyProfileFieldTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.trailingIcon = Icons.edit_outlined,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      trailing: Icon(trailingIcon, size: 18),
      onTap: onTap,
    );
  }
}

/// Legacy profile landing — prefer [FamilySettingsScreen] as the shell tab.
class FamilyProfileScreen extends ConsumerWidget {
  const FamilyProfileScreen({
    required this.config,
    required this.membership,
    required this.onOpenSettings,
    required this.onOpenAbout,
    this.onOpenMembership,
    this.authConfig,
    super.key,
  });

  final FamilyChromeConfig config;
  final FamilyMembershipState membership;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenAbout;
  final VoidCallback? onOpenMembership;
  final FamilyAuthChromeConfig? authConfig;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FamilyProfileSection(
          config: config,
          membership: membership,
          onOpenMembership: onOpenMembership,
        ),
        const SizedBox(height: 16),
        SuperGarageCard(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: onOpenSettings,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: onOpenAbout,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            unawaited(() async {
              await ref.read(familyProfileIdentityProvider.notifier).clearAll();
              await ref.read(afterAuthRepositoryProvider).signOut();
            }());
          },
          child: const Text('Sign out'),
        ),
      ],
    );
  }
}
