import 'package:after_consumer/after_consumer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AfterCurrentLocality.label returns city only', () {
    const locality = AfterCurrentLocality(
      neighborhood: 'Moda',
      district: 'Kadıköy',
      city: 'İstanbul',
    );
    expect(locality.label, 'İstanbul');
    expect(const AfterCurrentLocality().label, isNull);
    expect(const AfterCurrentLocality(city: '  ').label, isNull);
  });
}
