import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  /// Opens Google Maps directions to the given coordinates.
  ///
  /// We use directions instead of a plain search so the user can directly
  /// navigate to the food item's location.
  static Future<void> openDirections({
    required double latitude,
    required double longitude,
  }) async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );

    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw Exception('Could not open map');
    }
  }
}