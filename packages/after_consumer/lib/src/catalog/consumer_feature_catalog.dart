import 'package:meta/meta.dart';

/// Shell-level consumer feature identity that every B2C Super App carries.
/// Home / Explore / Assistant / Search / Profile — the SuperGarage family
/// contract. Product screens live in `lib/features/<vertical>/` and
/// register with the product-specific feature catalog.
enum ConsumerCoreFeatureId { home, explore, assistant, search, profile }

@immutable
class ConsumerVerticalFeature {
  const ConsumerVerticalFeature({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    this.requiresPremium = false,
  });

  final String id;
  final String titleKey;
  final String subtitleKey;
  final bool requiresPremium;
}
