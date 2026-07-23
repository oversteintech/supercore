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
import 'family_region_language_section.dart';
import 'family_settings_chrome.dart';
import 'family_theme_controller.dart';
import 'family_ui_strings.dart';

/// Garage-parity settings body used as the rightmost MainShell tab.
///
/// Sections: Profile · Emergency · Region & language · Theme · App icon ·
/// Subscription · Cloud sync · Privacy · Security · Early access · Help/FAQ ·
/// App tour · About · Sign out · Delete account.
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
    this.countryCode,
    this.onCountry,
    this.plugins = const FamilySettingsPlugins(),
    this.canUsePremiumThemes = true,
    this.version = '0.1.0',
    this.embedded = false,
    this.tourPages = const <FamilyAppTourPage>[],
    this.onDeleteAccount,
    this.onSignOut,
    this.onAccountDeletionFeedback,
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

  /// App language change. Pass `null` for device/system language when supported.
  final ValueChanged<String?>? onLocale;

  /// ISO country code shown in Region & language (optional — prefs fallback).
  final String? countryCode;
  final ValueChanged<String?>? onCountry;
  final FamilySettingsPlugins plugins;
  final bool canUsePremiumThemes;
  final String version;

  /// When true (MainShell tab), omit the Scaffold AppBar.
  final bool embedded;

  /// Optional product tour pages; defaults to a short generic tour.
  final List<FamilyAppTourPage> tourPages;

  /// Product-specific permanent delete (Garage cloud wipe, etc.).
  /// Defaults to [AfterAuthRepository.deleteAccount] + local profile clear.
  final Future<void> Function({String? feedback})? onDeleteAccount;

  /// Optional product sign-out (Garage [AppSession.signOut]). When set, used
  /// instead of the default After auth repository sign-out alone.
  final Future<void> Function()? onSignOut;

  /// Optional feedback submit without deleting.
  final Future<void> Function(String feedback)? onAccountDeletionFeedback;

  Future<void> _selectTheme(
    BuildContext context,
    WidgetRef ref,
    AfterThemeStyle style,
    String locale,
  ) async {
    if (style.isComingSoonRoyalTheme) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(FamilyUiStrings.t('royal_soon', locale))),
      );
      return;
    }
    // Silver pack stays Premium-gated; Gold/Diamond are launch-free.
    if (style.isSilverPremiumOnly && !canUsePremiumThemes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(FamilyUiStrings.t('upgrade_themes', locale))),
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

  Future<void> _signOut(
    BuildContext context,
    WidgetRef ref,
    String locale,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(FamilyUiStrings.t('sign_out_q', locale)),
        content: Text(FamilyUiStrings.t('sign_out_body', locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(FamilyUiStrings.t('cancel', locale)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(FamilyUiStrings.t('sign_out', locale)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final custom = onSignOut;
    if (custom != null) {
      await custom();
      return;
    }
    try {
      await ref.read(afterAuthRepositoryProvider).signOut();
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    }
  }

  Future<void> _deleteAccount(
    BuildContext context,
    WidgetRef ref,
    String locale,
  ) async {
    await AfterAccountDeletionFlow.show(
      context,
      localeCode: locale,
      onFeedback: onAccountDeletionFeedback,
      onDelete: ({String? feedback}) async {
        final custom = onDeleteAccount;
        if (custom != null) {
          await custom(feedback: feedback);
          return;
        }
        await ref.read(familyProfileIdentityProvider.notifier).clearAll();
        await ref.read(afterAuthRepositoryProvider).deleteAccount();
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveStyle = themeStyle ?? ref.watch(familyThemeStyleProvider);
    final locale = localeCode ?? AfterSupportedLocales.fallbackLanguage;
    String s(String key, {Map<String, String> args = const {}}) =>
        FamilyUiStrings.t(key, locale, args: args);
    final body = ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        AfterSettingsSection(
          title: s('profile'),
          subtitle: s('profile_sub'),
          icon: Icons.person_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FamilyProfileSection(
                config: config,
                membership: membership,
                localeCode: locale,
                // Canonical profile rows are always core-backed and identical
                // across every Super App (Garage included).
                showFieldEditors: true,
                animateAvatar: false,
                embeddedInSection: true,
              ),
              if (plugins.insideProfile != null)
                ...plugins.insideProfile!(context, ref),
            ],
          ),
        ),
        if (plugins.belowProfile != null) ...[
          const AfterSettingsSectionGap(),
          ...plugins.belowProfile!(context, ref),
        ],
        const AfterSettingsSectionGap(),
        AfterSettingsSection(
          title: s('emergency'),
          subtitle: s('emergency_sub'),
          icon: Icons.health_and_safety_rounded,
          headerBackgroundColor: AfterSettingsSection.emergencyRed,
          headerTextColor: Colors.white,
          child: const FamilyEmergencyProfileSection(),
        ),
        const AfterSettingsSectionGap(),
        AfterSettingsSection(
          title: s('region_language'),
          subtitle: s('region_language_sub'),
          icon: Icons.public_rounded,
          child: FamilyRegionLanguageSection(
            localeCode: locale,
            onLocale: onLocale,
            countryCode: countryCode,
            onCountry: onCountry,
            extras: plugins.regionalExtras?.call(context, ref) ?? const [],
          ),
        ),
        if (plugins.aboveTheme != null) ...[
          const AfterSettingsSectionGap(),
          ...plugins.aboveTheme!(context, ref),
        ],
        const AfterSettingsSectionGap(),
        AfterSettingsSection(
          title: s('theme'),
          subtitle: s('theme_sub'),
          icon: Icons.palette_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ThemeModeTile(
                title: s('light'),
                subtitle: s('light_sub'),
                icon: Icons.light_mode_rounded,
                selected: effectiveStyle == AfterThemeStyle.light ||
                    effectiveStyle == AfterThemeStyle.system,
                onTap: () => unawaited(
                  _selectTheme(context, ref, AfterThemeStyle.light, locale),
                ),
              ),
              const Divider(height: 1),
              _ThemeModeTile(
                title: s('dark'),
                subtitle: s('dark_sub'),
                icon: Icons.dark_mode_rounded,
                selected: effectiveStyle == AfterThemeStyle.dark,
                onTap: () => unawaited(
                  _selectTheme(context, ref, AfterThemeStyle.dark, locale),
                ),
              ),
              const Divider(height: 1),
              AfterPremiumThemesAccordion(
                title: s('premium_themes'),
                subtitle: canUsePremiumThemes
                    ? s('premium_themes_sub')
                    : s('upgrade_themes'),
                locked: !canUsePremiumThemes,
                children: [
                  for (final style in AfterThemeStyle.values)
                    if (style != AfterThemeStyle.system &&
                        style != AfterThemeStyle.light &&
                        style != AfterThemeStyle.dark) ...[
                      _ThemeModeTile(
                        title: _premiumThemeTitle(style, s),
                        subtitle: _premiumThemeSubtitle(
                          style,
                          s,
                          canUsePremiumThemes: canUsePremiumThemes,
                        ),
                        icon: _premiumThemeIcon(style),
                        selected: effectiveStyle == style,
                        onTap: () => unawaited(
                          _selectTheme(context, ref, style, locale),
                        ),
                      ),
                      if (style != AfterThemeStyle.royal)
                        const Divider(height: 1),
                    ],
                ],
              ),
            ],
          ),
        ),
        if (plugins.belowTheme != null) ...[
          const AfterSettingsSectionGap(),
          ...plugins.belowTheme!(context, ref),
        ],
        const AfterSettingsSectionGap(),
        AfterSettingsSection(
          title: s('app_icon'),
          subtitle: s('app_icon_sub'),
          icon: Icons.apps_rounded,
          child: _AppIconPanel(locale: locale),
        ),
        const AfterSettingsSectionGap(),
        AfterSettingsSection(
          title: s('subscription'),
          subtitle: s('subscription_sub'),
          icon: Icons.workspace_premium_rounded,
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s('current_plan')),
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
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.workspace_premium_outlined),
                title: Text(s('manage_subscription')),
                subtitle: Text(s('plans_hint')),
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
        const AfterSettingsSectionGap(),
        AfterSettingsSection(
          title: s('cloud_sync'),
          subtitle: s('cloud_sync_sub'),
          icon: Icons.cloud_sync_rounded,
          child: Consumer(
            builder: (context, ref, _) {
              final sync = ref.watch(familyCloudSyncProvider);
              final subtitle = switch (sync.status) {
                FamilyCloudSyncStatus.syncing => s('syncing'),
                FamilyCloudSyncStatus.error => sync.errorCode ?? s('sync_error'),
                FamilyCloudSyncStatus.idle => sync.lastSyncedMillis == null
                    ? s('not_synced')
                    : s('last_sync_ok'),
              };
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cloud_sync_outlined),
                title: Text(s('sync_now')),
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
        const AfterSettingsSectionGap(),
        AfterSettingsSection(
          title: s('privacy'),
          subtitle: s('privacy_sub'),
          icon: Icons.privacy_tip_rounded,
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.verified_user_rounded),
                title: Text(s('permissions')),
                subtitle: Text(s('permissions_sub')),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  final open = plugins.onOpenPermissions;
                  if (open != null) {
                    open();
                    return;
                  }
                  _info(
                    context,
                    s('permissions'),
                    s('permissions_body'),
                    locale: locale,
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.privacy_tip_rounded),
                title: Text(s('privacy_policy')),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  final open = plugins.onOpenPrivacyPolicy;
                  if (open != null) {
                    open();
                    return;
                  }
                  _info(
                    context,
                    s('privacy_policy'),
                    '${s('privacy_policy_body')}\n\n${s('support')}: ${config.supportEmail}',
                    locale: locale,
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.description_rounded),
                title: Text(s('terms')),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  final open = plugins.onOpenTerms;
                  if (open != null) {
                    open();
                    return;
                  }
                  _info(
                    context,
                    s('terms'),
                    '${s('terms_body', args: {'app': config.appName})}\n\n${s('support')}: ${config.supportEmail}',
                    locale: locale,
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.download_rounded),
                title: Text(s('export_data')),
                subtitle: Text(s('export_sub')),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  final open = plugins.onExportData;
                  if (open != null) {
                    open();
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(s('export_soon')),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const AfterSettingsSectionGap(),
        AfterSettingsSection(
          title: s('security'),
          subtitle: s('security_sub'),
          icon: Icons.shield_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_rounded,
                    color: Theme.of(context).colorScheme.adaptiveIcon,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s('security_body'),
                      style: const TextStyle(height: 1.35),
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.password_rounded),
                title: Text(s('change_password')),
                subtitle: Text(s('change_password_sub')),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _info(
                  context,
                  s('change_password'),
                  s('change_password_body'),
                  locale: locale,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.security_rounded),
                title: Text(s('your_rights')),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _info(
                  context,
                  s('your_rights'),
                  s('your_rights_body', args: {'email': config.supportEmail}),
                  locale: locale,
                ),
              ),
              if (plugins.securityExtras != null) ...[
                const Divider(height: 1),
                ...plugins.securityExtras!(context, ref),
              ],
            ],
          ),
        ),
        const AfterSettingsSectionGap(),
        AfterSettingsSection(
          title: s('early_user'),
          subtitle: s('early_user_sub'),
          icon: Icons.rocket_launch_rounded,
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.rocket_launch_rounded),
                title: Text(s('early_access')),
                subtitle: Text(
                  membership.isSuperAdmin
                      ? s('early_access_admin')
                      : s('early_access_user'),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.mail_outline_rounded),
                title: Text(s('join_inquire')),
                subtitle: Text(config.supportEmail),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _info(
                  context,
                  s('early_user'),
                  s('early_user_body', args: {
                    'email': config.supportEmail,
                    'app': config.appName,
                  }),
                  locale: locale,
                ),
              ),
            ],
          ),
        ),
        const AfterSettingsSectionGap(),
        AfterSettingsSection(
          title: s('help_faq'),
          subtitle: s('help_faq_sub'),
          icon: Icons.help_outline_rounded,
          child: Column(
            children: [
              if (plugins.faqItems != null)
                ..._faqTilesFromItems(
                  plugins.faqItems!(context, ref),
                )
              else
                ..._faqTiles(config.appName, locale),
              if (plugins.helpExtras != null) ...[
                const Divider(height: 1),
                ...plugins.helpExtras!(context, ref),
              ],
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.support_agent_rounded),
                title: Text(s('contact_support')),
                subtitle: Text(config.supportEmail),
                onTap: plugins.onContactSupport,
              ),
            ],
          ),
        ),
        const AfterSettingsSectionGap(),
        AfterSettingsSection(
          title: s('app_tour'),
          subtitle: s('app_tour_sub'),
          icon: Icons.play_circle_outline_rounded,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.play_circle_outline_rounded),
            title: Text(s('replay_tour')),
            subtitle: Text(s('replay_tour_sub')),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => FamilyAppTourScreen(
                    appName: config.appName,
                    locale: locale,
                    pages: tourPages.isEmpty
                        ? FamilyAppTourPage.defaultsFor(
                            config.appName,
                            locale: locale,
                          )
                        : tourPages,
                  ),
                ),
              );
            },
          ),
        ),
        const AfterSettingsSectionGap(),
        AfterSettingsSection(
          title: s('about'),
          subtitle: s('about_sub'),
          icon: Icons.info_outline_rounded,
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(config.appName),
                subtitle: Text(s('version', args: {'version': version})),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.email_outlined),
                title: Text(config.supportEmail),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(config.tagline),
                subtitle: Text(s('built_by')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
            side: BorderSide(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.55),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () => unawaited(_signOut(context, ref, locale)),
          icon: const Icon(Icons.exit_to_app_rounded),
          label: Text(
            s('sign_out'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor:
                Theme.of(context).colorScheme.error.withValues(alpha: 0.78),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () => unawaited(_deleteAccount(context, ref, locale)),
          icon: const Icon(Icons.person_off_outlined, size: 20),
          label: Text(
            s('delete_account'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );

    if (embedded) {
      return body;
    }
    return Scaffold(
      appBar: AppBar(title: Text(s('settings'))),
      body: body,
    );
  }

  static List<Widget> _faqTiles(String appName, String locale) {
    final faqs = _defaultFaqs(appName, locale);
    return _faqTilesFromPairs(faqs);
  }

  static List<Widget> _faqTilesFromItems(
    List<({String title, String body})> items,
  ) {
    return _faqTilesFromPairs([
      for (final item in items) (item.title, item.body),
    ]);
  }

  static List<Widget> _faqTilesFromPairs(List<(String, String)> faqs) {
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

  static List<(String, String)> _defaultFaqs(String appName, String locale) => [
        (
          FamilyUiStrings.t('faq1_q', locale),
          FamilyUiStrings.t('faq1_a', locale),
        ),
        (
          FamilyUiStrings.t('faq2_q', locale),
          FamilyUiStrings.t('faq2_a', locale),
        ),
        (
          FamilyUiStrings.t('faq3_q', locale),
          FamilyUiStrings.t('faq3_a', locale),
        ),
        (
          FamilyUiStrings.t('faq4_q', locale),
          FamilyUiStrings.t('faq4_a', locale, args: {'app': appName}),
        ),
      ];

  static void _info(
    BuildContext context,
    String title,
    String body, {
    required String locale,
  }) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(body)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(FamilyUiStrings.t('ok', locale)),
            ),
          ],
        ),
      ),
    );
  }
}

String _premiumThemeTitle(
  AfterThemeStyle style,
  String Function(String key, {Map<String, String> args}) s,
) {
  return switch (style) {
    AfterThemeStyle.racingRed => s('theme_racing_red'),
    AfterThemeStyle.racingBlue => s('theme_racing_blue'),
    AfterThemeStyle.darkNight => s('theme_dark_night'),
    AfterThemeStyle.forestGreen => s('theme_forest_green'),
    AfterThemeStyle.silverGrey => s('theme_silver_grey'),
    AfterThemeStyle.blossomPink => s('theme_blossom_pink'),
    AfterThemeStyle.brightGold => s('theme_bright_gold'),
    AfterThemeStyle.diamond => s('theme_diamond'),
    AfterThemeStyle.royal => s('theme_royal'),
    AfterThemeStyle.system ||
    AfterThemeStyle.light ||
    AfterThemeStyle.dark => style.name,
  };
}

String _premiumThemeSubtitle(
  AfterThemeStyle style,
  String Function(String key, {Map<String, String> args}) s, {
  required bool canUsePremiumThemes,
}) {
  if (style.isComingSoonRoyalTheme) {
    return s('theme_royal_sub');
  }
  if (style.isSilverPremiumOnly && !canUsePremiumThemes) {
    return s('theme_locked');
  }
  return switch (style) {
    AfterThemeStyle.racingRed => s('theme_racing_red_sub'),
    AfterThemeStyle.racingBlue => s('theme_racing_blue_sub'),
    AfterThemeStyle.darkNight => s('theme_dark_night_sub'),
    AfterThemeStyle.forestGreen => s('theme_forest_green_sub'),
    AfterThemeStyle.silverGrey => s('theme_silver_grey_sub'),
    AfterThemeStyle.blossomPink => s('theme_blossom_pink_sub'),
    AfterThemeStyle.brightGold => s('theme_bright_gold_sub'),
    AfterThemeStyle.diamond => s('theme_diamond_sub'),
    AfterThemeStyle.royal => s('theme_royal_sub'),
    AfterThemeStyle.system ||
    AfterThemeStyle.light ||
    AfterThemeStyle.dark => s('theme_sub'),
  };
}

IconData _premiumThemeIcon(AfterThemeStyle style) {
  if (style.isComingSoonRoyalTheme) {
    return Icons.schedule_rounded;
  }
  return switch (style) {
    AfterThemeStyle.racingRed => Icons.sports_motorsports_rounded,
    AfterThemeStyle.racingBlue => Icons.electric_bolt_rounded,
    AfterThemeStyle.darkNight => Icons.nightlight_rounded,
    AfterThemeStyle.forestGreen => Icons.forest_rounded,
    AfterThemeStyle.silverGrey => Icons.diamond_outlined,
    AfterThemeStyle.blossomPink => Icons.favorite_rounded,
    AfterThemeStyle.brightGold => Icons.workspace_premium_rounded,
    AfterThemeStyle.diamond => Icons.diamond_rounded,
    AfterThemeStyle.royal => Icons.military_tech_rounded,
    AfterThemeStyle.system ||
    AfterThemeStyle.light ||
    AfterThemeStyle.dark => Icons.palette_rounded,
  };
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

class _AppIconPanel extends ConsumerStatefulWidget {
  const _AppIconPanel({required this.locale});

  final String locale;

  @override
  ConsumerState<_AppIconPanel> createState() => _AppIconPanelState();
}

class _AppIconPanelState extends ConsumerState<_AppIconPanel> {
  bool _white = true;
  var _loaded = false;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    await AfterDynamicAppIconService.initialize(prefs);
    if (!mounted) return;
    setState(() {
      _white =
          prefs.getBool(AfterSettingsKeys.appIconWhiteBackground) ?? true;
      _loaded = true;
    });
  }

  Future<void> _setWhite(bool white) async {
    if (_busy || white == _white) return;
    final prefs = await SharedPreferences.getInstance();
    final previous = _white;
    setState(() {
      _busy = true;
      _white = white;
    });
    await prefs.setBool(AfterSettingsKeys.appIconWhiteBackground, white);

    final applied = await AfterDynamicAppIconService.applyBackgroundAndRestart(
      whiteBackground: white,
    );

    if (!mounted) return;

    if (!applied) {
      await prefs.setBool(AfterSettingsKeys.appIconWhiteBackground, previous);
      setState(() {
        _white = previous;
        _busy = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            FamilyUiStrings.t('app_icon_change_failed', widget.locale),
          ),
        ),
      );
      return;
    }

    setState(() => _busy = false);
    // Android relaunch usually kills this process; snackbar is a fallback.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          white
              ? FamilyUiStrings.t('app_icon_pref_white', widget.locale)
              : FamilyUiStrings.t('app_icon_pref_black', widget.locale),
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
          Text(
            FamilyUiStrings.t('app_icon_choose', widget.locale),
            style: const TextStyle(fontWeight: FontWeight.w600, height: 1.35),
          ),
          const SizedBox(height: 10),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: true,
                label: Text(FamilyUiStrings.t('app_icon_white', widget.locale)),
              ),
              ButtonSegment(
                value: false,
                label: Text(FamilyUiStrings.t('app_icon_black', widget.locale)),
              ),
            ],
            selected: {_white},
            onSelectionChanged: _busy
                ? null
                : (selection) => unawaited(_setWhite(selection.first)),
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
                  _busy
                      ? FamilyUiStrings.t('app_icon_updating', widget.locale)
                      : _white
                          ? FamilyUiStrings.t(
                              'app_icon_white_hint',
                              widget.locale,
                            )
                          : FamilyUiStrings.t(
                              'app_icon_black_hint',
                              widget.locale,
                            ),
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

  static List<FamilyAppTourPage> defaultsFor(
    String appName, {
    String locale = 'en',
  }) =>
      [
        FamilyAppTourPage(
          title: FamilyUiStrings.t(
            'tour_welcome_title',
            locale,
            args: {'app': appName},
          ),
          body: FamilyUiStrings.t('tour_welcome_body', locale),
        ),
        FamilyAppTourPage(
          title: FamilyUiStrings.t('tour_home_title', locale),
          body: FamilyUiStrings.t('tour_home_body', locale),
        ),
        FamilyAppTourPage(
          title: FamilyUiStrings.t('tour_ai_title', locale),
          body: FamilyUiStrings.t('tour_ai_body', locale),
        ),
        FamilyAppTourPage(
          title: FamilyUiStrings.t('tour_settings_title', locale),
          body: FamilyUiStrings.t('tour_settings_body', locale),
        ),
      ];
}

class FamilyAppTourScreen extends StatefulWidget {
  const FamilyAppTourScreen({
    required this.appName,
    required this.pages,
    this.locale = 'en',
    super.key,
  });

  final String appName;
  final List<FamilyAppTourPage> pages;
  final String locale;

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
      appBar: AppBar(title: Text(FamilyUiStrings.t('app_tour', widget.locale))),
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
                    child: Text(
                      FamilyUiStrings.t('tour_next', widget.locale),
                    ),
                  )
                else
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      FamilyUiStrings.t('tour_done', widget.locale),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
