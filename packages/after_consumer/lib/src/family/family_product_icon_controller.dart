import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global product-icon look — one setting restyles every sibling Super App.
final afterProductIconStyleProvider =
    NotifierProvider<AfterProductIconStyleController, AfterProductIconStyle>(
  AfterProductIconStyleController.new,
);

class AfterProductIconStyleController extends Notifier<AfterProductIconStyle> {
  @override
  AfterProductIconStyle build() {
    final store = ref.watch(afterSettingsStoreProvider);
    return AfterProductIconStyleAccess.fromStorage(
      store.getString(AfterSettingsKeys.productIconStyle),
    );
  }

  Future<void> setStyle(AfterProductIconStyle style) async {
    final store = ref.read(afterSettingsStoreProvider);
    await store.setString(AfterSettingsKeys.productIconStyle, style.storageKey);
    state = style;
  }
}
