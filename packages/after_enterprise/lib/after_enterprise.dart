/// After Enterprise — shared OS layer for AfterArtificial B2B / vertical
/// Super Apps (SuperHospital reference, plus SuperAirport, SuperMaritime,
/// SuperLogistics, SuperFactory, SuperConstruction, SuperSchool, SuperHotel,
/// SuperRestaurant, SuperRetail, SuperEnergy, SuperAgriculture,
/// SuperMunicipality, SuperPolice, SuperFire, SuperMining).
///
/// Ports + `Mock*` implementations for organization/tenant, RBAC,
/// workflow, tasks, calendar, documents, enterprise AI, messaging,
/// notifications, reporting, analytics, audit logging, offline sync
/// and API conventions. Vertical products depend on ports only.
library;

export 'src/ai/enterprise_ai.dart';
export 'src/analytics/enterprise_analytics.dart';
export 'src/api/enterprise_api.dart';
export 'src/audit/audit_log.dart';
export 'src/calendar/calendar.dart';
export 'src/catalog/enterprise_feature_catalog.dart';
export 'src/di/enterprise_providers.dart';
export 'src/documents/documents.dart';
export 'src/messaging/messaging.dart';
export 'src/notifications/enterprise_notifications.dart';
export 'src/organization/organization.dart';
export 'src/rbac/rbac.dart';
export 'src/reporting/reporting.dart';
export 'src/repository/enterprise_repository.dart';
export 'src/sync/offline_sync.dart';
export 'src/tasks/tasks.dart';
export 'src/workflow/workflow.dart';
