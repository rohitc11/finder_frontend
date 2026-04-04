import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../config/user_session.dart';
import '../models/bucket_list_item_model.dart';

/// Service responsible for current user's bucket-list APIs.
///
/// Auth rule:
/// - backend derives current user from JWT
/// - frontend should not send userId
class BucketListService {
  /// Fetch current user's saved items.
  Future<List<BucketListItemModel>> fetchSavedItems() async {
    final response = await http.get(
      Uri.parse(ApiConfig.myBucketListEndpoint),
      headers: {
        ...UserSession.authHeaders,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load saved items');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => BucketListItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Add item to current user's bucket list.
  Future<void> addToBucketList(String itemId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.bucketListEndpoint}?itemId=$itemId'),
      headers: {
        ...UserSession.authHeaders,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to add bookmark');
    }
  }

  /// Remove item from current user's bucket list.
  Future<void> removeFromBucketList(String itemId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.bucketListEndpoint}?itemId=$itemId'),
      headers: {
        ...UserSession.authHeaders,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to remove bookmark');
    }
  }

  /// Check whether current user bookmarked an item.
  Future<bool> isBookmarked(String itemId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.bucketListCheckEndpoint}?itemId=$itemId'),
      headers: {
        ...UserSession.authHeaders,
      },
    );

    if (response.statusCode != 200) {
      return false;
    }

    return response.body.toLowerCase().contains('true');
  }
}