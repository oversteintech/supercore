import 'dart:async';

import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'family_chrome.dart';
import 'family_cloud_sync.dart';
import 'family_emergency_profile.dart';
import 'family_membership_badge.dart';
import 'family_membership_controller.dart';
import 'family_plans_chrome.dart';
import 'family_profile_identity.dart';
import 'family_settings_chrome.dart';
import 'family_theme_controller.dart';

/// Garage-parity settings body used as the rightmost MainShell tab.
///
/// Sections: Profile · Emergency · Language · Theme · App icon · Subscription ·
/// Cloud sync · Privacy · Security · Early access · Help/FAQ · App tour ·
/// About · Sign out · Delete account.
class FamilySettingsScreen extends ConsumerWidget {
  const FamilySettingsScreen({
    required this.config,
    required this.membership,
    required this.onSetPlan,
    this.themeStyle,
    this.onThemeStyle,
    this.themeMode,
    this.onThemeMode,
    this.localeCode,
    this.onLocale,
    this.plugins = const FamilySettingsPlugins(),
    this.canUsePremiumThemes = true,
    this.version = '0.1.0',
    this.embedded = false,
    this.tourPages = const <FamilyAppTourPage>[],
    super.key,
  });

  final FamilyChromeConfig config;
  final FamilyMembershipState membership;
  final Future<void> Function(AfterUserPlan plan) onSetPlan;
  final AfterThemeStyle? themeStyle;
  final ValueChanged<AfterThemeStyle>? onThemeStyle;
  final ThemeMode? themeMode;
  final ValueChanged<ThemeMode>? onThemeMode;
  final String? localeCode;
  final ValueChanged<String>? onLocale;
  final FamilySettingsPlugins plugins;
  final bool canUsePremiumThemes;
  final String version;

  /// When true (MainShell tab), omit the Scaffold AppBar.
  final bool embedded;

  /// Optional product tour pages; defaults to a short generic tour.
  final List<FamilyAppTourPage> tourPages;

  Future<void> _selectTheme(
    BuildContext context,
    WidgetRef ref,
    AfterThemeStyle style,
  ) async {
    if (style.isComingSoonRoyalTheme) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Royal theme — coming soon')),
      );
      return;
    }
    if (style.isPremiumOnly && !canUsePremiumThemes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upgrade to unlock premium themes')),
      );
      return;
    }
    if (onThemeStyle != null) {
      onThemeStyle!(style);
    } else {
      await ref.read(familyThemeStyleProvider.notifier).setStyle(style);
    }
    onThemeMode?.call(style.materialThemeMode);
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(familyProfileIdentityProvider.notifier).clearAll();
    await ref.read(afterAuthRepositoryProvider).signOut();
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your account on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(familyProfileIdentityProvider.notifier).clearAll();
    await ref.read(afterAuthRepositoryProvider).deleteAccount();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveStyle = themeStyle ?? ref.watch(familyThemeStyleProvider);
    final locale = localeCode ?? 'en';
    final body = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Section(
          title: 'Profile',
          subtitle: 'Account, photo and personal details',
          icon: Icons.person_rounded,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: FamilyProfileSection(
              config: config,
              membership: membership,
              showFieldEditors: true,
              animateAvatar: false,
            ),
          ),
        ),
        if (plugins.belowProfile != null)
          ...plugins.belowProfile!(context, ref),
        const _Section(
          title: 'Emergency profile',
          subtitle: 'Blood type, contacts and medical notes for ICE',
          icon: Icons.health_and_safety_rounded,
          headerBackgroundColor: Color(0xFFC62828),
          headerTextColor: Colors.white,
          child: FamilyEmergencyProfileSection(),
        ),
        _Section(
          title: 'Language',
          subtitle: 'App language for labels and AI replies',
          icon: Icons.translate_rounded,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Language',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  key: ValueKey<String>('locale-picker-$locale'),
                  isExpanded: true,
                  initialValue: AfterSupportedLocales.isSupported(locale)
                      ? locale
                      : AfterSupportedLocales.fallbackLanguage,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.language_rounded),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: onLocale == null
                      ? null
                      : (v) {
                          if (v == null) return;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            onLocale!(v);
                          });
                        },
                  items: [
                    for (final code in AfterSupportedLocales.languageCodes)
                      DropdownMenuItem(
                        value: code,
                        child: Text(
                          AfterSupportedLocales.displayNameFor(code),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (plugins.aboveTheme != null) ...plugins.aboveTheme!(context, ref),
        _Section(
          title: 'Theme',
          subtitle: 'Light, dark and premium packs',
          icon: Icons.palette_rounded,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ThemeModeTile(
                  title: 'System',
                  subtitle: 'Follow device setting',
                  icon: Icons.brightness_auto_rounded,
                  selected: effectiveStyle == AfterThemeStyle.system,
                  onTap: () => unawaited(
                    _selectTheme(context, ref, AfterThemeStyle.system),
                  ),
                ),
                const Divider(height: 1),
                _ThemeModeTile(
                  title: 'Light',
                  subtitle: 'Bright surfaces',
                  icon: Icons.light_mode_rounded,
                  selected: effectiveStyle == AfterThemeStyle.light,
                  onTap: () => unawaited(
                    _selectTheme(context, ref, AfterThemeStyle.light),
                  ),
                ),
                const Divider(height: 1),
                _ThemeModeTile(
                  title: 'Dark',
                  subtitle: 'Dim surfaces',
                  icon: Icons.dark_mode_rounded,
                  selected: effectiveStyle == AfterThemeStyle.dark,
                  onTap: () => unawaited(
                    _selectTheme(context, ref, AfterThemeStyle.dark),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Text(
                    'Premium themes',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final style in AfterThemeStyle.values)
                        if (style != AfterThemeStyle.system &&
                            style != AfterThemeStyle.light &&
                            style != AfterThemeStyle.dark)
                          _ThemeChip(
                            style: style,
                            selected: effectiveStyle == style,
                            locked:
                                style.isPremiumOnly && !canUsePremiumThemes,
                            comingSoon: style.isComingSoonRoyalTheme,
                            accent: config.accent,
                            onTap: () =>
                                unawaited(_selectTheme(context, ref, style)),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (plugins.belowTheme != null) ...plugins.belowTheme!(context, ref),
        const _Section(
          title: 'App icon',
          subtitle: 'Black or white launcher background',
          icon: Icons.apps_rounded,
          child: _AppIconPanel(),
        ),
        _Section(
          title: 'Subscription',
          child: Column(
            children: [
              ListTile(
                title: const Text('Current plan'),
                subtitle: Text(
                  '${FamilyPlanCatalog.title(membership.plan)} · '
                  '${membership.badge}',
                ),
                trailing: FamilyMembershipPlanBadge(
                  plan: membership.plan,
                  label: membership.badge,
                  pill: true,
                  fontSize: 11,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.workspace_premium_outlined),
                title: const Text('Manage subscription'),
                subtitle: const Text('Free · Silver · Gold · Business'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: membership.isSuperAdmin
                    ? null
                    : () {
                        unawaited(
                          showFamilyPlansSheet(
                            context: context,
                            config: config,
                            membership: membership,
                            onSetPlan: onSetPlan,
                          ),
                        );
                      },
              ),
            ],
          ),
        ),
        _Section(
          title: 'Cloud sync',
          child: Consumer(
            builder: (context, ref, _) {
              final sync = ref.watch(familyCloudSyncProvider);
              final subtitle = switch (sync.status) {
                FamilyCloudSyncStatus.syncing => 'Syncing…',
                FamilyCloudSyncStatus.error => sync.errorCode ?? 'Sync error',
                FamilyCloudSyncStatus.idle => sync.lastSyncedMillis == null
                    ? 'Not synced yet'
                    : 'Last sync OK',
              };
              return ListTile(
                leading: const Icon(Icons.cloud_sync_outlined),
                title: const Text('Sync now'),
                subtitle: Text(subtitle),
                trailing: sync.status == FamilyCloudSyncStatus.syncing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right_rounded),
                onTap: sync.status == FamilyCloudSyncStatus.syncing
                    ? null
                    : () => unawaited(
                          ref.read(familyCloudSyncProvider.notifier).syncNow(),
                        ),
              );
            },
          ),
        ),
        _Section(
          title: 'Privacy',
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.verified_user_rounded),
                title: const Text('Permissions'),
                subtitle: const Text(
                  'Location, notifications, and camera are requested only when needed.',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _info(
                  context,
                  'Permissions',
                  'This Super App asks for sensitive permissions only when you '
                      'use a feature that needs them. You can revoke access in '
                      'system settings anytime.',
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.privacy_tip_rounded),
                title: const Text('Privacy policy'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _info(
                  context,
                  'Privacy policy',
                  'Your data stays under your control. Cloud sync and sharing '
                      'run only when you enable those features.\n\n'
                      'Support: ${config.supportEmail}',
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.description_rounded),
                title: const Text('Terms of use'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _info(
                  context,
                  'Terms of use',
                  'By using ${config.appName} you agree to Overstein Labs terms '
                      'for AfterArtificial Super Apps.\n\n'
                      'Support: ${config.supportEmail}',
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.download_rounded),
                title: const Text('Export data'),
                subtitle: const Text('Download a local copy of your data'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Export will be available with cloud sync'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        _Section(
          title: 'Security',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Your account and on-device data are protected. '
                        'Sign-in tokens never leave secure storage.',
                        style: TextStyle(height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.password_rounded),
                title: const Text('Change password'),
                subtitle: const Text('Managed by your sign-in provider'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _info(
                  context,
                  'Change password',
                  'Password changes are handled by your Google / email provider. '
                      'Use the provider account settings to update credentials.',
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.security_rounded),
                title: const Text('Your rights'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _info(
                  context,
                  'Your rights',
                  'You can export, correct, or delete your data. Email '
                      '${config.supportEmail} for KVKK/GDPR requests.',
                ),
              ),
            ],
          ),
        ),
        _Section(
          title: 'Early user program',
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.rocket_launch_rounded),
                title: const Text('Early access'),
                subtitle: Text(
                  membership.isSuperAdmin
                      ? 'Admin: manage early-user tiers from the backend console.'
                      : 'Founders and pioneers get beta features and launch perks.',
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.mail_outline_rounded),
                title: const Text('Join / inquire'),
                subtitle: Text(config.supportEmail),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _info(
                  context,
                  'Early user program',
                  'Write to ${config.supportEmail} with your account email to '
                      'join the early user program for ${config.appName}.',
                ),
              ),
            ],
          ),
        ),
        _Section(
          title: 'Help / FAQ',
          child: Column(
            children: [
              ..._faqTiles(config.appName),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.support_agent_rounded),
                title: const Text('Contact support'),
                subtitle: Text(config.supportEmail),
              ),
            ],
          ),
        ),
        _Section(
          title: 'App tour',
          child: ListTile(
            leading: const Icon(Icons.play_circle_outline_rounded),
            title: const Text('Replay app tour'),
            subtitle: const Text('Quick walkthrough of the main tabs'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => FamilyAppTourScreen(
                    appName: config.appName,
                    pages: tourPages.isEmpty
                        ? FamilyAppTourPage.defaultsFor(config.appName)
                        : tourPages,
                  ),
                ),
              );
            },
          ),
        ),
        _Section(
          title: 'About',
          child: Column(
            children: [
              ListTile(
                title: Text(config.appName),
                subtitle: Text('Version $version'),
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text(config.supportEmail),
              ),
              ListTile(
                title: Text(config.tagline),
                subtitle: const Text(
                  'Built by Overstein Labs · AfterArtificial Super Apps',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => unawaited(_signOut(context, ref)),
          child: const Text('Sign out'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => unawaited(_deleteAccount(context, ref)),
          child: Text(
            'Delete account',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );

    if (embedded) {
      return body;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: body,
    );
  }

  static List<Widget> _faqTiles(String appName) {
    final faqs = _defaultFaqs(appName);
    return [
      for (var i = 0; i < faqs.length; i++) ...[
        if (i > 0) const Divider(height: 1),
        ExpansionTile(
          title: Text(
            faqs[i].$1,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(faqs[i].$2, style: const TextStyle(height: 1.4)),
              ),
            ),
          ],
        ),
      ],
    ];
  }

  static List<(String, String)> _defaultFaqs(String appName) => [
        (
          'What plans are available?',
          'Free, Silver, Gold, and Business. Manage them under Subscription.',
        ),
        (
          'How does cloud sync work?',
          'Cloud sync uploads your data when you tap Sync now and you are signed in.',
        ),
        (
          'How do I change the app icon?',
          'Open Settings → App icon and choose black or white background.',
        ),
        (
          'How do I contact support?',
          'Use Help / FAQ or email the support address shown in About for $appName.',
        ),
      ];

  static void _info(BuildContext context, String title, String body) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(body)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.headerBackgroundColor,
    this.headerTextColor,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;
  final Color? headerBackgroundColor;
  final Color? headerTextColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accentHeader =
        headerBackgroundColor != null && headerTextColor != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SuperGarageCard(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: accentHeader ? headerBackgroundColor : null,
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: false,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: EdgeInsets.zero,
            maintainState: true,
            backgroundColor: headerBackgroundColor,
            collapsedBackgroundColor: headerBackgroundColor,
            iconColor: headerTextColor,
            collapsedIconColor: headerTextColor,
            leading: icon == null
                ? null
                : CircleAvatar(
                    backgroundColor: accentHeader
                        ? headerTextColor!.withValues(alpha: 0.18)
                        : scheme.primary.withValues(alpha: 0.12),
                    foregroundColor:
                        accentHeader ? headerTextColor : scheme.primary,
                    child: Icon(icon, size: 20),
                  ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: accentHeader ? headerTextColor : null,
              ),
            ),
            subtitle: subtitle == null
                ? null
                : Text(
                    subtitle!,
                    style: TextStyle(
                      color: accentHeader
                          ? headerTextColor!.withValues(alpha: 0.92)
                          : scheme.onSurfaceVariant,
                    ),
                  ),
            children: [
              if (accentHeader)
                ColoredBox(
                  color: scheme.surface,
                  child: child,
                )
              else
                child,
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: selected ? scheme.primary : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: scheme.primary)
          : const Icon(Icons.circle_outlined),
      onTap: onTap,
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.style,
    required this.selected,
    required this.locked,
    required this.comingSoon,
    required this.accent,
    required this.onTap,
  });

  final AfterThemeStyle style;
  final bool selected;
  final bool locked;
  final bool comingSoon;
  final Color accent;
  final VoidCallback onTap;

  String get _label {
    final name = style.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_label),
          if (locked || comingSoon) ...[
            const SizedBox(width: 4),
            Icon(
              comingSoon ? Icons.schedule_rounded : Icons.lock_rounded,
              size: 14,
            ),
          ],
        ],
      ),
      onSelected: (_) => onTap(),
      selectedColor: accent.withValues(alpha: 0.25),
      checkmarkColor: accent,
    );
  }
}

class _AppIconPanel extends ConsumerStatefulWidget {
  const _AppIconPanel();

  @override
  ConsumerState<_AppIconPanel> createState() => _AppIconPanelState();
}

class _AppIconPanelState extends ConsumerState<_AppIconPanel> {
  bool _white = false;
  var _loaded = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _white =
          prefs.getBool(AfterSettingsKeys.appIconWhiteBackground) ?? false;
      _loaded = true;
    });
  }

  Future<void> _setWhite(bool white) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AfterSettingsKeys.appIconWhiteBackground, white);
    if (!mounted) return;
    setState(() => _white = white);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          white
              ? 'App icon preference: white background'
              : 'App icon preference: black background',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose the launcher icon background',
            style: TextStyle(fontWeight: FontWeight.w600, height: 1.35),
          ),
          const SizedBox(height: 10),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Black')),
              ButtonSegment(value: true, label: Text('White')),
            ],
            selected: {_white},
            onSelectionChanged: (selection) =>
                unawaited(_setWhite(selection.first)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: _white ? Colors.white : Colors.black,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.apps_rounded,
                  color: _white ? Colors.black87 : Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _white
                      ? 'White background — best on dark home screens.'
                      : 'Black background — best on light home screens.',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

@immutable
class FamilyAppTourPage {
  const FamilyAppTourPage({required this.title, required this.body});

  final String title;
  final String body;

  static List<FamilyAppTourPage> defaultsFor(String appName) => [
        FamilyAppTourPage(
          title: 'Welcome to $appName',
          body: 'Your AfterArtificial Super App — same family chrome as Garage.',
        ),
        const FamilyAppTourPage(
          title: 'Home & Live',
          body: 'Track your day from Home and watch live signals on Live.',
        ),
        const FamilyAppTourPage(
          title: 'AI assistant',
          body: 'Ask the AI tab for help, or tap the sparkle in the top bar.',
        ),
        const FamilyAppTourPage(
          title: 'Settings',
          body:
              'Profile, subscription, privacy, security, and more live on the Settings tab.',
        ),
      ];
}

class FamilyAppTourScreen extends StatefulWidget {
  const FamilyAppTourScreen({
    required this.appName,
    required this.pages,
    super.key,
  });

  final String appName;
  final List<FamilyAppTourPage> pages;

  @override
  State<FamilyAppTourScreen> createState() => _FamilyAppTourScreenState();
}

class _FamilyAppTourScreenState extends State<FamilyAppTourScreen> {
  final _controller = PageController();
  var _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.pages;
    return Scaffold(
      appBar: AppBar(title: const Text('App tour')),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final page = pages[i];
                return Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        page.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 16),
                      Text(page.body, style: const TextStyle(height: 1.45)),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(
              children: [
                Text('${_index + 1} / ${pages.length}'),
                const Spacer(),
                if (_index < pages.length - 1)
                  FilledButton(
                    onPressed: () => _controller.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                    ),
                    child: const Text('Next'),
                  )
                else
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
