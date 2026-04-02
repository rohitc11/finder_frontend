/// Model representing one review returned by backend.
///
/// Used in:
/// - item detail recent reviews section
/// - future user review history
class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String targetType;
  final String targetId;
  final String targetName;
  final String restaurantId;
  final String restaurantName;
  final int rating;
  final String comment;
  final String status;
  final bool isEdited;
  final String createdAt;
  final String updatedAt;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.targetType,
    required this.targetId,
    required this.targetName,
    required this.restaurantId,
    required this.restaurantName,
    required this.rating,
    required this.comment,
    required this.status,
    required this.isEdited,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
      targetType: (json['targetType'] ?? '').toString(),
      targetId: (json['targetId'] ?? '').toString(),
      targetName: (json['targetName'] ?? '').toString(),
      restaurantId: (json['restaurantId'] ?? '').toString(),
      restaurantName: (json['restaurantName'] ?? '').toString(),
      rating: (json['rating'] ?? 0) as int,
      comment: (json['comment'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      isEdited: (json['isEdited'] ?? false) as bool,
      createdAt: (json['createdAt'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? '').toString(),
    );
  }
}