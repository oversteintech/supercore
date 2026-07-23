import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

/// Localized labels for the shared photo crop editor.
class AfterPhotoCropCopy {
  const AfterPhotoCropCopy({
    required this.title,
    required this.hint,
    required this.saveLabel,
    required this.failedMessage,
  });

  factory AfterPhotoCropCopy.english() {
    return const AfterPhotoCropCopy(
      title: 'Adjust photo',
      hint: 'Pinch and drag to frame the photo, then save.',
      saveLabel: 'Save',
      failedMessage: 'Could not crop the photo. Try again.',
    );
  }

  final String title;
  final String hint;
  final String saveLabel;
  final String failedMessage;
}

/// Interactive crop / resize editor used by vehicle and profile photo flows.
class AfterPhotoCropScreen extends StatefulWidget {
  const AfterPhotoCropScreen({
    required this.imageBytes,
    required this.aspectRatio,
    this.copy = const AfterPhotoCropCopy(
      title: 'Adjust photo',
      hint: 'Pinch and drag to frame the photo, then save.',
      saveLabel: 'Save',
      failedMessage: 'Could not crop the photo. Try again.',
    ),
    super.key,
  });

  final Uint8List imageBytes;
  final double aspectRatio;
  final AfterPhotoCropCopy copy;

  /// Square frame for profile / avatar photos.
  static const double profileAspectRatio = 1;

  static Future<Uint8List?> open(
    BuildContext context, {
    required Uint8List imageBytes,
    required double aspectRatio,
    AfterPhotoCropCopy? copy,
    bool rootNavigator = true,
  }) {
    return Navigator.of(context, rootNavigator: rootNavigator).push<Uint8List>(
      MaterialPageRoute<Uint8List>(
        builder: (_) => AfterPhotoCropScreen(
          imageBytes: imageBytes,
          aspectRatio: aspectRatio,
          copy: copy ?? AfterPhotoCropCopy.english(),
        ),
      ),
    );
  }

  @override
  State<AfterPhotoCropScreen> createState() => _AfterPhotoCropScreenState();
}

class _AfterPhotoCropScreenState extends State<AfterPhotoCropScreen> {
  final _controller = CropController();
  var _cropping = false;

  void _saveCrop() {
    if (_cropping) return;
    setState(() => _cropping = true);
    _controller.crop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final copy = widget.copy;

    return Scaffold(
      appBar: AppBar(
        title: Text(copy.title),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _cropping ? null : () => Navigator.of(context).pop(),
        ),
        actions: [
          FilledButton(
            onPressed: _cropping ? null : _saveCrop,
            child: _cropping
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(copy.saveLabel),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Text(
              copy.hint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Crop(
                  image: widget.imageBytes,
                  controller: _controller,
                  aspectRatio: widget.aspectRatio,
                  interactive: true,
                  baseColor: theme.colorScheme.surfaceContainerHighest,
                  maskColor: Colors.black.withValues(alpha: 0.55),
                  radius: 12,
                  onCropped: (result) {
                    if (!mounted) return;
                    switch (result) {
                      case CropSuccess(:final croppedImage):
                        Navigator.of(context).pop(croppedImage);
                      case CropFailure():
                        setState(() => _cropping = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(copy.failedMessage)),
                        );
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
