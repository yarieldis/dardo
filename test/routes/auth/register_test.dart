import 'dart:convert';
import 'dart:io';

import 'package:dardo/auth/password_hasher.dart';
import 'package:dardo/auth/user.dart';
import 'package:dardo/auth/user_store.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/auth/register.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}
class _MockUserStore extends Mock implements UserStore {}
class _MockPasswordHasher extends Mock implements PasswordHasher {}
class _MockRequest extends Mock implements Request {}
class _FakeUser extends Fake implements User {}

void main() {
  late _MockRequestContext context;
  late _MockUserStore store;
  late _MockPasswordHasher hasher;
  late _MockRequest request;

  setUpAll(() {
    registerFallbackValue(_FakeUser());
  });

  setUp(() {
    context = _MockRequestContext();
    store = _MockUserStore();
    hasher = _MockPasswordHasher();
    request = _MockRequest();
    when(() => context.read<UserStore>()).thenReturn(store);
    when(() => context.read<PasswordHasher>()).thenReturn(hasher);
    when(() => context.request).thenReturn(request);
  });

  Future<Response> call() => route.onRequest(context);

  group('POST /auth/register', () {
    test('returns 201 with user JSON on success', () async {
      when(() => request.method).thenReturn(HttpMethod.post);
      when(() => request.body()).thenAnswer(
        (_) async => '{"username":"alice","password":"secret123"}',
      );
      when(() => store.findByUsername('alice'))
          .thenAnswer((_) async => null);
      when(() => hasher.hash('secret123')).thenReturn('hashed');
      when(() => store.createUser(any())).thenAnswer((_) async {});

      final response = await call();
      expect(response.statusCode, equals(HttpStatus.created));
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;
      expect(body['username'], equals('alice'));
      expect(body, isNot(contains('passwordHash')));
    });

    test('returns 409 for duplicate username', () async {
      when(() => request.method).thenReturn(HttpMethod.post);
      when(() => request.body()).thenAnswer(
        (_) async => '{"username":"alice","password":"secret123"}',
      );
      when(() => store.findByUsername('alice')).thenAnswer(
        (_) async => User(
          id: 'existing',
          username: 'alice',
          passwordHash: 'x',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final response = await call();
      expect(response.statusCode, equals(HttpStatus.conflict));
    });

    test('returns 400 for missing username', () async {
      when(() => request.method).thenReturn(HttpMethod.post);
      when(() => request.body())
          .thenAnswer((_) async => '{"password":"secret123"}');

      final response = await call();
      expect(response.statusCode, equals(HttpStatus.badRequest));
    });

    test('returns 400 for missing password', () async {
      when(() => request.method).thenReturn(HttpMethod.post);
      when(() => request.body())
          .thenAnswer((_) async => '{"username":"alice"}');

      final response = await call();
      expect(response.statusCode, equals(HttpStatus.badRequest));
    });

    test('returns 400 for short username', () async {
      when(() => request.method).thenReturn(HttpMethod.post);
      when(() => request.body())
          .thenAnswer((_) async => '{"username":"ab","password":"secret123"}');

      final response = await call();
      expect(response.statusCode, equals(HttpStatus.badRequest));
    });

    test('returns 400 for short password', () async {
      when(() => request.method).thenReturn(HttpMethod.post);
      when(() => request.body())
          .thenAnswer((_) async => '{"username":"alice","password":"12345"}');

      final response = await call();
      expect(response.statusCode, equals(HttpStatus.badRequest));
    });

    test('returns 400 for invalid JSON', () async {
      when(() => request.method).thenReturn(HttpMethod.post);
      when(() => request.body()).thenAnswer((_) async => 'not json');

      final response = await call();
      expect(response.statusCode, equals(HttpStatus.badRequest));
    });

    test('returns 405 for non-POST method', () async {
      when(() => request.method).thenReturn(HttpMethod.get);

      final response = await call();
      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });
  });
}
