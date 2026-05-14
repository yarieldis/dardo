import 'dart:convert';
import 'dart:io';

import 'package:dardo/auth/claims.dart';
import 'package:dardo/auth/user_store.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/auth/login.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}
class _MockUserStore extends Mock implements UserStore {}
class _MockRequest extends Mock implements Request {}

void main() {
  late _MockRequestContext context;
  late _MockUserStore store;
  late _MockRequest request;

  setUp(() {
    context = _MockRequestContext();
    store = _MockUserStore();
    request = _MockRequest();
    when(() => context.read<UserStore>()).thenReturn(store);
    when(() => context.request).thenReturn(request);
  });

  Future<Response> call() => route.onRequest(context);

  group('POST /auth/login', () {
    test('returns 200 with token for valid credentials', () async {
      when(() => request.method).thenReturn(HttpMethod.post);
      when(() => request.body())
          .thenAnswer((_) async => '{"username":"alice","password":"secret"}');
      when(() => store.validate('alice', 'secret')).thenAnswer(
        (_) async => const AuthClaims(userId: '1', username: 'alice'),
      );

      final response = await call();
      expect(response.statusCode, equals(HttpStatus.ok));
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;
      expect(body, contains('token'));
    });

    test('returns 401 for invalid credentials', () async {
      when(() => request.method).thenReturn(HttpMethod.post);
      when(() => request.body())
          .thenAnswer((_) async => '{"username":"alice","password":"wrong"}');
      when(() => store.validate('alice', 'wrong'))
          .thenAnswer((_) async => null);

      final response = await call();
      expect(response.statusCode, equals(HttpStatus.unauthorized));
    });

    test('returns 400 for missing fields', () async {
      when(() => request.method).thenReturn(HttpMethod.post);
      when(() => request.body())
          .thenAnswer((_) async => '{"username":"alice"}');

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
