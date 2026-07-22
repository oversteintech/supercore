/// Premium / Super App capability flags — single source for entitlements.
enum AfterPlanFeature {
  unlimitedEntities,
  premiumThemes,
  cloudSync,
  cloudSyncBasic,
  familyShare,
  pdfExport,
  liveData,
  aiLimited,
  aiUnlimited,
  community,
  fleetDashboard,
  adFree,
  tracking,
}

/// Canonical membership tiers for AfterArtificial Super Apps.
enum AfterUserPlan {
  free,
  premium,
  superPlan,
  business,
  superadmin,
}

/// Fixed English tier labels for badges — never localized.
abstract final class AfterMembershipBadge {
  static const free = 'FREE';
  static const silver = 'SILVER';
  static const gold = 'GOLD';
  static const business = 'BUSINESS';
  static const royal = 'SUPER';
  static const admin = 'ADMIN';
  static const comingSoon = 'COMING SOON';

  static String forPlan(AfterUserPlan plan) => switch (plan) {
        AfterUserPlan.free => free,
        AfterUserPlan.premium => silver,
        AfterUserPlan.superPlan => gold,
        AfterUserPlan.business => business,
        AfterUserPlan.superadmin => admin,
      };
}

extension AfterUserPlanRank on AfterUserPlan {
  int get rank => switch (this) {
        AfterUserPlan.free => 0,
        AfterUserPlan.premium => 1,
        AfterUserPlan.superPlan => 2,
        AfterUserPlan.business => 3,
        AfterUserPlan.superadmin => 4,
      };

  bool isAtLeast(AfterUserPlan other) => rank >= other.rank;

  String get storageKey => switch (this) {
        AfterUserPlan.free => 'free',
        AfterUserPlan.premium => 'premium',
        AfterUserPlan.business => 'business',
        AfterUserPlan.superPlan => 'super',
        AfterUserPlan.superadmin => 'superadmin',
      };

  static AfterUserPlan fromStorage(String? raw) => switch (raw) {
        'premium' => AfterUserPlan.premium,
        'business' => AfterUserPlan.business,
        'super' => AfterUserPlan.superPlan,
        'superadmin' => AfterUserPlan.superadmin,
        _ => AfterUserPlan.free,
      };
}

/// Default feature matrix — Super Apps MAY override via [AfterEntitlementPolicy].
abstract final class AfterDefaultPlanMatrix {
  static const Map<AfterUserPlan, Set<AfterPlanFeature>> features = {
    AfterUserPlan.free: {
      AfterPlanFeature.aiLimited,
    },
    AfterUserPlan.premium: {
      AfterPlanFeature.aiLimited,
      AfterPlanFeature.unlimitedEntities,
      AfterPlanFeature.premiumThemes,
      AfterPlanFeature.cloudSyncBasic,
    },
    AfterUserPlan.superPlan: {
      AfterPlanFeature.aiLimited,
      AfterPlanFeature.aiUnlimited,
      AfterPlanFeature.unlimitedEntities,
      AfterPlanFeature.premiumThemes,
      AfterPlanFeature.cloudSync,
      AfterPlanFeature.cloudSyncBasic,
      AfterPlanFeature.familyShare,
      AfterPlanFeature.pdfExport,
      AfterPlanFeature.liveData,
      AfterPlanFeature.community,
      AfterPlanFeature.adFree,
      AfterPlanFeature.tracking,
    },
    AfterUserPlan.business: {
      AfterPlanFeature.aiLimited,
      AfterPlanFeature.aiUnlimited,
      AfterPlanFeature.unlimitedEntities,
      AfterPlanFeature.premiumThemes,
      AfterPlanFeature.cloudSync,
      AfterPlanFeature.cloudSyncBasic,
      AfterPlanFeature.familyShare,
      AfterPlanFeature.pdfExport,
      AfterPlanFeature.liveData,
      AfterPlanFeature.community,
      AfterPlanFeature.fleetDashboard,
      AfterPlanFeature.adFree,
      AfterPlanFeature.tracking,
    },
    AfterUserPlan.superadmin: {
      ...AfterPlanFeature.values,
    },
  };

  static bool hasFeature(AfterUserPlan plan, AfterPlanFeature feature) {
    return features[plan]?.contains(feature) ?? false;
  }
}

class AfterEntitlement {
  const AfterEntitlement({
    required this.effectivePlan,
    required this.storedPlan,
    this.goldTrialDaysRemaining,
    this.policy = const AfterEntitlementPolicy(),
  });

  final AfterUserPlan effectivePlan;
  final AfterUserPlan storedPlan;
  final int? goldTrialDaysRemaining;
  final AfterEntitlementPolicy policy;

  bool canUse(AfterPlanFeature feature) =>
      policy.hasFeature(effectivePlan, feature);

  bool get isPaid => effectivePlan.isAtLeast(AfterUserPlan.premium);
  bool get isSuperApp => effectivePlan.isAtLeast(AfterUserPlan.superPlan);
}

/// Overrideable feature matrix.
class AfterEntitlementPolicy {
  const AfterEntitlementPolicy({this.matrix});

  final Map<AfterUserPlan, Set<AfterPlanFeature>>? matrix;

  bool hasFeature(AfterUserPlan plan, AfterPlanFeature feature) {
    final custom = matrix;
    if (custom != null) {
      return custom[plan]?.contains(feature) ?? false;
    }
    return AfterDefaultPlanMatrix.hasFeature(plan, feature);
  }
}

/// Application-agnostic entitlement resolution.
abstract final class AfterEntitlementEngine {
  static AfterUserPlan effectivePlan({
    required AfterUserPlan stored,
    AfterUserPlan? remotePlan,
    bool remoteActive = true,
    AfterUserPlan? trialPlan,
  }) {
    var best = stored;
    if (remotePlan != null &&
        remoteActive &&
        remotePlan.rank > best.rank) {
      best = remotePlan;
    }
    if (trialPlan != null && trialPlan.rank > best.rank) {
      best = trialPlan;
    }
    return best;
  }

  static bool canUpgrade({
    required AfterUserPlan from,
    required AfterUserPlan to,
  }) {
    if (from == to) return true;
    return to.rank > from.rank;
  }

  static AfterUserPlan? planForProductKey(String? productKey) {
    if (productKey == null || productKey.isEmpty) return null;
    return switch (productKey) {
      'premium' => AfterUserPlan.premium,
      'super' => AfterUserPlan.superPlan,
      'business' => AfterUserPlan.business,
      _ => null,
    };
  }

  static String? productKeyForPlan(AfterUserPlan plan) => switch (plan) {
        AfterUserPlan.premium => 'premium',
        AfterUserPlan.superPlan => 'super',
        AfterUserPlan.business => 'business',
        _ => null,
      };
}

/// Receipt / subscription verification port (server-side).
abstract class AfterSubscriptionVerifier {
  Future<AfterUserPlan?> verifyPurchase({
    required String productId,
    required String verificationData,
    required String source,
  });
}

class NoOpAfterSubscriptionVerifier implements AfterSubscriptionVerifier {
  const NoOpAfterSubscriptionVerifier();

  @override
  Future<AfterUserPlan?> verifyPurchase({
    required String productId,
    required String verificationData,
    required String source,
  }) async =>
      null;
}

/// In-memory verifier for tests / skeleton — maps productId → plan.
///
/// Production apps keep [NoOpAfterSubscriptionVerifier] until store IAP
/// adapters are wired; this does not talk to Play Billing or App Store.
class MemoryAfterSubscriptionVerifier implements AfterSubscriptionVerifier {
  MemoryAfterSubscriptionVerifier([
    Map<String, AfterUserPlan>? productPlans,
  ]) : _productPlans = productPlans ??
            const {
              'after_plus_premium': AfterUserPlan.premium,
              'after_plus_super': AfterUserPlan.superPlan,
              'after_plus_business': AfterUserPlan.business,
            };

  final Map<String, AfterUserPlan> _productPlans;

  @override
  Future<AfterUserPlan?> verifyPurchase({
    required String productId,
    required String verificationData,
    required String source,
  }) async {
    if (verificationData.isEmpty) return null;
    return _productPlans[productId];
  }
}
