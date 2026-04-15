import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../config/user_session.dart';
import '../models/item_model.dart';

/// Service responsible for item-related backend APIs.
class ItemService {
  /// Fetches full item details by item ID.
  Future<ItemModel> fetchItemById(String itemId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/items/$itemId');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...UserSession.authHeaders,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load item details');
    }

    final Map data = jsonDecode(response.body);
    return ItemModel.fromJson(data);
  }

  Future<ItemWorthTryingResult> markWorthTrying(String itemId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/items/$itemId/worth-trying');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...UserSession.authHeaders,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to mark item as worth trying');
    }

    final Map data = jsonDecode(response.body);
    return ItemWorthTryingResult.fromJson(data);
  }

  Future<ItemWorthTryingResult> removeWorthTrying(String itemId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/items/$itemId/worth-trying');

    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...UserSession.authHeaders,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to remove worth trying');
    }

    final Map data = jsonDecode(response.body);
    return ItemWorthTryingResult.fromJson(data);
  }
}

class ItemWorthTryingResult {
  final String itemId;
  final bool worthTrying;
  final int likeCount;

  ItemWorthTryingResult({
    required this.itemId,
    required this.worthTrying,
    required this.likeCount,
  });

  factory ItemWorthTryingResult.fromJson(Map json) {
    return ItemWorthTryingResult(
      itemId: (json['itemId'] ?? '').toString(),
      worthTrying: json['worthTrying'] ?? false,
      likeCount: (json['likeCount'] ?? 0) as int,
    );
  }
}