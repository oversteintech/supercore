import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../membership/consumer_membership.dart';

/// Prefs-backed plan controller shared by consumer Super Apps.
class FamilyMembershipState {
  const FamilyMembershipState({this.plan = AfterUserPlan.free});

  final AfterUserPlan plan;

  AfterEntitlement get entitlement => AfterEntitlement(
        effectivePlan: plan,
        storedPlan: plan,
      );

  ConsumerMembership get membership =>
      ConsumerMembership(entitlement: entitlement);

  String get badge => AfterMembershipBadge.forPlan(plan);

  bool get isSuperAdmin => plan == AfterUserPlan.superadmin;

  bool has(AfterPlanFeature feature) =>
      AfterDefaultPlanMatrix.hasFeature(plan, feature);

  FamilyMembershipState copyWith({AfterUserPlan? plan}) =>
      FamilyMembershipState(plan: plan ?? this.plan);
}

/// Create per-app: `NotifierProvider(() => FamilyMembershipController('app.plan'))`.
class FamilyMembershipController extends Notifier<FamilyMembershipState> {
  FamilyMembershipController(this.storageKey);

  final String storageKey;

  @override
  FamilyMembershipState build() {
    final prefs = ref.watch(afterSharedPreferencesProvider);
    final session = ref.watch(afterAuthSessionProvider).asData?.value;
    if (AfterSuperAdmin.isSuperAdminEmail(session?.user?.email)) {
      return const FamilyMembershipState(plan: AfterUserPlan.superadmin);
    }
    final plan = AfterUserPlanRank.fromStorage(prefs.getString(storageKey));
    if (plan == AfterUserPlan.superadmin) {
      return const FamilyMembershipState();
    }
    return FamilyMembershipState(plan: plan);
  }

  Future<void> setPlan(AfterUserPlan plan) async {
    if (state.isSuperAdmin) return;
    final prefs = ref.read(afterSharedPreferencesProvider);
    await prefs.setString(storageKey, plan.storageKey);
    state = state.copyWith(plan: plan);
  }
}
