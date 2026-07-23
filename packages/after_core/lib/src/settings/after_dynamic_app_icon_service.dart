import 'dart:async';

import 'package:dynamic_app_icon_changer/dynamic_app_icon_changer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../platform/app_platform_manifest.dart';
import '../settings/after_settings.dart';

/// Syncs the OS launcher icon background (black or white monogram).
///
/// Garage-parity: Android activity-alias toggles are deferred until the app
/// backgrounds when possible; [applyBackgroundAndRestart] forces an immediate
/// apply + relaunch so the home-screen icon refreshes right away.
///
/// Requires each product's AndroidManifest to declare `.DefaultIcon` and
/// `.MonogramWhite` activity-aliases (see SuperGarage).
abstract final class AfterDynamicAppIconService {
  static const defaultIconAlias = 'DefaultIcon';
  static const whiteBackgroundIconAlias = 'MonogramWhite';

  /// Persisted preference key (shared across Super Apps).
  static const prefsKey = AfterSettingsKeys.appIconWhiteBackground;

  static bool? _pendingWhiteBackground;
  static var _flushInFlight = false;
  static var _flushQueued = false;
  static var _queuedRestartAfterApply = false;
  static var _initialized = false;
  static _AfterDynamicAppIconLifecycleObserver? _lifecycleObserver;

  static bool get _enabled =>
      !kIsWeb && defaultTargetPlatform != TargetPlatform.linux;

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @visibleForTesting
  static Future<bool> Function({
    required bool whiteBackground,
    bool relaunchAfterApply,
  })?
  platformApplyOverride;

  @visibleForTesting
  static String? aliasForBackground(bool whiteBackground) =>
      whiteBackground ? whiteBackgroundIconAlias : defaultIconAlias;

  static Future<bool> _canChangeIcon() async {
    if (!_enabled) {
      return false;
    }
    try {
      return await DynamicAppIconChanger.supportsAlternateIcons;
    } on Object catch (error) {
      debugPrint('AfterDynamicAppIconService.isSupported failed: $error');
      return false;
    }
  }

  static Future<bool> get isSupported => _canChangeIcon();

  static Future<String?> get currentIconName async {
    if (!_enabled) {
      return null;
    }
    return DynamicAppIconChanger.alternateIconName;
  }

  static Future<void> initialize([SharedPreferences? preferences]) async {
    // Widget tests inject [platformApplyOverride] — skip plugin channels so
    // Linux CI / desktop hosts never hang on MissingPluginException awaits.
    if (platformApplyOverride != null) {
      _initialized = true;
      return;
    }
    if (!_enabled) {
      return;
    }
    if (!_initialized) {
      _initialized = true;
      _lifecycleObserver ??= _AfterDynamicAppIconLifecycleObserver()
        ..register();
    }

    try {
      final protected = <ProtectedComponent>[
        const ProtectedComponent(
          className:
              'com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver',
          desiredState: ComponentState.enabled,
        ),
        const ProtectedComponent(
          className:
              'com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver',
          desiredState: ComponentState.enabled,
        ),
      ];
      final widgetProvider = PlatformConfig.current.androidWidgetProvider.trim();
      // Only register concrete widget providers — empty / unset placeholders
      // throw and previously aborted icon sync on sibling apps.
      if (widgetProvider.isNotEmpty &&
          !widgetProvider.contains('unset') &&
          widgetProvider.contains('.')) {
        protected.insert(
          0,
          ProtectedComponent(
            className: widgetProvider,
            desiredState: ComponentState.enabled,
          ),
        );
      }
      try {
        await DynamicAppIconChanger.registerProtectedComponents(protected);
      } on Object catch (error) {
        debugPrint(
          'AfterDynamicAppIconService.registerProtectedComponents: $error',
        );
      }

      final whiteBackground = preferences?.getBool(prefsKey) ?? true;
      scheduleBackgroundSync(whiteBackground: whiteBackground);
    } on Object catch (error, stackTrace) {
      debugPrint('AfterDynamicAppIconService.initialize failed: $error');
      debugPrint('$stackTrace');
    }
  }

  /// Applies [whiteBackground] without killing the process.
  ///
  /// Android launcher aliases update in-place; forcing a relaunch previously
  /// cold-started the app and looked like a sign-out to users.
  static Future<bool> applyBackgroundAndRestart({
    required bool whiteBackground,
  }) async {
    // Honor test overrides even on Linux/web where launcher aliases are N/A.
    if (platformApplyOverride != null) {
      _initialized = true;
      _pendingWhiteBackground = whiteBackground;
      return _flushPendingSync(restartAfterApply: false);
    }

    if (!_enabled) {
      return false;
    }

    // Settings can open before cold-start warm — ensure plugin is ready.
    if (!_initialized) {
      await initialize();
    }

    _pendingWhiteBackground = whiteBackground;
    return _flushPendingSync(restartAfterApply: false);
  }

  static void scheduleBackgroundSync({required bool whiteBackground}) {
    if (!_enabled) {
      return;
    }

    _pendingWhiteBackground = whiteBackground;

    if (!_isAndroid) {
      unawaited(_flushPendingSync(restartAfterApply: false));
      return;
    }

    if (_shouldFlushForLifecycle(WidgetsBinding.instance.lifecycleState)) {
      unawaited(_flushPendingSync(restartAfterApply: false));
    }
  }

  static void onAppLifecycleChanged(AppLifecycleState state) {
    if (!_enabled) {
      return;
    }
    if (_shouldFlushForLifecycle(state)) {
      unawaited(_flushPendingSync(restartAfterApply: false));
    }
  }

  @visibleForTesting
  static bool shouldFlushForLifecycle(AppLifecycleState? state) =>
      _shouldFlushForLifecycle(state);

  @visibleForTesting
  static void resetForTests() {
    _pendingWhiteBackground = null;
    _flushInFlight = false;
    _flushQueued = false;
    _queuedRestartAfterApply = false;
    _initialized = false;
    platformApplyOverride = null;
    _lifecycleObserver?.unregister();
    _lifecycleObserver = null;
  }

  static bool _shouldFlushForLifecycle(AppLifecycleState? state) {
    return state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden;
  }

  static String _normalizeAlias(String? alias) {
    if (alias == null || alias.isEmpty) {
      return defaultIconAlias;
    }
    return alias;
  }

  static Future<bool> _flushPendingSync({
    required bool restartAfterApply,
  }) async {
    if (_flushInFlight) {
      _flushQueued = true;
      _queuedRestartAfterApply = _queuedRestartAfterApply || restartAfterApply;
      return false;
    }
    final whiteBackground = _pendingWhiteBackground;
    if (whiteBackground == null) {
      return false;
    }

    _flushInFlight = true;
    var applied = false;
    bool? queuedRestartAfterApply;
    try {
      applied = await syncBackground(
        whiteBackground: whiteBackground,
        relaunchAfterApply: restartAfterApply,
      );
    } finally {
      _flushInFlight = false;
      if (applied && _pendingWhiteBackground == whiteBackground) {
        _pendingWhiteBackground = null;
      }

      if (_flushQueued) {
        _flushQueued = false;
        queuedRestartAfterApply = _queuedRestartAfterApply;
        _queuedRestartAfterApply = false;
      }
    }
    if (queuedRestartAfterApply != null) {
      return _flushPendingSync(restartAfterApply: queuedRestartAfterApply);
    }
    return applied;
  }

  static Future<bool> syncBackground({
    required bool whiteBackground,
    bool relaunchAfterApply = false,
  }) async {
    final override = platformApplyOverride;
    if (override != null) {
      return override(
        whiteBackground: whiteBackground,
        relaunchAfterApply: relaunchAfterApply,
      );
    }

    if (!_enabled) {
      return false;
    }
    if (!await _canChangeIcon()) {
      return false;
    }

    final target = aliasForBackground(whiteBackground);

    try {
      final current = await DynamicAppIconChanger.alternateIconName;
      if (!relaunchAfterApply &&
          _normalizeAlias(current) == _normalizeAlias(target)) {
        return true;
      }

      await DynamicAppIconChanger.setAlternateIconName(
        target,
        relaunch: relaunchAfterApply && _isAndroid,
      );
      return true;
    } on DynamicIconException catch (error) {
      debugPrint(
        'AfterDynamicAppIconService.syncBackground('
        'white=$whiteBackground, target=$target): ${error.message}',
      );
      return false;
    } on Object catch (error, stackTrace) {
      debugPrint('AfterDynamicAppIconService.syncBackground failed: $error');
      debugPrint('$stackTrace');
      return false;
    }
  }
}

final class _AfterDynamicAppIconLifecycleObserver with WidgetsBindingObserver {
  void register() {
    WidgetsBinding.instance.addObserver(this);
  }

  void unregister() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AfterDynamicAppIconService.onAppLifecycleChanged(state);
  }
}
