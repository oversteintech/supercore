import 'package:after_core/after_core.dart';

/// Product [AppPlatformManifest] for a **consumer** Super App on the
/// AfterArtificial platform.
///
/// Copy this file into `lib/app/platform/manifest.dart` inside the new
/// app, then swap the identifiers. Product line stays `consumer`.
const superAppConsumerManifest = AppPlatformManifest(
  appName: 'SuperExample',
  appId: 'super_example',
  packageName: 'com.overstein.superexample',
  androidWidgetProvider: 'com.overstein.superexample.WidgetProvider',
  iosAppGroupId: 'group.com.overstein.superexample',
  productLine: AfterProductLine.consumer,
);
