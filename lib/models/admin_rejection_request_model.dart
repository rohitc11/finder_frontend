class AdminRejectionRequestModel {
  final String rejectionReason;

  const AdminRejectionRequestModel({
    required this.rejectionReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'rejectionReason': rejectionReason,
    };
  }
}