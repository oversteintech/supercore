import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Family settings must not reintroduce a Settings app-tour accordion.
void main() {
  test('FamilySettingsScreen source has no app-tour replay surface', () {
    final path = File(
      'lib/src/family/family_settings_screen.dart',
    );
    expect(path.existsSync(), isTrue);
    final source = path.readAsStringSync();
    expect(source, isNot(contains("s('app_tour')")));
    expect(source, isNot(contains("s('replay_tour')")));
    expect(source, isNot(contains('tourPages')));
    expect(source, isNot(contains('FamilyAppTourScreen')));
    expect(source, isNot(contains('class FamilyAppTourPage')));
    expect(source, contains('first-run only'));
  });
}
