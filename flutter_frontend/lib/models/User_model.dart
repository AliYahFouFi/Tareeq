class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String token;
  final bool is2FAEnabled;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
    required this.is2FAEnabled,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '0', // Default to 0 if null
      name: json['name'] ?? 'Unknown', // Default to 'Unknown' if null
      email: json['email'] ?? '', // Default to empty string if null
      role: json['role'] ?? 'user', // Default to 'Unknown' if null
      token: json['token'] ?? '',
      is2FAEnabled: json['is_2fa_enabled'] == 1,
    );
  }
}
