import 'package:dart_frog/dart_frog.dart';
import 'package:dardo/auth/user_store.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response.json(
      body: {'error': 'Method not allowed'},
      statusCode: 405,
    );
  }

  final store = context.read<UserStore>();
  final users = await store.findAll();
  return Response.json(body: users.map((u) => u.toJson()).toList());
}
