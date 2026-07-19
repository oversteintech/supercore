import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../errors/after_exception.dart';
import '../utils/after_utils.dart';

/// Secure key-value storage (tokens, installation id, BYOK keys).
abstract class AfterSecureStorage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
  Future<bool> containsKey(String key);
}

/// Preferences storage for non-secret flags and caches.
abstract class AfterPreferences {
  Future<bool> setString(String key, String value);
  String? getString(String key);
  Future<bool> setBool(String key, bool value);
  bool? getBool(String key);
  Future<bool> setInt(String key, int value);
  int? getInt(String key);
  Future<bool> remove(String key);
  Set<String> getKeys();
}

class FlutterSecureAfterStorage implements AfterSecureStorage {
  FlutterSecureAfterStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw AfterStorageException('secure_write_failed', cause: e, code: key);
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw AfterStorageException('secure_read_failed', cause: e, code: key);
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw AfterStorageException('secure_delete_failed', cause: e, code: key);
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw AfterStorageException('secure_delete_all_failed', cause: e);
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      throw AfterStorageException('secure_contains_failed', cause: e, code: key);
    }
  }
}

class SharedPreferencesAfterStore implements AfterPreferences {
  SharedPreferencesAfterStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  @override
  int? getInt(String key) => _prefs.getInt(key);

  @override
  Future<bool> remove(String key) => _prefs.remove(key);

  @override
  Set<String> getKeys() => _prefs.getKeys();
}

/// Installation ID persisted in secure storage.
class AfterInstallationIdStore {
  AfterInstallationIdStore(this._secure, {this.key = 'after_installation_id'});

  final AfterSecureStorage _secure;
  final String key;

  Future<String> getOrCreate() async {
    final existing = await _secure.read(key);
    if (existing != null && existing.isNotEmpty) return existing;
    final created = AfterUtils.newId();
    await _secure.write(key, created);
    return created;
  }
}
