import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'family_profile_identity.dart';

Future<String?> _showTextEditDialog(
  BuildContext context, {
  required String title,
  required String initialValue,
  String? hintText,
  TextInputType? keyboardType,
  TextCapitalization textCapitalization = TextCapitalization.none,
}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      return _TextEditDialog(
        title: title,
        initialValue: initialValue,
        hintText: hintText,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
      );
    },
  );
}

class _TextEditDialog extends StatefulWidget {
  const _TextEditDialog({
    required this.title,
    required this.initialValue,
    this.hintText,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  final String title;
  final String initialValue;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  @override
  State<_TextEditDialog> createState() => _TextEditDialogState();
}

class _TextEditDialogState extends State<_TextEditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        decoration: InputDecoration(hintText: widget.hintText),
        onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

Future<void> editFamilyProfileDisplayName(
  BuildContext context,
  WidgetRef ref,
  String? current,
) async {
  final saved = await _showTextEditDialog(
    context,
    title: 'Display name',
    initialValue: current ?? '',
    hintText: 'Your name',
    textCapitalization: TextCapitalization.words,
  );
  if (saved == null || saved == current || !context.mounted) return;
  await Future<void>.delayed(Duration.zero);
  if (!context.mounted) return;
  await ref
      .read(familyProfileIdentityProvider.notifier)
      .updateFields(displayName: saved);
}

Future<void> editFamilyProfileEmail(
  BuildContext context,
  WidgetRef ref,
  String? current,
) async {
  final saved = await _showTextEditDialog(
    context,
    title: 'Email',
    initialValue: current ?? '',
    hintText: 'you@example.com',
    keyboardType: TextInputType.emailAddress,
  );
  if (saved == null || saved == current) return;
  if (!saved.contains('@') || !saved.contains('.')) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enter a valid email')),
    );
    return;
  }
  if (!context.mounted) return;
  await Future<void>.delayed(Duration.zero);
  if (!context.mounted) return;
  await ref
      .read(familyProfileIdentityProvider.notifier)
      .updateFields(email: saved);
}

Future<void> editFamilyProfilePhoneNumber(
  BuildContext context,
  WidgetRef ref,
  String? current,
) async {
  final saved = await _showTextEditDialog(
    context,
    title: 'Phone',
    initialValue: current ?? '',
    hintText: '+90…',
    keyboardType: TextInputType.phone,
  );
  if (saved == null || saved == current || !context.mounted) return;
  await Future<void>.delayed(Duration.zero);
  if (!context.mounted) return;
  await ref
      .read(familyProfileIdentityProvider.notifier)
      .updateFields(phoneNumber: saved);
}

Future<void> editFamilyProfileUsername(
  BuildContext context,
  WidgetRef ref,
  String? current,
) async {
  final saved = await _showTextEditDialog(
    context,
    title: 'Username',
    initialValue: current ?? '',
    hintText: 'letters, numbers, . and _',
  );
  if (saved == null || saved == current) return;
  final normalized = saved.trim().replaceAll('@', '');
  if (normalized.length < 3) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Username must be at least 3 characters')),
    );
    return;
  }
  if (!context.mounted) return;
  await Future<void>.delayed(Duration.zero);
  if (!context.mounted) return;
  await ref
      .read(familyProfileIdentityProvider.notifier)
      .updateFields(username: normalized);
}
