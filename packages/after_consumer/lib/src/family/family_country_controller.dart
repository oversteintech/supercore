import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared country / region — one prefs key for every Super App settings menu.
final afterCountryCodeProvider =
    NotifierProvider<AfterCountryCodeController, String?>(
  AfterCountryCodeController.new,
);

class AfterCountryCodeController extends Notifier<String?> {
  @override
  String? build() {
    final prefs = ref.watch(afterSharedPreferencesProvider);
    return AfterCountryPrefs.read(prefs);
  }

  Future<void> setCountry(String? code, {String? legacyKey}) async {
    final prefs = ref.read(afterSharedPreferencesProvider);
    await AfterCountryPrefs.write(prefs, code, legacyKey: legacyKey);
    state = AfterCountryPrefs.read(prefs, legacyKey: legacyKey);
  }
}
