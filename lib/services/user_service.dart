import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../config/user_session.dart';
import '../models/user_model.dart';

/// Service responsible for current user APIs.
class UserService {
  /// Fetches current logged-in user profile.
  Future<UserModel> fetchCurrentUser() async {
    final uri = Uri.parse(ApiConfig.currentUserEndpoint);
    final response = await http.get(
      uri,
      headers: {
        ...UserSession.authHeaders,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load current user');
    }

    final Map<String, dynamic> data =
    jsonDecode(response.body) as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Future<UserModel> updatePublicUsername(String publicUsername) async {
    final uri = Uri.parse(ApiConfig.updatePublicUsernameEndpoint);

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...UserSession.authHeaders,
      },
      body: jsonEncode({
        'publicUsername': publicUsername.trim(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractMessage(response.body, 'Failed to update public username'));
    }

    final Map<String, dynamic> data =
    jsonDecode(response.body) as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  String _extractMessage(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
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