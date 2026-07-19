import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AfterArtificial product line — determines which OS layer a Super App
/// composes on top of the shared [after_core] kernel.
///
/// - [AfterProductLine.consumer] → B2C Super Apps (SuperGarage, SuperHealth, …)
///   use `after_consumer` on top of `after_core`.
/// - [AfterProductLine.enterprise] → B2B / vertical enterprise Super Apps
///   (SuperHospital, SuperAirport, …) use `after_enterprise` on top of
///   `after_core`.
enum AfterProductLine {
  consumer,
  enterprise,
}

/// Runtime branding/configuration for a Super application.
///
/// Each Super App sets [PlatformConfig.current] in its composition root
/// before `runApp()` (see After Framework / Platform Standard).
///
/// The [productLine] selects the OS layer at runtime. It is intentionally
/// optional (defaults to [AfterProductLine.consumer]) to remain backward
/// compatible with existing SuperGarage-family manifests.
class AppPlatformManifest {
  const AppPlatformManifest({
    required this.appName,
    required this.appId,
    required this.packageName,
    required this.androidWidgetProvider,
    required this.iosAppGroupId,
    this.productLine = AfterProductLine.consumer,
  });

  final String appName;
  final String appId;
  final String packageName;
  final String androidWidgetProvider;
  final String iosAppGroupId;
  final AfterProductLine productLine;

  bool get isConsumer => productLine == AfterProductLine.consumer;
  bool get isEnterprise => productLine == AfterProductLine.enterprise;
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
    productLine: AfterProductLine.consumer,
  );
}

final platformManifestProvider = Provider<AppPlatformManifest>((ref) {
  return PlatformConfig.current;
});
