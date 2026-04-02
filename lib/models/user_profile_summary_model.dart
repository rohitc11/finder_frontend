class UserProfileSummaryModel {
  final String userId;
  final String name;
  final int rewardPoints;
  final int approvedContributions;
  final int pendingContributions;
  final int rejectedContributions;

  const UserProfileSummaryModel({
    required this.userId,
    required this.name,
    required this.rewardPoints,
    required this.approvedContributions,
    required this.pendingContributions,
    required this.rejectedContributions,
  });

  int get totalContributions =>
      approvedContributions + pendingContributions + rejectedContributions;

  factory UserProfileSummaryModel.fromJson(Map<String, dynamic> json) {
    return UserProfileSummaryModel(
      userId: (json['userId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      rewardPoints: (json['rewardPoints'] ?? 0) as int,
      approvedContributions: (json['approvedContributions'] ?? 0) as int,
      pendingContributions: (json['pendingContributions'] ?? 0) as int,
      rejectedContributions: (json['rejectedContributions'] ?? 0) as int,
    );
  }
}