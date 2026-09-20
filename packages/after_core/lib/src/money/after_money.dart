import 'package:meta/meta.dart';

/// ISO-4217 money in integer minor units (cents, yen, fils).
@immutable
class AfterMoney implements Comparable<AfterMoney> {
  const AfterMoney({
    required this.minorUnits,
    required this.currency,
  });

  factory AfterMoney.zero(String currency) => AfterMoney(
        minorUnits: 0,
        currency: currency.toUpperCase(),
      );

  factory AfterMoney.fromDecimal(num amount, String currency) {
    final code = currency.toUpperCase();
    final factor = _pow10(exponentFor(code));
    return AfterMoney(
      minorUnits: (amount * factor).round(),
      currency: code,
    );
  }

  factory AfterMoney.parse(String raw, String currency) {
    final cleaned = raw.trim().replaceAll(',', '');
    return AfterMoney.fromDecimal(num.parse(cleaned), currency);
  }

  final int minorUnits;
  final String currency;

  String get currencyCode => currency.toUpperCase();

  /// Decimal exponent: JPY/KRW = 0, KWD/BHD = 3, most others = 2.
  static int exponentFor(String currency) {
    switch (currency.toUpperCase()) {
      case 'JPY':
      case 'KRW':
      case 'VND':
        return 0;
      case 'KWD':
      case 'BHD':
      case 'OMR':
        return 3;
      default:
        return 2;
    }
  }

  double get decimalAmount {
    final factor = _pow10(exponentFor(currencyCode));
    return minorUnits / factor;
  }

  AfterMoney operator +(AfterMoney other) {
    _assertSameCurrency(other);
    return AfterMoney(
      minorUnits: minorUnits + other.minorUnits,
      currency: currencyCode,
    );
  }

  AfterMoney operator -(AfterMoney other) {
    _assertSameCurrency(other);
    return AfterMoney(
      minorUnits: minorUnits - other.minorUnits,
      currency: currencyCode,
    );
  }

  @override
  int compareTo(AfterMoney other) {
    _assertSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  bool operator <(AfterMoney other) => compareTo(other) < 0;
  bool operator <=(AfterMoney other) => compareTo(other) <= 0;
  bool operator >(AfterMoney other) => compareTo(other) > 0;
  bool operator >=(AfterMoney other) => compareTo(other) >= 0;

  String format() {
    final exp = exponentFor(currencyCode);
    final sign = minorUnits < 0 ? '-' : '';
    final abs = minorUnits.abs();
    if (exp == 0) return '$sign$currencyCode $abs';
    final factor = _pow10(exp);
    final whole = abs ~/ factor;
    final frac = (abs % factor).toString().padLeft(exp, '0');
    return '$sign$currencyCode $whole.$frac';
  }

  Map<String, Object?> toJson() => {
        'minorUnits': minorUnits,
        'currency': currencyCode,
      };

  factory AfterMoney.fromJson(Map<String, Object?> json) {
    return AfterMoney(
      minorUnits: (json['minorUnits'] as num?)?.toInt() ?? 0,
      currency: (json['currency'] as String? ?? 'USD').toUpperCase(),
    );
  }

  void _assertSameCurrency(AfterMoney other) {
    if (currencyCode != other.currencyCode) {
      throw ArgumentError(
        'Currency mismatch: $currencyCode vs ${other.currencyCode}',
      );
    }
  }

  static int _pow10(int exp) {
    var n = 1;
    for (var i = 0; i < exp; i++) {
      n *= 10;
    }
    return n;
  }

  @override
  bool operator ==(Object other) =>
      other is AfterMoney &&
      other.minorUnits == minorUnits &&
      other.currencyCode == currencyCode;

  @override
  int get hashCode => Object.hash(minorUnits, currencyCode);

  @override
  String toString() => format();
}

/// Base + taxes + fees − discounts. All legs must share a currency.
@immutable
class AfterPriceBreakdown {
  AfterPriceBreakdown({
    required this.base,
    AfterMoney? taxes,
    AfterMoney? fees,
    AfterMoney? discounts,
  })  : taxes = taxes ?? AfterMoney.zero(base.currency),
        fees = fees ?? AfterMoney.zero(base.currency),
        discounts = discounts ?? AfterMoney.zero(base.currency) {
    for (final part in [this.taxes, this.fees, this.discounts]) {
      if (part.currencyCode != base.currencyCode) {
        throw ArgumentError(
          'Price parts must use ${base.currencyCode}, got ${part.currencyCode}',
        );
      }
    }
  }

  final AfterMoney base;
  final AfterMoney taxes;
  final AfterMoney fees;
  final AfterMoney discounts;

  AfterMoney get total => base + taxes + fees - discounts;

  String get currencyCode => base.currencyCode;

  Map<String, Object?> toJson() => {
        'base': base.toJson(),
        'taxes': taxes.toJson(),
        'fees': fees.toJson(),
        'discounts': discounts.toJson(),
      };

  factory AfterPriceBreakdown.fromJson(Map<String, Object?> json) {
    AfterMoney read(String key, String fallbackCurrency) {
      final raw = json[key];
      if (raw is Map<String, Object?>) return AfterMoney.fromJson(raw);
      if (raw is Map) {
        return AfterMoney.fromJson(raw.cast<String, Object?>());
      }
      return AfterMoney.zero(fallbackCurrency);
    }

    final base = read('base', 'USD');
    return AfterPriceBreakdown(
      base: base,
      taxes: read('taxes', base.currencyCode),
      fees: read('fees', base.currencyCode),
      discounts: read('discounts', base.currencyCode),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AfterPriceBreakdown &&
      other.base == base &&
      other.taxes == taxes &&
      other.fees == fees &&
      other.discounts == discounts;

  @override
  int get hashCode => Object.hash(base, taxes, fees, discounts);
}
