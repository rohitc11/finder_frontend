enum SuggestionStatus {
  pendingReview,
  approvedNew,
  approvedMerged,
  rejected,
  unknown;

  static SuggestionStatus fromBackend(String? value) {
    switch ((value ?? '').trim()) {
      case 'PENDING_REVIEW':
        return SuggestionStatus.pendingReview;
      case 'APPROVED_NEW':
        return SuggestionStatus.approvedNew;
      case 'APPROVED_MERGED':
        return SuggestionStatus.approvedMerged;
      case 'REJECTED':
        return SuggestionStatus.rejected;
      default:
        return SuggestionStatus.unknown;
    }
  }
}

class UserSuggestionModel {
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
  final SuggestionStatus status;
  final String linkedItemId;
  final int rewardPointsGranted;
  final String reviewReason;
  final DateTime? createdAt;
  final DateTime? reviewedAt;
  final double? latitude;
  final double? longitude;

  const UserSuggestionModel({
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
    required this.status,
    required this.linkedItemId,
    required this.rewardPointsGranted,
    required this.reviewReason,
    required this.createdAt,
    required this.reviewedAt,
    required this.latitude,
    required this.longitude,
  });

  String get locationLabel {
    if (areaName.isNotEmpty && city.isNotEmpty) {
      return '$areaName, $city';
    }
    return areaName.isNotEmpty ? areaName : city;
  }

  bool get isApproved =>
      status == SuggestionStatus.approvedNew ||
          status == SuggestionStatus.approvedMerged;

  String get statusLabel {
    switch (status) {
      case SuggestionStatus.pendingReview:
        return 'Pending';
      case SuggestionStatus.approvedNew:
        return 'Approved';
      case SuggestionStatus.approvedMerged:
        return 'Merged';
      case SuggestionStatus.rejected:
        return 'Rejected';
      case SuggestionStatus.unknown:
        return 'Unknown';
    }
  }

  factory UserSuggestionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      final raw = (value ?? '').toString().trim();
      if (raw.isEmpty) return null;
      return DateTime.tryParse(raw);
    }

    return UserSuggestionModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      itemName: (json['itemName'] ?? '').toString(),
      restaurantName: (json['restaurantName'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      areaName: (json['areaName'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      subCategory: (json['subCategory'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble(),
      currency: (json['currency'] ?? '').toString(),
      isVeg: json['isVeg'] as bool?,
      note: (json['note'] ?? '').toString(),
      status: SuggestionStatus.fromBackend(json['status']?.toString()),
      linkedItemId: (json['linkedItemId'] ?? '').toString(),
      rewardPointsGranted: (json['rewardPointsGranted'] ?? 0) as int,
      reviewReason: (json['reviewReason'] ?? '').toString(),
      createdAt: parseDate(json['createdAt']),
      reviewedAt: parseDate(json['reviewedAt']),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}