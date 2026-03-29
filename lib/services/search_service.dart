import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/search_result_model.dart';
import '../models/suggestion_model.dart';

/// Service responsible for all search-related backend communication.
///
/// Responsibility:
/// - fetch autocomplete suggestions
/// - fetch smart search results
/// - keep API logic outside UI widgets
class SearchService {
  /// Fetches autocomplete suggestions from backend.
  Future<List<SuggestionModel>> fetchSuggestions(String query) async {
    final uri = Uri.parse(
      '${ApiConfig.suggestionsEndpoint}?query=${Uri.encodeComponent(query)}',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load suggestions');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => SuggestionModel.fromJson(e)).toList();
  }

  /// Fetches smart search results from backend.
  ///
  /// Optional parameters can be used later for:
  /// - location-aware search
  /// - bookmark-aware results via userId
  Future<List<SearchResultModel>> fetchSmartSearch({
    required String query,
    String? userId,
    double? latitude,
    double? longitude,
    double? radiusInKm,
  }) async {
    final Map<String, String> queryParams = {
      'query': query,
    };

    if (userId != null && userId.isNotEmpty) {
      queryParams['userId'] = userId;
    }
    if (latitude != null) {
      queryParams['latitude'] = latitude.toString();
    }
    if (longitude != null) {
      queryParams['longitude'] = longitude.toString();
    }
    if (radiusInKm != null) {
      queryParams['radiusInKm'] = radiusInKm.toString();
    }

    final uri = Uri.parse(ApiConfig.smartSearchEndpoint).replace(
      queryParameters: queryParams,
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load search results');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => SearchResultModel.fromJson(e)).toList();
  }
}