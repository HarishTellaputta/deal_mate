class LoginResponse {
  final String token;
  final int userId;
  final String name;
  final String mobile;
  final String role;
  final int? businessId;

  LoginResponse({
    required this.token,
    required this.userId,
    required this.name,
    required this.mobile,
    required this.role,
    this.businessId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      userId: json['userId'] ?? 0,
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      role: json['role'] ?? '',
      businessId: json['businessId'],
    );
  }
}