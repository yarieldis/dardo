import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'package:dardo/auth/claims.dart';

class JwtHelper {
  JwtHelper({String? secret})
      : _secret = secret ?? Platform.environment['JWT_SECRET'] ?? 'dev-secret';

  final String _secret;

  String sign(AuthClaims claims) {
    final jwt = JWT({
      'sub': claims.userId,
      'username': claims.username,
    });
    return jwt.sign(SecretKey(_secret), expiresIn: const Duration(hours: 24));
  }

  AuthClaims? verify(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secret));
      return AuthClaims(
        userId: jwt.payload['sub'] as String,
        username: jwt.payload['username'] as String,
      );
    } on JWTException {
      return null;
    }
  }
}
