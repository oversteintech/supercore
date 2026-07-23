import 'dart:async';

import 'package:flutter/material.dart';

/// Localized copy for the shared account-deletion empathy flow.
@immutable
class AfterAccountDeletionCopy {
  const AfterAccountDeletionCopy({
    required this.title,
    required this.body,
    required this.feedbackHint,
    required this.feedbackEmptyError,
    required this.keepAccount,
    required this.sendFeedback,
    required this.deleteAnyway,
    required this.deleting,
    required this.goodbyeTitle,
    required this.goodbyeBody,
    required this.goodbyeAction,
    required this.feedbackSent,
    this.cancel,
  });

  /// English (fallback).
  factory AfterAccountDeletionCopy.english() {
    return const AfterAccountDeletionCopy(
      title: "We're sorry you're thinking about leaving",
      body:
          'Please share a quick note about what went wrong — '
          "we'll fix ourselves right away.",
      feedbackHint: 'What disappointed you? What were you looking for?',
      feedbackEmptyError: 'Please leave a short note so we can improve.',
      keepAccount: 'Keep my account',
      sendFeedback: 'Send feedback',
      deleteAnyway: 'Delete anyway',
      deleting: 'Deleting account…',
      goodbyeTitle: "We're sorry we lost you 😢",
      goodbyeBody: 'We hope to see you again.',
      goodbyeAction: 'OK',
      feedbackSent: 'Thank you — your feedback was sent.',
      cancel: 'Cancel',
    );
  }

  /// Turkish.
  factory AfterAccountDeletionCopy.turkish() {
    return const AfterAccountDeletionCopy(
      title: 'Bu düşünceye girdiğin için üzgünüz',
      body:
          'Lütfen bize kısa bir geri bildirim bırak — '
          'hemen kendimizi düzeltelim.',
      feedbackHint: 'Seni hayal kırıklığına uğratan ne oldu? Ne arıyordun?',
      feedbackEmptyError:
          'Lütfen kısa bir not bırak — neleri kaçırdığımızı anlayalım.',
      keepAccount: 'Hesabımı koru',
      sendFeedback: 'Geri bildirim gönder',
      deleteAnyway: 'Yine de sil',
      deleting: 'Hesap siliniyor…',
      goodbyeTitle: 'Seni kaybettiğimiz için üzgünüz 😢',
      goodbyeBody: 'Umarız tekrar görüşürüz.',
      goodbyeAction: 'Tamam',
      feedbackSent: 'Teşekkürler — geri bildirimin gönderildi.',
      cancel: 'İptal',
    );
  }

  /// Picks TR when [localeCode] starts with `tr`, otherwise English.
  factory AfterAccountDeletionCopy.forLocale(String? localeCode) {
    final code = (localeCode ?? 'en').trim().toLowerCase();
    if (code.startsWith('tr')) {
      return AfterAccountDeletionCopy.turkish();
    }
    return AfterAccountDeletionCopy.english();
  }

  final String title;
  final String body;
  final String feedbackHint;
  final String feedbackEmptyError;
  final String keepAccount;
  final String sendFeedback;
  final String deleteAnyway;
  final String deleting;
  final String goodbyeTitle;
  final String goodbyeBody;
  final String goodbyeAction;
  final String feedbackSent;
  final String? cancel;
}

/// Result of [AfterAccountDeletionFlow.show].
enum AfterAccountDeletionOutcome {
  /// User kept the account (closed without deleting).
  kept,

  /// User sent feedback only and kept the account.
  feedbackOnly,

  /// Account was deleted (goodbye was shown).
  deleted,
}

/// Shared Super App account-deletion UX (Garage + every sibling).
///
/// Flow:
/// 1. Empathy sheet — sorry you're thinking this, please give feedback,
///    we'll fix ourselves immediately.
/// 2. Bottom action — "Delete anyway" → runs [onDelete].
/// 3. Farewell — "We're sorry we lost you 😢 hope we see you again."
abstract final class AfterAccountDeletionFlow {
  /// Opens the empathy dialog; returns when the user dismisses or finishes.
  static Future<AfterAccountDeletionOutcome> show(
    BuildContext context, {
    AfterAccountDeletionCopy? copy,
    String? localeCode,

    /// Permanently delete the account. [feedback] may be null/empty.
    required Future<void> Function({String? feedback}) onDelete,

    /// Optional: submit feedback without deleting.
    Future<void> Function(String feedback)? onFeedback,
  }) async {
    final resolved = copy ?? AfterAccountDeletionCopy.forLocale(localeCode);
    final outcome = await showDialog<AfterAccountDeletionOutcome>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _AfterAccountDeletionDialog(
        copy: resolved,
        onDelete: onDelete,
        onFeedback: onFeedback,
      ),
    );
    final result = outcome ?? AfterAccountDeletionOutcome.kept;
    if (result == AfterAccountDeletionOutcome.deleted && context.mounted) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Text('😢', style: TextStyle(fontSize: 36)),
          title: Text(resolved.goodbyeTitle),
          content: Text(resolved.goodbyeBody),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(resolved.goodbyeAction),
            ),
          ],
        ),
      );
    }
    return result;
  }
}

class _AfterAccountDeletionDialog extends StatefulWidget {
  const _AfterAccountDeletionDialog({
    required this.copy,
    required this.onDelete,
    this.onFeedback,
  });

  final AfterAccountDeletionCopy copy;
  final Future<void> Function({String? feedback}) onDelete;
  final Future<void> Function(String feedback)? onFeedback;

  @override
  State<_AfterAccountDeletionDialog> createState() =>
      _AfterAccountDeletionDialogState();
}

class _AfterAccountDeletionDialogState
    extends State<_AfterAccountDeletionDialog> {
  static const _maxChars = 2000;

  final TextEditingController _controller = TextEditingController();
  bool _busy = false;

  AfterAccountDeletionCopy get _copy => widget.copy;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendFeedbackOnly() async {
    final message = _controller.text.trim();
    if (message.isEmpty) {
      _toast(_copy.feedbackEmptyError);
      return;
    }
    final submit = widget.onFeedback;
    if (submit == null) {
      _toast(_copy.feedbackSent);
      return;
    }
    setState(() => _busy = true);
    try {
      await submit(message);
      if (!mounted) return;
      _toast(_copy.feedbackSent);
      Navigator.of(context).pop(AfterAccountDeletionOutcome.feedbackOnly);
    } on Object catch (error) {
      if (!mounted) return;
      _toast(error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteAnyway() async {
    setState(() => _busy = true);
    final feedback = _controller.text.trim();
    try {
      await widget.onDelete(feedback: feedback.isEmpty ? null : feedback);
      if (!mounted) return;
      Navigator.of(context).pop(AfterAccountDeletionOutcome.deleted);
    } on Object catch (error) {
      if (!mounted) return;
      _toast(error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;
    final length = _controller.text.characters.length;
    final hasFeedback = _controller.text.trim().isNotEmpty;

    return AlertDialog(
      icon: Icon(
        Icons.sentiment_dissatisfied_rounded,
        color: scheme.error.withValues(alpha: 0.85),
      ),
      title: Text(_copy.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _copy.body,
              style: TextStyle(color: muted, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              enabled: !_busy,
              maxLength: _maxChars,
              maxLines: 5,
              minLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: _copy.feedbackHint,
                counterText: '$length / $_maxChars',
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: _busy
              ? null
              : () => Navigator.of(context).pop(AfterAccountDeletionOutcome.kept),
          child: Text(_copy.keepAccount),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (hasFeedback && widget.onFeedback != null)
              TextButton(
                onPressed: _busy ? null : () => unawaited(_sendFeedbackOnly()),
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_copy.sendFeedback),
              ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: scheme.error),
              onPressed: _busy ? null : () => unawaited(_deleteAnyway()),
              child: Text(_busy ? _copy.deleting : _copy.deleteAnyway),
            ),
          ],
        ),
      ],
    );
  }
}
