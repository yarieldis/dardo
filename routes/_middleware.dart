import 'package:dart_frog/dart_frog.dart';
import 'package:dardo/auth/claims.dart';
import 'package:dardo/auth/in_memory_user_store.dart';
import 'package:dardo/auth/jwt.dart';
import 'package:dardo/auth/password_hasher.dart';
import 'package:dardo/auth/user_store.dart';

final _jwt = JwtHelper();
final _passwordHasher = BcryptPasswordHasher();
final _userStore = InMemoryUserStore(passwordHasher: _passwordHasher);

Handler middleware(Handler handler) {
  return handler
      .use(provider<UserStore>((_) => _userStore))
      .use(provider<PasswordHasher>((_) => _passwordHasher))
      .use((handler) {
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
  });
}
