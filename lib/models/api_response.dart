class ApiResponse {
  final bool status;
  final String message;
  final String? token;
  final User? user;

  ApiResponse({
    required this.status,
    required this.message,
    this.token,
    this.user,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class User {
  final int pk;
  final String email;
  final String name;

  User({
    required this.pk,
    required this.email,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      pk: json['pk'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
