import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('freshness is stale after ttl', () {
    final freshness = AfterDataFreshness(
      fetchedAt: DateTime(2026, 9, 20, 12),
      ttl: const Duration(minutes: 15),
    );
    expect(freshness.isStale(DateTime(2026, 9, 20, 12, 10)), isFalse);
    expect(freshness.isStale(DateTime(2026, 9, 20, 12, 16)), isTrue);
  });

  test('commercial disclosure labels affiliate and sponsored', () {
    const organic = AfterCommercialDisclosure();
    const affiliate = AfterCommercialDisclosure(
      kind: AfterCommercialKind.affiliate,
      partnerName: 'Partner Co',
    );
    expect(organic.requiresLabel, isFalse);
    expect(affiliate.isAffiliate, isTrue);
    expect(affiliate.requiresLabel, isTrue);
    expect(
      AfterCommercialDisclosure.fromJson(affiliate.toJson()).partnerName,
      'Partner Co',
    );
  });
}
