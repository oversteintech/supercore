import 'package:meta/meta.dart';

/// Conventions for enterprise API clients. Provides a lightweight builder for
/// tenant-scoped headers so verticals share the same wire format when they
/// swap in a real HTTP client via `after_core.AfterApiClient`.
@immutable
class EnterpriseApiHeaders {
  const EnterpriseApiHeaders({
    required this.tenantHeader,
    required this.actorHeader,
    this.correlationIdHeader = 'x-correlation-id',
    this.roleHeader = 'x-roles',
  });

  final String tenantHeader;
  final String actorHeader;
  final String correlationIdHeader;
  final String roleHeader;

  static const EnterpriseApiHeaders standard = EnterpriseApiHeaders(
    tenantHeader: 'x-organization-id',
    actorHeader: 'x-actor-id',
  );

  Map<String, String> build({
    required String organizationId,
    String? actorId,
    List<String> roleIds = const [],
    String? correlationId,
  }) {
    return {
      tenantHeader: organizationId,
      if (actorId != null) actorHeader: actorId,
      if (roleIds.isNotEmpty) roleHeader: roleIds.join(','),
      if (correlationId != null) correlationIdHeader: correlationId,
    };
  }
}

/// Minimal port describing an enterprise HTTP client. Products depend on
/// this + inject a real `Dio` adapter at composition time.
abstract class EnterpriseApiClient {
  Future<Map<String, Object?>> getJson(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? query,
  });

  Future<Map<String, Object?>> postJson(
    String path,
    Object? body, {
    Map<String, String>? headers,
  });
}

/// Deterministic stub used by scaffolds & tests.
class NoOpEnterpriseApiClient implements EnterpriseApiClient {
  const NoOpEnterpriseApiClient();

  @override
  Future<Map<String, Object?>> getJson(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? query,
  }) async {
    return {'path': path, 'method': 'GET'};
  }

  @override
  Future<Map<String, Object?>> postJson(
    String path,
    Object? body, {
    Map<String, String>? headers,
  }) async {
    return {'path': path, 'method': 'POST'};
  }
}
