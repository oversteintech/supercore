import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'entity_editor_sheet.dart';
import 'family_field_labels.dart';
import 'family_map_record.dart';

/// Drop-in CRUD list page for family Super App features.
class FamilyCrudListPage extends ConsumerWidget {
  const FamilyCrudListPage({
    required this.title,
    required this.listProvider,
    required this.fieldKeys,
    this.fieldLabels,
    this.emptyLabel,
    this.icon = Icons.list_alt_outlined,
    super.key,
  });

  final String title;
  final NotifierProvider<FamilyMapListController, List<FamilyMapRecord>>
      listProvider;
  final List<String> fieldKeys;

  /// Optional override; defaults to [FamilyFieldLabels] for the active locale.
  final Map<String, String>? fieldLabels;
  final String? emptyLabel;
  final IconData icon;

  String _lang(BuildContext context) =>
      Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final lang = _lang(context);
    final blank = {for (final k in fieldKeys) k: ''};
    final result = await showEntityEditorSheet(
      context: context,
      title: '${FamilyFieldLabels.ui('ui.add', lang)} $title',
      fields: blank,
      fieldLabels: fieldLabels,
      languageCode: lang,
    );
    if (result == null || !context.mounted) return;
    // Let the modal route finish unmounting before mutating providers
    // (avoids InheritedElement `_dependents.isEmpty` red screen).
    await Future<void>.delayed(Duration.zero);
    if (!context.mounted) return;
    final id = 'id_${DateTime.now().microsecondsSinceEpoch}';
    await ref.read(listProvider.notifier).upsert(
          FamilyMapRecord(id: id, fields: result),
        );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    FamilyMapRecord item,
  ) async {
    final lang = _lang(context);
    final fields = {
      for (final k in fieldKeys) k: item.fields[k] ?? '',
    };
    final result = await showEntityEditorSheet(
      context: context,
      title: '${FamilyFieldLabels.ui('ui.edit', lang)} $title',
      fields: fields,
      fieldLabels: fieldLabels,
      languageCode: lang,
    );
    if (result == null || !context.mounted) return;
    await Future<void>.delayed(Duration.zero);
    if (!context.mounted) return;
    await ref.read(listProvider.notifier).upsert(
          FamilyMapRecord(id: item.id, fields: result),
        );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    FamilyMapRecord item,
  ) async {
    final ok = await confirmDelete(context, item.title);
    if (!ok || !context.mounted) return;
    await ref.read(listProvider.notifier).deleteById(item.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(listProvider);
    final lang = _lang(context);
    final empty = emptyLabel ?? FamilyFieldLabels.ui('ui.empty', lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _add(context, ref),
        child: const Icon(Icons.add),
      ),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(empty, textAlign: TextAlign.center),
              ),
            )
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                final subtitle = fieldKeys
                    .where((k) => k != 'title' && k != 'name')
                    .map((k) => item.fields[k])
                    .whereType<String>()
                    .where((v) => v.isNotEmpty)
                    .take(2)
                    .join(' · ');
                return ListTile(
                  leading: Icon(icon),
                  title: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: subtitle.isEmpty
                      ? null
                      : Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                  onTap: () => _edit(context, ref, item),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(context, ref, item),
                  ),
                );
              },
            ),
    );
  }
}
