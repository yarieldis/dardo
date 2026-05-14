import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dardo/auth/jwt.dart';
import 'package:dardo/auth/user_store.dart';

final _jwt = JwtHelper();

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      body: {'error': 'Method not allowed'},
      statusCode: 405,
    );
  }

  final body = await context.request.body();
  Map<String, dynamic> data;
  try {
    data = jsonDecode(body) as Map<String, dynamic>;
  } on FormatException {
    return Response.json(
      body: {'error': 'Invalid JSON body'},
      statusCode: 400,
    );
  }

  final username = data['username'] as String?;
  final password = data['password'] as String?;
  if (username == null || password == null) {
    return Response.json(
      body: {'error': 'username and password are required'},
      statusCode: 400,
    );
  }

  final store = context.read<UserStore>();
  final claims = await store.validate(username, password);
  if (claims == null) {
    return Response.json(
      body: {'error': 'Invalid credentials'},
      statusCode: 401,
    );
  }

  final token = _jwt.sign(claims);
  return Response.json(body: {'token': token});
}
