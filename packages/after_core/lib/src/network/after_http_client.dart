import 'package:dio/dio.dart';

import '../errors/after_exception.dart';
import '../logging/after_logger.dart';

/// Security + policy hooks for outbound HTTP.
class AfterHttpPolicy {
  const AfterHttpPolicy({
    this.userAgent = 'AfterCore/1.0 (Flutter)',
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 20),
    this.sendTimeout = const Duration(seconds: 15),
    this.requireHttps = true,
    this.blockedHosts = const {},
    this.maxRequestsPerHostPerMinute = 60,
  });

  final String userAgent;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool requireHttps;
  final Set<String> blockedHosts;
  final int maxRequestsPerHostPerMinute;
}

/// Builds a hardened Dio client shared across Super Apps.
class AfterHttpClientFactory {
  AfterHttpClientFactory({
    this.policy = const AfterHttpPolicy(),
    AfterLogger? logger,
  }) : _logger = logger ?? const NoOpAfterLogger();

  final AfterHttpPolicy policy;
  final AfterLogger _logger;
  final _RateLimiter _limiter = _RateLimiter();

  Dio create() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: policy.connectTimeout,
        receiveTimeout: policy.receiveTimeout,
        sendTimeout: policy.sendTimeout,
        headers: {
          'User-Agent': policy.userAgent,
          'Accept': 'application/json, text/xml, application/xml, */*',
        },
        followRedirects: false,
        receiveDataWhenStatusError: true,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final uri = options.uri;
          if (uri.host.isEmpty) {
            return handler.reject(_reject(options, 'invalid_request_url'));
          }
          if (policy.blockedHosts.contains(uri.host.toLowerCase())) {
            return handler.reject(_reject(options, 'blocked_request_host'));
          }
          if (policy.requireHttps && uri.scheme != 'https') {
            return handler.reject(_reject(options, 'insecure_request_scheme'));
          }
          final key = '${options.method}:${uri.host}${uri.path}';
          if (!_limiter.allow(key, policy.maxRequestsPerHostPerMinute)) {
            return handler.reject(
              _reject(options, 'rate_limited', type: DioExceptionType.cancel),
            );
          }
          handler.next(options);
        },
        onError: (error, handler) {
          _logger.w(
            'http_error',
            error: error,
            extras: {
              'path': error.requestOptions.path,
              'status': error.response?.statusCode,
            },
          );
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  DioException _reject(
    RequestOptions options,
    String code, {
    DioExceptionType type = DioExceptionType.badResponse,
  }) {
    return DioException(
      requestOptions: options,
      error: FormatException(code),
      type: type,
    );
  }
}

class _RateLimiter {
  final Map<String, List<DateTime>> _hits = {};

  bool allow(String key, int maxPerMinute) {
    final now = DateTime.now();
    final windowStart = now.subtract(const Duration(minutes: 1));
    final list = (_hits[key] ?? []).where((t) => t.isAfter(windowStart)).toList();
    if (list.length >= maxPerMinute) {
      _hits[key] = list;
      return false;
    }
    list.add(now);
    _hits[key] = list;
    return true;
  }
}

/// Maps Dio errors to [AfterNetworkException].
AfterNetworkException mapDioException(DioException error) {
  final status = error.response?.statusCode;
  final retryable = switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.connectionError =>
      true,
    _ => status == null || status >= 500,
  };
  return AfterNetworkException(
    error.message ?? 'network_error',
    cause: error,
    code: error.type.name,
    isRetryable: retryable,
    statusCode: status,
  );
}
