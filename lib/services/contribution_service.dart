import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../config/user_session.dart';
import '../models/user_profile_summary_model.dart';
import '../models/user_suggestion_model.dart';

/// Service responsible for contribution-related APIs.
///
/// Auth rule:
/// - current logged-in user is derived from JWT on backend
/// - frontend should not send raw userId for "my" APIs
class ContributionService {
  /// Fetches current user's contribution summary.
  Future<UserProfileSummaryModel> fetchUserSummary() async {
    final uri = Uri.parse(ApiConfig.currentUserSummaryEndpoint);
    final response = await http.get(
      uri,
      headers: {
        ...UserSession.authHeaders,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load contribution summary');
    }

    final Map<String, dynamic> data =
    jsonDecode(response.body) as Map<String, dynamic>;

    return UserProfileSummaryModel.fromJson(data);
  }

  /// Fetches current user's suggestions.
  Future<List<UserSuggestionModel>> fetchUserSuggestions() async {
    final uri = Uri.parse(ApiConfig.mySuggestionsEndpoint);
    final response = await http.get(
      uri,
      headers: {
        ...UserSession.authHeaders,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load user suggestions');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((e) => UserSuggestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Submits a new item suggestion for current logged-in user.
  Future<void> submitSuggestion({
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
    List<String>? cuisineTypes,
    List<String>? mealTypes,
    List<String>? courseTypes,
    List<String>? dietTags,
    List<String>? experienceTags,
  }) async {
    final uri = Uri.parse(ApiConfig.contributionSuggestionsEndpoint);

    final body = <String, dynamic>{
      'itemName': itemName.trim(),
      'restaurantName': restaurantName.trim(),
      'city': city.trim(),
      'areaName': areaName.trim(),
      'category': category.trim(),
      'subCategory': subCategory.trim(),
      'cuisineTypes': cuisineTypes ?? [],
      'mealTypes': mealTypes ?? [],
      'courseTypes': courseTypes ?? [],
      'dietTags': dietTags ?? [],
      'experienceTags': experienceTags ?? [],
      'price': price,
      'currency': currency.trim().isEmpty ? 'INR' : currency.trim(),
      'isVeg': isVeg,
      'note': note.trim(),
      'latitude': latitude,
      'longitude': longitude,
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...UserSession.authHeaders,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to submit suggestion');
    }
  }

  /// Submits a correction/edit suggestion for an existing item.
  ///
  /// Only changed fields should be sent by the UI. Empty strings are trimmed;
  /// null means "no proposed change" for that field.
  Future<void> submitItemEditSuggestion({
    required String targetItemId,
    String? itemName,
    String? restaurantName,
    String? city,
    String? areaName,
    String? category,
    String? subCategory,
    double? price,
    bool? isVeg,
    String? note,
    double? latitude,
    double? longitude,
    List<String>? cuisineTypes,
    List<String>? mealTypes,
    List<String>? courseTypes,
    List<String>? dietTags,
    List<String>? experienceTags,

  }) async {
    final uri = Uri.parse(ApiConfig.itemEditSuggestionEndpoint);

    final body = <String, dynamic>{
      'targetItemId': targetItemId.trim(),
      'itemName': _trimToNullable(itemName),
      'restaurantName': _trimToNullable(restaurantName),
      'city': _trimToNullable(city),
      'areaName': _trimToNullable(areaName),
      'category': _trimToNullable(category),
      'subCategory': _trimToNullable(subCategory),
      'cuisineTypes': cuisineTypes ?? [],
      'mealTypes': mealTypes ?? [],
      'courseTypes': courseTypes ?? [],
      'dietTags': dietTags ?? [],
      'experienceTags': experienceTags ?? [],
      'price': price,
      'isVeg': isVeg,
      'note': _trimToNullable(note),
      'latitude': latitude,
      'longitude': longitude,
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...UserSession.authHeaders,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to submit item edit suggestion');
    }
  }

  String? _trimToNullable(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}