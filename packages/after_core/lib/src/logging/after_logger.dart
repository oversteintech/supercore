import 'package:flutter/foundation.dart';

enum AfterLogLevel { verbose, debug, info, warning, error }

/// Pluggable logger for Super Apps.
abstract class AfterLogger {
  void log(
    AfterLogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> extras = const {},
  });

  void v(String message, {Map<String, Object?> extras = const {}}) =>
      log(AfterLogLevel.verbose, message, extras: extras);

  void d(String message, {Map<String, Object?> extras = const {}}) =>
      log(AfterLogLevel.debug, message, extras: extras);

  void i(String message, {Map<String, Object?> extras = const {}}) =>
      log(AfterLogLevel.info, message, extras: extras);

  void w(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> extras = const {},
  }) =>
      log(
        AfterLogLevel.warning,
        message,
        error: error,
        stackTrace: stackTrace,
        extras: extras,
      );

  void e(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> extras = const {},
  }) =>
      log(
        AfterLogLevel.error,
        message,
        error: error,
        stackTrace: stackTrace,
        extras: extras,
      );
}

/// Debug-console logger. Never logs secrets — callers MUST scrub first.
class ConsoleAfterLogger implements AfterLogger {
  const ConsoleAfterLogger({this.minLevel = AfterLogLevel.debug});

  final AfterLogLevel minLevel;

  @override
  void log(
    AfterLogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> extras = const {},
  }) {
    if (level.index < minLevel.index) return;
    if (!kDebugMode && level.index < AfterLogLevel.warning.index) return;

    final tag = level.name.toUpperCase().padRight(7);
    final extra = extras.isEmpty ? '' : ' $extras';
    debugPrint('[$tag] $message$extra');
    if (error != null) debugPrint('  error: $error');
    if (stackTrace != null) debugPrint('$stackTrace');
  }

  @override
  void v(String message, {Map<String, Object?> extras = const {}}) =>
      log(AfterLogLevel.verbose, message, extras: extras);

  @override
  void d(String message, {Map<String, Object?> extras = const {}}) =>
      log(AfterLogLevel.debug, message, extras: extras);

  @override
  void i(String message, {Map<String, Object?> extras = const {}}) =>
      log(AfterLogLevel.info, message, extras: extras);

  @override
  void w(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> extras = const {},
  }) =>
      log(
        AfterLogLevel.warning,
        message,
        error: error,
        stackTrace: stackTrace,
        extras: extras,
      );

  @override
  void e(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> extras = const {},
  }) =>
      log(
        AfterLogLevel.error,
        message,
        error: error,
        stackTrace: stackTrace,
        extras: extras,
      );
}

class NoOpAfterLogger implements AfterLogger {
  const NoOpAfterLogger();

  @override
  void log(
    AfterLogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> extras = const {},
  }) {}

  @override
  void v(String message, {Map<String, Object?> extras = const {}}) {}

  @override
  void d(String message, {Map<String, Object?> extras = const {}}) {}

  @override
  void i(String message, {Map<String, Object?> extras = const {}}) {}

  @override
  void w(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> extras = const {},
  }) {}

  @override
  void e(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> extras = const {},
  }) {}
}
