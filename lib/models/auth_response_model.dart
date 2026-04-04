/// Model representing auth response returned by backend.
class AuthResponseModel {
  final String token;
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;

  const AuthResponseModel({
    required this.token,
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: (json['token'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
    );
  }
}