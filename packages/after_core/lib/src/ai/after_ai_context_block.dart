import 'package:meta/meta.dart';

/// Opaque AI context payload shared across packages without cycles (ADR-001).
///
/// `after_ecosystem` builds this from [AfterEcosystemAiContext];
/// `after_ai` injects it into chat system prompts.
@immutable
class AfterAiContextBlock {
  const AfterAiContextBlock({
    required this.text,
    this.metadata = const <String, Object?>{},
  });

  /// Prompt-ready text block (may be empty).
  final String text;

  /// Structured metadata (afterId, organizationId, productId, etc.).
  final Map<String, Object?> metadata;

  bool get isEmpty => text.trim().isEmpty;

  AfterAiContextBlock merge(AfterAiContextBlock other) {
    if (other.isEmpty) return this;
    if (isEmpty) return other;
    return AfterAiContextBlock(
      text: '$text\n\n${other.text}',
      metadata: {...metadata, ...other.metadata},
    );
  }
}
