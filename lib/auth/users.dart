import 'package:dardo/auth/claims.dart';

/// In-memory user store — replace with a database-backed implementation
/// when ready.
class UserStore {
  // username → hashed password
  final _users = <String, String>{
    'admin': 'admin123', // TODO(username): hash with bcrypt
  };

  AuthClaims? validate(String username, String password) {
    final stored = _users[username];
    if (stored == null || stored != password) return null;
    return AuthClaims(userId: username, username: username);
  }
}
