/// Shared superadmin allowlist for every AfterArtificial Super App.
///
/// When a user signs in (Google, email, or other) with one of these addresses,
/// membership MUST elevate to [AfterUserPlan.superadmin] with every
/// [AfterPlanFeature] unlocked. Sessions remain per-app (no cross-app SSO).
abstract final class AfterSuperAdmin {
  static const emails = <String>{
    'ayhanuzundal@gmail.com',
    'admin@overstein.com',
    'superadmin@overstein.com',
    'ayhan@overstein.com',
    'contact@overstein.com',
    'support@overstein.com',
    // Per-product inboxes (Workspace) — ops may sign in via these too.
    'supergarage@overstein.com',
    'superhealth@overstein.com',
    'superfinance@overstein.com',
    'superhome@overstein.com',
    'superpet@overstein.com',
    'supersports@overstein.com',
    'supertravel@overstein.com',
    'supernews@overstein.com',
    'supergames@overstein.com',
  };

  static bool isSuperAdminEmail(String? email) {
    if (email == null) return false;
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    return emails.contains(normalized);
  }
}
