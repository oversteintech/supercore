#!/usr/bin/env python3
"""Patch FamilySettingsScreen to use FamilyUiStrings (Garage-parity i18n)."""

from pathlib import Path

path = Path(
    r"D:/Projects/HANTURAI/supercore/packages/after_consumer/"
    r"lib/src/family/family_settings_screen.dart"
)
text = path.read_text(encoding="utf-8")

if "family_ui_strings.dart" not in text:
    text = text.replace(
        "import 'family_theme_controller.dart';",
        "import 'family_theme_controller.dart';\nimport 'family_ui_strings.dart';",
    )

# Replace helper methods to accept locale
old_select = '''  Future<void> _selectTheme(
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
    }'''

new_select = '''  Future<void> _selectTheme(
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
    if (style.isPremiumOnly && !canUsePremiumThemes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(FamilyUiStrings.t('upgrade_themes', locale))),
      );
      return;
    }'''

if old_select not in text:
    raise SystemExit('selectTheme block not found')
text = text.replace(old_select, new_select)

# Sign out / delete — inject locale param via reading localeCode in methods
# Simpler: change methods to take locale string

old_sign = '''  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
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
    );'''

new_sign = '''  Future<void> _signOut(
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
    );'''

if old_sign not in text:
    raise SystemExit('signOut block not found')
text = text.replace(old_sign, new_sign)

old_del = '''  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
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
    );'''

new_del = '''  Future<void> _deleteAccount(
    BuildContext context,
    WidgetRef ref,
    String locale,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(FamilyUiStrings.t('delete_q', locale)),
        content: Text(FamilyUiStrings.t('delete_body', locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(FamilyUiStrings.t('cancel', locale)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(FamilyUiStrings.t('delete', locale)),
          ),
        ],
      ),
    );'''

if old_del not in text:
    raise SystemExit('deleteAccount block not found')
text = text.replace(old_del, new_del)

# In build(): add s helper after locale
needle = '''    final effectiveStyle = themeStyle ?? ref.watch(familyThemeStyleProvider);
    final locale = localeCode ?? 'en';
    final body = ListView('''

insert = '''    final effectiveStyle = themeStyle ?? ref.watch(familyThemeStyleProvider);
    final locale = localeCode ?? AfterSupportedLocales.fallbackLanguage;
    String s(String key, {Map<String, String> args = const {}}) =>
        FamilyUiStrings.t(key, locale, args: args);
    final body = ListView('''

if needle not in text:
    raise SystemExit('build locale block not found')
text = text.replace(needle, insert)

# Bulk string replacements for section titles — order matters for uniqueness
replacements = [
    ("title: 'Profile',\n          subtitle: 'Account, photo and personal details',",
     "title: s('profile'),\n          subtitle: s('profile_sub'),"),
    ("const _Section(\n          title: 'Emergency profile',\n          subtitle: 'Blood type, contacts and medical notes for ICE',",
     "_Section(\n          title: s('emergency'),\n          subtitle: s('emergency_sub'),"),
    ("title: 'Language',\n          subtitle: 'App language for labels and AI replies',",
     "title: s('language'),\n          subtitle: s('language_sub'),"),
    ("const Text(\n                  'Language',\n                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),\n                ),",
     "Text(\n                  s('language'),\n                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),\n                ),"),
    ("title: 'Theme',\n          subtitle: 'Light, dark and premium packs',",
     "title: s('theme'),\n          subtitle: s('theme_sub'),"),
    ("title: 'System',\n                  subtitle: 'Follow device setting',",
     "title: s('system'),\n                  subtitle: s('system_sub'),"),
    ("title: 'Light',\n                  subtitle: 'Bright surfaces',",
     "title: s('light'),\n                  subtitle: s('light_sub'),"),
    ("title: 'Dark',\n                  subtitle: 'Dim surfaces',",
     "title: s('dark'),\n                  subtitle: s('dark_sub'),"),
    ("_selectTheme(context, ref, AfterThemeStyle.system)",
     "_selectTheme(context, ref, AfterThemeStyle.system, locale)"),
    ("_selectTheme(context, ref, AfterThemeStyle.light)",
     "_selectTheme(context, ref, AfterThemeStyle.light, locale)"),
    ("_selectTheme(context, ref, AfterThemeStyle.dark)",
     "_selectTheme(context, ref, AfterThemeStyle.dark, locale)"),
    ("unawaited(_selectTheme(context, ref, style))",
     "unawaited(_selectTheme(context, ref, style, locale))"),
    ("child: Text(\n                    'Premium themes',",
     "child: Text(\n                    s('premium_themes'),"),
    ("const _Section(\n          title: 'App icon',\n          subtitle: 'Black or white launcher background',\n          icon: Icons.apps_rounded,\n          child: _AppIconPanel(),\n        ),",
     "_Section(\n          title: s('app_icon'),\n          subtitle: s('app_icon_sub'),\n          icon: Icons.apps_rounded,\n          child: _AppIconPanel(locale: locale),\n        ),"),
    ("title: 'Subscription',",
     "title: s('subscription'),"),
    ("title: const Text('Current plan'),",
     "title: Text(s('current_plan')),"),
    ("title: const Text('Manage subscription'),\n                subtitle: const Text('Free · Silver · Gold · Business'),",
     "title: Text(s('manage_subscription')),\n                subtitle: Text(s('plans_hint')),"),
    ("title: 'Cloud sync',",
     "title: s('cloud_sync'),"),
    ("FamilyCloudSyncStatus.syncing => 'Syncing…',\n                FamilyCloudSyncStatus.error => sync.errorCode ?? 'Sync error',\n                FamilyCloudSyncStatus.idle => sync.lastSyncedMillis == null\n                    ? 'Not synced yet'\n                    : 'Last sync OK',",
     "FamilyCloudSyncStatus.syncing => s('syncing'),\n                FamilyCloudSyncStatus.error => sync.errorCode ?? s('sync_error'),\n                FamilyCloudSyncStatus.idle => sync.lastSyncedMillis == null\n                    ? s('not_synced')\n                    : s('last_sync_ok'),"),
    ("title: const Text('Sync now'),",
     "title: Text(s('sync_now')),"),
    ("title: 'Privacy',",
     "title: s('privacy'),"),
    ("title: const Text('Permissions'),\n                subtitle: const Text(\n                  'Location, notifications, and camera are requested only when needed.',\n                ),",
     "title: Text(s('permissions')),\n                subtitle: Text(s('permissions_sub')),"),
    ("'Permissions',\n                  'This Super App asks for sensitive permissions only when you '\n                      'use a feature that needs them. You can revoke access in '\n                      'system settings anytime.',",
     "s('permissions'),\n                  s('permissions_body'),"),
    ("title: const Text('Privacy policy'),",
     "title: Text(s('privacy_policy')),"),
    ("'Privacy policy',\n                  'Your data stays under your control. Cloud sync and sharing '\n                      'run only when you enable those features.\\n\\n'\n                      'Support: ${config.supportEmail}',",
     "s('privacy_policy'),\n                  '${s('privacy_policy_body')}\\n\\n${s('support')}: ${config.supportEmail}',"),
    ("title: const Text('Terms of use'),",
     "title: Text(s('terms')),"),
    ("'Terms of use',\n                  'By using ${config.appName} you agree to Overstein Labs terms '\n                      'for AfterArtificial Super Apps.\\n\\n'\n                      'Support: ${config.supportEmail}',",
     "s('terms'),\n                  '${s('terms_body', args: {'app': config.appName})}\\n\\n${s('support')}: ${config.supportEmail}',"),
    ("title: const Text('Export data'),\n                subtitle: const Text('Download a local copy of your data'),",
     "title: Text(s('export_data')),\n                subtitle: Text(s('export_sub')),"),
    ("const SnackBar(\n                      content: Text('Export will be available with cloud sync'),\n                    ),",
     "SnackBar(\n                      content: Text(s('export_soon')),\n                    ),"),
    ("title: 'Security',",
     "title: s('security'),"),
    ("const Expanded(\n                      child: Text(\n                        'Your account and on-device data are protected. '\n                        'Sign-in tokens never leave secure storage.',\n                        style: TextStyle(height: 1.35),\n                      ),\n                    ),",
     "Expanded(\n                      child: Text(\n                        s('security_body'),\n                        style: const TextStyle(height: 1.35),\n                      ),\n                    ),"),
    ("title: const Text('Change password'),\n                subtitle: const Text('Managed by your sign-in provider'),",
     "title: Text(s('change_password')),\n                subtitle: Text(s('change_password_sub')),"),
    ("'Change password',\n                  'Password changes are handled by your Google / email provider. '\n                      'Use the provider account settings to update credentials.',",
     "s('change_password'),\n                  s('change_password_body'),"),
    ("title: const Text('Your rights'),",
     "title: Text(s('your_rights')),"),
    ("'Your rights',\n                  'You can export, correct, or delete your data. Email '\n                      '${config.supportEmail} for KVKK/GDPR requests.',",
     "s('your_rights'),\n                  s('your_rights_body', args: {'email': config.supportEmail}),"),
    ("title: 'Early user program',",
     "title: s('early_user'),"),
    ("title: const Text('Early access'),\n                subtitle: Text(\n                  membership.isSuperAdmin\n                      ? 'Admin: manage early-user tiers from the backend console.'\n                      : 'Founders and pioneers get beta features and launch perks.',\n                ),",
     "title: Text(s('early_access')),\n                subtitle: Text(\n                  membership.isSuperAdmin\n                      ? s('early_access_admin')\n                      : s('early_access_user'),\n                ),"),
    ("title: const Text('Join / inquire'),",
     "title: Text(s('join_inquire')),"),
    ("'Early user program',\n                  'Write to ${config.supportEmail} with your account email to '\n                      'join the early user program for ${config.appName}.',",
     "s('early_user'),\n                  s('early_user_body', args: {\n                    'email': config.supportEmail,\n                    'app': config.appName,\n                  }),"),
    ("title: 'Help / FAQ',",
     "title: s('help_faq'),"),
    ("..._faqTiles(config.appName),",
     "..._faqTiles(config.appName, locale),"),
    ("title: const Text('Contact support'),",
     "title: Text(s('contact_support')),"),
    ("title: 'App tour',",
     "title: s('app_tour'),"),
    ("title: const Text('Replay app tour'),\n            subtitle: const Text('Quick walkthrough of the main tabs'),",
     "title: Text(s('replay_tour')),\n            subtitle: Text(s('replay_tour_sub')),"),
    ("pages: tourPages.isEmpty\n                        ? FamilyAppTourPage.defaultsFor(config.appName)\n                        : tourPages,",
     "pages: tourPages.isEmpty\n                        ? FamilyAppTourPage.defaultsFor(\n                            config.appName,\n                            locale: locale,\n                          )\n                        : tourPages,"),
    ("title: 'About',",
     "title: s('about'),"),
    ("subtitle: Text('Version $version'),",
     "subtitle: Text(s('version', args: {'version': version})),"),
    ("subtitle: const Text(\n                  'Built by Overstein Labs · AfterArtificial Super Apps',\n                ),",
     "subtitle: Text(s('built_by')),"),
    ("onPressed: () => unawaited(_signOut(context, ref)),\n          child: const Text('Sign out'),",
     "onPressed: () => unawaited(_signOut(context, ref, locale)),\n          child: Text(s('sign_out')),"),
    ("'Delete account',",
     "s('delete_account'),"),
    ("onPressed: () => unawaited(_deleteAccount(context, ref)),",
     "onPressed: () => unawaited(_deleteAccount(context, ref, locale)),"),
    ("appBar: AppBar(title: const Text('Settings')),",
     "appBar: AppBar(title: Text(s('settings'))),"),
]

for old, new in replacements:
    if old not in text:
        print('WARN missing:', old[:80].replace('\\n', ' '))
    else:
        text = text.replace(old, new)

# FAQ + info + tour + app icon panel
old_faq = '''  static List<Widget> _faqTiles(String appName) {
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
          ],'''

new_faq = '''  static List<Widget> _faqTiles(String appName, String locale) {
    final faqs = _defaultFaqs(appName, locale);
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
          ],'''

if old_faq not in text:
    raise SystemExit('faq block not found')
text = text.replace(old_faq, new_faq)

# Fix _info( calls to pass locale — they currently are _info(context, title, body)
text = text.replace(
    "_info(\n                  context,\n                  s('permissions'),\n                  s('permissions_body'),\n                )",
    "_info(\n                  context,\n                  s('permissions'),\n                  s('permissions_body'),\n                  locale: locale,\n                )",
)
# Generic: add locale to remaining _info calls that don't have it yet
import re
text2 = text
# Match _info( context, X, Y, ); without locale
pattern = re.compile(
    r"_info\(\s*context,\s*([^,]+),\s*([^)]+?)\)",
    re.S,
)

def add_locale(m):
    args = m.group(0)
    if 'locale:' in args:
        return args
    # insert before closing )
    inner = args[:-1].rstrip()
    return inner + ',\n                  locale: locale,\n                )'

text = pattern.sub(add_locale, text)

# App icon panel + tour
text = text.replace(
    "class _AppIconPanel extends ConsumerStatefulWidget {\n  const _AppIconPanel();",
    "class _AppIconPanel extends ConsumerStatefulWidget {\n  const _AppIconPanel({required this.locale});\n\n  final String locale;",
)
text = text.replace(
    """    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          white
              ? 'App icon preference: white background'
              : 'App icon preference: black background',
        ),
      ),
    );""",
    """    final locale = widget.locale;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          white
              ? FamilyUiStrings.t('app_icon_pref_white', locale)
              : FamilyUiStrings.t('app_icon_pref_black', locale),
        ),
      ),
    );""",
)
text = text.replace(
    """          const Text(
            'Choose the launcher icon background',
            style: TextStyle(fontWeight: FontWeight.w600, height: 1.35),
          ),
          const SizedBox(height: 10),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Black')),
              ButtonSegment(value: true, label: Text('White')),
            ],""",
    """          Text(
            FamilyUiStrings.t('app_icon_choose', widget.locale),
            style: const TextStyle(fontWeight: FontWeight.w600, height: 1.35),
          ),
          const SizedBox(height: 10),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: false,
                label: Text(FamilyUiStrings.t('app_icon_black', widget.locale)),
              ),
              ButtonSegment(
                value: true,
                label: Text(FamilyUiStrings.t('app_icon_white', widget.locale)),
              ),
            ],""",
)
text = text.replace(
    """                child: Text(
                  _white
                      ? 'White background — best on dark home screens.'
                      : 'Black background — best on light home screens.',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                    fontSize: 13.5,
                  ),
                ),""",
    """                child: Text(
                  _white
                      ? FamilyUiStrings.t('app_icon_white_hint', widget.locale)
                      : FamilyUiStrings.t('app_icon_black_hint', widget.locale),
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                    fontSize: 13.5,
                  ),
                ),""",
)

# Tour pages defaults
text = text.replace(
    """  static List<FamilyAppTourPage> defaultsFor(String appName) => [
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
      ];""",
    """  static List<FamilyAppTourPage> defaultsFor(
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
      ];""",
)

text = text.replace(
    "appBar: AppBar(title: const Text('App tour')),",
    "appBar: AppBar(title: Text(FamilyUiStrings.t('app_tour', 'en'))),",
)
# Better: pass locale into FamilyAppTourScreen
text = text.replace(
    """class FamilyAppTourScreen extends StatefulWidget {
  const FamilyAppTourScreen({
    required this.appName,
    required this.pages,
    super.key,
  });

  final String appName;
  final List<FamilyAppTourPage> pages;""",
    """class FamilyAppTourScreen extends StatefulWidget {
  const FamilyAppTourScreen({
    required this.appName,
    required this.pages,
    this.locale = 'en',
    super.key,
  });

  final String appName;
  final List<FamilyAppTourPage> pages;
  final String locale;""",
)
text = text.replace(
    "appBar: AppBar(title: Text(FamilyUiStrings.t('app_tour', 'en'))),",
    "appBar: AppBar(title: Text(FamilyUiStrings.t('app_tour', widget.locale))),",
)
text = text.replace(
    """                  FilledButton(
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
                  ),""",
    """                  FilledButton(
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
                  ),""",
)
# Pass locale when pushing tour
text = text.replace(
    """                  builder: (_) => FamilyAppTourScreen(
                    appName: config.appName,
                    pages: tourPages.isEmpty""",
    """                  builder: (_) => FamilyAppTourScreen(
                    appName: config.appName,
                    locale: locale,
                    pages: tourPages.isEmpty""",
)

path.write_text(text, encoding="utf-8")
print("patched", path)
