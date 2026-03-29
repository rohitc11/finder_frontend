/// Model representing one bucket-list item returned by backend.
class BucketListItemModel {
  final String id;
  final String userId;
  final String itemId;
  final String itemName;
  final String normalizedItemName;
  final String city;
  final String normalizedCity;
  final String areaName;
  final String normalizedAreaName;
  final String createdAt;
  final bool isActive;

  BucketListItemModel({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.itemName,
    required this.normalizedItemName,
    required this.city,
    required this.normalizedCity,
    required this.areaName,
    required this.normalizedAreaName,
    required this.createdAt,
    required this.isActive,
  });

  /// Creates model from backend JSON response.
  factory BucketListItemModel.fromJson(Map<String, dynamic> json) {
    return BucketListItemModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      itemId: json['itemId'] ?? '',
      itemName: json['itemName'] ?? '',
      normalizedItemName: json['normalizedItemName'] ?? '',
      city: json['city'] ?? '',
      normalizedCity: json['normalizedCity'] ?? '',
      areaName: json['areaName'] ?? '',
      normalizedAreaName: json['normalizedAreaName'] ?? '',
      createdAt: json['createdAt'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }
}