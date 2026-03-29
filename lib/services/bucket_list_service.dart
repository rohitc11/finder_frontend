import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/bucket_list_item_model.dart';

/// Service responsible for bookmark / bucket-list related backend APIs.
///
/// Responsibility:
/// - add item to bucket list
/// - remove item from bucket list
/// - fetch saved items for a user
class BucketListService {
  /// Adds an item to the user's bucket list.
  Future<void> addToBucketList({
    required String userId,
    required String itemId,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/bucket-list?userId=$userId&itemId=$itemId',
    );

    final response = await http.post(uri);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add item to bucket list');
    }
  }

  /// Removes an item from the user's bucket list.
  Future<void> removeFromBucketList({
    required String userId,
    required String itemId,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/bucket-list?userId=$userId&itemId=$itemId',
    );

    final response = await http.delete(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to remove item from bucket list');
    }
  }

  /// Fetches all active saved items for a user.
  Future<List<BucketListItemModel>> fetchUserBucketList({
    required String userId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/bucket-list/$userId');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load bucket list');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => BucketListItemModel.fromJson(e)).toList();
  }
}