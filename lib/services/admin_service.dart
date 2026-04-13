import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../config/user_session.dart';
import '../models/admin_suggestion_model.dart';

class AdminService {
  Future<List<AdminSuggestionModel>> fetchPendingSuggestions() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/suggestions/pending');

    final response = await http.get(
      uri,
      headers: {
        ...UserSession.authHeaders,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(response.body, 'Failed to load pending suggestions'),
      );
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((e) => AdminSuggestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

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
      throw Exception(
        _extractMessage(response.body, 'Failed to approve suggestion'),
      );
    }
  }

  Future<void> approveSuggestionAsEdit(String suggestionId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/suggestions/$suggestionId/approve-edit',
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
      throw Exception(
        _extractMessage(response.body, 'Failed to approve edit suggestion'),
      );
    }
  }

  Future<void> rejectSuggestion(
      String suggestionId, {
        String? rejectionReason,
      }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/suggestions/$suggestionId/reject',
    );

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...UserSession.authHeaders,
      },
      body: jsonEncode({
        'rejectionReason': (rejectionReason ?? '').trim().isEmpty
            ? null
            : rejectionReason!.trim(),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        _extractMessage(response.body, 'Failed to reject suggestion'),
      );
    }
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