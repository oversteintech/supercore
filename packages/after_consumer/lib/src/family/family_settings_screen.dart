import 'dart:async';

import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'after_cloud_backup.dart';
import 'family_chrome.dart';
import 'family_emergency_profile.dart';
import 'family_membership_badge.dart';
import 'family_membership_controller.dart';
import 'family_plans_chrome.dart';
import 'family_profile_identity.dart';
import 'family_region_language_section.dart';
import 'family_rich_document.dart';
import 'family_settings_chrome.dart';
import 'family_theme_controller.dart';
import 'family_ui_strings.dart';
import 'family_member_id.dart';

/// Garage-parity settings body used as the rightmost MainShell tab.
///
/// Sections: Profile · Emergency · Region & language · Theme ·
/// Subscription · Early access · Other information (Privacy · Security ·
/// Help/FAQ · About) · Sign out · Delete account.
///
/// Product walkthrough is first-run only (AuthGate / FeatureTour), not replayed
/// from Settings.
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
    this.onDeleteAccount,
    this.onSignOut,
    this.onAccountDeletionFeedback,
    this.onManageSubscription,
    this.showEarlyAccessSection = true,
    this.premiumThemePromo,
    this.beforeAccountActions,
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

  /// ISO country code shown in Region & language (optional, prefs fallback).
  final String? countryCode;
  final ValueChanged<String?>? onCountry;
  final FamilySettingsPlugins plugins;
  final bool canUsePremiumThemes;
  final String version;

  /// When true (MainShell tab), omit the Scaffold AppBar.
  final bool embedded;

  /// Product-specific permanent delete (Garage cloud wipe, etc.).
  /// Defaults to [AfterAuthRepository.deleteAccount] + local profile clear.
  final Future<void> Function({String? feedback})? onDeleteAccount;

  /// Optional product sign-out (Garage [AppSession.signOut]). When set, used
  /// instead of the default After auth repository sign-out alone.
  final Future<void> Function()? onSignOut;

  /// Optional feedback submit without deleting.
  final Future<void> Function(String feedback)? onAccountDeletionFeedback;

  final Future<void> Function()? onManageSubscription;
  final bool showEarlyAccessSection;
  final FamilyThemePromo? Function(AfterThemeStyle style)? premiumThemePromo;
  final List<Widget> Function(BuildContext context, WidgetRef ref)?
      beforeAccountActions;

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
    // Silver/Gold/Diamond/Blossom Pink are launch-free one-time packs.
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
          child: FamilyEmergencyProfileSection(localeCode: locale),
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
              AfterSettingsMenuMetrics.divider,
              _ThemeModeTile(
                title: s('theme_dark_night'),
                subtitle: s('dark_sub'),
                icon: Icons.dark_mode_rounded,
                selected: effectiveStyle == AfterThemeStyle.darkNight ||
                    effectiveStyle == AfterThemeStyle.dark,
                onTap: () => unawaited(
                  _selectTheme(context, ref, AfterThemeStyle.darkNight, locale),
                ),
              ),
              AfterSettingsMenuMetrics.divider,
              Builder(
                builder: (context) {
                  // Launch-free one-time packs (Silver/Gold/Diamond/Blossom)
                  // keep the accordion unlocked for free members.
                  final hasLaunchFreeIap = premiumThemePromo != null &&
                      [
                        AfterThemeStyle.silverGrey,
                        AfterThemeStyle.blossomPink,
                        AfterThemeStyle.brightGold,
                        AfterThemeStyle.diamond,
                      ].any((style) => premiumThemePromo!(style) != null);
                  final premiumUnlocked =
                      canUsePremiumThemes || hasLaunchFreeIap;
                  return AfterPremiumThemesAccordion(
                    title: s('premium_themes'),
                    subtitle: premiumUnlocked
                        ? s('premium_themes_sub')
                        : s('upgrade_themes'),
                    locked: !premiumUnlocked,
                    children: [
                      for (final style in AfterThemeStyle.values)
                        if (style != AfterThemeStyle.system &&
                            style != AfterThemeStyle.light &&
                            style != AfterThemeStyle.dark &&
                            style != AfterThemeStyle.darkNight) ...[
                          Builder(
                            builder: (context) {
                              final promo = premiumThemePromo?.call(style);
                              return _ThemeModeTile(
                                title: _premiumThemeTitle(style, s),
                                subtitle: promo?.subtitle ??
                                    _premiumThemeSubtitle(
                                      style,
                                      s,
                                      canUsePremiumThemes: canUsePremiumThemes,
                                    ),
                                badgeLabel: promo?.badge,
                                struckPrice: promo?.struckPrice,
                                icon: _premiumThemeIcon(style),
                                selected: effectiveStyle == style,
                                onTap: () => unawaited(
                                  _selectTheme(
                                    context,
                                    ref,
                                    style,
                                    locale,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (style != AfterThemeStyle.royal)
                            AfterSettingsMenuMetrics.divider,
                        ],
                    ],
                  );
                },
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
          title: s('subscription'),
          subtitle: s('subscription_sub'),
          icon: Icons.workspace_premium_rounded,
          child: Column(
            children: [
              ListTile(
                contentPadding: AfterSettingsMenuMetrics.tilePadding,
                minVerticalPadding: AfterSettingsMenuMetrics.minVerticalPadding,
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
              AfterSettingsMenuMetrics.divider,
              ListTile(
                contentPadding: AfterSettingsMenuMetrics.tilePadding,
                minVerticalPadding: AfterSettingsMenuMetrics.minVerticalPadding,
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
        if (showEarlyAccessSection) ...[
        const AfterSettingsSectionGap(),
        AfterSettingsSection(
          title: s('early_user'),
          subtitle: s('early_user_sub'),
          icon: Icons.rocket_launch_rounded,
          child: Column(
            children: [
              ListTile(
                contentPadding: AfterSettingsMenuMetrics.tilePadding,
                minVerticalPadding: AfterSettingsMenuMetrics.minVerticalPadding,
                leading: const Icon(Icons.rocket_launch_rounded),
                title: Text(s('early_access')),
                subtitle: Text(
                  membership.isSuperAdmin
                      ? s('early_access_admin')
                      : s('early_access_user'),
                ),
              ),
              AfterSettingsMenuMetrics.divider,
              ListTile(
                contentPadding: AfterSettingsMenuMetrics.tilePadding,
                minVerticalPadding: AfterSettingsMenuMetrics.minVerticalPadding,
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
        ],
        const AfterSettingsSectionGap(),
        AfterSettingsSection(
          title: s('other_information'),
          subtitle: s('other_information_sub'),
          icon: Icons.privacy_tip_rounded,
          child: Column(
            children: [
              AfterSettingsNestedAccordionTile(
                leading: Icons.privacy_tip_rounded,
                title: s('privacy'),
                child: plugins.privacyBody?.call(context, ref) ??
                    _PrivacyAccordionBody(
                      config: config,
                      plugins: plugins,
                      locale: locale,
                      s: s,
                    ),
              ),
              AfterSettingsNestedAccordionTile(
                leading: Icons.shield_rounded,
                title: s('security'),
                child: plugins.securityBody?.call(context, ref) ??
                    _SecurityAccordionBody(
                      config: config,
                      plugins: plugins,
                      locale: locale,
                      s: s,
                    ),
              ),
              AfterSettingsNestedAccordionTile(
                leading: Icons.help_outline_rounded,
                title: s('help_faq'),
                child: plugins.helpBody?.call(context, ref) ??
                    _HelpAccordionBody(
                      config: config,
                      plugins: plugins,
                      locale: locale,
                      s: s,
                    ),
              ),
              AfterSettingsNestedAccordionTile(
                leading: Icons.info_outline_rounded,
                title: s('about'),
                child: plugins.aboutBody?.call(context, ref) ??
                    _AboutAccordionBody(
                      config: config,
                      plugins: plugins,
                      version: version,
                      s: s,
                    ),
              ),
            ],
          ),
        ),
        if (beforeAccountActions != null ||
            plugins.beforeAccountActions != null) ...[
          const AfterSettingsSectionGap(),
          ...(beforeAccountActions ?? plugins.beforeAccountActions)!(
            context,
            ref,
          ),
        ],
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
        if (i > 0) AfterSettingsMenuMetrics.divider,
        ExpansionTile(
          title: Text(
            faqs[i].$1,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FamilyRichBody(faqs[i].$2),
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
        builder: (ctx) {
          final theme = Theme.of(ctx);
          return AlertDialog(
            title: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            content: SingleChildScrollView(child: FamilyRichBody(body)),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(FamilyUiStrings.t('ok', locale)),
              ),
            ],
          );
        },
      ),
    );
  }

  static void _openDocument(
    BuildContext context, {
    required String locale,
    required String title,
    required String intro,
    required String prefix,
    required int count,
    Map<String, String> args = const {},
    IconData icon = Icons.article_outlined,
  }) {
    unawaited(
      showFamilyDocumentSheet(
        context: context,
        title: title,
        intro: intro,
        icon: icon,
        closeLabel: FamilyUiStrings.t('ok', locale),
        sections: [
          for (var i = 1; i <= count; i++)
            FamilyDocSection(
              title: FamilyUiStrings.t('${prefix}_s${i}_title', locale),
              body: FamilyUiStrings.t(
                '${prefix}_s${i}_body',
                locale,
                args: args,
              ),
            ),
        ],
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
    this.badgeLabel,
    this.struckPrice,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String? badgeLabel;
  final String? struckPrice;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final badge = badgeLabel?.trim();
    final struck = struckPrice?.trim();
    final hasPromo = (badge != null && badge.isNotEmpty) ||
        (struck != null && struck.isNotEmpty);

    // Custom row (not ListTile title+trailing) so long promo copy like
    // "Kısa süre ücretsiz" wraps under the description instead of
    // overflowing the title line on narrow widths.
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AfterSettingsMenuMetrics.minVerticalPadding,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: selected ? scheme.primary : null),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight:
                          selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.3,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (hasPromo) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (struck != null && struck.isNotEmpty)
                          Text(
                            struck,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.lineThrough,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        if (badge != null && badge.isNotEmpty)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              child: Text(
                                badge,
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                  color: scheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              color: selected ? scheme.primary : scheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

typedef _SettingsStringLookup = String Function(
  String key, {
  Map<String, String> args,
});

class _PrivacyAccordionBody extends ConsumerWidget {
  const _PrivacyAccordionBody({
    required this.config,
    required this.plugins,
    required this.locale,
    required this.s,
  });

  final FamilyChromeConfig config;
  final FamilySettingsPlugins plugins;
  final String locale;
  final _SettingsStringLookup s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          contentPadding: AfterSettingsMenuMetrics.tilePadding,
          minVerticalPadding: AfterSettingsMenuMetrics.minVerticalPadding,
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
            FamilySettingsScreen._openDocument(
              context,
              locale: locale,
              title: s('permissions'),
              intro: s('permissions_body', args: {'app': config.appName}),
              prefix: 'privacy_perm',
              count: 3,
              args: {'app': config.appName},
              icon: Icons.verified_user_rounded,
            );
          },
        ),
        AfterSettingsMenuMetrics.divider,
        ListTile(
          contentPadding: AfterSettingsMenuMetrics.tilePadding,
          minVerticalPadding: AfterSettingsMenuMetrics.minVerticalPadding,
          leading: const Icon(Icons.privacy_tip_rounded),
          title: Text(s('privacy_policy')),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {
            final open = plugins.onOpenPrivacyPolicy;
            if (open != null) {
              open();
              return;
            }
            FamilySettingsScreen._openDocument(
              context,
              locale: locale,
              title: s('privacy_policy'),
              intro: s(
                'privacy_policy_intro',
                args: {
                  'app': config.appName,
                  'email': config.supportEmail,
                },
              ),
              prefix: 'privacy',
              count: 8,
              args: {
                'app': config.appName,
                'email': config.supportEmail,
              },
              icon: Icons.privacy_tip_rounded,
            );
          },
        ),
        AfterSettingsMenuMetrics.divider,
        ListTile(
          contentPadding: AfterSettingsMenuMetrics.tilePadding,
          minVerticalPadding: AfterSettingsMenuMetrics.minVerticalPadding,
          leading: const Icon(Icons.description_rounded),
          title: Text(s('terms')),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {
            final open = plugins.onOpenTerms;
            if (open != null) {
              open();
              return;
            }
            FamilySettingsScreen._openDocument(
              context,
              locale: locale,
              title: s('terms'),
              intro: s(
                'terms_intro',
                args: {
                  'app': config.appName,
                  'email': config.supportEmail,
                },
              ),
              prefix: 'terms',
              count: 6,
              args: {
                'app': config.appName,
                'email': config.supportEmail,
              },
              icon: Icons.description_rounded,
            );
          },
        ),
        AfterSettingsMenuMetrics.divider,
        ListTile(
          contentPadding: AfterSettingsMenuMetrics.tilePadding,
          minVerticalPadding: AfterSettingsMenuMetrics.minVerticalPadding,
          leading: const Icon(Icons.cloud_sync_rounded),
          title: Text(s('cloud_sync')),
          subtitle: Text(
            ref.watch(afterCloudBackupProvider).lastSyncedMillis == null
                ? s('not_synced')
                : s('last_sync_ok'),
          ),
          trailing: ref.watch(afterCloudBackupProvider).status ==
                  AfterCloudBackupStatus.syncing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.chevron_right_rounded),
          onTap: () async {
            await ref.read(afterCloudBackupProvider.notifier).syncNow();
            if (!context.mounted) return;
            final err = ref.read(afterCloudBackupProvider).errorCode;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  err == null ? s('last_sync_ok') : s('sync_error'),
                ),
              ),
            );
          },
        ),
        AfterSettingsMenuMetrics.divider,
        ListTile(
          contentPadding: AfterSettingsMenuMetrics.tilePadding,
          minVerticalPadding: AfterSettingsMenuMetrics.minVerticalPadding,
          leading: const Icon(Icons.download_rounded),
          title: Text(s('export_data')),
          subtitle: Text(s('export_sub')),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () async {
            final open = plugins.onExportData;
            if (open != null) {
              open();
              return;
            }
            final json = await ref
                .read(afterCloudBackupProvider.notifier)
                .exportSnapshot();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  json == null ? s('export_soon') : s('export_ready'),
                ),
              ),
            );
          },
        ),
        if (plugins.privacyExtras != null) ...[
          AfterSettingsMenuMetrics.divider,
          ...plugins.privacyExtras!(context, ref),
        ],
      ],
    );
  }
}

class _SecurityAccordionBody extends ConsumerWidget {
  const _SecurityAccordionBody({
    required this.config,
    required this.plugins,
    required this.locale,
    required this.s,
  });

  final FamilyChromeConfig config;
  final FamilySettingsPlugins plugins;
  final String locale;
  final _SettingsStringLookup s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s('security_promise_title'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  FamilyRichBody(
                    s('security_body', args: {'app': config.appName}),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    s('security_protected_title'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  FamilyRichBody(
                    [
                      for (var i = 1; i <= 5; i++)
                        "• ${s('security_item_$i')}",
                    ].join('\n'),
                  ),
                ],
              ),
            ),
          ],
        ),
        AfterSettingsMenuMetrics.divider,
        ListTile(
          contentPadding: AfterSettingsMenuMetrics.tilePadding,
          minVerticalPadding: AfterSettingsMenuMetrics.minVerticalPadding,
          leading: const Icon(Icons.password_rounded),
          title: Text(s('change_password')),
          subtitle: Text(s('change_password_sub')),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => FamilySettingsScreen._info(
            context,
            s('change_password'),
            s('change_password_body'),
            locale: locale,
          ),
        ),
        AfterSettingsMenuMetrics.divider,
        ListTile(
          contentPadding: AfterSettingsMenuMetrics.tilePadding,
          minVerticalPadding: AfterSettingsMenuMetrics.minVerticalPadding,
          leading: const Icon(Icons.security_rounded),
          title: Text(s('your_rights')),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => FamilySettingsScreen._openDocument(
            context,
            locale: locale,
            title: s('your_rights'),
            intro: s(
              'your_rights_body',
              args: {
                'app': config.appName,
                'email': config.supportEmail,
              },
            ),
            prefix: 'rights',
            count: 3,
            args: {
              'app': config.appName,
              'email': config.supportEmail,
            },
            icon: Icons.gavel_rounded,
          ),
        ),
        if (plugins.securityExtras != null) ...[
          AfterSettingsMenuMetrics.divider,
          ...plugins.securityExtras!(context, ref),
        ],
      ],
    );
  }
}

class _HelpAccordionBody extends ConsumerWidget {
  const _HelpAccordionBody({
    required this.config,
    required this.plugins,
    required this.locale,
    required this.s,
  });

  final FamilyChromeConfig config;
  final FamilySettingsPlugins plugins;
  final String locale;
  final _SettingsStringLookup s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        if (plugins.faqItems != null)
          ...FamilySettingsScreen._faqTilesFromItems(
            plugins.faqItems!(context, ref),
          )
        else
          ...FamilySettingsScreen._faqTiles(config.appName, locale),
        if (plugins.helpExtras != null) ...[
          AfterSettingsMenuMetrics.divider,
          ...plugins.helpExtras!(context, ref),
        ],
        AfterSettingsMenuMetrics.divider,
        ListTile(
          contentPadding: AfterSettingsMenuMetrics.tilePadding,
          minVerticalPadding: AfterSettingsMenuMetrics.minVerticalPadding,
          leading: const Icon(Icons.support_agent_rounded),
          title: Text(s('contact_support')),
          subtitle: Text(config.supportEmail),
          onTap: plugins.onContactSupport,
        ),
      ],
    );
  }
}

class _AboutAccordionBody extends ConsumerWidget {
  const _AboutAccordionBody({
    required this.config,
    required this.plugins,
    required this.version,
    required this.s,
  });

  final FamilyChromeConfig config;
  final FamilySettingsPlugins plugins;
  final String version;
  final _SettingsStringLookup s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          contentPadding: AfterSettingsMenuMetrics.tilePadding,
          minVerticalPadding: AfterSettingsMenuMetrics.minVerticalPadding,
          title: Text(config.appName),
          subtitle: Text(s('version', args: {'version': version})),
        ),
        ListTile(
          contentPadding: AfterSettingsMenuMetrics.tilePadding,
          minVerticalPadding: AfterSettingsMenuMetrics.minVerticalPadding,
          leading: const Icon(Icons.email_outlined),
          title: Text(config.supportEmail),
        ),
        ListTile(
          contentPadding: AfterSettingsMenuMetrics.tilePadding,
          minVerticalPadding: AfterSettingsMenuMetrics.minVerticalPadding,
          title: Text(config.tagline),
          subtitle: Text(s('built_by')),
        ),
        if (plugins.aboutExtras != null) ...[
          AfterSettingsMenuMetrics.divider,
          ...plugins.aboutExtras!(context, ref),
        ],
      ],
    );
  }
}

