/// Model representing one pending suggestion for admin moderation.
///
/// This maps the backend suggestion response used in:
/// - pending suggestions list
/// - suggestion detail moderation screen
class AdminSuggestionModel {
  final String id;
  final String userId;
  final String itemName;
  final String restaurantName;
  final String city;
  final String areaName;
  final String category;
  final String subCategory;
  final double? price;
  final String currency;
  final bool? isVeg;
  final String note;
  final double? latitude;
  final double? longitude;
  final String status;
  final String createdAt;

  const AdminSuggestionModel({
    required this.id,
    required this.userId,
    required this.itemName,
    required this.restaurantName,
    required this.city,
    required this.areaName,
    required this.category,
    required this.subCategory,
    required this.price,
    required this.currency,
    required this.isVeg,
    required this.note,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
  });

  factory AdminSuggestionModel.fromJson(Map<String, dynamic> json) {
    return AdminSuggestionModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      itemName: (json['itemName'] ?? '').toString(),
      restaurantName: (json['restaurantName'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      areaName: (json['areaName'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      subCategory: (json['subCategory'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble(),
      currency: (json['currency'] ?? 'INR').toString(),
      isVeg: json['isVeg'] as bool?,
      note: (json['note'] ?? '').toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: (json['status'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
    );
  }
}