import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../config/user_session.dart';
import '../models/review_model.dart';

/// Service responsible for review-related backend APIs.
class ReviewService {
  /// Fetch reviews for one item.
  Future<List<ReviewModel>> fetchReviewsByItem(String itemId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/reviews/item/$itemId');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load item reviews');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Add review for current logged-in user.
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
      throw Exception('Failed to add review');
    }
  }
}