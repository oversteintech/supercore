import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'manifest.dart';

/// Composition root for a **consumer** Super App on After Framework.
///
/// Registers the product manifest (product line = consumer) and returns
/// the standard baseline `after_core` overrides. Vertical products layer
/// their feature-specific overrides on top.
class SuperAppConsumerFramework {
  SuperAppConsumerFramework._();

  static Future<List<Override>> ensureConfigured() async {
    PlatformConfig.current = superAppConsumerManifest;
    final prefs = await SharedPreferences.getInstance();
    return AfterStandardOverrides.create(
      preferences: prefs,
      userAgent:
          '${superAppConsumerManifest.appName}/${superAppConsumerManifest.appId}',
    );
  }
}
