import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'family_scoped_list.dart';

/// Generic string-field record for POC CRUD across Super Apps.
@immutable
class FamilyMapRecord {
  const FamilyMapRecord({
    required this.id,
    required this.fields,
  });

  final String id;
  final Map<String, String> fields;

  String get title {
    if (fields['title'] != null) return fields['title']!;
    if (fields['name'] != null) return fields['name']!;
    if (fields.isEmpty) return id;
    return fields.values.first;
  }

  FamilyMapRecord copyWith({Map<String, String>? fields}) => FamilyMapRecord(
        id: id,
        fields: fields ?? this.fields,
      );

  Map<String, dynamic> toJson() => {'id': id, 'fields': fields};

  factory FamilyMapRecord.fromJson(Map<String, dynamic> json) {
    final raw = json['fields'];
    final fields = <String, String>{};
    if (raw is Map) {
      for (final e in raw.entries) {
        fields['${e.key}'] = '${e.value}';
      }
    }
    return FamilyMapRecord(id: '${json['id']}', fields: fields);
  }
}

/// Prefs-backed map-record list. Construct with a storage key + optional seed.
class FamilyMapListController extends FamilyScopedListController<FamilyMapRecord> {
  FamilyMapListController(this._storageKey, {this.seed = const []});

  final String _storageKey;
  final List<FamilyMapRecord> seed;

  @override
  String get storageKey => _storageKey;

  @override
  String itemId(FamilyMapRecord item) => item.id;

  @override
  FamilyMapRecord decodeItem(Map<String, dynamic> json) =>
      FamilyMapRecord.fromJson(json);

  @override
  Map<String, dynamic> encodeItem(FamilyMapRecord item) => item.toJson();

  @override
  List<FamilyMapRecord> build() {
    ref.watch(afterAuthSessionProvider);
    final loaded = loadAll();
    if (loaded.isNotEmpty) return loaded;
    if (seed.isEmpty) return const [];
    return List<FamilyMapRecord>.from(seed);
  }
}

NotifierProvider<FamilyMapListController, List<FamilyMapRecord>>
    familyMapListProvider(
  String storageKey, {
  List<FamilyMapRecord> seed = const [],
}) {
  return NotifierProvider<FamilyMapListController, List<FamilyMapRecord>>(
    () => FamilyMapListController(storageKey, seed: seed),
  );
}
