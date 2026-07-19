import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppPlatformManifest', () {
    test('defaults to consumer product line for backward compatibility', () {
      const manifest = AppPlatformManifest(
        appName: 'Legacy',
        appId: 'legacy',
        packageName: 'com.overstein.legacy',
        androidWidgetProvider: '',
        iosAppGroupId: '',
      );
      expect(manifest.productLine, AfterProductLine.consumer);
      expect(manifest.isConsumer, isTrue);
      expect(manifest.isEnterprise, isFalse);
    });

    test('honours explicit enterprise product line', () {
      const manifest = AppPlatformManifest(
        appName: 'SuperHospital',
        appId: 'super_hospital',
        packageName: 'com.overstein.superhospital',
        androidWidgetProvider: '',
        iosAppGroupId: '',
        productLine: AfterProductLine.enterprise,
      );
      expect(manifest.productLine, AfterProductLine.enterprise);
      expect(manifest.isEnterprise, isTrue);
      expect(manifest.isConsumer, isFalse);
    });

    test('PlatformConfig placeholder is consumer by default', () {
      expect(PlatformConfig.current.productLine, AfterProductLine.consumer);
    });
  });
}
