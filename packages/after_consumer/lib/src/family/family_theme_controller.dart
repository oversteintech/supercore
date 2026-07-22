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
    final store = ref.read(afterSettingsStoreProvider);
    await store.setString(AfterSettingsKeys.themeStyle, style.name);
    // Keep legacy themeMode in sync for light/dark/system.
    if (style == AfterThemeStyle.system ||
        style == AfterThemeStyle.light ||
        style == AfterThemeStyle.dark) {
      await store.setString(AfterSettingsKeys.themeMode, style.name);
    }
    state = style;
  }
}
