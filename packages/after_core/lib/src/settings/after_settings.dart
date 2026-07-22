import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../di/after_providers.dart';
import '../storage/secure_storage.dart';

/// Standard settings keys every Super App uses. Verticals may add their
/// own keys but MUST reuse these for anything cross-cutting so the
/// design-system + shell components can bind to them by contract.
class AfterSettingsKeys {
  AfterSettingsKeys._();

  /// Theme mode — `system` | `light` | `dark`.
  static const themeMode = 'after.settings.themeMode';

  /// Named premium theme style ([AfterThemeStyle] name).
  static const themeStyle = 'after.settings.themeStyle';

  /// Current locale (BCP-47, e.g. `en` / `tr`).
  static const locale = 'after.settings.locale';

  /// Master notifications toggle — governs push + local dispatch.
  static const notificationsEnabled = 'after.settings.notifications.enabled';

  /// Toggle for haptic feedback across the app.
  static const hapticsEnabled = 'after.settings.haptics.enabled';

  /// User-selected accent color (hex `#RRGGBB`).
  static const accentColor = 'after.settings.accent';

  /// Analytics opt-in.
  static const analyticsEnabled = 'after.settings.analytics.enabled';

  /// Whether onboarding has been completed at least once.
  static const onboardingCompleted = 'after.settings.onboarding.completed';

  /// Launcher icon uses white background (false = black).
  static const appIconWhiteBackground =
      'after.settings.appIcon.whiteBackground';

  /// Every key defined in this catalog (handy for tests / debug).
  static const List<String> all = <String>[
    themeMode,
    themeStyle,
    locale,
    notificationsEnabled,
    hapticsEnabled,
    accentColor,
    analyticsEnabled,
    onboardingCompleted,
    appIconWhiteBackground,
  ];
}

/// Well-known values for [AfterSettingsKeys.themeMode].
class AfterThemeModeValue {
  AfterThemeModeValue._();
  static const system = 'system';
  static const light = 'light';
  static const dark = 'dark';
  static const Set<String> all = <String>{system, light, dark};
}

/// A single settings change event.
@immutable
class AfterSettingsChange {
  const AfterSettingsChange({required this.key, this.value});
  final String key;
  final Object? value;
}

/// Settings store port. Backed by [AfterPreferences] but adds
/// change-notification, defaults, and a typed accessor surface.
abstract class AfterSettingsStore {
  String? getString(String key, {String? defaultValue});
  bool? getBool(String key, {bool? defaultValue});
  int? getInt(String key, {int? defaultValue});

  Future<void> setString(String key, String value);
  Future<void> setBool(String key, bool value);
  Future<void> setInt(String key, int value);
  Future<void> remove(String key);

  /// Broadcast stream — emits after each mutation. Use to drive
  /// live-refresh of theme, locale, etc.
  Stream<AfterSettingsChange> watch();

  /// Snapshot of every stored key/value pair.
  Map<String, Object?> snapshot();
}

/// Default implementation over [AfterPreferences].
class PrefsAfterSettingsStore implements AfterSettingsStore {
  PrefsAfterSettingsStore(this._prefs, {Map<String, Object?>? defaults})
      : _defaults = Map<String, Object?>.from(defaults ?? const <String, Object?>{});

  final AfterPreferences _prefs;
  final Map<String, Object?> _defaults;
  final StreamController<AfterSettingsChange> _controller =
      StreamController<AfterSettingsChange>.broadcast();

  void _emit(String key, Object? value) {
    if (_controller.isClosed) return;
    _controller.add(AfterSettingsChange(key: key, value: value));
  }

  @override
  String? getString(String key, {String? defaultValue}) {
    final v = _prefs.getString(key);
    if (v != null) return v;
    final d = _defaults[key];
    if (d is String) return d;
    return defaultValue;
  }

  @override
  bool? getBool(String key, {bool? defaultValue}) {
    final v = _prefs.getBool(key);
    if (v != null) return v;
    final d = _defaults[key];
    if (d is bool) return d;
    return defaultValue;
  }

  @override
  int? getInt(String key, {int? defaultValue}) {
    final v = _prefs.getInt(key);
    if (v != null) return v;
    final d = _defaults[key];
    if (d is int) return d;
    return defaultValue;
  }

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
    _emit(key, value);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
    _emit(key, value);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
    _emit(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
    _emit(key, null);
  }

  @override
  Stream<AfterSettingsChange> watch() => _controller.stream;

  @override
  Map<String, Object?> snapshot() {
    final out = <String, Object?>{..._defaults};
    for (final key in _prefs.getKeys()) {
      final s = _prefs.getString(key);
      if (s != null) {
        out[key] = s;
        continue;
      }
      final b = _prefs.getBool(key);
      if (b != null) {
        out[key] = b;
        continue;
      }
      final i = _prefs.getInt(key);
      if (i != null) {
        out[key] = i;
      }
    }
    return Map<String, Object?>.unmodifiable(out);
  }

  Future<void> dispose() async {
    if (!_controller.isClosed) await _controller.close();
  }
}

/// Default defaults every Super App inherits — matches SuperGarage /
/// SuperHospital behaviour.
Map<String, Object?> afterSettingsDefaults() => <String, Object?>{
      AfterSettingsKeys.themeMode: AfterThemeModeValue.system,
      AfterSettingsKeys.notificationsEnabled: true,
      AfterSettingsKeys.hapticsEnabled: true,
      AfterSettingsKeys.analyticsEnabled: true,
      AfterSettingsKeys.onboardingCompleted: false,
    };

/// App-wide settings store. Override at bootstrap if the product needs
/// product-specific defaults.
final afterSettingsStoreProvider = Provider<AfterSettingsStore>((ref) {
  return PrefsAfterSettingsStore(
    ref.watch(afterPreferencesProvider),
    defaults: afterSettingsDefaults(),
  );
});
