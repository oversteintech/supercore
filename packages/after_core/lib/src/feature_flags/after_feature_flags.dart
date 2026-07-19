import 'dart:async';

import '../storage/secure_storage.dart';

/// Local + remote feature flag surface.
abstract class AfterFeatureFlags {
  bool isEnabled(String key, {bool defaultValue = false});

  T getValue<T>(String key, T defaultValue);

  Future<void> refresh();

  Stream<void> get onChanged;
}

/// Preferences-backed flags with optional remote overlay.
class PrefsAfterFeatureFlags implements AfterFeatureFlags {
  PrefsAfterFeatureFlags(
    this._prefs, {
    Map<String, Object?> remoteDefaults = const {},
    this.keyPrefix = 'after_ff_',
  }) : _remote = Map<String, Object?>.from(remoteDefaults);

  final AfterPreferences _prefs;
  final Map<String, Object?> _remote;
  final String keyPrefix;
  final _controller = StreamController<void>.broadcast();

  void applyRemote(Map<String, Object?> values) {
    _remote
      ..clear()
      ..addAll(values);
    _controller.add(null);
  }

  @override
  bool isEnabled(String key, {bool defaultValue = false}) {
    final local = _prefs.getBool('$keyPrefix$key');
    if (local != null) return local;
    final remote = _remote[key];
    if (remote is bool) return remote;
    return defaultValue;
  }

  @override
  T getValue<T>(String key, T defaultValue) {
    if (T == bool || defaultValue is bool) {
      return isEnabled(key, defaultValue: defaultValue as bool) as T;
    }
    if (T == int || defaultValue is int) {
      final local = _prefs.getInt('$keyPrefix$key');
      if (local != null) return local as T;
      final remote = _remote[key];
      if (remote is int) return remote as T;
      return defaultValue;
    }
    if (T == String || defaultValue is String) {
      final local = _prefs.getString('$keyPrefix$key');
      if (local != null) return local as T;
      final remote = _remote[key];
      if (remote is String) return remote as T;
      return defaultValue;
    }
    final remote = _remote[key];
    if (remote is T) return remote;
    return defaultValue;
  }

  Future<void> setLocalBool(String key, bool value) async {
    await _prefs.setBool('$keyPrefix$key', value);
    _controller.add(null);
  }

  @override
  Future<void> refresh() async {
    _controller.add(null);
  }

  @override
  Stream<void> get onChanged => _controller.stream;

  void dispose() => _controller.close();
}
