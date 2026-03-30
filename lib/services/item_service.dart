import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/item_model.dart';

/// Service responsible for item-related backend APIs.
class ItemService {
  /// Fetches full item details by item ID.
  ///
  /// Expected backend endpoint:
  /// GET /items/{id}
  Future<ItemModel> fetchItemById(String itemId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/items/$itemId');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load item details');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return ItemModel.fromJson(data);
  }
}