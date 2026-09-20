import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../launch/after_location_permission.dart';
import '../location/after_current_locality.dart';
import '../location/after_regional_location.dart';
import '../location/after_regional_location_apply.dart';
import 'family_ui_strings.dart';

/// Language + country controls for [FamilySettingsScreen].
///
/// Includes shared “Use my location” and optional “match language to country”
/// — every Super App gets the same UX from SuperCore (not Garage-only).
class FamilyRegionLanguageSection extends ConsumerStatefulWidget {
  const FamilyRegionLanguageSection({
    required this.localeCode,
    this.onLocale,
    this.countryCode,
    this.onCountry,
    this.showLocationButton = true,
    this.extras = const <Widget>[],
    super.key,
  });

  final String localeCode;
  final ValueChanged<String?>? onLocale;
  final String? countryCode;
  final ValueChanged<String?>? onCountry;

  /// GPS → country (+ optional language). Off for first-install compact gates.
  final bool showLocationButton;
  final List<Widget> extras;

  @override
  ConsumerState<FamilyRegionLanguageSection> createState() =>
      _FamilyRegionLanguageSectionState();
}

class _FamilyRegionLanguageSectionState
    extends ConsumerState<FamilyRegionLanguageSection> {
  String? _localCountry;
  bool _detecting = false;
  String? _statusMessage;
  bool _statusIsError = false;

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

  Future<void> _setMatchLanguage(bool value) async {
    final prefs = ref.read(afterSharedPreferencesProvider);
    await AfterRegionalLocationApply.writeMatchLanguage(prefs, value);
    if (!value) {
      if (mounted) setState(() {});
      return;
    }

    final country = _resolvedCountry;
    if (country == null || widget.onLocale == null) {
      if (mounted) setState(() {});
      return;
    }
    final language = AfterRegionalPreferences.languageForCountry(country);
    widget.onLocale!(language);
    if (mounted) setState(() {});
  }

  Future<void> _detectLocation() async {
    final locale = widget.localeCode;
    String s(String key) => FamilyUiStrings.t(key, locale);

    setState(() {
      _detecting = true;
      _statusMessage = null;
    });

    try {
      final status = await AfterLocationPermission.requestIfConsented();
      if (!mounted) return;
      if (!status.isGranted && !status.isLimited) {
        setState(() {
          _statusMessage = s('location_unavailable');
          _statusIsError = true;
        });
        return;
      }

      final detected =
          await AfterRegionalLocationService.detectRegionalLocation();
      if (!mounted) return;
      if (detected == null) {
        setState(() {
          _statusMessage = s('location_unavailable');
          _statusIsError = true;
        });
        return;
      }

      final prefs = ref.read(afterSharedPreferencesProvider);
      final matchLanguage =
          AfterRegionalLocationApply.readMatchLanguage(prefs);
      final applied = await AfterRegionalLocationApply.applyDetection(
        prefs: prefs,
        detected: detected,
        matchLanguageToCountry: matchLanguage,
      );

      await _setCountry(applied.countryCode);
      if (applied.languageCode != null && widget.onLocale != null) {
        widget.onLocale!(applied.languageCode);
      }

      ref.invalidate(afterCurrentLocalityProvider);

      final countryName =
          AfterSupportedCountries.displayNameFor(applied.countryCode);
      final city = applied.cityName?.trim();
      setState(() {
        _statusMessage = (city == null || city.isEmpty)
            ? FamilyUiStrings.t('location_country_detected', locale)
                .replaceAll('{country}', countryName)
            : FamilyUiStrings.t('location_detected', locale)
                .replaceAll('{country}', countryName)
                .replaceAll('{city}', city);
        _statusIsError = false;
      });
    } on Object catch (error) {
      debugPrint('Family regional location failed: $error');
      if (mounted) {
        setState(() {
          _statusMessage = s('location_unavailable');
          _statusIsError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _detecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.localeCode;
    String s(String key) => FamilyUiStrings.t(key, locale);
    final country = _resolvedCountry;
    final prefs = ref.watch(afterSharedPreferencesProvider);
    final matchLanguage =
        AfterRegionalLocationApply.readMatchLanguage(prefs);
    final scheme = Theme.of(context).colorScheme;

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
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(s('match_language_to_country')),
          subtitle: Text(s('match_language_to_country_sub')),
          value: matchLanguage,
          onChanged: widget.onLocale == null ? null : _setMatchLanguage,
        ),
        if (widget.showLocationButton) ...[
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: _detecting ? null : _detectLocation,
            icon: _detecting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(s('use_my_location')),
            ),
          ),
          if (_statusMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _statusMessage!,
              style: TextStyle(
                color: _statusIsError
                    ? scheme.error
                    : scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ],
        if (widget.extras.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...widget.extras,
        ],
      ],
    );
  }
}
