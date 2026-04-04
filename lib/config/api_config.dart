/// Central API configuration for the app.
class ApiConfig {
  /// Android emulator localhost mapping.
  static const String baseUrl = 'http://10.0.2.2:8080';

  static const String environmentDisplay = 'Local';

  /// Auth endpoints
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String registerEndpoint = '$baseUrl/auth/register';

  /// Search endpoints
  static const String suggestionsEndpoint = '$baseUrl/search/suggestions';
  static const String smartSearchEndpoint = '$baseUrl/search/items/smart';

  /// Suggestion / contribution endpoints
  static const String contributionSuggestionsEndpoint = '$baseUrl/suggestions';
  static const String mySuggestionsEndpoint = '$baseUrl/suggestions/me';

  /// User endpoints
  static const String currentUserEndpoint = '$baseUrl/users/me';
  static const String currentUserSummaryEndpoint = '$baseUrl/users/me/summary';

  /// Bucket-list endpoints
  static const String myBucketListEndpoint = '$baseUrl/bucket-list/me';
  static const String bucketListEndpoint = '$baseUrl/bucket-list';
  static const String bucketListCheckEndpoint = '$baseUrl/bucket-list/check';

  /// Health endpoint
  static const String healthEndpoint = '$baseUrl/actuator/health';
}