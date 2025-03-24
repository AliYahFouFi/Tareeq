class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '0', // Default to 0 if null
      name: json['name'] ?? 'Unknown', // Default to 'Unknown' if null
      email: json['email'] ?? '', // Default to empty string if null
      role: json['role'] ?? 'user', // Default to 'Unknown' if null
      token: json['token'] ?? '',
    );
  }
}
