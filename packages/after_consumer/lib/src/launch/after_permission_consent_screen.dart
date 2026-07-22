import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'after_launch_consent.dart';
import 'after_launch_consent_strings.dart';
import 'after_location_permission.dart';
import '../location/after_current_locality.dart';

class AfterPermissionConsentScreen extends ConsumerStatefulWidget {
  const AfterPermissionConsentScreen({
    required this.strings,
    required this.onAccepted,
    this.requestLocationOnAccept = true,
    super.key,
  });

  final AfterLaunchConsentStrings strings;
  final VoidCallback onAccepted;
  final bool requestLocationOnAccept;

  @override
  ConsumerState<AfterPermissionConsentScreen> createState() =>
      _AfterPermissionConsentScreenState();
}

class _AfterPermissionConsentScreenState
    extends ConsumerState<AfterPermissionConsentScreen> {
  bool _checked = false;
  bool _saving = false;

  Future<void> _accept() async {
    if (!_checked || _saving) return;
    setState(() => _saving = true);
    await ref.read(afterPermissionConsentProvider.notifier).accept();
    if (widget.requestLocationOnAccept) {
      await AfterLocationPermission.requestIfConsented();
      // Shell header locality resolves after OS grant.
      ref.invalidate(afterCurrentLocalityProvider);
    }
    if (mounted) widget.onAccepted();
  }

  void _decline() {
    final strings = widget.strings;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(strings.permissionRequiredTitle),
          content: Text(strings.permissionRequiredBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                SystemNavigator.pop();
              },
              child: Text(strings.legalExitApp),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.strings;
    final theme = Theme.of(context);

    final items = [
      (
        Icons.location_on_rounded,
        strings.permissionLocation,
        strings.permissionLocationBody,
      ),
      (
        Icons.notifications_rounded,
        strings.permissionNotifications,
        strings.permissionNotificationsBody,
      ),
      (
        Icons.photo_library_rounded,
        strings.permissionPhotos,
        strings.permissionPhotosBody,
      ),
      (
        Icons.photo_camera_rounded,
        strings.permissionCamera,
        strings.permissionCameraBody,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                children: [
                  Icon(
                    Icons.shield_rounded,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    strings.permissionTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.permissionSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...items.map(
                    (item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          item.$1,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          item.$2,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          item.$3,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.permissionFooter,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: _checked,
                    onChanged: (value) =>
                        setState(() => _checked = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(strings.permissionCheckbox),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: _checked && !_saving ? _accept : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(strings.permissionAccept),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _decline,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(strings.legalDecline),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
