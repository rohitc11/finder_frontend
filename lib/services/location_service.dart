import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Result object used when the app needs device location plus optional
/// human-readable address parts.
///
/// Why this model exists:
/// - backend needs machine-usable coordinates
/// - UI benefits from readable city / area fields
/// - keeping both together makes integration cleaner
class AppLocationResult {
  final double latitude;
  final double longitude;
  final String? city;
  final String? areaName;
  final String? fullAddress;

  const AppLocationResult({
    required this.latitude,
    required this.longitude,
    this.city,
    this.areaName,
    this.fullAddress,
  });
}

/// Service responsible for:
/// - requesting location permission only when needed
/// - fetching current device coordinates
/// - reverse geocoding into city / area when possible
///
/// Notes:
/// - this service is intentionally UI-agnostic
/// - screens can decide how to react when location is unavailable
class LocationService {
  /// Returns true if the query expresses near-me intent.
  ///
  /// This should stay aligned with backend near-me phrases.
  static bool hasNearMeIntent(String query) {
    final q = query.toLowerCase().trim();

    return q.contains('near me') ||
        q.contains('nearby') ||
        q.contains('around me') ||
        q.contains('around') ||
        q.contains('near by me') ||
        q.contains('nearby me') ||
        q.contains('close to me') ||
        q.contains('close by') ||
        q.contains('near my location');
  }

  /// Fetches current location and tries to reverse-geocode it.
  ///
  /// Returns null when:
  /// - location service is disabled
  /// - permission is denied
  /// - permission is denied forever
  static Future<AppLocationResult?> getCurrentLocationWithAddress() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    String? city;
    String? areaName;
    String? fullAddress;

    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;

        city = _firstNonEmpty([
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
        ]);

        areaName = _firstNonEmpty([
          place.subLocality,
          place.locality,
          place.name,
        ]);

        final List<String> parts = [
          if ((place.name ?? '').trim().isNotEmpty) place.name!.trim(),
          if ((place.subLocality ?? '').trim().isNotEmpty)
            place.subLocality!.trim(),
          if ((place.locality ?? '').trim().isNotEmpty) place.locality!.trim(),
          if ((place.administrativeArea ?? '').trim().isNotEmpty)
            place.administrativeArea!.trim(),
        ];

        fullAddress = parts.isEmpty ? null : parts.join(', ');
      }
    } catch (_) {
      // Reverse geocoding failure should not block coordinate usage.
    }

    return AppLocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      city: city,
      areaName: areaName,
      fullAddress: fullAddress,
    );
  }

  /// Returns the first non-empty string from the list.
  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = (value ?? '').trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }
}