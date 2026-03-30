import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/user_model.dart';

/// Service responsible for user-related backend APIs.
class UserService {
  /// Fetches one user by ID.
  Future<UserModel> fetchUserById(String userId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/users/$userId');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load user');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return UserModel.fromJson(data);
  }
}