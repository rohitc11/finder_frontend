import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/review_model.dart';

/// Service responsible for review-related backend APIs.
///
/// Current launch scope:
/// - add review for item
/// - fetch reviews for item
class ReviewService {
  /// Fetches all reviews for a given item.
  Future<List<ReviewModel>> fetchReviewsByItem(String itemId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/reviews/item/$itemId');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load item reviews');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Adds a new review for an item.
  Future<void> addItemReview({
    required String userId,
    required String userName,
    required String itemId,
    required int rating,
    String? comment,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/reviews/item');

    final payload = <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'itemId': itemId,
      'rating': rating,
      'comment': (comment ?? '').trim().isEmpty ? null : comment!.trim(),
    };

    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to add review');
    }
  }
}