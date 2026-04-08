/// Model representing one user returned by backend.
class UserModel {
  final String id;
  final String name;
  final String publicUsername;
  final String email;
  final String phoneNumber;
  final String profileImageUrl;
  final String bio;
  final int totalReviewsGiven;
  final List<String> citiesVisited;
  final int citiesVisitedCount;

  UserModel({
    required this.id,
    required this.name,
    required this.publicUsername,
    required this.email,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.bio,
    required this.totalReviewsGiven,
    required this.citiesVisited,
    required this.citiesVisitedCount,
  });

  /// Creates model from backend JSON response.
  factory UserModel.fromJson(Map json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      publicUsername: (json['publicUsername'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      profileImageUrl: (json['profileImageUrl'] ?? '').toString(),
      bio: (json['bio'] ?? '').toString(),
      totalReviewsGiven: json['totalReviewsGiven'] ?? 0,
      citiesVisited: (json['citiesVisited'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      citiesVisitedCount: json['citiesVisitedCount'] ?? 0,
    );
  }
}