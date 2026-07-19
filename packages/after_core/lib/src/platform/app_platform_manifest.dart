import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Runtime branding/configuration for a Super application.
///
/// Each Super App sets [PlatformConfig.current] in its composition root
/// before `runApp()` (see After Framework / Platform Standard).
class AppPlatformManifest {
  const AppPlatformManifest({
    required this.appName,
    required this.appId,
    required this.packageName,
    required this.androidWidgetProvider,
    required this.iosAppGroupId,
  });

  final String appName;
  final String appId;
  final String packageName;
  final String androidWidgetProvider;
  final String iosAppGroupId;
}

/// Holds the active Super App identity for shared After Framework code.
class PlatformConfig {
  PlatformConfig._();

  /// Placeholder until the product composition root calls [ensureConfigured].
  static AppPlatformManifest current = const AppPlatformManifest(
    appName: 'After',
    appId: 'after_unset',
    packageName: 'com.afterartificial.unset',
    androidWidgetProvider: '',
    iosAppGroupId: '',
  );
}

final platformManifestProvider = Provider<AppPlatformManifest>((ref) {
  return PlatformConfig.current;
});
