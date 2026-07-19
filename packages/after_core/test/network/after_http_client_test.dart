import 'package:after_core/after_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AfterHttpPolicy', () {
    test('defaults are correct', () {
      const policy = AfterHttpPolicy();
      expect(policy.requireHttps, true);
      expect(policy.maxRequestsPerHostPerMinute, 60);
    });
  });

  group('AfterHttpClientFactory', () {
    late AfterHttpClientFactory factory;

    setUp(() {
      factory = AfterHttpClientFactory();
    });

    test('create returns dio with correct options', () {
      final dio = factory.create();
      expect(dio.options.connectTimeout, const Duration(seconds: 15));
      expect(dio.options.headers['User-Agent'], 'AfterCore/1.0 (Flutter)');
    });

    test('rejects insecure request if policy requires https', () async {
      final dio = factory.create();
      
      try {
        await dio.get<dynamic>('http://example.com');
        fail('Should have rejected insecure request');
      } on DioException catch (e) {
        expect(e.error.toString(), contains('insecure_request_scheme'));
      }
    });

    test('rejects blocked hosts', () async {
      factory = AfterHttpClientFactory(
        policy: const AfterHttpPolicy(blockedHosts: {'blocked.com'}),
      );
      final dio = factory.create();

      try {
        await dio.get<dynamic>('https://blocked.com/test');
        fail('Should have rejected blocked host');
      } on DioException catch (e) {
        expect(e.error.toString(), contains('blocked_request_host'));
      }
    });
  });

  group('mapDioException', () {
    test('maps timeout to retryable exception', () {
      final error = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      );
      final mapped = mapDioException(error);
      expect(mapped.isRetryable, true);
      expect(mapped.code, DioExceptionType.connectionTimeout.name);
    });

    test('maps 500 status to retryable exception', () {
      final error = DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        ),
      );
      final mapped = mapDioException(error);
      expect(mapped.isRetryable, true);
    });
  });
}
