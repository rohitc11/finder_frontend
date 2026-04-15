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
  final int likeCount;
  final bool likedByCurrentUser;
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
    required this.likeCount,
    required this.likedByCurrentUser,
    required this.distanceInKm,
    required this.isBookmarked,
  });

  /// Creates model from backend JSON response.
  factory SearchResultModel.fromJson(Map json) {
    return SearchResultModel(
      itemId: json['itemId'] ?? '',
      itemName: json['itemName'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      city: json['city'] ?? '',
      areaName: json['areaName'] ?? '',
      avgItemRating: (json['avgItemRating'] as num?)?.toDouble(),
      ratingCount: json['ratingCount'],
      likeCount: (json['likeCount'] ?? 0) as int,
      likedByCurrentUser: json['likedByCurrentUser'] ?? false,
      distanceInKm: (json['distanceInKm'] as num?)?.toDouble(),
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }

  SearchResultModel copyWith({
    String? itemId,
    String? itemName,
    String? restaurantId,
    String? restaurantName,
    String? city,
    String? areaName,
    double? avgItemRating,
    int? ratingCount,
    int? likeCount,
    bool? likedByCurrentUser,
    double? distanceInKm,
    bool? isBookmarked,
  }) {
    return SearchResultModel(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      city: city ?? this.city,
      areaName: areaName ?? this.areaName,
      avgItemRating: avgItemRating ?? this.avgItemRating,
      ratingCount: ratingCount ?? this.ratingCount,
      likeCount: likeCount ?? this.likeCount,
      likedByCurrentUser: likedByCurrentUser ?? this.likedByCurrentUser,
      distanceInKm: distanceInKm ?? this.distanceInKm,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}