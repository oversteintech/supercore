import 'package:meta/meta.dart';

@immutable
class ReportDefinition {
  const ReportDefinition({
    required this.id,
    required this.name,
    required this.description,
    this.parameters = const [],
  });

  final String id;
  final String name;
  final String description;
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
  Future<List<ReportDefinition>> listReports();
  Future<ReportResult> runReport({
    required String reportId,
    Map<String, String> parameters = const {},
  });
}

class MockReportingRepository implements ReportingRepository {
  MockReportingRepository({List<ReportDefinition>? seed})
      : _defs = {for (final r in seed ?? const <ReportDefinition>[]) r.id: r};

  final Map<String, ReportDefinition> _defs;

  @override
  Future<List<ReportDefinition>> listReports() async =>
      List.unmodifiable(_defs.values);

  @override
  Future<ReportResult> runReport({
    required String reportId,
    Map<String, String> parameters = const {},
  }) async {
    final def = _defs[reportId];
    if (def == null) {
      throw StateError('Unknown report $reportId');
    }
    return ReportResult(
      reportId: reportId,
      generatedAt: DateTime.now().toUtc(),
      columns: const ['metric', 'value'],
      rows: [
        <Object?>['generated_for', def.name],
        <Object?>['parameter_count', parameters.length],
      ],
      metadata: const {'source': 'mock'},
    );
  }
}
