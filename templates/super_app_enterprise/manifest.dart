import 'package:after_core/after_core.dart';

/// Product [AppPlatformManifest] for an **enterprise** Super App on the
/// AfterArtificial platform.
///
/// Copy this file into `lib/app/platform/manifest.dart` inside the new
/// vertical, then swap the identifiers. Product line stays `enterprise`.
const superAppEnterpriseManifest = AppPlatformManifest(
  appName: 'SuperEnterprise',
  appId: 'super_enterprise',
  packageName: 'com.overstein.superenterprise',
  androidWidgetProvider: 'com.overstein.superenterprise.WidgetProvider',
  iosAppGroupId: 'group.com.overstein.superenterprise',
  productLine: AfterProductLine.enterprise,
);
