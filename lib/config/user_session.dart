import 'package:shared_preferences/shared_preferences.dart';

/// Holds current authenticated session for the app.
///
/// Responsibilities:
/// - keep token and user identity in memory
/// - persist session locally
/// - expose simple helpers for login/logout checks
class UserSession {
  static String? token;
  static String? userId;
  static String? name;
  static String? email;
  static String? phoneNumber;
  static String? role;

  /// Returns true when a valid token is present in memory.
  static bool get isLoggedIn => token != null && token!.trim().isNotEmpty;

  /// Loads session from local storage during app startup.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
    userId = prefs.getString('auth_user_id');
    name = prefs.getString('auth_name');
    email = prefs.getString('auth_email');
    phoneNumber = prefs.getString('auth_phone');
    role = prefs.getString('auth_role');
  }

  /// Saves a new logged-in session locally and in memory.
  static Future<void> saveSession({
    required String tokenValue,
    required String userIdValue,
    required String nameValue,
    String? emailValue,
    String? phoneNumberValue,
    String? roleValue,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    token = tokenValue;
    userId = userIdValue;
    name = nameValue;
    email = emailValue;
    phoneNumber = phoneNumberValue;
    role = roleValue;

    await prefs.setString('auth_token', tokenValue);
    await prefs.setString('auth_user_id', userIdValue);
    await prefs.setString('auth_name', nameValue);
    await prefs.setString('auth_email', emailValue ?? '');
    await prefs.setString('auth_phone', phoneNumberValue ?? '');
    await prefs.setString('auth_role', roleValue ?? '');
  }

  /// Clears current session on logout.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    token = null;
    userId = null;
    name = null;
    email = null;
    phoneNumber = null;
    role = null;

    await prefs.remove('auth_token');
    await prefs.remove('auth_user_id');
    await prefs.remove('auth_name');
    await prefs.remove('auth_email');
    await prefs.remove('auth_phone');
    await prefs.remove('auth_role');
  }

  /// Returns auth header map for protected APIs.
  static Map<String, String> get authHeaders {
    if (!isLoggedIn) return {};
    return {
      'Authorization': 'Bearer $token',
    };
  }
}