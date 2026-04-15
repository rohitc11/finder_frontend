/// Central API configuration for the app.
///
/// Uses compile-time environment values so debug/release can point to
/// different backend servers without code changes in multiple places.
class ApiConfig {
  /// Example usage:
  /// flutter run --dart-define=BASE_URL=http://10.0.2.2:8080
  /// http://3.108.193.120:8080
  /// flutter build appbundle --dart-define=BASE_URL=https://api.yourdomain.com
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String environmentDisplay = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'Local',
  );

  /// Auth endpoints
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String registerEndpoint = '$baseUrl/auth/register';

  /// Search endpoints
  static const String suggestionsEndpoint = '$baseUrl/search/suggestions';
  static const String smartSearchEndpoint = '$baseUrl/search/items/smart';

  /// Suggestion / contribution endpoints
  static const String contributionSuggestionsEndpoint = '$baseUrl/suggestions';
  static const String itemEditSuggestionEndpoint =
      '$baseUrl/suggestions/item-edit';
  static const String mySuggestionsEndpoint = '$baseUrl/suggestions/me';

  /// User endpoints
  static const String currentUserEndpoint = '$baseUrl/account/me';
  static const String currentUserSummaryEndpoint = '$baseUrl/users/me/summary';
  static const String updatePublicUsernameEndpoint =
      '$baseUrl/account/me/public-username';

  /// Bucket-list endpoints
  static const String myBucketListEndpoint = '$baseUrl/bucket-list/me';
  static const String bucketListEndpoint = '$baseUrl/bucket-list';
  static const String bucketListCheckEndpoint = '$baseUrl/bucket-list/check';

  /// Health endpoint
  static const String healthEndpoint = '$baseUrl/health';
}