import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolvedSupportEmail derives from appId when unset', () {
    const m = AppPlatformManifest(
      appName: 'Garage',
      appId: 'super_garage',
      packageName: 'com.overstein.supergarage',
      androidWidgetProvider: '',
      iosAppGroupId: '',
    );
    expect(m.resolvedSupportEmail, 'supergarage@overstein.com');
  });

  test('explicit supportEmail wins', () {
    const m = AppPlatformManifest(
      appName: 'Sports',
      appId: 'super_sports',
      packageName: 'com.overstein.supersports',
      androidWidgetProvider: '',
      iosAppGroupId: '',
      supportEmail: 'supersports@overstein.com',
    );
    expect(m.resolvedSupportEmail, 'supersports@overstein.com');
  });
}
