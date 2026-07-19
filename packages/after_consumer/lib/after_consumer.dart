/// After Consumer — OS layer for AfterArtificial B2C Super Apps.
///
/// A thin set of helpers on top of `after_core` that keeps the consumer
/// family (SuperGarage reference, SuperHealth, SuperFinance, SuperHome,
/// SuperTravel, SuperPet, SuperSports, SuperNews, SuperGames, SuperFamily,
/// SuperDocuments, SuperLearning) architecturally consistent.
library;

export 'src/catalog/consumer_feature_catalog.dart';
export 'src/di/consumer_providers.dart';
export 'src/membership/consumer_membership.dart';
export 'src/vault/personal_vault.dart';
