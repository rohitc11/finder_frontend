/// Central API configuration for the app.
///
/// Responsibility:
/// - keeps backend base URL in one place
/// - keeps endpoint paths centralized
/// - exposes small environment labels for UI/debug use
class ApiConfig {
  /// Android emulator localhost mapping.
  ///
  /// Important:
  /// - use 10.0.2.2 for Android emulator
  /// - if testing on physical device, replace with your machine IP
  static const String baseUrl = 'http://10.0.2.2:8080';

  /// Friendly environment label used in profile/debug UI.
  static const String environmentDisplay = 'Local';

  /// Search suggestion endpoint.
  static const String suggestionsEndpoint = '$baseUrl/search/suggestions';

  /// Smart search endpoint.
  static const String smartSearchEndpoint = '$baseUrl/search/items/smart';

  /// Basic backend health check endpoint.
  ///
  /// Note:
  /// Add Spring Boot actuator health endpoint if needed:
  /// /actuator/health
  static const String healthEndpoint = '$baseUrl/actuator/health';
}