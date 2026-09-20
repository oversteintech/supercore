import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AfterMoney', () {
    test('parses decimal currencies into minor units', () {
      expect(AfterMoney.parse('186.50', 'eur').minorUnits, 18650);
      expect(AfterMoney.parse('186.50', 'EUR').currencyCode, 'EUR');
      expect(AfterMoney.fromDecimal(12.9, 'TRY').format(), 'TRY 12.90');
    });

    test('uses zero exponent for JPY', () {
      final yen = AfterMoney.fromDecimal(12800, 'JPY');
      expect(yen.minorUnits, 12800);
      expect(yen.format(), 'JPY 12800');
    });

    test('adds and subtracts in the same currency', () {
      final a = AfterMoney.fromDecimal(100, 'EUR');
      final b = AfterMoney.fromDecimal(12.5, 'EUR');
      expect((a + b).format(), 'EUR 112.50');
      expect((a - b).format(), 'EUR 87.50');
    });

    test('rejects mixed-currency arithmetic', () {
      expect(
        () => AfterMoney.fromDecimal(1, 'EUR') + AfterMoney.fromDecimal(1, 'USD'),
        throwsArgumentError,
      );
    });
  });

  group('AfterPriceBreakdown', () {
    test('total is base + taxes + fees − discounts', () {
      final price = AfterPriceBreakdown(
        base: AfterMoney.fromDecimal(100, 'EUR'),
        taxes: AfterMoney.fromDecimal(12, 'EUR'),
        fees: AfterMoney.fromDecimal(8.5, 'EUR'),
        discounts: AfterMoney.fromDecimal(10, 'EUR'),
      );
      expect(price.total.minorUnits, 11050);
      expect(price.total.format(), 'EUR 110.50');
    });

    test('round-trips through JSON', () {
      final price = AfterPriceBreakdown(
        base: AfterMoney.fromDecimal(80, 'USD'),
        taxes: AfterMoney.fromDecimal(7.2, 'USD'),
      );
      final restored = AfterPriceBreakdown.fromJson(price.toJson());
      expect(restored, price);
      expect(restored.total.minorUnits, 8720);
    });
  });
}
