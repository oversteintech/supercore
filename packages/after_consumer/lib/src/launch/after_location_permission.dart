import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'after_launch_consent.dart';

/// Requests OS location-when-in-use only after the permission intro is accepted.
class AfterLocationPermission {
  AfterLocationPermission._();

  static Future<PermissionStatus> requestIfConsented() async {
    final prefs = await SharedPreferences.getInstance();
    if (!readAfterPermissionConsentAccepted(prefs)) {
      return PermissionStatus.denied;
    }
    return Permission.locationWhenInUse.request();
  }
}
