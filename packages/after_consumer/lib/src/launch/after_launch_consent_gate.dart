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
class AfterLaunchConsentGate extends ConsumerStatefulWidget {
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
  ConsumerState<AfterLaunchConsentGate> createState() =>
      _AfterLaunchConsentGateState();
}

class _AfterLaunchConsentGateState
    extends ConsumerState<AfterLaunchConsentGate> {
  @override
  Widget build(BuildContext context) {
    final legal = ref.watch(afterLegalConsentProvider);
    final permission = ref.watch(afterPermissionConsentProvider);
    // Explicit listens keep this State rebuildable if a parent Element
    // temporarily drops ConsumerWidget watch notifications (test harness).
    ref.listen<AfterLegalConsent>(afterLegalConsentProvider, (previous, next) {
      if (previous?.needsConsent != next.needsConsent && mounted) {
        setState(() {});
      }
    });
    ref.listen<AfterPermissionConsent>(
      afterPermissionConsentProvider,
      (previous, next) {
        if (previous?.needsConsent != next.needsConsent && mounted) {
          setState(() {});
        }
      },
    );

    final strings = AfterLaunchConsentStrings.forLocale(
      appName: widget.appName,
      locale: Localizations.maybeLocaleOf(context),
    );

    if (legal.needsConsent) {
      return AfterLegalConsentScreen(
        key: const ValueKey('after-legal-consent'),
        strings: strings,
        privacyPolicyUrl: widget.privacyPolicyUrl,
        termsOfUseUrl: widget.termsOfUseUrl,
        onAccepted: () {
          if (mounted) setState(() {});
        },
      );
    }

    if (permission.needsConsent) {
      return AfterPermissionConsentScreen(
        key: const ValueKey('after-permission-consent'),
        strings: strings,
        requestLocationOnAccept: widget.requestLocationOnAccept,
        onAccepted: () {
          widget.onPermissionAccepted?.call();
          if (mounted) setState(() {});
        },
      );
    }

    return KeyedSubtree(
      key: const ValueKey('after-consent-complete'),
      child: widget.child,
    );
  }
}
