import 'dart:async';
import 'dart:convert';

import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'family_cloud_sync.dart';

/// SharedPreferences-backed JSON list — Garage-style CRUD without Drift.
///
/// Subclasses supply [storageKey], [decodeItem], [encodeItem], and [itemId].
abstract class FamilyScopedListController<T> extends Notifier<List<T>> {
  String get storageKey;

  T decodeItem(Map<String, dynamic> json);

  Map<String, dynamic> encodeItem(T item);

  String itemId(T item);

  SharedPreferences get preferences =>
      ref.read(afterSharedPreferencesProvider);

  String? get userScope {
    final session = ref.watch(afterAuthSessionProvider).asData?.value;
    return session?.user?.uid;
  }

  String scopedKey(String key) {
    final scope = userScope;
    if (scope == null || scope.isEmpty) return key;
    return '${key}_$scope';
  }

  @override
  List<T> build() {
    ref.watch(afterAuthSessionProvider);
    return loadAll();
  }

  List<T> loadAll() {
    final raw = preferences.getString(scopedKey(storageKey));
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(decodeItem)
          .toList(growable: true);
    } on FormatException {
      return const [];
    }
  }

  Future<void> persist(List<T> records) async {
    await preferences.setString(
      scopedKey(storageKey),
      jsonEncode(records.map(encodeItem).toList()),
    );
    state = List<T>.from(records);
    try {
      unawaited(ref.read(familyCloudSyncProvider.notifier).markLocalDirty());
    } on Object {
      // Sync optional when provider not mounted in unit tests.
    }
  }

  Future<void> upsert(T item) async {
    final id = itemId(item);
    final next = [...state.where((e) => itemId(e) != id), item];
    await persist(next);
  }

  Future<void> deleteById(String id) async {
    await persist(state.where((e) => itemId(e) != id).toList());
  }

  Future<void> clear() => persist(const []);
}
