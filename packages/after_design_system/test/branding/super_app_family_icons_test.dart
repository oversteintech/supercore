import 'package:after_design_system/after_design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('family icon paths are stable and package-scoped', () {
    expect(
      SuperAppFamilyIcons.svgPath(SuperAppFamilyIconId.garage),
      'assets/branding/super_app_icons/super_garage.svg',
    );
    expect(
      SuperAppFamilyIcons.hdPngPath(SuperAppFamilyIconId.pets),
      'assets/branding/super_app_icons/super_pets_hd.png',
    );
    expect(SuperAppFamilyIcons.package, 'after_design_system');
    expect(
      SuperAppFamilyIcons.byPackageName('super_finance'),
      SuperAppFamilyIconId.finance,
    );
    expect(
      SuperAppFamilyIcons.byPackageName('super_pet'),
      SuperAppFamilyIconId.pets,
    );
    expect(SuperAppFamilyIcons.all, hasLength(8));
  });
}
