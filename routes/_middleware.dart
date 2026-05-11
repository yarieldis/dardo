import 'package:dart_frog/dart_frog.dart';
import 'package:dardo/auth/claims.dart';
import 'package:dardo/auth/jwt.dart';

final _jwt = JwtHelper();

Handler middleware(Handler handler) {
  return (context) async {
    // Allow unauthenticated access to auth endpoints.
    if (context.request.uri.path.startsWith('/auth/')) {
      return handler(context);
    }

    final authHeader = context.request.headers['Authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response.json(
        body: {'error': 'Missing or malformed Authorization header'},
        statusCode: 401,
      );
    }

    final token = authHeader.substring(7);
    final claims = _jwt.verify(token);
    if (claims == null) {
      return Response.json(
        body: {'error': 'Invalid or expired token'},
        statusCode: 401,
      );
    }

    return handler(context.provide<AuthClaims>(() => claims));
  };
}
