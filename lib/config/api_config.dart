/// API Configuration for different environments
class ApiConfig {
  static const String _devBaseUrl = 'http://localhost:8080';
  static const String _stagingBaseUrl = 'https://staging-api.finder.com';
  static const String _prodBaseUrl = 'https://api.finder.com';

  /// Get base URL based on environment
  /// Default to dev if not specified
  static String get baseUrl {
    const String environment = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'dev',
    );

    switch (environment.toLowerCase()) {
      case 'prod':
      case 'production':
        return _prodBaseUrl;
      case 'staging':
      case 'stage':
        return _stagingBaseUrl;
      case 'dev':
      case 'development':
      default:
        return _devBaseUrl;
    }
  }

  /// Health check endpoint
  static String get healthEndpoint => '$baseUrl/health';

  /// Search endpoint
  static String get searchEndpoint => '$baseUrl/api/v1/search';

  /// User profile endpoint
  static String get profileEndpoint => '$baseUrl/api/v1/user/profile';

  /// Get environment name
  static String get environment {
    const String env = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'dev',
    );
    return env.toLowerCase();
  }

  /// Get user-friendly environment name
  static String get environmentDisplay {
    switch (environment) {
      case 'prod':
      case 'production':
        return 'Production';
      case 'staging':
      case 'stage':
        return 'Staging';
      case 'dev':
      case 'development':
      default:
        return 'Development';
    }
  }
}
