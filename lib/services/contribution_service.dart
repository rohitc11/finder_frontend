import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/user_profile_summary_model.dart';
import '../models/user_suggestion_model.dart';

class ContributionService {
  Future<UserProfileSummaryModel> fetchUserSummary(String userId) async {
    final uri = Uri.parse(ApiConfig.userSummaryEndpoint(userId));
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load contribution summary');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return UserProfileSummaryModel.fromJson(data);
  }

  Future<List<UserSuggestionModel>> fetchUserSuggestions(String userId) async {
    final uri = Uri.parse(ApiConfig.userSuggestionsEndpoint(userId));
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load user suggestions');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((e) => UserSuggestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> submitSuggestion({
    required String userId,
    required String itemName,
    required String restaurantName,
    required String city,
    required String areaName,
    String category = '',
    String subCategory = '',
    double? price,
    String currency = 'INR',
    bool? isVeg,
    String note = '',
    double? latitude,
    double? longitude,
  }) async {
    final uri = Uri.parse(ApiConfig.contributionSuggestionsEndpoint);

    final body = <String, dynamic>{
      'userId': userId,
      'itemName': itemName.trim(),
      'restaurantName': restaurantName.trim(),
      'city': city.trim(),
      'areaName': areaName.trim(),
      'category': category.trim(),
      'subCategory': subCategory.trim(),
      'price': price,
      'currency': currency.trim().isEmpty ? 'INR' : currency.trim(),
      'isVeg': isVeg,
      'note': note.trim(),
      'latitude': latitude,
      'longitude': longitude,
    };

    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to submit suggestion');
    }
  }
}