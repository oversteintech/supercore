import 'package:meta/meta.dart';

import '../scope/enterprise_scope.dart';

@immutable
class ReportDefinition {
  const ReportDefinition({
    required this.id,
    required this.name,
    required this.description,
    this.organizationId,
    this.parameters = const [],
  });

  final String id;
  final String name;
  final String description;

  /// When null, the report is available to every tenant catalog.
  final String? organizationId;
  final List<String> parameters;
}

@immutable
class ReportResult {
  const ReportResult({
    required this.reportId,
    required this.generatedAt,
    required this.columns,
    required this.rows,
    this.metadata = const {},
  });

  final String reportId;
  final DateTime generatedAt;
  final List<String> columns;
  final List<List<Object?>> rows;
  final Map<String, String> metadata;
}

abstract class ReportingRepository {
  /// Fail-closed: [organizationId] is required (ADR-002).
  Future<List<ReportDefinition>> listReports({required String organizationId});
  Future<ReportResult> runReport({
    required String organizationId,
    required String reportId,
    Map<String, String> parameters = const {},
  });
}

class MockReportingRepository implements ReportingRepository {
  MockReportingRepository({List<ReportDefinition>? seed})
      : _defs = {for (final r in seed ?? const <ReportDefinition>[]) r.id: r};

  final Map<String, ReportDefinition> _defs;

  @override
  Future<List<ReportDefinition>> listReports({
    required String organizationId,
  }) async {
    final org = EnterpriseScope.requireOrganizationId(organizationId);
    return _defs.values
        .where((r) => r.organizationId == null || r.organizationId == org)
        .toList(growable: false);
  }

  @override
  Future<ReportResult> runReport({
    required String organizationId,
    required String reportId,
    Map<String, String> parameters = const {},
  }) async {
    final org = EnterpriseScope.requireOrganizationId(organizationId);
    final def = _defs[reportId];
    if (def == null) {
      throw StateError('Unknown report $reportId');
    }
    if (def.organizationId != null && def.organizationId != org) {
      throw StateError('Report $reportId is not available for org $org');
    }
    return ReportResult(
      reportId: reportId,
      generatedAt: DateTime.now().toUtc(),
      columns: const ['metric', 'value'],
      rows: [
        <Object?>['generated_for', def.name],
        <Object?>['organization_id', org],
        <Object?>['parameter_count', parameters.length],
      ],
      metadata: const {'source': 'mock'},
    );
  }
}
