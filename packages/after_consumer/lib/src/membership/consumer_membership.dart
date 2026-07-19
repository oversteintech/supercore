import 'package:after_core/after_core.dart';
import 'package:meta/meta.dart';

/// Snapshot of a consumer's active membership across After Framework
/// billing surfaces. Wraps the [AfterEntitlement] from `after_core` and
/// adds household / family context that only consumer Super Apps use.
@immutable
class ConsumerMembership {
  const ConsumerMembership({
    required this.entitlement,
    this.familyPlanId,
    this.familyMemberIds = const [],
  });

  final AfterEntitlement entitlement;
  final String? familyPlanId;
  final List<String> familyMemberIds;

  bool get isFamilyPlan => familyPlanId != null;

  bool has(AfterPlanFeature feature) {
    return AfterDefaultPlanMatrix.hasFeature(
      entitlement.effectivePlan,
      feature,
    );
  }

  static const ConsumerMembership free = ConsumerMembership(
    entitlement: AfterEntitlement(
      effectivePlan: AfterUserPlan.free,
      storedPlan: AfterUserPlan.free,
    ),
  );
}
