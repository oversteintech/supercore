import 'package:dio/dio.dart';

import '../errors/after_exception.dart';
import '../network/after_http_client.dart';

/// Typed REST helper over Dio.
class AfterApiClient {
  AfterApiClient(this._dio, {this.baseUrl});

  final Dio _dio;
  final String? baseUrl;

  Uri _resolve(String path, [Map<String, dynamic>? query]) {
    final base = baseUrl;
    final uri = base == null || base.isEmpty
        ? Uri.parse(path)
        : Uri.parse(base).resolve(path);
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...query.map((k, v) => MapEntry(k, '$v')),
      },
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _guard(
        () => _dio.getUri<T>(
          _resolve(path, query),
          options: options,
          cancelToken: cancelToken,
        ),
      );

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _guard(
        () => _dio.postUri<T>(
          _resolve(path, query),
          data: data,
          options: options,
          cancelToken: cancelToken,
        ),
      );

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _guard(
        () => _dio.putUri<T>(
          _resolve(path, query),
          data: data,
          options: options,
          cancelToken: cancelToken,
        ),
      );

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _guard(
        () => _dio.patchUri<T>(
          _resolve(path, query),
          data: data,
          options: options,
          cancelToken: cancelToken,
        ),
      );

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _guard(
        () => _dio.deleteUri<T>(
          _resolve(path, query),
          data: data,
          options: options,
          cancelToken: cancelToken,
        ),
      );

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() run) async {
    try {
      return await run();
    } on DioException catch (e) {
      throw mapDioException(e);
    } catch (e) {
      if (e is AfterException) rethrow;
      throw AfterNetworkException('api_error', cause: e);
    }
  }
}

/// Auth header injector for API clients.
class AfterAuthInterceptor extends Interceptor {
  AfterAuthInterceptor(this.tokenProvider);

  final Future<String?> Function() tokenProvider;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
