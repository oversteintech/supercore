import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'family_ui_strings.dart';

/// Language + country controls for [FamilySettingsScreen].
///
/// Country catalog and prefs live in after_core
/// ([AfterSupportedCountries], [AfterCountryPrefs]).
class FamilyRegionLanguageSection extends ConsumerStatefulWidget {
  const FamilyRegionLanguageSection({
    required this.localeCode,
    this.onLocale,
    this.countryCode,
    this.onCountry,
    this.extras = const <Widget>[],
    super.key,
  });

  final String localeCode;
  final ValueChanged<String?>? onLocale;
  final String? countryCode;
  final ValueChanged<String?>? onCountry;
  final List<Widget> extras;

  @override
  ConsumerState<FamilyRegionLanguageSection> createState() =>
      _FamilyRegionLanguageSectionState();
}

class _FamilyRegionLanguageSectionState
    extends ConsumerState<FamilyRegionLanguageSection> {
  String? _localCountry;

  @override
  void initState() {
    super.initState();
    _localCountry = widget.countryCode;
  }

  @override
  void didUpdateWidget(covariant FamilyRegionLanguageSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.countryCode != oldWidget.countryCode) {
      _localCountry = widget.countryCode;
    }
  }

  String? get _resolvedCountry {
    if (widget.onCountry != null) {
      return widget.countryCode;
    }
    return _localCountry ??
        AfterCountryPrefs.read(ref.read(afterSharedPreferencesProvider));
  }

  Future<void> _setCountry(String? code) async {
    if (widget.onCountry != null) {
      widget.onCountry!(code);
      return;
    }
    final prefs = ref.read(afterSharedPreferencesProvider);
    await AfterCountryPrefs.write(prefs, code);
    if (mounted) {
      setState(() => _localCountry = AfterCountryPrefs.read(prefs));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.localeCode;
    String s(String key) => FamilyUiStrings.t(key, locale);
    final country = _resolvedCountry;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          s('language'),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String?>(
          key: ValueKey<String>('family-lang-$locale'),
          isExpanded: true,
          menuMaxHeight: 320,
          initialValue: AfterSupportedLocales.isSupported(locale)
              ? locale
              : AfterSupportedLocales.fallbackLanguage,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.translate_rounded),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          items: [
            for (final code in AfterSupportedLocales.languageCodes)
              DropdownMenuItem<String?>(
                value: code,
                child: Text(
                  AfterSupportedLocales.displayNameFor(code),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: widget.onLocale == null
              ? null
              : (code) {
                  if (code == null) return;
                  widget.onLocale!(code);
                },
        ),
        const SizedBox(height: 16),
        Text(
          s('country'),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String?>(
          key: ValueKey<String>('family-country-${country ?? 'none'}'),
          isExpanded: true,
          menuMaxHeight: 320,
          initialValue: country,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.public_rounded),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                s('system_locale'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            for (final item in AfterSupportedCountries.all)
              DropdownMenuItem<String?>(
                value: item.code,
                child: Text(
                  '${item.code} · ${item.name}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: _setCountry,
        ),
        if (widget.extras.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...widget.extras,
        ],
      ],
    );
  }
}
