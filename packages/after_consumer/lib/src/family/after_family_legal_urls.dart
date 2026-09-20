/// Hosted legal document URLs for Super App consent surfaces.
///
/// Path segment uses the product slug (`superhealth`, `superpet`, …).
/// Products may still pass explicit URLs into [FamilyAuthGate].
abstract final class AfterFamilyLegalUrls {
  static const _host = 'https://overstein.com';

  static String slugForAppId(String appId) {
    final raw = appId.trim().toLowerCase().replaceAll('_', '');
    if (raw.isEmpty) return 'after';
    return raw;
  }

  static Uri privacyPolicy(String appId) =>
      Uri.parse('$_host/legal/${slugForAppId(appId)}/privacy');

  static Uri termsOfUse(String appId) =>
      Uri.parse('$_host/legal/${slugForAppId(appId)}/terms');
}
