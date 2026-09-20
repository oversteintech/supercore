import 'dart:convert';

/// Public Family member number derived from a Firebase uid.
abstract final class FamilyMemberId {
  static const int maxValue = 8000000000;

  static int numberFromUid(String uid) {
    final bytes = utf8.encode(uid);
    var hash = 0x811C9DC5;
    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    final value = (hash % maxValue) + 1;
    return value;
  }

  static String format(String uid) => '${numberFromUid(uid)}';
}

/// Launch-promo copy shown on one-time IAP theme tiles.
class FamilyThemePromo {
  const FamilyThemePromo({
    required this.badge,
    required this.subtitle,
    this.struckPrice,
  });

  final String badge;
  final String subtitle;

  /// Localized list price shown with a strikethrough while the promo is free.
  final String? struckPrice;
}
