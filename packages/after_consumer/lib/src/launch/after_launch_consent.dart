import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bump when privacy policy or terms change materially; users must re-accept.
const afterLegalConsentVersion = 1;

/// Bump when the permissions intro copy / scope changes materially.
const afterPermissionConsentVersion = 1;

class AfterLegalConsent {
  const AfterLegalConsent({
    required this.accepted,
    required this.version,
    this.acceptedAt,
  });

  final bool accepted;
  final int version;
  final DateTime? acceptedAt;

  bool get needsConsent =>
      !accepted || version < afterLegalConsentVersion;
}

class AfterPermissionConsent {
  const AfterPermissionConsent({
    required this.accepted,
    required this.version,
    this.acceptedAt,
  });

  final bool accepted;
  final int version;
  final DateTime? acceptedAt;

  bool get needsConsent =>
      !accepted || version < afterPermissionConsentVersion;
}

final afterLegalConsentProvider =
    NotifierProvider<AfterLegalConsentController, AfterLegalConsent>(
      AfterLegalConsentController.new,
    );

final afterPermissionConsentProvider =
    NotifierProvider<AfterPermissionConsentController, AfterPermissionConsent>(
      AfterPermissionConsentController.new,
    );

class AfterLegalConsentController extends Notifier<AfterLegalConsent> {
  static const acceptedKey = 'legal_consent_accepted';
  static const versionKey = 'legal_consent_version';
  static const acceptedAtKey = 'legal_consent_accepted_at';

  SharedPreferences get _preferences =>
      ref.read(afterSharedPreferencesProvider);

  @override
  AfterLegalConsent build() {
    final accepted = _preferences.getBool(acceptedKey) ?? false;
    final version = _preferences.getInt(versionKey) ?? 0;
    final acceptedAtMillis = _preferences.getInt(acceptedAtKey);
    return AfterLegalConsent(
      accepted: accepted,
      version: version,
      acceptedAt: acceptedAtMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(acceptedAtMillis),
    );
  }

  Future<void> accept() async {
    final now = DateTime.now();
    await _preferences.setBool(acceptedKey, true);
    await _preferences.setInt(versionKey, afterLegalConsentVersion);
    await _preferences.setInt(acceptedAtKey, now.millisecondsSinceEpoch);
    state = AfterLegalConsent(
      accepted: true,
      version: afterLegalConsentVersion,
      acceptedAt: now,
    );
  }
}

class AfterPermissionConsentController
    extends Notifier<AfterPermissionConsent> {
  static const acceptedKey = 'permission_consent_accepted';
  static const versionKey = 'permission_consent_version';
  static const acceptedAtKey = 'permission_consent_accepted_at';

  SharedPreferences get _preferences =>
      ref.read(afterSharedPreferencesProvider);

  @override
  AfterPermissionConsent build() {
    final accepted = _preferences.getBool(acceptedKey) ?? false;
    final version = _preferences.getInt(versionKey) ?? 0;
    final acceptedAtMillis = _preferences.getInt(acceptedAtKey);
    return AfterPermissionConsent(
      accepted: accepted,
      version: version,
      acceptedAt: acceptedAtMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(acceptedAtMillis),
    );
  }

  Future<void> accept() async {
    final now = DateTime.now();
    await _preferences.setBool(acceptedKey, true);
    await _preferences.setInt(versionKey, afterPermissionConsentVersion);
    await _preferences.setInt(acceptedAtKey, now.millisecondsSinceEpoch);
    state = AfterPermissionConsent(
      accepted: true,
      version: afterPermissionConsentVersion,
      acceptedAt: now,
    );
  }
}

/// True after the user acknowledged the permissions intro on first launch.
bool readAfterPermissionConsentAccepted(SharedPreferences preferences) {
  final accepted =
      preferences.getBool(AfterPermissionConsentController.acceptedKey) ??
      false;
  final version =
      preferences.getInt(AfterPermissionConsentController.versionKey) ?? 0;
  return accepted && version >= afterPermissionConsentVersion;
}
