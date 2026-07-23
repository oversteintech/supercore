import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../media/after_photo_crop.dart';
import 'family_animated_profile_avatar.dart';
import 'family_avatar_options.dart';
import 'family_profile_identity.dart';

export 'family_avatar_options.dart';

/// Opens Garage-parity avatar / profile-photo sheet.
Future<void> showFamilyAvatarPicker(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      return const SafeArea(
        child: _FamilyProfileIdentitySheet(),
      );
    },
  );
}

class _FamilyProfileIdentitySheet extends ConsumerStatefulWidget {
  const _FamilyProfileIdentitySheet();

  @override
  ConsumerState<_FamilyProfileIdentitySheet> createState() =>
      _FamilyProfileIdentitySheetState();
}

class _FamilyProfileIdentitySheetState
    extends ConsumerState<_FamilyProfileIdentitySheet> {
  bool _busy = false;

  Future<void> _pickPhoto() async {
    final identity = ref.read(familyProfileIdentityProvider);
    if (!identity.canAddPhoto) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Maximum ${FamilyProfileIdentity.maxProfilePhotos} photos',
          ),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
      maxWidth: 4096,
      maxHeight: 4096,
    );
    if (picked == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      if (bytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AfterPhotoCropCopy.english().failedMessage)),
        );
        return;
      }

      final cropped = await AfterPhotoCropScreen.open(
        context,
        imageBytes: Uint8List.fromList(bytes),
        aspectRatio: AfterPhotoCropScreen.profileAspectRatio,
      );
      if (cropped == null || !mounted) return;

      await ref
          .read(familyProfileIdentityProvider.notifier)
          .addProfilePhoto(cropped);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _selectAvatar(String avatarId) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(familyProfileIdentityProvider.notifier)
          .setAvatarId(avatarId);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final identity = ref.watch(familyProfileIdentityProvider);
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.66;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 28,
      ),
      child: SizedBox(
        height: sheetHeight,
        child: DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (_busy)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              const TabBar(
                tabs: [
                  Tab(text: 'Avatar'),
                  Tab(text: 'Profile photo'),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    _AvatarTab(
                      busy: _busy,
                      selectedAvatarId: identity.avatarId,
                      onSelect: _selectAvatar,
                    ),
                    _ProfilePhotoTab(
                      busy: _busy,
                      onPickPhoto: _pickPhoto,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarTab extends StatelessWidget {
  const _AvatarTab({
    required this.busy,
    required this.selectedAvatarId,
    required this.onSelect,
  });

  final bool busy;
  final String selectedAvatarId;
  final Future<void> Function(String avatarId) onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: familyAvatarOptions
            .map((avatar) {
              final selected = avatar.id == selectedAvatarId;
              return FamilyAnimatedAvatarPickerTile(
                avatar: avatar,
                selected: selected,
                enabled: !busy,
                onTap: () => onSelect(avatar.id),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _ProfilePhotoTab extends ConsumerWidget {
  const _ProfilePhotoTab({
    required this.busy,
    required this.onPickPhoto,
  });

  final bool busy;
  final Future<void> Function() onPickPhoto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final identity = ref.watch(familyProfileIdentityProvider);
    final thumbs = ref.watch(familyProfilePhotoThumbnailsProvider);
    final photos = identity.photoIds;
    final activePhoto = identity.activePhotoId;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: busy ? null : onPickPhoto,
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('Add profile photo'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (photos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No profile photos yet. Add one from your gallery.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final id = photos[index];
                  final isActive = id == activePhoto;
                  return _ProfilePhotoTile(
                    photoId: id,
                    isActive: isActive,
                    onTap: () => ref
                        .read(familyProfileIdentityProvider.notifier)
                        .setActiveProfilePhoto(id),
                    onDelete: () => ref
                        .read(familyProfileIdentityProvider.notifier)
                        .removeProfilePhotoAt(index),
                    thumbs: thumbs,
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          if (photos.isNotEmpty)
            TextButton.icon(
              onPressed: busy
                  ? null
                  : () => ref
                      .read(familyProfileIdentityProvider.notifier)
                      .clearProfilePhotos(),
              icon: const Icon(Icons.delete_sweep_rounded),
              label: const Text('Remove all photos'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfilePhotoTile extends StatelessWidget {
  const _ProfilePhotoTile({
    required this.photoId,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
    required this.thumbs,
  });

  final String photoId;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final List<FamilyProfilePhotoThumb> thumbs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Uint8List? bytes;
    for (final thumb in thumbs) {
      if (thumb.id == photoId) {
        bytes = thumb.bytes;
        break;
      }
    }

    return Stack(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
                width: isActive ? 3 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: bytes != null
                ? Image.memory(bytes, fit: BoxFit.cover)
                : const Icon(Icons.broken_image_rounded),
          ),
        ),
        if (isActive)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Active',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: theme.colorScheme.scrim.withValues(alpha: 0.54),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            onPressed: onDelete,
          ),
        ),
      ],
    );
  }
}
