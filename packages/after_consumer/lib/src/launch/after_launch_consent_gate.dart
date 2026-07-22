import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'after_launch_consent.dart';
import 'after_launch_consent_strings.dart';
import 'after_legal_consent_screen.dart';
import 'after_permission_consent_screen.dart';

/// Garage-parity first-launch gates: Legal → Permission (OS location) → [child].
///
/// Wrap each Super App [AuthGate] body with this so splash is always followed
/// by consent screens before login/shell.
class AfterLaunchConsentGate extends ConsumerWidget {
  const AfterLaunchConsentGate({
    required this.appName,
    required this.child,
    this.privacyPolicyUrl,
    this.termsOfUseUrl,
    this.requestLocationOnAccept = true,
    this.onPermissionAccepted,
    super.key,
  });

  final String appName;
  final Widget child;
  final Uri? privacyPolicyUrl;
  final Uri? termsOfUseUrl;
  final bool requestLocationOnAccept;
  final VoidCallback? onPermissionAccepted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final legal = ref.watch(afterLegalConsentProvider);
    final permission = ref.watch(afterPermissionConsentProvider);
    final strings = AfterLaunchConsentStrings.forLocale(
      appName: appName,
      locale: Localizations.maybeLocaleOf(context),
    );

    if (legal.needsConsent) {
      return AfterLegalConsentScreen(
        strings: strings,
        privacyPolicyUrl: privacyPolicyUrl,
        termsOfUseUrl: termsOfUseUrl,
        onAccepted: () {},
      );
    }

    if (permission.needsConsent) {
      return AfterPermissionConsentScreen(
        strings: strings,
        requestLocationOnAccept: requestLocationOnAccept,
        onAccepted: () => onPermissionAccepted?.call(),
      );
    }

    return child;
  }
}
