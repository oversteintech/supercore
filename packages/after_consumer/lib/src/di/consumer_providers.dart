import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../membership/consumer_membership.dart';
import '../vault/personal_vault.dart';

/// Bridge provider: derives a [ConsumerMembership] from the shared
/// `after_core` entitlement provider so consumer features stay decoupled
/// from the underlying billing pipeline.
final consumerMembershipProvider = Provider<ConsumerMembership>((ref) {
  final entitlement = ref.watch(afterEntitlementProvider);
  return ConsumerMembership(entitlement: entitlement);
});

final personalVaultRepositoryProvider = Provider<PersonalVaultRepository>((
  ref,
) {
  return InMemoryPersonalVaultRepository();
});
