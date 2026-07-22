import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'after_launch_consent.dart';
import 'after_launch_consent_strings.dart';

class AfterLegalConsentScreen extends ConsumerStatefulWidget {
  const AfterLegalConsentScreen({
    required this.strings,
    required this.onAccepted,
    this.privacyPolicyUrl,
    this.termsOfUseUrl,
    super.key,
  });

  final AfterLaunchConsentStrings strings;
  final VoidCallback onAccepted;
  final Uri? privacyPolicyUrl;
  final Uri? termsOfUseUrl;

  @override
  ConsumerState<AfterLegalConsentScreen> createState() =>
      _AfterLegalConsentScreenState();
}

class _AfterLegalConsentScreenState
    extends ConsumerState<AfterLegalConsentScreen> {
  bool _checked = false;
  bool _saving = false;

  Future<void> _accept() async {
    if (!_checked || _saving) return;
    setState(() => _saving = true);
    await ref.read(afterLegalConsentProvider.notifier).accept();
    if (mounted) widget.onAccepted();
  }

  void _decline() {
    final strings = widget.strings;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(strings.legalRequiredTitle),
          content: Text(strings.legalRequiredBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                SystemNavigator.pop();
              },
              child: Text(strings.legalExitApp),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.strings;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    strings.legalTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.legalSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        strings.privacyIntro,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.privacy_tip_rounded),
                          title: Text(strings.privacyPolicy),
                          subtitle: Text(strings.privacyPolicyHint),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.description_rounded),
                          title: Text(strings.termsOfUse),
                          subtitle: Text(strings.termsOfUseHint),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: _checked,
                    onChanged: (value) =>
                        setState(() => _checked = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(strings.legalCheckbox),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: _checked && !_saving ? _accept : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(strings.legalAccept),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _decline,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(strings.legalDecline),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
