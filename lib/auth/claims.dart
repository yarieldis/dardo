import 'package:dart_frog/dart_frog.dart';

/// Authenticated user claims injected into [RequestContext] by auth middleware.
class AuthClaims {
  const AuthClaims({
    required this.userId,
    required this.username,
  });

  final String userId;
  final String username;
}
