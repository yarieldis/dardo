import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dardo/auth/claims.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('GET /', () {
    test('responds with a 200 and a welcome JSON body.', () {
      final context = _MockRequestContext();
      when(() => context.read<AuthClaims>()).thenReturn(
        const AuthClaims(userId: 'admin', username: 'admin'),
      );

      final response = route.onRequest(context);
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(
        response.body(),
        completion(
          equals(jsonEncode({
            'message': 'Welcome to Dart Frog!',
            'user': 'admin',
          })),
        ),
      );
    });
  });
}
