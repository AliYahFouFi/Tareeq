class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String token;
  final bool is2FAEnabled;
  final String busId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
    required this.is2FAEnabled,
    this.busId = '', // Make busId optional with default empty string
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '0',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      token: json['token'] ?? '',
      busId: json['busId']?.toString() ?? '', // Handle null bus_id
      is2FAEnabled: json['is_2fa_enabled'] == 1,
    );
  }
}
