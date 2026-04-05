import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/** 
   Central API configuration for the app.
   Set the build-time environment variable to switch targets:
   flutter run  --dart-define=ENVIRONMENT=dev       (default)
   flutter run  --dart-define=ENVIRONMENT=staging
   flutter run  --dart-define=ENVIRONMENT=prod
*/
class ApiConfig {
  // ── Private base URLs ────────────────────────────────────────────────────
  /// Standard localhost for iOS simulator, web, and physical devices on the
  /// same network as the dev machine.
  static const String _devLocalhostUrl = 'http://localhost:8080';

  /// Android emulator routes host-machine localhost through 10.0.2.2.
  static const String _devAndroidUrl = 'http://10.0.2.2:8080';

  static const String _stagingBaseUrl = 'https://staging-api.finder.com';
  static const String _prodBaseUrl = 'https://api.finder.com';

  // ── Environment ──────────────────────────────────────────────────────────
  /// Normalized environment identifier (always lower-case).
  static String get environment {
    const String env = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'dev',
    );
    return env.toLowerCase();
  }

  /// User-friendly label shown in the UI / logs.
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

  // ── Base URL (platform + environment aware) ───────────────────────────────
  static String get baseUrl {
    switch (environment) {
      case 'prod':
      case 'production':
        return _prodBaseUrl;
      case 'staging':
      case 'stage':
        return _stagingBaseUrl;
      case 'dev':
      case 'development':
      default:
        // Android emulator cannot reach the host via "localhost"; use the
        // special alias 10.0.2.2 instead. Web and iOS simulator work fine
        // with localhost, as does a real device connected to the same LAN.
        if (!kIsWeb && Platform.isAndroid) {
          return _devAndroidUrl;
        }
        return _devLocalhostUrl;
    }
  }

  // ── Auth endpoints ────────────────────────────────────────────────────────
  static String get loginEndpoint => '$baseUrl/auth/login';
  static String get registerEndpoint => '$baseUrl/auth/register';

  // ── Search endpoints ──────────────────────────────────────────────────────
  static String get suggestionsEndpoint => '$baseUrl/search/suggestions';
  static String get smartSearchEndpoint => '$baseUrl/search/items/smart';

  // ── Suggestion / contribution endpoints ──────────────────────────────────
  static String get contributionSuggestionsEndpoint => '$baseUrl/suggestions';
  static String get mySuggestionsEndpoint => '$baseUrl/suggestions/me';

  // ── User endpoints ────────────────────────────────────────────────────────
  static String get currentUserEndpoint => '$baseUrl/users/me';
  static String get currentUserSummaryEndpoint => '$baseUrl/users/me/summary';

  // ── Bucket-list endpoints ─────────────────────────────────────────────────
  static String get myBucketListEndpoint => '$baseUrl/bucket-list/me';
  static String get bucketListEndpoint => '$baseUrl/bucket-list';
  static String get bucketListCheckEndpoint => '$baseUrl/bucket-list/check';

  // ── Health endpoint ───────────────────────────────────────────────────────
  static String get healthEndpoint => '$baseUrl/actuator/health';
}