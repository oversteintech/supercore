import 'dart:async';
import 'dart:convert';

import '../errors/after_exception.dart';
import '../storage/secure_storage.dart';

/// Remote configuration port (Firebase RC, Supabase, custom CDN, etc.).
abstract class AfterRemoteConfig {
  Future<void> fetchAndActivate({Duration minimumFetchInterval});

  String getString(String key, {String defaultValue = ''});

  bool getBool(String key, {bool defaultValue = false});

  int getInt(String key, {int defaultValue = 0});

  double getDouble(String key, {double defaultValue = 0});

  Map<String, Object?> getAll();

  Stream<void> get onConfigUpdated;
}

/// Cached remote config backed by preferences + in-memory map.
///
/// Super Apps call [hydrateFromJson] after fetching a JSON payload from their
/// backend. This keeps Firebase Remote Config optional.
class CachedAfterRemoteConfig implements AfterRemoteConfig {
  CachedAfterRemoteConfig(
    this._prefs, {
    this.cacheKey = 'after_remote_config_json',
    Map<String, Object?> defaults = const {},
  }) : _values = Map<String, Object?>.from(defaults);

  final AfterPreferences _prefs;
  final String cacheKey;
  final Map<String, Object?> _values;
  final _controller = StreamController<void>.broadcast();
  DateTime? _lastFetch;

  Future<void> loadFromCache() async {
    final raw = _prefs.getString(cacheKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _values
          ..clear()
          ..addAll(decoded);
      }
    } catch (e) {
      throw AfterConfigException('remote_config_cache_corrupt', cause: e);
    }
  }

  Future<void> hydrateFromJson(Map<String, Object?> json) async {
    _values
      ..clear()
      ..addAll(json);
    await _prefs.setString(cacheKey, jsonEncode(json));
    _lastFetch = DateTime.now();
    _controller.add(null);
  }

  @override
  Future<void> fetchAndActivate({
    Duration minimumFetchInterval = const Duration(hours: 1),
  }) async {
    if (_lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < minimumFetchInterval) {
      return;
    }
    // No built-in transport — Super Apps override or call hydrateFromJson.
    await loadFromCache();
    _controller.add(null);
  }

  @override
  String getString(String key, {String defaultValue = ''}) {
    final v = _values[key];
    if (v is String) return v;
    if (v != null) return '$v';
    return defaultValue;
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    final v = _values[key];
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true' || v == '1';
    return defaultValue;
  }

  @override
  int getInt(String key, {int defaultValue = 0}) {
    final v = _values[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? defaultValue;
    return defaultValue;
  }

  @override
  double getDouble(String key, {double defaultValue = 0}) {
    final v = _values[key];
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? defaultValue;
    return defaultValue;
  }

  @override
  Map<String, Object?> getAll() => Map.unmodifiable(_values);

  @override
  Stream<void> get onConfigUpdated => _controller.stream;

  void dispose() => _controller.close();
}
