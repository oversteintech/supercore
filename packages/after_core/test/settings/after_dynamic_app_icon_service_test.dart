import 'package:after_core/after_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(AfterDynamicAppIconService.resetForTests);

  test('aliasForBackground matches Garage DefaultIcon / MonogramWhite', () {
    expect(
      AfterDynamicAppIconService.aliasForBackground(false),
      AfterDynamicAppIconService.defaultIconAlias,
    );
    expect(
      AfterDynamicAppIconService.aliasForBackground(true),
      AfterDynamicAppIconService.whiteBackgroundIconAlias,
    );
  });

  test('prefs key is AfterSettingsKeys.appIconWhiteBackground', () {
    expect(
      AfterDynamicAppIconService.prefsKey,
      AfterSettingsKeys.appIconWhiteBackground,
    );
  });

  test('shouldFlushForLifecycle matches Garage paused/hidden states', () {
    expect(
      AfterDynamicAppIconService.shouldFlushForLifecycle(
        AppLifecycleState.paused,
      ),
      isTrue,
    );
    expect(
      AfterDynamicAppIconService.shouldFlushForLifecycle(
        AppLifecycleState.resumed,
      ),
      isFalse,
    );
  });

  testWidgets('applyBackgroundAndRestart uses platform override', (tester) async {
    var called = false;
    AfterDynamicAppIconService.platformApplyOverride =
        ({required whiteBackground, relaunchAfterApply = false}) async {
      called = true;
      expect(whiteBackground, isTrue);
      expect(relaunchAfterApply, isTrue);
      return true;
    };

    final ok = await AfterDynamicAppIconService.applyBackgroundAndRestart(
      whiteBackground: true,
    );
    expect(ok, isTrue);
    expect(called, isTrue);
  });
}
