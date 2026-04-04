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
}