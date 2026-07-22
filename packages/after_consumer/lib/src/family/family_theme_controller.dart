import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Prefs-backed [AfterThemeStyle] for consumer Super Apps.
final familyThemeStyleProvider =
    NotifierProvider<FamilyThemeStyleController, AfterThemeStyle>(
  FamilyThemeStyleController.new,
);

class FamilyThemeStyleController extends Notifier<AfterThemeStyle> {
  @override
  AfterThemeStyle build() {
    final store = ref.watch(afterSettingsStoreProvider);
    return AfterThemeStyles.fromStorage(
      store.getString(AfterSettingsKeys.themeStyle),
    );
  }

  Future<void> setStyle(AfterThemeStyle style) async {
    // Product rule: no system-follow theme — white/light is the default.
    final resolved =
        style == AfterThemeStyle.system ? AfterThemeStyle.light : style;
    final store = ref.read(afterSettingsStoreProvider);
    await store.setString(AfterSettingsKeys.themeStyle, resolved.name);
    if (resolved == AfterThemeStyle.light ||
        resolved == AfterThemeStyle.dark) {
      await store.setString(AfterSettingsKeys.themeMode, resolved.name);
    }
    state = resolved;
  }
}
