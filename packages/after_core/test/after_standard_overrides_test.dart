import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AfterStandardOverrides.create returns baseline overrides', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final overrides = AfterStandardOverrides.create(
      preferences: prefs,
      userAgent: 'TestApp/1.0',
    );
    expect(overrides.length, greaterThanOrEqualTo(5));
  });
}
