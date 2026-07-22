import 'package:flutter/material.dart';

import 'family_field_labels.dart';

/// Multi-field editor sheet used by family Super App CRUD screens.
Future<Map<String, String>?> showEntityEditorSheet({
  required BuildContext context,
  required String title,
  required Map<String, String> fields,
  Map<String, String>? fieldLabels,
  String? languageCode,
}) async {
  final lang = languageCode ??
      Localizations.maybeLocaleOf(context)?.languageCode ??
      'en';
  final labels = fieldLabels ?? FamilyFieldLabels.mapFor(fields.keys, lang);
  final saveLabel = FamilyFieldLabels.ui('ui.save', lang);

  return showModalBottomSheet<Map<String, String>>(
    context: context,
    isScrollControlled: true,
    // Keep sheet widgets mounted until the route finishes popping so
    // TextEditingControllers are not disposed while still inherited.
    useRootNavigator: false,
    builder: (ctx) {
      return _EntityEditorSheetBody(
        title: title,
        fields: fields,
        labels: labels,
        saveLabel: saveLabel,
        languageCode: lang,
      );
    },
  );
}

class _EntityEditorSheetBody extends StatefulWidget {
  const _EntityEditorSheetBody({
    required this.title,
    required this.fields,
    required this.labels,
    required this.saveLabel,
    required this.languageCode,
  });

  final String title;
  final Map<String, String> fields;
  final Map<String, String> labels;
  final String saveLabel;
  final String languageCode;

  @override
  State<_EntityEditorSheetBody> createState() => _EntityEditorSheetBodyState();
}

class _EntityEditorSheetBodyState extends State<_EntityEditorSheetBody> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final entry in widget.fields.entries)
        entry.key: TextEditingController(text: entry.value),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.9;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              for (final key in _controllers.keys) ...[
                TextField(
                  controller: _controllers[key],
                  decoration: InputDecoration(
                    labelText: widget.labels[key] ??
                        FamilyFieldLabels.label(key, widget.languageCode),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop({
                    for (final e in _controllers.entries)
                      e.key: e.value.text.trim(),
                  });
                },
                child: Text(widget.saveLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> confirmDelete(BuildContext context, String label) async {
  final lang = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(FamilyFieldLabels.ui('ui.delete', lang)),
      content: Text(
        '${FamilyFieldLabels.ui('ui.delete', lang)} "$label"?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(FamilyFieldLabels.ui('ui.cancel', lang)),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(FamilyFieldLabels.ui('ui.delete', lang)),
        ),
      ],
    ),
  );
  return ok ?? false;
}

String familyFmtDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime familyParseDateOr(String raw, DateTime fallback) =>
    DateTime.tryParse(raw) ?? fallback;
