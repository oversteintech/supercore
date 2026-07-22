import 'package:after_core/after_core.dart';
import 'package:meta/meta.dart';

import '../identity/after_id.dart';

/// After+ — one subscription fabric across the ecosystem.
@immutable
class AfterPlusSubscription {
  const AfterPlusSubscription({
    required this.afterId,
    required this.plan,
    required this.active,
    this.renewsAt,
    this.features = const <AfterPlanFeature>{},
  });

  final AfterId afterId;
  final AfterUserPlan plan;
  final bool active;
  final DateTime? renewsAt;
  final Set<AfterPlanFeature> features;

  bool allows(AfterPlanFeature feature) =>
      active && (features.contains(feature) || plan == AfterUserPlan.superadmin);
}

abstract class AfterPlusRepository {
  Future<AfterPlusSubscription?> subscriptionFor(AfterId afterId);

  Future<AfterPlusSubscription> upsert(AfterPlusSubscription subscription);

  Stream<AfterPlusSubscription?> watch(AfterId afterId);
}

class InMemoryAfterPlusRepository implements AfterPlusRepository {
  final Map<String, AfterPlusSubscription> _byId = {};

  @override
  Future<AfterPlusSubscription?> subscriptionFor(AfterId afterId) async =>
      _byId[afterId.value];

  @override
  Future<AfterPlusSubscription> upsert(AfterPlusSubscription subscription) async {
    _byId[subscription.afterId.value] = subscription;
    return subscription;
  }

  @override
  Stream<AfterPlusSubscription?> watch(AfterId afterId) async* {
    yield _byId[afterId.value];
  }
}
