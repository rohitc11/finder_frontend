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
  final double? price;
  final String currency;
  final bool isVeg;
  final bool isAvailable;
  final bool isVerified;
  final bool isActive;

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
    required this.price,
    required this.currency,
    required this.isVeg,
    required this.isAvailable,
    required this.isVerified,
    required this.isActive,
  });

  /// Creates model from backend JSON response.
  factory ItemModel.fromJson(Map<String, dynamic> json) {
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
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] ?? 'INR',
      isVeg: json['isVeg'] ?? false,
      isAvailable: json['isAvailable'] ?? false,
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? false,
    );
  }
}