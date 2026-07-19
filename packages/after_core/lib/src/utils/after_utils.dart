import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart' show sha256;
import 'package:uuid/uuid.dart';

/// Shared utilities for Super Apps.
abstract final class AfterUtils {
  static const uuid = Uuid();

  static String newId() => uuid.v4();

  static String? nullIfBlank(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static bool isValidEmail(String? value) {
    final email = nullIfBlank(value);
    if (email == null) return false;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  /// Stable, non-reversible fingerprint for analytics (not a password hash).
  static String fingerprint(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  static Future<T> withTimeout<T>(
    Future<T> future, {
    Duration timeout = const Duration(seconds: 15),
    FutureOr<T> Function()? onTimeout,
  }) {
    return future.timeout(timeout, onTimeout: onTimeout);
  }

  static Map<String, Object?> scrubExtras(
    Map<String, Object?> input, {
    Set<String> denyKeys = const {
      'password',
      'token',
      'apiKey',
      'api_key',
      'authorization',
      'secret',
      'refreshToken',
    },
  }) {
    return {
      for (final entry in input.entries)
        if (!denyKeys.contains(entry.key.toLowerCase()) &&
            !denyKeys.contains(entry.key))
          entry.key: entry.value,
    };
  }
}

/// Simple debounce helper for search fields / analytics.
class AfterDebouncer {
  AfterDebouncer({this.duration = const Duration(milliseconds: 300)});

  final Duration duration;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() => _timer?.cancel();

  void dispose() => cancel();
}

/// Result type for boundary operations without throwing.
sealed class AfterResult<T> {
  const AfterResult();

  bool get isSuccess => this is AfterSuccess<T>;
  bool get isFailure => this is AfterFailure<T>;

  T? get valueOrNull => switch (this) {
        AfterSuccess(:final value) => value,
        AfterFailure() => null,
      };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Object error, StackTrace? stack) onFailure,
  }) {
    return switch (this) {
      AfterSuccess(:final value) => onSuccess(value),
      AfterFailure(:final error, :final stackTrace) =>
        onFailure(error, stackTrace),
    };
  }
}

final class AfterSuccess<T> extends AfterResult<T> {
  const AfterSuccess(this.value);
  final T value;
}

final class AfterFailure<T> extends AfterResult<T> {
  const AfterFailure(this.error, [this.stackTrace]);
  final Object error;
  final StackTrace? stackTrace;
}
