import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/after_providers.dart';
import 'after_auth.dart';

/// Localized copy for the shared forgot-password flow.
@immutable
class AfterForgotPasswordCopy {
  const AfterForgotPasswordCopy({
    required this.title,
    required this.subtitle,
    required this.emailLabel,
    required this.validEmail,
    required this.sendButton,
    required this.sentMessage,
    required this.resendButton,
    this.unavailableMessage,
  });

  factory AfterForgotPasswordCopy.english() {
    return const AfterForgotPasswordCopy(
      title: 'Forgot password',
      subtitle:
          'Enter your email and we will send a link to reset your password.',
      emailLabel: 'Email',
      validEmail: 'Enter a valid email',
      sendButton: 'Send reset link',
      sentMessage: 'Password reset email sent. Check your inbox.',
      resendButton: 'Send again',
      unavailableMessage: 'Password reset is unavailable in this build.',
    );
  }

  final String title;
  final String subtitle;
  final String emailLabel;
  final String validEmail;
  final String sendButton;
  final String sentMessage;
  final String resendButton;
  final String? unavailableMessage;
}

/// Pure helpers shared by every Super App forgot-password UI.
abstract final class AfterForgotPassword {
  static final RegExp emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String normalizeEmail(String email) => email.trim();

  static bool isValidEmail(String email) {
    final normalized = normalizeEmail(email);
    return emailPattern.hasMatch(normalized);
  }

  /// Sends a reset email via [auth]. Throws if email is invalid.
  static Future<void> sendResetEmail({
    required AfterAuthRepository auth,
    required String email,
  }) async {
    final normalized = normalizeEmail(email);
    if (!isValidEmail(normalized)) {
      throw ArgumentError.value(email, 'email', 'Invalid email');
    }
    await auth.sendPasswordResetEmail(normalized);
  }

  /// Opens the dedicated reset screen (not the sign-in form).
  static Future<T?> push<T extends Object?>(
    BuildContext context, {
    AfterForgotPasswordCopy? copy,
    String? initialEmail,
    Color? accent,
    Future<void> Function(String email)? onSend,
    bool resetAvailable = true,
    Widget? footer,
    String Function(Object error)? errorMapper,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(
        builder: (_) => AfterForgotPasswordScreen(
          copy: copy ?? AfterForgotPasswordCopy.english(),
          initialEmail: initialEmail,
          accent: accent,
          onSend: onSend,
          resetAvailable: resetAvailable,
          footer: footer,
          errorMapper: errorMapper,
        ),
      ),
    );
  }
}

enum AfterForgotPasswordBannerTone { info, success, error }

class AfterForgotPasswordBanner extends StatelessWidget {
  const AfterForgotPasswordBanner({
    required this.message,
    required this.tone,
    super.key,
  });

  final String message;
  final AfterForgotPasswordBannerTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (Color bg, Color fg, IconData icon) = switch (tone) {
      AfterForgotPasswordBannerTone.success => (
          theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
          theme.colorScheme.primary,
          Icons.check_circle_rounded,
        ),
      AfterForgotPasswordBannerTone.error => (
          theme.colorScheme.errorContainer.withValues(alpha: 0.55),
          theme.colorScheme.error,
          Icons.error_outline_rounded,
        ),
      AfterForgotPasswordBannerTone.info => (
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

/// Email-only reset form — wrap in product [AuthExperienceShell] / Family shell.
class AfterForgotPasswordForm extends ConsumerStatefulWidget {
  const AfterForgotPasswordForm({
    required this.copy,
    this.initialEmail,
    this.onSend,
    this.resetAvailable = true,
    this.accent,
    this.errorMapper,
    super.key,
  });

  final AfterForgotPasswordCopy copy;
  final String? initialEmail;

  /// Defaults to [afterAuthRepositoryProvider.sendPasswordResetEmail].
  final Future<void> Function(String email)? onSend;

  /// When false, send is disabled and [copy.unavailableMessage] is shown.
  final bool resetAvailable;
  final Color? accent;

  /// Maps thrown errors to a user-visible string.
  final String Function(Object error)? errorMapper;

  @override
  ConsumerState<AfterForgotPasswordForm> createState() =>
      AfterForgotPasswordFormState();
}

class AfterForgotPasswordFormState
    extends ConsumerState<AfterForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email = TextEditingController(
    text: AfterForgotPassword.normalizeEmail(widget.initialEmail ?? ''),
  );
  var _busy = false;
  var _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @visibleForTesting
  String get emailText => _email.text;

  @visibleForTesting
  bool get isSent => _sent;

  Future<void> submit() => _send();

  Future<void> _send() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!widget.resetAvailable) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final email = AfterForgotPassword.normalizeEmail(_email.text);
      final custom = widget.onSend;
      if (custom != null) {
        await custom(email);
      } else {
        await AfterForgotPassword.sendResetEmail(
          auth: ref.read(afterAuthRepositoryProvider),
          email: email,
        );
      }
      if (!mounted) return;
      setState(() => _sent = true);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = widget.errorMapper?.call(error) ?? error.toString();
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = widget.copy;
    final unavailable = !widget.resetAvailable;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (unavailable && copy.unavailableMessage != null) ...[
            AfterForgotPasswordBanner(
              message: copy.unavailableMessage!,
              tone: AfterForgotPasswordBannerTone.error,
            ),
            const SizedBox(height: 16),
          ],
          if (_sent) ...[
            AfterForgotPasswordBanner(
              message: copy.sentMessage,
              tone: AfterForgotPasswordBannerTone.success,
            ),
            const SizedBox(height: 16),
          ],
          if (_error != null) ...[
            AfterForgotPasswordBanner(
              message: _error!,
              tone: AfterForgotPasswordBannerTone.error,
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            enabled: widget.resetAvailable && !_sent,
            decoration: InputDecoration(
              labelText: copy.emailLabel,
              prefixIcon: const Icon(Icons.email_rounded),
            ),
            validator: (value) {
              if (!AfterForgotPassword.isValidEmail(value ?? '')) {
                return copy.validEmail;
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy || unavailable || _sent ? null : _send,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: widget.accent,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(copy.sendButton),
            ),
          ),
          if (_sent) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => setState(() {
                        _sent = false;
                        _error = null;
                      }),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(copy.resendButton),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Standalone Material screen for Super Apps without a custom auth shell.
class AfterForgotPasswordScreen extends ConsumerWidget {
  const AfterForgotPasswordScreen({
    required this.copy,
    this.initialEmail,
    this.onSend,
    this.resetAvailable = true,
    this.accent,
    this.errorMapper,
    this.footer,
    this.leading,
    super.key,
  });

  final AfterForgotPasswordCopy copy;
  final String? initialEmail;
  final Future<void> Function(String email)? onSend;
  final bool resetAvailable;
  final Color? accent;
  final String Function(Object error)? errorMapper;
  final Widget? footer;
  final Widget? leading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: leading ??
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
        title: Text(copy.title),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: [
            Icon(
              Icons.lock_reset_rounded,
              size: 48,
              color: accent ?? theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              copy.subtitle,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            AfterForgotPasswordForm(
              copy: copy,
              initialEmail: initialEmail,
              onSend: onSend,
              resetAvailable: resetAvailable,
              accent: accent,
              errorMapper: errorMapper,
            ),
            if (footer != null) ...[
              const SizedBox(height: 24),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}
