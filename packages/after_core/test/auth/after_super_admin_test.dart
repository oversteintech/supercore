import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ayhanuzundal@gmail.com is superadmin', () {
    expect(AfterSuperAdmin.isSuperAdminEmail('ayhanuzundal@gmail.com'), isTrue);
    expect(AfterSuperAdmin.isSuperAdminEmail('AyhanUzundal@Gmail.com'), isTrue);
    expect(AfterSuperAdmin.isSuperAdminEmail(' member@afterartificial.com '), isFalse);
    expect(AfterSuperAdmin.isSuperAdminEmail(null), isFalse);
  });
}
