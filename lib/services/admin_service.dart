import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../config/user_session.dart';
import '../models/admin_suggestion_model.dart';

/// Service responsible for admin moderation APIs.
///
/// Security:
/// - backend verifies ADMIN role using JWT
/// - frontend only shows this flow for admin users
class AdminService {
  /// Fetches all pending suggestions for moderation.
  Future<List<AdminSuggestionModel>> fetchPendingSuggestions() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/suggestions/pending');

    final response = await http.get(
      uri,
      headers: {
        ...UserSession.authHeaders,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load pending suggestions');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => AdminSuggestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Approves one suggestion as a brand-new item.
  Future<void> approveSuggestionAsNew(String suggestionId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/suggestions/$suggestionId/approve-new',
    );

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...UserSession.authHeaders,
      },
      body: jsonEncode({}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to approve suggestion');
    }
  }

  /// Rejects one suggestion.
  Future<void> rejectSuggestion(String suggestionId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/suggestions/$suggestionId/reject',
    );

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...UserSession.authHeaders,
      },
      body: jsonEncode({}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to reject suggestion');
    }
  }
}