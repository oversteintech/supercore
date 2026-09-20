import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'after_launch_consent.dart';
import 'after_launch_consent_strings.dart';
import 'after_legal_consent_screen.dart';
import 'after_permission_consent_screen.dart';

/// Garage-parity first-launch gates: Legal → Permission (OS location) → [child].
///
/// Wrap each Super App [AuthGate] body with this so splash is always followed
/// by consent screens before login/shell. Copy comes from SuperCore
/// [AfterLaunchConsentStrings] (all 20 supported locales).
class AfterLaunchConsentGate extends ConsumerStatefulWidget {
  const AfterLaunchConsentGate({
    required this.appName,
    required this.child,
    this.privacyPolicyUrl,
    this.termsOfUseUrl,
    this.requestLocationOnAccept = true,
    this.onPermissionAccepted,
    this.strings,
    this.onPrivacyPolicyTap,
    this.onTermsOfUseTap,
    super.key,
  });

  final String appName;
  final Widget child;
  final Uri? privacyPolicyUrl;
  final Uri? termsOfUseUrl;
  final bool requestLocationOnAccept;
  final VoidCallback? onPermissionAccepted;

  /// Optional override — prefer null so all apps use the shared 20-locale catalog.
  final AfterLaunchConsentStrings? strings;
  final VoidCallback? onPrivacyPolicyTap;
  final VoidCallback? onTermsOfUseTap;

  @override
  ConsumerState<AfterLaunchConsentGate> createState() =>
      _AfterLaunchConsentGateState();
}

class _AfterLaunchConsentGateState
    extends ConsumerState<AfterLaunchConsentGate> {
  AfterLaunchConsentStrings _resolveStrings(BuildContext context) {
    if (widget.strings != null) return widget.strings!;
    final prefs = ref.read(afterSharedPreferencesProvider);
    final saved = AfterLocalePrefs.read(prefs);
    final locale = saved != null
        ? Locale(saved)
        : Localizations.maybeLocaleOf(context);
    return AfterLaunchConsentStrings.forLocale(
      appName: widget.appName,
      locale: locale,
    );
  }

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

    final strings = _resolveStrings(context);

    if (legal.needsConsent) {
      return AfterLegalConsentScreen(
        key: const ValueKey('after-legal-consent'),
        strings: strings,
        privacyPolicyUrl: widget.privacyPolicyUrl,
        termsOfUseUrl: widget.termsOfUseUrl,
        onPrivacyPolicyTap: widget.onPrivacyPolicyTap,
        onTermsOfUseTap: widget.onTermsOfUseTap,
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
