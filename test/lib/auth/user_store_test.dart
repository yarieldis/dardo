import 'package:dardo/auth/in_memory_user_store.dart';
import 'package:dardo/auth/password_hasher.dart';
import 'package:dardo/auth/user.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockPasswordHasher extends Mock implements PasswordHasher {}

void main() {
  late InMemoryUserStore store;
  late PasswordHasher hasher;

  final user = User(
    id: '1',
    username: 'alice',
    passwordHash: 'hashed',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    hasher = _MockPasswordHasher();
    store = InMemoryUserStore(passwordHasher: hasher);
  });

  group('createUser', () {
    test('stores a user and finds by username', () async {
      await store.createUser(user);
      final found = await store.findByUsername('alice');
      expect(found, isNotNull);
      expect(found!.username, equals('alice'));
    });
  });

  group('findByUsername', () {
    test('returns null for missing user', () async {
      final found = await store.findByUsername('nobody');
      expect(found, isNull);
    });
  });

  group('findById', () {
    test('finds by id', () async {
      await store.createUser(user);
      final found = await store.findById('1');
      expect(found, isNotNull);
      expect(found!.id, equals('1'));
    });

    test('returns null for missing id', () async {
      final found = await store.findById('nope');
      expect(found, isNull);
    });
  });

  group('findAll', () {
    test('returns all users', () async {
      await store.createUser(user);
      final user2 = User(
        id: '2',
        username: 'bob',
        passwordHash: 'hashed2',
        createdAt: DateTime(2026, 1, 2),
        updatedAt: DateTime(2026, 1, 2),
      );
      await store.createUser(user2);
      final all = await store.findAll();
      expect(all.length, equals(2));
    });
  });

  group('updateUser', () {
    test('updates an existing user', () async {
      await store.createUser(user);
      final updated = User(
        id: '1',
        username: 'alice_v2',
        passwordHash: 'hashed',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 6, 1),
      );
      await store.updateUser(updated);
      final found = await store.findById('1');
      expect(found!.username, equals('alice_v2'));
    });
  });

  group('deleteUser', () {
    test('deletes a user by id', () async {
      await store.createUser(user);
      await store.deleteUser('1');
      final found = await store.findById('1');
      expect(found, isNull);
    });
  });

  group('validate', () {
    test('returns AuthClaims for correct password', () async {
      when(() => hasher.verify('secret', 'hashed')).thenReturn(true);
      await store.createUser(user);
      final claims = await store.validate('alice', 'secret');
      expect(claims, isNotNull);
      expect(claims!.username, equals('alice'));
      expect(claims.userId, equals('1'));
    });

    test('returns null for wrong password', () async {
      when(() => hasher.verify('wrong', 'hashed')).thenReturn(false);
      await store.createUser(user);
      final claims = await store.validate('alice', 'wrong');
      expect(claims, isNull);
    });

    test('returns null for non-existent user', () async {
      final claims = await store.validate('nobody', 'secret');
      expect(claims, isNull);
    });
  });
}
