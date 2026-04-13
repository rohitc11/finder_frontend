/// Model representing one pending suggestion for admin moderation.
///
/// This maps the backend suggestion response used in:
/// - pending suggestions list
/// - suggestion detail moderation screen
class AdminSuggestionModel {
  final String id;
  final String userId;

  /// ADD_ITEM or EDIT_ITEM from backend.
  final String suggestionType;

  /// Present for edit suggestions.
  final String targetItemId;

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
    required this.suggestionType,
    required this.targetItemId,
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

  bool get isEditSuggestion => suggestionType.trim() == 'EDIT_ITEM';
  bool get isAddSuggestion => suggestionType.trim() == 'ADD_ITEM';

  factory AdminSuggestionModel.fromJson(Map json) {
    final String parsedSuggestionType =
    (json['suggestionType'] ?? '').toString().trim();
    final String parsedTargetItemId =
    (json['targetItemId'] ?? '').toString().trim();

    return AdminSuggestionModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      suggestionType: parsedSuggestionType.isNotEmpty
          ? parsedSuggestionType
          : (parsedTargetItemId.isNotEmpty ? 'EDIT_ITEM' : 'ADD_ITEM'),
      targetItemId: parsedTargetItemId,
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