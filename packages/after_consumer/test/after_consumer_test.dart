import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ConsumerMembership.free has free plan', () {
    expect(ConsumerMembership.free.entitlement.effectivePlan, AfterUserPlan.free);
    expect(ConsumerMembership.free.isFamilyPlan, isFalse);
  });

  test('ConsumerMembership derives feature access from plan matrix', () {
    const membership = ConsumerMembership(
      entitlement: AfterEntitlement(
        effectivePlan: AfterUserPlan.superPlan,
        storedPlan: AfterUserPlan.superPlan,
      ),
    );
    expect(membership.has(AfterPlanFeature.aiUnlimited), isTrue);
  });

  test('PersonalVaultRepository shares item with household', () async {
    final repo = InMemoryPersonalVaultRepository();
    final item = await repo.saveItem(
      const PersonalVaultItem(
        id: '',
        ownerId: 'u1',
        kind: 'document',
        title: 'Passport',
      ),
    );
    await repo.shareWithHousehold(
      itemId: item.id,
      memberIds: const ['spouse', 'child'],
    );
    final items = await repo.listItems(ownerId: 'u1');
    expect(items.single.isSharedWithFamily, isTrue);
    expect(items.single.sharedWithHouseholdMemberIds, hasLength(2));
  });
}
