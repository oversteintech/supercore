int? afterCommunityReadJsonInt(dynamic raw) {
  if (raw == null) return null;
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  return int.tryParse(raw.toString());
}

int afterCommunityReadJsonIntOr(dynamic raw, int fallback) =>
    afterCommunityReadJsonInt(raw) ?? fallback;

List<String> afterCommunityReadJsonStringList(Object? raw) {
  if (raw is! List) return const [];
  return raw
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
