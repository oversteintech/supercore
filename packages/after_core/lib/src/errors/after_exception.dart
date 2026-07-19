/// Base exception for all After Core application-level errors.
sealed class AfterException implements Exception {
  const AfterException(this.message, {this.cause, this.code});

  final String message;
  final Object? cause;
  final String? code;

  @override
  String toString() => 'AfterException: $message';
}

final class AfterAuthException extends AfterException {
  const AfterAuthException(super.message, {super.cause, super.code});
}

final class AfterNetworkException extends AfterException {
  const AfterNetworkException(
    super.message, {
    super.cause,
    super.code,
    this.isRetryable = true,
    this.statusCode,
  });

  final bool isRetryable;
  final int? statusCode;
}

final class AfterStorageException extends AfterException {
  const AfterStorageException(super.message, {super.cause, super.code});
}

final class AfterSyncException extends AfterException {
  const AfterSyncException(super.message, {super.cause, super.code});
}

final class AfterSubscriptionException extends AfterException {
  const AfterSubscriptionException(super.message, {super.cause, super.code});
}

final class AfterAiException extends AfterException {
  const AfterAiException(super.message, {super.cause, super.code});
}

final class AfterConfigException extends AfterException {
  const AfterConfigException(super.message, {super.cause, super.code});
}

final class AfterDeepLinkException extends AfterException {
  const AfterDeepLinkException(super.message, {super.cause, super.code});
}

/// Maps arbitrary errors into [AfterException] at boundaries.
AfterException afterExceptionFrom(Object error, [StackTrace? stack]) {
  if (error is AfterException) return error;
  return AfterExceptionWrapper(error.toString(), cause: error);
}

final class AfterExceptionWrapper extends AfterException {
  const AfterExceptionWrapper(super.message, {super.cause, super.code});
}
