import 'dart:convert';

import 'package:flutter/services.dart';

import 'after_supported_locales.dart';

/// JSON string catalog loaded from `assets/l10n/{code}.json`.
///
/// Loads every [AfterSupportedLocales] code when the asset exists; missing
/// locale files are skipped and resolve through English at [t].
class AfterAssetStringCatalog {
  AfterAssetStringCatalog._(this._tables);

  factory AfterAssetStringCatalog.forTest(
    Map<String, Map<String, String>> tables,
  ) =>
      AfterAssetStringCatalog._(tables);

  final Map<String, Map<String, String>> _tables;
  String locale = AfterSupportedLocales.fallbackLanguage;

  static Future<AfterAssetStringCatalog>? _cached;

  /// Load all platform locales (EN required). Safe to call from splash/bootstrap.
  static Future<AfterAssetStringCatalog> load({
    String assetDir = 'assets/l10n',
    AssetBundle? bundle,
  }) async {
    final b = bundle ?? rootBundle;
    final en = await _loadLocale(b, assetDir, AfterSupportedLocales.fallbackLanguage);
    final tables = <String, Map<String, String>>{
      AfterSupportedLocales.fallbackLanguage: en,
    };
    for (final code in AfterSupportedLocales.languageCodes) {
      if (code == AfterSupportedLocales.fallbackLanguage) continue;
      try {
        tables[code] = await _loadLocale(b, assetDir, code);
      } on Object {
        // Missing / malformed asset — English fallback at resolve time.
      }
    }
    return AfterAssetStringCatalog._(tables);
  }

  static Future<AfterAssetStringCatalog> ensureLoaded({
    String assetDir = 'assets/l10n',
  }) {
    return _cached ??= load(assetDir: assetDir);
  }

  static void clearCache() => _cached = null;

  static Future<Map<String, String>> _loadLocale(
    AssetBundle bundle,
    String assetDir,
    String code,
  ) async {
    final raw = await bundle.loadString('$assetDir/$code.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, '$v'));
  }

  /// Locale codes that have a loaded table (always includes `en`).
  Set<String> get loadedLocales => _tables.keys.toSet();

  String t(String key, {Map<String, String> args = const {}}) {
    final table = _tables[locale] ??
        _tables[AfterSupportedLocales.fallbackLanguage] ??
        const <String, String>{};
    final fallback = _tables[AfterSupportedLocales.fallbackLanguage] ??
        const <String, String>{};
    var value = table[key] ?? fallback[key] ?? key;
    for (final entry in args.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }
    return value;
  }

  void setLocale(String? code) {
    if (code == null) {
      return;
    }
    if (AfterSupportedLocales.isSupported(code)) {
      locale = code;
    }
  }
}
