import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MemoryAfterSubscriptionVerifier maps known products', () async {
    final verifier = MemoryAfterSubscriptionVerifier();
    final plan = await verifier.verifyPurchase(
      productId: 'after_plus_super',
      verificationData: 'receipt',
      source: 'test',
    );
    expect(plan, AfterUserPlan.superPlan);
  });

  test('MemoryAfterSubscriptionVerifier rejects empty receipt', () async {
    final verifier = MemoryAfterSubscriptionVerifier();
    final plan = await verifier.verifyPurchase(
      productId: 'after_plus_premium',
      verificationData: '',
      source: 'test',
    );
    expect(plan, isNull);
  });
}
