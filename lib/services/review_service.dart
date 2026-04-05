import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../config/user_session.dart';
import '../models/review_model.dart';

class ReviewService {
  Future<List<ReviewModel>> fetchReviewsByItem(String itemId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/reviews/item/$itemId');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(_extractMessage(response.body, 'Failed to load item reviews'));
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ReviewModel>> fetchMyReviews() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/reviews/me');
    final response = await http.get(
      uri,
      headers: {
        ...UserSession.authHeaders,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(_extractMessage(response.body, 'Failed to load your reviews'));
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addItemReview({
    required String itemId,
    required int rating,
    String? comment,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/reviews/item');

    final payload = <String, dynamic>{
      'itemId': itemId,
      'rating': rating,
      'comment': (comment ?? '').trim().isEmpty ? null : comment!.trim(),
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...UserSession.authHeaders,
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractMessage(response.body, 'Failed to add review'));
    }
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