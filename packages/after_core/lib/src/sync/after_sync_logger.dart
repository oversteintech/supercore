import 'package:flutter/foundation.dart';

/// Structured sync logs shared across Super Apps.
abstract final class AfterSyncLogger {
  static void auth(String message) => _emit('AUTH', message);
  static void hydrate(String message) => _emit('HYDRATE', message);
  static void upload(String message) => _emit('UPLOAD', message);
  static void download(String message) => _emit('DOWNLOAD', message);
  static void cloudError(String message) => _emit('CLOUD_ERROR', message);

  static void _emit(String channel, String message) {
    if (kDebugMode) {
      debugPrint('AFTER_SYNC[$channel] $message');
    }
  }
}
