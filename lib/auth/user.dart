class User {
  const User({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.createdAt,
    required this.updatedAt,
    this.email,
    this.role = 'user',
  });

  final String id;
  final String username;
  final String? email;
  final String passwordHash;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        if (email != null) 'email': email,
        'role': role,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
