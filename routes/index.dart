import 'package:dart_frog/dart_frog.dart';
import 'package:dardo/auth/claims.dart';

Response onRequest(RequestContext context) {
  final claims = context.read<AuthClaims>();
  return Response.json(
    body: {
      'message': 'Welcome to Dart Frog!',
      'user': claims.username,
    },
  );
}
