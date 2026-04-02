/// Model representing one full item detail returned by backend.
///
/// Notes:
/// - backend returns location as GeoJSON-like object:
///   {
///     "type": "Point",
///     "coordinates": [longitude, latitude]
///   }
/// - frontend exposes latitude / longitude as optional convenience fields
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

  /// Optional latitude parsed from backend location.coordinates[1]
  final double? latitude;

  /// Optional longitude parsed from backend location.coordinates[0]
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
    double? latitude;
    double? longitude;

    if (location is Map && location['coordinates'] is List) {
      final coordinates = location['coordinates'] as List;

      if (coordinates.length >= 2) {
        longitude = (coordinates[0] as num?)?.toDouble();
        latitude = (coordinates[1] as num?)?.toDouble();
      }
    }

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
      latitude: latitude,
      longitude: longitude,
    );
  }
}