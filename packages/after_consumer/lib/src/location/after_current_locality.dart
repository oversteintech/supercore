import 'dart:async';

import 'package:after_core/after_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../launch/after_launch_consent.dart';

/// City / province label for the MainShell membership column.
@immutable
class AfterCurrentLocality {
  const AfterCurrentLocality({
    this.neighborhood,
    this.district,
    this.city,
  });

  final String? neighborhood;
  final String? district;
  final String? city;

  /// Compact top-bar label — city only (Garage contract).
  String? get label {
    final cityName = city?.trim();
    if (cityName == null || cityName.isEmpty) return null;
    return cityName;
  }
}

enum AfterDeviceLocationError implements Exception {
  serviceOff,
  permissionDenied,
  unavailable,
}

/// Resolves device position. OS permission is requested only when
/// [requestIfDenied] is true and the permissions intro was accepted.
Future<Position> afterResolveDeviceLocation({
  SharedPreferences? preferences,
  bool requestIfDenied = false,
}) async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw AfterDeviceLocationError.serviceOff;
  }

  final prefs = preferences ?? await SharedPreferences.getInstance();
  final mayRequest =
      requestIfDenied && readAfterPermissionConsentAccepted(prefs);

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    if (mayRequest) {
      permission = await Geolocator.requestPermission();
    } else {
      throw AfterDeviceLocationError.permissionDenied;
    }
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw AfterDeviceLocationError.permissionDenied;
  }

  Position? lastKnown;
  try {
    lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) {
      final age = DateTime.now().difference(lastKnown.timestamp);
      if (age.inMinutes <= 10) {
        return lastKnown;
      }
    }
  } on Object catch (error) {
    debugPrint('After last-known location unavailable: $error');
    lastKnown = null;
  }

  const attempts = <LocationSettings>[
    LocationSettings(
      accuracy: LocationAccuracy.best,
      timeLimit: Duration(seconds: 6),
    ),
    LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 8),
    ),
    LocationSettings(
      accuracy: LocationAccuracy.medium,
      timeLimit: Duration(seconds: 8),
    ),
    LocationSettings(
      accuracy: LocationAccuracy.low,
      timeLimit: Duration(seconds: 10),
    ),
  ];

  for (final settings in attempts) {
    try {
      return await Geolocator.getCurrentPosition(locationSettings: settings);
    } on TimeoutException {
      continue;
    } on LocationServiceDisabledException {
      throw AfterDeviceLocationError.serviceOff;
    } on PermissionDeniedException {
      throw AfterDeviceLocationError.permissionDenied;
    } on Object catch (error) {
      debugPrint('After location attempt failed (${settings.accuracy}): $error');
      continue;
    }
  }

  if (lastKnown != null) {
    return lastKnown;
  }

  throw AfterDeviceLocationError.unavailable;
}

final afterCurrentLocalityProvider =
    AsyncNotifierProvider<AfterCurrentLocalityController, AfterCurrentLocality?>(
      AfterCurrentLocalityController.new,
    );

/// Shared shell locality — every Super App header feeds from this.
class AfterCurrentLocalityController
    extends AsyncNotifier<AfterCurrentLocality?> {
  @override
  Future<AfterCurrentLocality?> build() => _resolve();

  Future<void> refresh() async {
    state = const AsyncValue<AfterCurrentLocality?>.loading();
    state = await AsyncValue.guard(_resolve);
  }

  Future<AfterCurrentLocality?> _resolve() async {
    final prefs = ref.read(afterSharedPreferencesProvider);
    if (!readAfterPermissionConsentAccepted(prefs)) {
      return null;
    }

    try {
      final position = await afterResolveDeviceLocation(preferences: prefs);

      final platformResult = await _fromPlatformGeocoder(
        position.latitude,
        position.longitude,
      );
      if (platformResult?.label != null) {
        return platformResult;
      }

      return await _fromNominatim(position.latitude, position.longitude);
    } on Object catch (error) {
      debugPrint('After current locality unavailable: $error');
      return null;
    }
  }

  Future<AfterCurrentLocality?> _fromPlatformGeocoder(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) {
        return null;
      }

      final place = placemarks.first;
      return AfterCurrentLocality(
        neighborhood: place.subLocality,
        district: _firstNonEmpty([place.subAdministrativeArea, place.locality]),
        city: _firstNonEmpty([place.administrativeArea, place.locality]),
      );
    } on Object catch (error) {
      debugPrint('After platform reverse geocoding failed: $error');
      return null;
    }
  }

  Future<AfterCurrentLocality?> _fromNominatim(
    double latitude,
    double longitude,
  ) async {
    try {
      final dio = ref.read(afterDioProvider);
      final response = await dio.get<Map<String, dynamic>>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: <String, dynamic>{
          'lat': latitude,
          'lon': longitude,
          'format': 'jsonv2',
          'zoom': 14,
          'addressdetails': 1,
        },
        options: Options(
          headers: const {
            'User-Agent': 'AfterArtificial/1.0 (current-locality)',
          },
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      final address = response.data?['address'];
      if (address is! Map<String, dynamic>) {
        return null;
      }

      String? pick(List<String> keys) => _firstNonEmpty(
            [for (final key in keys) address[key]?.toString()],
          );

      return AfterCurrentLocality(
        neighborhood: pick(const ['neighbourhood', 'suburb', 'quarter']),
        district: pick(const ['town', 'city_district', 'district', 'county']),
        city: pick(const ['city', 'province', 'state']),
      );
    } on Object catch (error) {
      debugPrint('After Nominatim reverse geocoding failed: $error');
      return null;
    }
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }
}
