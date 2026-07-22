import 'package:after_firebase/after_firebase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegistrationIndexClient.normalizeUsername', () {
    test('trims and lowercases', () {
      expect(
        RegistrationIndexClient.normalizeUsername('  AyHan.User  '),
        'ayhan.user',
      );
    });

    test('strips illegal characters', () {
      expect(
        RegistrationIndexClient.normalizeUsername('a@b#c!'),
        'abc',
      );
    });

    test('pattern accepts valid names', () {
      expect(
        RegistrationIndexClient.usernamePattern.hasMatch('rider_01'),
        isTrue,
      );
      expect(
        RegistrationIndexClient.usernamePattern.hasMatch('ab'),
        isFalse,
      );
    });
  });
}
