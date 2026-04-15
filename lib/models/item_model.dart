/// Model representing one full item detail returned by backend.
class ItemModel {
  final String id;
  final String itemName;
  final String restaurantId;
  final String restaurantName;
  final String city;
  final String areaName;
  final String category;
  final String subCategory;
  final double? avgItemRating;
  final int? ratingCount;
  final int likeCount;
  final bool likedByCurrentUser;
  final double? price;
  final String currency;
  final bool isVeg;
  final bool isAvailable;
  final bool isVerified;
  final bool isActive;
  final double? latitude;
  final double? longitude;

  ItemModel({
    required this.id,
    required this.itemName,
    required this.restaurantId,
    required this.restaurantName,
    required this.city,
    required this.areaName,
    required this.category,
    required this.subCategory,
    required this.avgItemRating,
    required this.ratingCount,
    required this.likeCount,
    required this.likedByCurrentUser,
    required this.price,
    required this.currency,
    required this.isVeg,
    required this.isAvailable,
    required this.isVerified,
    required this.isActive,
    required this.latitude,
    required this.longitude,
  });

  /// Creates model from backend JSON response.
  factory ItemModel.fromJson(Map json) {
    final location = json['location'];
    final coordinates = location is Map ? location['coordinates'] : null;

    return ItemModel(
      id: json['id'] ?? '',
      itemName: json['itemName'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      city: json['city'] ?? '',
      areaName: json['areaName'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      avgItemRating: (json['avgItemRating'] as num?)?.toDouble(),
      ratingCount: json['ratingCount'],
      likeCount: (json['likeCount'] ?? 0) as int,
      likedByCurrentUser: json['likedByCurrentUser'] ?? false,
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] ?? 'INR',
      isVeg: json['isVeg'] ?? false,
      isAvailable: json['isAvailable'] ?? false,
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? false,
      latitude: coordinates is List && coordinates.length >= 2
          ? (coordinates[1] as num?)?.toDouble()
          : null,
      longitude: coordinates is List && coordinates.length >= 2
          ? (coordinates[0] as num?)?.toDouble()
          : null,
    );
  }

  ItemModel copyWith({
    String? id,
    String? itemName,
    String? restaurantId,
    String? restaurantName,
    String? city,
    String? areaName,
    String? category,
    String? subCategory,
    double? avgItemRating,
    int? ratingCount,
    int? likeCount,
    bool? likedByCurrentUser,
    double? price,
    String? currency,
    bool? isVeg,
    bool? isAvailable,
    bool? isVerified,
    bool? isActive,
    double? latitude,
    double? longitude,
  }) {
    return ItemModel(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      city: city ?? this.city,
      areaName: areaName ?? this.areaName,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      avgItemRating: avgItemRating ?? this.avgItemRating,
      ratingCount: ratingCount ?? this.ratingCount,
      likeCount: likeCount ?? this.likeCount,
      likedByCurrentUser: likedByCurrentUser ?? this.likedByCurrentUser,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isVeg: isVeg ?? this.isVeg,
      isAvailable: isAvailable ?? this.isAvailable,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}