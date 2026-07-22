import 'package:meta/meta.dart';

import '../identity/after_id.dart';

/// Product line for interop policy.
enum AfterEcosystemLine { consumer, enterprise }

/// One callable endpoint exposed by a product module.
@immutable
class AfterProductEndpoint {
  const AfterProductEndpoint({
    required this.name,
    required this.description,
    this.requiredScopes = const <String>[],
    this.inputSchema = const <String, Object?>{},
    this.outputSchema = const <String, Object?>{},
  });

  final String name;
  final String description;
  final List<String> requiredScopes;
  final Map<String, Object?> inputSchema;
  final Map<String, Object?> outputSchema;
}

typedef AfterProductInvoker = Future<Object?> Function(
  AfterProductApiCall call,
);

/// Descriptor registered by every product at bootstrap.
@immutable
class AfterProductApi {
  const AfterProductApi({
    required this.productId,
    required this.displayName,
    required this.line,
    required this.endpoints,
    this.invoke,
  });

  final String productId;
  final String displayName;
  final AfterEcosystemLine line;
  final List<AfterProductEndpoint> endpoints;

  /// Runtime handler — null means discoverable but not locally invokable.
  final AfterProductInvoker? invoke;
}

@immutable
class AfterProductApiCall {
  const AfterProductApiCall({
    required this.targetProductId,
    required this.endpoint,
    required this.callerProductId,
    required this.afterId,
    this.organizationId,
    this.scopes = const <String>{},
    this.args = const <String, Object?>{},
  });

  final String targetProductId;
  final String endpoint;
  final String callerProductId;
  final AfterId afterId;
  final String? organizationId;
  final Set<String> scopes;
  final Map<String, Object?> args;
}

class AfterInteropException implements Exception {
  AfterInteropException(this.message);
  final String message;
  @override
  String toString() => 'AfterInteropException: $message';
}

typedef AfterInteropAuditHook = void Function(
  AfterProductApiCall call, {
  required bool allowed,
  Object? error,
});

/// Registry of every product API in the ecosystem.
abstract class AfterProductApiRegistry {
  void register(AfterProductApi api);

  void unregister(String productId);

  AfterProductApi? get(String productId);

  List<AfterProductApi> get all;

  /// Internal invoke — products must use [AfterSecureInteropBridge] (ADR-006).
  @visibleForTesting
  Future<Object?> invokeInternal(AfterProductApiCall call);
}

class InMemoryAfterProductApiRegistry implements AfterProductApiRegistry {
  final Map<String, AfterProductApi> _apis = {};

  @override
  void register(AfterProductApi api) => _apis[api.productId] = api;

  @override
  void unregister(String productId) => _apis.remove(productId);

  @override
  AfterProductApi? get(String productId) => _apis[productId];

  @override
  List<AfterProductApi> get all =>
      List<AfterProductApi>.unmodifiable(_apis.values);

  @override
  Future<Object?> invokeInternal(AfterProductApiCall call) async {
    final api = _apis[call.targetProductId];
    if (api == null) {
      throw AfterInteropException(
        'Unknown product API "${call.targetProductId}"',
      );
    }
    AfterProductEndpoint? endpoint;
    for (final e in api.endpoints) {
      if (e.name == call.endpoint) {
        endpoint = e;
        break;
      }
    }
    if (endpoint == null) {
      throw AfterInteropException(
        'Unknown endpoint "${call.endpoint}" on ${call.targetProductId}',
      );
    }
    for (final scope in endpoint.requiredScopes) {
      if (!call.scopes.contains(scope)) {
        throw AfterInteropException('Missing scope "$scope"');
      }
    }
    final invoker = api.invoke;
    if (invoker == null) {
      throw AfterInteropException(
        'Product "${call.targetProductId}" has no local invoker',
      );
    }
    return invoker(call);
  }
}

/// Secure bridge for all cross-product calls (ADR-006).
abstract class AfterSecureInteropBridge {
  Future<Object?> call({
    required AfterProductApiCall call,
    required AfterEcosystemLine callerLine,
  });
}

/// Policy: cross-line calls require explicit `interop.*` scopes + **mandatory** audit.
class PolicyAfterSecureInteropBridge implements AfterSecureInteropBridge {
  PolicyAfterSecureInteropBridge({
    required AfterProductApiRegistry registry,
    required this.onAudited,
  }) : _registry = registry;

  final AfterProductApiRegistry _registry;

  /// Mandatory audit hook — never optional (ADR-006).
  final AfterInteropAuditHook onAudited;

  @override
  Future<Object?> call({
    required AfterProductApiCall call,
    required AfterEcosystemLine callerLine,
  }) async {
    final target = _registry.get(call.targetProductId);
    if (target == null) {
      onAudited(call, allowed: false, error: 'unknown_target');
      throw AfterInteropException('Unknown target ${call.targetProductId}');
    }

    final crossLine = target.line != callerLine;
    if (crossLine &&
        !call.scopes.contains('interop.cross_line') &&
        !call.scopes.contains('interop.*')) {
      onAudited(call, allowed: false, error: 'missing_cross_line_scope');
      throw AfterInteropException(
        'Cross-line call requires scope interop.cross_line',
      );
    }

    try {
      final result = await _registry.invokeInternal(call);
      onAudited(call, allowed: true);
      return result;
    } catch (e) {
      onAudited(call, allowed: false, error: e);
      rethrow;
    }
  }
}
