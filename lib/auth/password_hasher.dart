import 'package:bcrypt/bcrypt.dart';

abstract class PasswordHasher {
  String hash(String password);
  bool verify(String password, String hash);
}

class BcryptPasswordHasher implements PasswordHasher {
  @override
  String hash(String password) => BCrypt.hashpw(password, BCrypt.gensalt());

  @override
  bool verify(String password, String hash) =>
      BCrypt.checkpw(password, hash);
}
