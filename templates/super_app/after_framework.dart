import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'manifest.dart';

/// Composition root for the Super App After Framework wiring.
class SuperAppAfterFramework {
  SuperAppAfterFramework._();

  /// Ensures the platform is configured and returns the baseline overrides.
  /// 
  /// Call this in `main()` before `runApp`.
  static Future<List<Override>> ensureConfigured() async {
    // 1. Set global identity
    PlatformConfig.current = superAppManifest;

    // 2. Initialize dependencies
    final prefs = await SharedPreferences.getInstance();

    // 3. Create standard overrides
    return AfterStandardOverrides.create(
      preferences: prefs,
      userAgent: '${superAppManifest.appName}/${superAppManifest.appId}',
    );
  }
}
