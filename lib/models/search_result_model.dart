/// Model representing one search result item returned by backend.
class SearchResultModel {
  final String itemId;
  final String itemName;
  final String restaurantId;
  final String restaurantName;
  final String city;
  final String areaName;
  final double? avgItemRating;
  final int? ratingCount;
  final double? distanceInKm;
  final bool isBookmarked;

  SearchResultModel({
    required this.itemId,
    required this.itemName,
    required this.restaurantId,
    required this.restaurantName,
    required this.city,
    required this.areaName,
    required this.avgItemRating,
    required this.ratingCount,
    required this.distanceInKm,
    required this.isBookmarked,
  });

  /// Creates model from backend JSON response.
  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      itemId: json['itemId'] ?? '',
      itemName: json['itemName'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      city: json['city'] ?? '',
      areaName: json['areaName'] ?? '',
      avgItemRating: (json['avgItemRating'] as num?)?.toDouble(),
      ratingCount: json['ratingCount'],
      distanceInKm: (json['distanceInKm'] as num?)?.toDouble(),
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }
}