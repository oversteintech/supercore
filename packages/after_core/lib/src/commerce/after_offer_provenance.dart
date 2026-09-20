import 'package:meta/meta.dart';

/// Where an offer came from. Demo results must never be labeled live.
enum AfterOfferSource {
  live,
  demo,
  cached,
  unavailable,
}

/// Freshness window for priced inventory. Stale offers must not be booked.
@immutable
class AfterDataFreshness {
  const AfterDataFreshness({
    required this.fetchedAt,
    this.ttl = const Duration(minutes: 15),
  });

  final DateTime fetchedAt;
  final Duration ttl;

  DateTime get expiresAt => fetchedAt.add(ttl);

  bool isStale([DateTime? now]) =>
      (now ?? DateTime.now()).isAfter(expiresAt);

  Map<String, Object?> toJson() => {
        'fetchedAt': fetchedAt.toIso8601String(),
        'ttlMs': ttl.inMilliseconds,
      };

  factory AfterDataFreshness.fromJson(Map<String, Object?> json) {
    return AfterDataFreshness(
      fetchedAt: DateTime.tryParse('${json['fetchedAt']}') ?? DateTime.now(),
      ttl: Duration(milliseconds: (json['ttlMs'] as num?)?.toInt() ?? 900000),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AfterDataFreshness &&
      other.fetchedAt == fetchedAt &&
      other.ttl == ttl;

  @override
  int get hashCode => Object.hash(fetchedAt, ttl);
}

/// Affiliate / sponsored labeling. Empty means organic comparison.
enum AfterCommercialKind { none, affiliate, sponsored }

@immutable
class AfterCommercialDisclosure {
  const AfterCommercialDisclosure({
    this.kind = AfterCommercialKind.none,
    this.partnerName,
  });

  final AfterCommercialKind kind;
  final String? partnerName;

  bool get isAffiliate => kind == AfterCommercialKind.affiliate;
  bool get isSponsored => kind == AfterCommercialKind.sponsored;
  bool get requiresLabel => kind != AfterCommercialKind.none;

  Map<String, Object?> toJson() => {
        'kind': kind.name,
        'partnerName': partnerName,
      };

  factory AfterCommercialDisclosure.fromJson(Map<String, Object?> json) {
    final raw = '${json['kind'] ?? 'none'}';
    final kind = AfterCommercialKind.values.firstWhere(
      (k) => k.name == raw,
      orElse: () => AfterCommercialKind.none,
    );
    return AfterCommercialDisclosure(
      kind: kind,
      partnerName: json['partnerName'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AfterCommercialDisclosure &&
      other.kind == kind &&
      other.partnerName == partnerName;

  @override
  int get hashCode => Object.hash(kind, partnerName);
}
