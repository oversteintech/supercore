import 'package:after_core/after_core.dart';

/// Product [AppPlatformManifest] for this Super App.
/// 
/// See After Framework / Platform Standard.
const superAppManifest = AppPlatformManifest(
  appName: 'SuperApp',
  appId: 'super_app',
  packageName: 'com.afterartificial.superapp',
  androidWidgetProvider: 'com.afterartificial.superapp.WidgetProvider',
  iosAppGroupId: 'group.com.afterartificial.superapp',
);
