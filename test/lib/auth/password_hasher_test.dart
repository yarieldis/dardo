import 'package:dardo/auth/password_hasher.dart';
import 'package:test/test.dart';

void main() {
  final hasher = BcryptPasswordHasher();

  group('BcryptPasswordHasher', () {
    test('hash produces a non-empty string', () {
      final hash = hasher.hash('password123');
      expect(hash, isNotEmpty);
    });

    test('verify returns true for the correct password', () {
      final hash = hasher.hash('password123');
      expect(hasher.verify('password123', hash), isTrue);
    });

    test('verify returns false for an incorrect password', () {
      final hash = hasher.hash('password123');
      expect(hasher.verify('wrongpassword', hash), isFalse);
    });

    test('same password produces different hashes', () {
      final hash1 = hasher.hash('password123');
      final hash2 = hasher.hash('password123');
      expect(hash1, isNot(equals(hash2)));
    });
  });
}
