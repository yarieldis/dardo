import 'package:dardo/auth/claims.dart';
import 'package:dardo/auth/user.dart';

abstract class UserStore {
  Future<User?> findByUsername(String username);
  Future<User?> findById(String id);
  Future<List<User>> findAll();
  Future<void> createUser(User user);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String id);
  Future<AuthClaims?> validate(String username, String password);
}
