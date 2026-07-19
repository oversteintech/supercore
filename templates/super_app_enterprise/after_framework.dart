import 'package:after_core/after_core.dart';
import 'package:after_enterprise/after_enterprise.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'manifest.dart';

/// Composition root for an **enterprise** Super App on After Framework.
///
/// - Registers the product manifest (product line = enterprise).
/// - Returns baseline `after_core` overrides.
/// - Binds `enterpriseRepositoryProvider` to a [MockEnterpriseRepository]
///   by default. Real backend adapters override this at composition root.
class SuperAppEnterpriseFramework {
  SuperAppEnterpriseFramework._();

  static Future<List<Override>> ensureConfigured({
    EnterpriseRepository? enterpriseRepository,
  }) async {
    PlatformConfig.current = superAppEnterpriseManifest;
    final prefs = await SharedPreferences.getInstance();
    return [
      ...AfterStandardOverrides.create(
        preferences: prefs,
        userAgent: '${superAppEnterpriseManifest.appName}/'
            '${superAppEnterpriseManifest.appId}',
      ),
      enterpriseRepositoryProvider.overrideWithValue(
        enterpriseRepository ?? MockEnterpriseRepository(),
      ),
    ];
  }
}
