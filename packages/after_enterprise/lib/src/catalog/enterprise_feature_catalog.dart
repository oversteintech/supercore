import 'package:meta/meta.dart';

/// Shell-level enterprise feature identity that every enterprise Super App
/// carries: Home dashboard, Tasks, Calendar, Documents, AI, and a "More"
/// surface (org / settings / admin). Vertical products may EXTEND but not
/// REPLACE this catalog to preserve family feel.
enum EnterpriseCoreFeatureId {
  dashboard,
  tasks,
  calendar,
  documents,
  assistant,
  more,
}

/// A vertical / industry feature exposed by a specific enterprise product
/// (e.g. Patients in SuperHospital). Kept as a pure record so `domain/`
/// layers can consume it without a Flutter dependency.
@immutable
class EnterpriseIndustryFeature {
  const EnterpriseIndustryFeature({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    this.requiredPermission,
  });

  final String id;
  final String titleKey;
  final String subtitleKey;
  final String? requiredPermission;
}
