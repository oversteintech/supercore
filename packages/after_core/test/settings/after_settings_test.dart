import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory [AfterPreferences] so settings tests don't need to boot
/// flutter test bindings.
class _MemoryPrefs implements AfterPreferences {
  final Map<String, Object> _values = <String, Object>{};

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  String? getString(String key) => _values[key] as String?;

  @override
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }

  @override
  bool? getBool(String key) => _values[key] as bool?;

  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  int? getInt(String key) => _values[key] as int?;

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }

  @override
  Set<String> getKeys() => _values.keys.toSet();
}

void main() {
  group('PrefsAfterSettingsStore', () {
    test('reads defaults when no stored value', () {
      final store = PrefsAfterSettingsStore(
        _MemoryPrefs(),
        defaults: afterSettingsDefaults(),
      );
      expect(
        store.getString(AfterSettingsKeys.themeMode),
        AfterThemeModeValue.light,
      );
      expect(store.getBool(AfterSettingsKeys.notificationsEnabled), isTrue);
      expect(store.getBool(AfterSettingsKeys.onboardingCompleted), isFalse);
    });

    test('stored value wins over default', () async {
      final store = PrefsAfterSettingsStore(
        _MemoryPrefs(),
        defaults: afterSettingsDefaults(),
      );
      await store.setString(
        AfterSettingsKeys.themeMode,
        AfterThemeModeValue.dark,
      );
      expect(
        store.getString(AfterSettingsKeys.themeMode),
        AfterThemeModeValue.dark,
      );
    });

    test('watch emits on every mutation', () async {
      final store = PrefsAfterSettingsStore(_MemoryPrefs());
      final events = <AfterSettingsChange>[];
      final sub = store.watch().listen(events.add);
      await store.setString('a', 'x');
      await store.setBool('b', true);
      await store.setInt('c', 3);
      await store.remove('a');
      await Future<void>.delayed(Duration.zero);
      expect(events.map((e) => e.key), ['a', 'b', 'c', 'a']);
      expect(events.last.value, isNull);
      await sub.cancel();
      await store.dispose();
    });

    test('snapshot merges defaults with stored values', () async {
      final store = PrefsAfterSettingsStore(
        _MemoryPrefs(),
        defaults: <String, Object?>{
          AfterSettingsKeys.themeMode: AfterThemeModeValue.light,
        },
      );
      await store.setString(AfterSettingsKeys.locale, 'tr');
      final snap = store.snapshot();
      expect(snap[AfterSettingsKeys.themeMode], AfterThemeModeValue.light);
      expect(snap[AfterSettingsKeys.locale], 'tr');
    });

    test('AfterSettingsKeys.all catalogs every standard key', () {
      expect(AfterSettingsKeys.all, contains(AfterSettingsKeys.themeMode));
      expect(AfterSettingsKeys.all, contains(AfterSettingsKeys.locale));
      expect(
        AfterSettingsKeys.all,
        contains(AfterSettingsKeys.analyticsEnabled),
      );
    });

    test('theme mode value set enumerates all modes', () {
      expect(
        AfterThemeModeValue.all,
        containsAll({
          AfterThemeModeValue.system,
          AfterThemeModeValue.light,
          AfterThemeModeValue.dark,
        }),
      );
    });
  });
}
