import 'dart:async';

import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:after_firebase/after_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'family_chrome.dart';
import 'family_profile_identity.dart';

String _authErrorMessage(Object error) {
  if (error is AfterException) return error.message;
  final text = error.toString().toLowerCase();
  if (text.contains('email-already-in-use') ||
      text.contains('email already')) {
    return 'This email is already in use.';
  }
  if (text.contains('weak-password')) {
    return 'Password is too weak.';
  }
  if (text.contains('invalid-email')) {
    return 'Enter a valid email address.';
  }
  if (text.contains('network-request-failed') || text.contains('network')) {
    return 'Network error. Check your connection.';
  }
  if (text.contains('too-many-requests')) {
    return 'Too many attempts. Please wait and try again.';
  }
  if (text.contains('operation-not-allowed') ||
      text.contains('api-key') ||
      text.contains('app-not-authorized')) {
    return 'Sign-up is not configured on this build.';
  }
  return 'Account creation failed. Please try again.';
}

enum _UsernameAvailability { idle, checking, available, taken, invalid }

/// Optional identity extras for the shared registration wizard (Garage plugin).
abstract class FamilyRegistrationPlugin {
  const FamilyRegistrationPlugin();

  /// Extra widgets under the Identity step (license, blood type, …).
  List<Widget> buildIdentityExtras(BuildContext context);

  /// Collected field map merged into the registration payload.
  Map<String, String?> collectIdentityExtras();

  /// Validate extras; return error message or null.
  String? validateIdentityExtras();
}

/// Auth chrome config — branding + optional registration plugin.
@immutable
class FamilyAuthChromeConfig extends FamilyChromeConfig {
  const FamilyAuthChromeConfig({
    required super.appName,
    required super.supportEmail,
    required super.accent,
    super.tagline,
    super.aiTitle,
    super.defaultLoginEmail,
    super.defaultLoginPassword,
    this.logo,
    this.registrationPlugin,
    this.enableGoogle = true,
    this.enableApple = true,
    this.enableGuest = true,
  });

  /// Optional product mark (defaults to Overstein wordmark block).
  final WidgetBuilder? logo;

  final FamilyRegistrationPlugin? registrationPlugin;
  final bool enableGoogle;
  final bool enableApple;
  final bool enableGuest;
}

enum FamilyAuthStatusTone { info, success, error }

class FamilyAuthStatusBanner extends StatelessWidget {
  const FamilyAuthStatusBanner({
    required this.message,
    required this.tone,
    super.key,
  });

  final String message;
  final FamilyAuthStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (Color bg, Color fg, IconData icon) = switch (tone) {
      FamilyAuthStatusTone.success => (
          theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
          theme.colorScheme.primary,
          Icons.check_circle_rounded,
        ),
      FamilyAuthStatusTone.error => (
          theme.colorScheme.errorContainer.withValues(alpha: 0.55),
          theme.colorScheme.error,
          Icons.error_outline_rounded,
        ),
      FamilyAuthStatusTone.info => (
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.onSurfaceVariant,
          Icons.info_outline_rounded,
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w600,
                height: 1.45,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium auth chrome — matches SuperGarage [AuthExperienceShell].
class FamilyAuthExperienceShell extends StatelessWidget {
  const FamilyAuthExperienceShell({
    required this.title,
    required this.child,
    required this.config,
    super.key,
    this.subtitle,
    this.heroIcon,
    this.appBarActions,
    this.leading,
    this.maxWidth = 520,
    this.footer,
  });

  final String title;
  final String? subtitle;
  final IconData? heroIcon;
  final Widget child;
  final FamilyAuthChromeConfig config;
  final List<Widget>? appBarActions;
  final Widget? leading;
  final double maxWidth;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: leading,
        actions: appBarActions,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.brightness == Brightness.dark
                ? [
                    theme.colorScheme.surface,
                    theme.colorScheme.surfaceContainerLow,
                  ]
                : const [Color(0xFFFFFFFF), Color(0xFFF3F4F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SuperGarageCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: ColoredBox(
                            color: Colors.black,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              child: config.logo?.call(context) ??
                                  Text(
                                    config.appName.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'OVERSTEIN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.4,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (heroIcon != null) ...[
                          Icon(heroIcon, size: 36, color: config.accent),
                          const SizedBox(height: 10),
                        ],
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            subtitle!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: muted,
                              height: 1.4,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        child,
                        if (footer != null) ...[
                          const SizedBox(height: 16),
                          footer!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Garage-parity login + entry to registration wizard.
class FamilyLoginScreen extends ConsumerStatefulWidget {
  const FamilyLoginScreen({
    required this.config,
    this.onAuthenticated,
    this.authConfig,
    super.key,
  });

  final FamilyChromeConfig config;
  final FamilyAuthChromeConfig? authConfig;
  final VoidCallback? onAuthenticated;

  @override
  ConsumerState<FamilyLoginScreen> createState() => _FamilyLoginScreenState();
}

class _FamilyLoginScreenState extends ConsumerState<FamilyLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _email =
      TextEditingController(text: widget.config.defaultLoginEmail);
  late final _password =
      TextEditingController(text: widget.config.defaultLoginPassword);
  late final _name = TextEditingController();
  var _busy = false;
  var _showPassword = false;
  var _registerMode = false;
  String? _error;

  FamilyAuthChromeConfig get _auth =>
      widget.authConfig ??
      FamilyAuthChromeConfig(
        appName: widget.config.appName,
        supportEmail: widget.config.supportEmail,
        accent: widget.config.accent,
        tagline: widget.config.tagline,
        aiTitle: widget.config.aiTitle,
        defaultLoginEmail: widget.config.defaultLoginEmail,
        defaultLoginPassword: widget.config.defaultLoginPassword,
      );

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_registerMode) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => FamilyRegistrationWizardScreen(
            config: _auth,
            onComplete: () {
              Navigator.of(context).pop();
              widget.onAuthenticated?.call();
            },
          ),
        ),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = ref.read(afterAuthRepositoryProvider);
      await auth.signInWithEmailPassword(
        AfterEmailPasswordCredentials(
          email: _email.text.trim(),
          password: _password.text,
        ),
      );
      widget.onAuthenticated?.call();
    } on Object catch (e) {
      if (mounted) setState(() => _error = _authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _guest() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(afterAuthRepositoryProvider)
          .signInAnonymously(installationId: 'family-guest');
      widget.onAuthenticated?.call();
    } on Object catch (e) {
      if (mounted) setState(() => _error = _authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(afterAuthRepositoryProvider).signInWithGoogle();
      widget.onAuthenticated?.call();
    } on Object catch (e) {
      if (mounted) setState(() => _error = _authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _apple() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(afterAuthRepositoryProvider).signInWithApple();
      widget.onAuthenticated?.call();
    } on Object catch (e) {
      if (mounted) setState(() => _error = _authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgot() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email first');
      return;
    }
    try {
      await ref.read(afterAuthRepositoryProvider).sendPasswordResetEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } on Object catch (e) {
      if (mounted) setState(() => _error = _authErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final theme = Theme.of(context);

    return FamilyAuthExperienceShell(
      config: _auth,
      title: _registerMode ? 'Create account' : 'Welcome back',
      subtitle: _auth.tagline,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_auth.enableGoogle) ...[
              FilledButton.tonalIcon(
                onPressed: _busy ? null : _google,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                label: const Text('Sign in with Google'),
              ),
              const SizedBox(height: 12),
            ],
            if (_auth.enableApple) ...[
              OutlinedButton.icon(
                onPressed: _busy ? null : _apple,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.apple, size: 22),
                label: const Text('Sign in with Apple'),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(child: Divider(color: theme.dividerColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or continue with', style: TextStyle(color: muted)),
                ),
                Expanded(child: Divider(color: theme.dividerColor)),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              segments: const [
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Sign in'),
                  icon: Icon(Icons.login_rounded, size: 18),
                ),
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Register'),
                  icon: Icon(Icons.person_add_alt_1_rounded, size: 18),
                ),
              ],
              selected: {_registerMode},
              onSelectionChanged: _busy
                  ? null
                  : (selection) {
                      setState(() {
                        _registerMode = selection.first;
                        _error = null;
                      });
                    },
            ),
            const SizedBox(height: 16),
            if (_registerMode)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Registration wizard',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your ${_auth.appName} account in a few steps — '
                      'region, identity, contact, and security.',
                      style: TextStyle(
                        color: muted,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Display name',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_rounded),
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_rounded),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _busy ? null : _forgot,
                  child: const Text('Forgot password?'),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              FamilyAuthStatusBanner(
                message: _error!,
                tone: FamilyAuthStatusTone.error,
              ),
            ],
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: _auth.accent,
              ),
              child: Text(
                _registerMode ? 'Start registration' : 'Sign in',
              ),
            ),
            if (_auth.enableGuest) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _busy ? null : _guest,
                child: const Text('Continue as guest'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 5-step Garage-parity registration wizard with optional domain plugin.
class FamilyRegistrationWizardScreen extends ConsumerStatefulWidget {
  const FamilyRegistrationWizardScreen({
    required this.config,
    this.onComplete,
    super.key,
  });

  final FamilyAuthChromeConfig config;
  final VoidCallback? onComplete;

  @override
  ConsumerState<FamilyRegistrationWizardScreen> createState() =>
      _FamilyRegistrationWizardScreenState();
}

class _FamilyRegistrationWizardScreenState
    extends ConsumerState<FamilyRegistrationWizardScreen> {
  final _identityKey = GlobalKey<FormState>();
  final _contactKey = GlobalKey<FormState>();
  final _securityKey = GlobalKey<FormState>();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _country = TextEditingController(text: 'TR');
  final _indexClient = RegistrationIndexClient();

  var _step = 0;
  var _busy = false;
  var _showPassword = false;
  var _terms = false;
  var _privacy = false;
  String? _error;
  DateTime? _birthDate;
  _UsernameAvailability _usernameStatus = _UsernameAvailability.idle;
  Timer? _usernameDebounce;
  int _usernameRequestId = 0;

  static const _stepCount = 5;
  static const _titles = [
    'Region',
    'Identity',
    'Contact',
    'Security',
    'Review',
  ];

  @override
  void dispose() {
    _usernameDebounce?.cancel();
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _country.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String raw) {
    _usernameDebounce?.cancel();
    final value = RegistrationIndexClient.normalizeUsername(raw);
    if (value.isEmpty) {
      setState(() => _usernameStatus = _UsernameAvailability.idle);
      return;
    }
    if (!RegistrationIndexClient.usernamePattern.hasMatch(value)) {
      setState(() => _usernameStatus = _UsernameAvailability.invalid);
      return;
    }
    setState(() => _usernameStatus = _UsernameAvailability.checking);
    final requestId = ++_usernameRequestId;
    _usernameDebounce = Timer(const Duration(milliseconds: 450), () async {
      final available = await _indexClient.tryIsUsernameAvailable(value);
      if (!mounted || requestId != _usernameRequestId) return;
      setState(() {
        if (available == false) {
          _usernameStatus = _UsernameAvailability.taken;
        } else {
          // true or null (unknown) → allow continue; claim enforces later
          _usernameStatus = _UsernameAvailability.available;
        }
      });
    });
  }

  Widget? _usernameSuffix() {
    return switch (_usernameStatus) {
      _UsernameAvailability.checking => const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      _UsernameAvailability.available => const Icon(
          Icons.check_circle_rounded,
          color: Colors.green,
        ),
      _UsernameAvailability.taken => const Icon(
          Icons.cancel_rounded,
          color: Colors.red,
        ),
      _UsernameAvailability.invalid => const Icon(
          Icons.warning_rounded,
          color: Colors.orange,
        ),
      _UsernameAvailability.idle => null,
    };
  }

  bool _validate() {
    return switch (_step) {
      0 => _country.text.trim().length == 2,
      1 => (_identityKey.currentState?.validate() ?? false) &&
          _usernameStatus != _UsernameAvailability.taken &&
          _usernameStatus != _UsernameAvailability.invalid &&
          (widget.config.registrationPlugin?.validateIdentityExtras() == null),
      2 => _contactKey.currentState?.validate() ?? false,
      3 => (_securityKey.currentState?.validate() ?? false) &&
          _terms &&
          _privacy,
      _ => true,
    };
  }

  Future<void> _next() async {
    setState(() => _error = null);
    if (!_validate()) {
      setState(() {
        _error = _step == 1 && _usernameStatus == _UsernameAvailability.taken
            ? 'This username is already taken'
            : _step == 3 && (!_terms || !_privacy)
                ? 'Accept Terms and Privacy to continue'
                : widget.config.registrationPlugin?.validateIdentityExtras() ??
                    'Please complete this step';
      });
      return;
    }
    if (_step >= _stepCount - 1) {
      await _finish();
      return;
    }
    setState(() => _step++);
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _step--);
  }

  Future<void> _finish() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // Never block account creation on pre-auth index reads (permission-denied
      // / missing Cloud Functions). Uniqueness is claimed after auth.
      if (_usernameStatus == _UsernameAvailability.taken) {
        throw const AfterAuthException(
          'This username is already taken',
          code: 'username-taken',
        );
      }

      final user =
          await ref.read(afterAuthRepositoryProvider).signUpWithEmailPassword(
                AfterEmailPasswordCredentials(
                  email: _email.text.trim(),
                  password: _password.text,
                ),
              );

      // Best-effort profile index claim — must not fail the signup UX.
      await _indexClient.claimUsername(
        uid: user.uid,
        username: _username.text,
      );

      await ref.read(familyProfileIdentityProvider.notifier).seedFromRegistration(
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            username: _username.text.trim(),
            email: _email.text.trim(),
            phoneNumber: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          );

      widget.onComplete?.call();
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } on Object catch (e) {
      if (mounted) setState(() => _error = _authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _stepBody(ThemeData theme) {
    final plugin = widget.config.registrationPlugin;
    return switch (_step) {
      0 => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _country,
              decoration: const InputDecoration(
                labelText: 'Country code',
                helperText: 'ISO-2, e.g. TR / US / DE',
                prefixIcon: Icon(Icons.public_rounded),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 2,
            ),
          ],
        ),
      1 => Form(
          key: _identityKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _firstName,
                decoration: const InputDecoration(labelText: 'First name'),
                validator: (v) =>
                    (v == null || v.trim().length < 2) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastName,
                decoration: const InputDecoration(labelText: 'Last name'),
                validator: (v) =>
                    (v == null || v.trim().length < 2) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _username,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: 'Username',
                  helperText: 'Letters, numbers, . and _ (3–30)',
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                  suffixIcon: _usernameSuffix(),
                ),
                validator: (v) {
                  final value = RegistrationIndexClient.normalizeUsername(
                    v ?? '',
                  );
                  if (value.length < 3) return 'Min 3 chars';
                  if (!RegistrationIndexClient.usernamePattern.hasMatch(value)) {
                    return 'Invalid username';
                  }
                  if (_usernameStatus == _UsernameAvailability.taken) {
                    return 'Already taken';
                  }
                  return null;
                },
                onChanged: _onUsernameChanged,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cake_rounded),
                title: Text(
                  _birthDate == null
                      ? 'Birth date (optional)'
                      : '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}',
                ),
                subtitle: _birthDate == null
                    ? const Text('Optional — you can skip this')
                    : null,
                trailing: _birthDate == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => setState(() => _birthDate = null),
                      ),
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(now.year - 18),
                    firstDate: DateTime(1920),
                    lastDate: now,
                  );
                  if (picked != null) setState(() => _birthDate = picked);
                },
              ),
              if (plugin != null) ...plugin.buildIdentityExtras(context),
            ],
          ),
        ),
      2 => Form(
          key: _contactKey,
          child: Column(
            children: [
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_rounded),
                ),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Valid email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
                validator: (v) =>
                    (v == null || v.trim().length < 7) ? 'Required' : null,
              ),
            ],
          ),
        ),
      3 => Form(
          key: _securityKey,
          child: Column(
            children: [
              TextFormField(
                controller: _password,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_rounded),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.length < 8) ? 'Min 8 characters' : null,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _terms,
                onChanged: (v) => setState(() => _terms = v ?? false),
                title: const Text('I accept the Terms of Service'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: _privacy,
                onChanged: (v) => setState(() => _privacy = v ?? false),
                title: const Text('I accept the Privacy Policy'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      _ => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Country: ${_country.text.toUpperCase()}'),
            Text('Name: ${_firstName.text} ${_lastName.text}'),
            Text('Username: ${_username.text}'),
            Text('Email: ${_email.text}'),
            Text('Phone: ${_phone.text}'),
            if (plugin != null)
              ...plugin.collectIdentityExtras().entries.map(
                    (e) => Text('${e.key}: ${e.value ?? '—'}'),
                  ),
            const SizedBox(height: 12),
            Text(
              'Create your ${widget.config.appName} account?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FamilyAuthExperienceShell(
      config: widget.config,
      title: _titles[_step],
      subtitle: 'Step ${_step + 1} of $_stepCount',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: _busy ? null : _back,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: List.generate(_stepCount, (index) {
              final active = index <= _step;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < _stepCount - 1 ? 6 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: active
                        ? widget.config.accent
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          _stepBody(theme),
          if (_error != null) ...[
            const SizedBox(height: 12),
            FamilyAuthStatusBanner(
              message: _error!,
              tone: FamilyAuthStatusTone.error,
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _next,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: widget.config.accent,
            ),
            child: Text(_step == _stepCount - 1 ? 'Create account' : 'Continue'),
          ),
        ],
      ),
    );
  }
}
