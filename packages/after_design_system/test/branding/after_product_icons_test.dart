import 'package:after_design_system/after_design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog covers sibling products and excludes garage package', () {
    final packages = AfterProductIconCatalog.all.map((e) => e.packageName);
    expect(packages, isNot(contains('super_garage')));
    expect(AfterProductIconCatalog.byPackage('super_health')?.monogram, 'S+');
    expect(AfterProductIconCatalog.byAppName('SuperTravel')?.glyph, isNotNull);
    expect(
      AfterProductIconStyleAccess.fromStorage('premiumGold'),
      AfterProductIconStyle.premiumGold,
    );
    expect(AfterProductIconStyle.premiumGold.monogramGradient, isNotEmpty);
  });
}
