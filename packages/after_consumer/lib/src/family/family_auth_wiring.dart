import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

/// Shared Google auth override for consumer Super Apps (PrefsGoogle).
Override familyPrefsGoogleAuthOverride(
  SharedPreferences preferences, {
  required String prefsKeyPrefix,
  String? googleServerClientId,
  String? googleIosClientId,
  String? mockGoogleEmailForTests,
  bool softGoogleFallbackOnMisconfig = false,
}) {
  return afterAuthRepositoryProvider.overrideWithValue(
    PrefsGoogleAuthRepository(
      preferences,
      prefsKeyPrefix: prefsKeyPrefix,
      googleServerClientId: googleServerClientId,
      googleIosClientId: googleIosClientId,
      mockGoogleEmailForTests: mockGoogleEmailForTests,
      softGoogleFallbackOnMisconfig: softGoogleFallbackOnMisconfig,
    ),
  );
}