import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../config/user_session.dart';
import '../models/auth_response_model.dart';

/// Service responsible for login, registration and logout.
class AuthService {
  Future<AuthResponseModel> login({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.loginEndpoint),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': (email ?? '').trim().isEmpty ? null : email!.trim(),
        'phoneNumber':
        (phoneNumber ?? '').trim().isEmpty ? null : phoneNumber!.trim(),
        'password': password.trim(),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractMessage(response.body, 'Invalid credentials'));
    }

    final data = jsonDecode(response.body) as Map;
    final auth = AuthResponseModel.fromJson(data);

    await UserSession.saveSession(
      tokenValue: auth.token,
      userIdValue: auth.userId,
      nameValue: auth.name,
      emailValue: auth.email,
      phoneNumberValue: auth.phoneNumber,
      roleValue: auth.role,
    );

    return auth;
  }

  Future<AuthResponseModel> register({
    required String name,
    required String publicUsername,
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.registerEndpoint),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name.trim(),
        'publicUsername': publicUsername.trim(),
        'email': (email ?? '').trim().isEmpty ? null : email!.trim(),
        'phoneNumber':
        (phoneNumber ?? '').trim().isEmpty ? null : phoneNumber!.trim(),
        'password': password.trim(),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractMessage(response.body, 'Registration failed'));
    }

    final data = jsonDecode(response.body) as Map;
    final auth = AuthResponseModel.fromJson(data);

    await UserSession.saveSession(
      tokenValue: auth.token,
      userIdValue: auth.userId,
      nameValue: auth.name,
      emailValue: auth.email,
      phoneNumberValue: auth.phoneNumber,
      roleValue: auth.role,
    );

    return auth;
  }

  Future<void> logout() async {
    await UserSession.clear();
  }

  String _extractMessage(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        if ((decoded['message'] ?? '').toString().trim().isNotEmpty) {
          return decoded['message'].toString();
        }
        if ((decoded['error'] ?? '').toString().trim().isNotEmpty) {
          return decoded['error'].toString();
        }
      }
    } catch (_) {}
    return fallback;
  }
}