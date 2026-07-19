import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AfterException', () {
    test('toString returns expected message', () {
      const ex = AfterAuthException('Login failed');
      expect(ex.toString(), contains('Login failed'));
    });

    test('AfterNetworkException stores extra fields', () {
      const ex = AfterNetworkException(
        'Timeout',
        isRetryable: true,
        statusCode: 408,
      );
      expect(ex.isRetryable, true);
      expect(ex.statusCode, 408);
    });
  });

  group('afterExceptionFrom', () {
    test('returns same instance if already AfterException', () {
      const original = AfterAuthException('fail');
      final result = afterExceptionFrom(original);
      expect(result, same(original));
    });

    test('wraps unknown errors in AfterExceptionWrapper', () {
      final error = Exception('Some error');
      final result = afterExceptionFrom(error);
      expect(result, isA<AfterExceptionWrapper>());
      expect(result.cause, error);
    });
  });
}
