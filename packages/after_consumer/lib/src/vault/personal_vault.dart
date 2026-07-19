import 'package:meta/meta.dart';

/// Personal document / secret stored in a consumer's private vault.
///
/// Thin placeholder that consumer Super Apps (SuperGarage documents,
/// SuperFinance receipts, SuperHealth records) extend with their own
/// domain shape. Real crypto lives in `after_core.AfterSecureStorage`.
@immutable
class PersonalVaultItem {
  const PersonalVaultItem({
    required this.id,
    required this.ownerId,
    required this.kind,
    required this.title,
    this.subtitle,
    this.tags = const [],
    this.createdAt,
    this.sharedWithHouseholdMemberIds = const [],
  });

  final String id;
  final String ownerId;
  final String kind;
  final String title;
  final String? subtitle;
  final List<String> tags;
  final DateTime? createdAt;
  final List<String> sharedWithHouseholdMemberIds;

  bool get isSharedWithFamily => sharedWithHouseholdMemberIds.isNotEmpty;
}

abstract class PersonalVaultRepository {
  Future<List<PersonalVaultItem>> listItems({required String ownerId});
  Future<PersonalVaultItem> saveItem(PersonalVaultItem item);
  Future<void> deleteItem(String id);
  Future<void> shareWithHousehold({
    required String itemId,
    required List<String> memberIds,
  });
}

class InMemoryPersonalVaultRepository implements PersonalVaultRepository {
  final Map<String, PersonalVaultItem> _items = {};
  var _nextId = 1;

  @override
  Future<List<PersonalVaultItem>> listItems({required String ownerId}) async {
    return _items.values
        .where((i) => i.ownerId == ownerId)
        .toList(growable: false);
  }

  @override
  Future<PersonalVaultItem> saveItem(PersonalVaultItem item) async {
    final id = item.id.isEmpty ? 'vault_${_nextId++}' : item.id;
    final stored = PersonalVaultItem(
      id: id,
      ownerId: item.ownerId,
      kind: item.kind,
      title: item.title,
      subtitle: item.subtitle,
      tags: item.tags,
      createdAt: item.createdAt ?? DateTime.now().toUtc(),
      sharedWithHouseholdMemberIds: item.sharedWithHouseholdMemberIds,
    );
    _items[id] = stored;
    return stored;
  }

  @override
  Future<void> deleteItem(String id) async {
    _items.remove(id);
  }

  @override
  Future<void> shareWithHousehold({
    required String itemId,
    required List<String> memberIds,
  }) async {
    final current = _items[itemId];
    if (current == null) return;
    _items[itemId] = PersonalVaultItem(
      id: current.id,
      ownerId: current.ownerId,
      kind: current.kind,
      title: current.title,
      subtitle: current.subtitle,
      tags: current.tags,
      createdAt: current.createdAt,
      sharedWithHouseholdMemberIds: List.unmodifiable(memberIds),
    );
  }
}
