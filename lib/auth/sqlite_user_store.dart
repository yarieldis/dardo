import 'package:dardo/auth/claims.dart';
import 'package:dardo/auth/password_hasher.dart';
import 'package:dardo/auth/user.dart';
import 'package:dardo/auth/user_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqliteUserStore implements UserStore {
  SqliteUserStore(this._db, {PasswordHasher? passwordHasher})
      : _passwordHasher = passwordHasher ?? BcryptPasswordHasher();

  final Database _db;
  final PasswordHasher _passwordHasher;

  @override
  Future<User?> findByUsername(String username) async {
    final results = await _db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return _rowToUser(results.first);
  }

  @override
  Future<User?> findById(String id) async {
    final results = await _db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return _rowToUser(results.first);
  }

  @override
  Future<List<User>> findAll() async {
    final results = await _db.query('users');
    return results.map(_rowToUser).toList();
  }

  @override
  Future<void> createUser(User user) async {
    await _db.insert('users', {
      'id': user.id,
      'username': user.username,
      'email': user.email,
      'password_hash': user.passwordHash,
      'role': user.role,
      'created_at': user.createdAt.toIso8601String(),
      'updated_at': user.updatedAt.toIso8601String(),
    });
  }

  @override
  Future<void> updateUser(User user) async {
    await _db.update(
      'users',
      {
        'username': user.username,
        'email': user.email,
        'password_hash': user.passwordHash,
        'role': user.role,
        'updated_at': user.updatedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  @override
  Future<void> deleteUser(String id) async {
    await _db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<AuthClaims?> validate(String username, String password) async {
    final user = await findByUsername(username);
    if (user == null) return null;
    if (!_passwordHasher.verify(password, user.passwordHash)) return null;
    return AuthClaims(userId: user.id, username: user.username);
  }

  User _rowToUser(Map<String, dynamic> row) {
    return User(
      id: row['id'] as String,
      username: row['username'] as String,
      passwordHash: row['password_hash'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      email: row['email'] as String?,
      role: row['role'] as String? ?? 'user',
    );
  }
}
