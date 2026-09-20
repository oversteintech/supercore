import 'package:after_core/after_core.dart';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';

/// Country (+ optional city) resolved from device GPS.
@immutable
class AfterRegionalLocationResult {
  const AfterRegionalLocationResult({
    required this.countryCode,
    this.cityName,
    this.districtName,
  });

  final String countryCode;
  final String? cityName;
  final String? districtName;
}

/// Shared reverse-geocode path for every Super App (not Garage-only).
///
/// Requires OS location permission already granted (launch consent or Settings).
abstract final class AfterRegionalLocationService {
  /// Detect ISO country (+ city) from current device position.
  static Future<AfterRegionalLocationResult?> detectRegionalLocation({
    Dio? dio,
    String userAgent = 'AfterArtificial/1.0 (regional-location)',
  }) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return null;
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 12),
      ),
    );

    return reverseGeocodeRegional(
      latitude: position.latitude,
      longitude: position.longitude,
      dio: dio,
      userAgent: userAgent,
    );
  }

  static Future<String?> detectCountryCode({Dio? dio}) async {
    final result = await detectRegionalLocation(dio: dio);
    return result?.countryCode;
  }

  static Future<AfterRegionalLocationResult?> reverseGeocodeRegional({
    required double latitude,
    required double longitude,
    Dio? dio,
    String userAgent = 'AfterArtificial/1.0 (regional-location)',
  }) async {
    final platformResult = await _fromPlatformGeocoder(latitude, longitude);
    if (platformResult != null) {
      return platformResult;
    }
    return _fromNominatim(
      latitude,
      longitude,
      dio: dio,
      userAgent: userAgent,
    );
  }

  static Future<AfterRegionalLocationResult?> _fromPlatformGeocoder(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) {
        return null;
      }

      final place = placemarks.first;
      final countryCode =
          AfterSupportedCountries.normalize(place.isoCountryCode);
      if (countryCode == null) {
        return null;
      }

      return AfterRegionalLocationResult(
        countryCode: countryCode,
        cityName: _firstNonEmpty([
          place.administrativeArea,
          place.locality,
          place.subAdministrativeArea,
        ]),
        districtName: _firstNonEmpty([
          place.subAdministrativeArea,
          place.locality,
        ]),
      );
    } on Exception {
      return null;
    }
  }

  static Future<AfterRegionalLocationResult?> _fromNominatim(
    double latitude,
    double longitude, {
    Dio? dio,
    required String userAgent,
  }) async {
    final client = dio ?? Dio();
    try {
      final response = await client.get<Map<String, dynamic>>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: <String, dynamic>{
          'lat': latitude,
          'lon': longitude,
          'format': 'jsonv2',
          'zoom': 10,
          'addressdetails': 1,
        },
        options: Options(
          headers: {'User-Agent': userAgent},
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      final address = response.data?['address'];
      if (address is! Map<String, dynamic>) {
        return null;
      }

      final rawCode = address['country_code']?.toString();
      final countryCode = AfterSupportedCountries.normalize(rawCode);
      if (countryCode == null) {
        return null;
      }

      String? pick(List<String> keys) => _firstNonEmpty(
            [for (final key in keys) address[key]?.toString()],
          );

      return AfterRegionalLocationResult(
        countryCode: countryCode,
        cityName: pick(const ['city', 'town', 'province', 'state']),
        districtName: pick(const [
          'county',
          'district',
          'borough',
          'municipality',
          'suburb',
        ]),
      );
    } on Exception {
      return null;
    }
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }
}
