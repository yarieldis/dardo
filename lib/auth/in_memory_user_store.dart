import 'package:dardo/auth/claims.dart';
import 'package:dardo/auth/password_hasher.dart';
import 'package:dardo/auth/user.dart';
import 'package:dardo/auth/user_store.dart';

class InMemoryUserStore implements UserStore {
  InMemoryUserStore({PasswordHasher? passwordHasher})
      : _passwordHasher = passwordHasher ?? BcryptPasswordHasher();

  final PasswordHasher _passwordHasher;
  final _users = <String, User>{};

  @override
  Future<User?> findByUsername(String username) async => _users[username];

  @override
  Future<User?> findById(String id) async {
    for (final user in _users.values) {
      if (user.id == id) return user;
    }
    return null;
  }

  @override
  Future<List<User>> findAll() async => _users.values.toList();

  @override
  Future<void> createUser(User user) async {
    _users[user.username] = user;
  }

  @override
  Future<void> updateUser(User user) async {
    _users.removeWhere((_, u) => u.id == user.id);
    _users[user.username] = user;
  }

  @override
  Future<void> deleteUser(String id) async {
    _users.removeWhere((_, user) => user.id == id);
  }

  @override
  Future<AuthClaims?> validate(String username, String password) async {
    final user = _users[username];
    if (user == null) return null;
    if (!_passwordHasher.verify(password, user.passwordHash)) return null;
    return AuthClaims(userId: user.id, username: user.username);
  }
}
