import 'package:after_consumer/after_consumer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AfterFamilyLegalUrls slug strips underscores', () {
    expect(AfterFamilyLegalUrls.slugForAppId('super_health'), 'superhealth');
    expect(
      AfterFamilyLegalUrls.privacyPolicy('super_pet').path,
      contains('superpet'),
    );
    expect(
      AfterFamilyLegalUrls.termsOfUse('superGarage').path,
      contains('supergarage'),
    );
  });
}
