import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:uuid/uuid.dart';
import 'package:dardo/auth/password_hasher.dart';
import 'package:dardo/auth/user.dart';
import 'package:dardo/auth/user_store.dart';

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
  final email = data['email'] as String?;

  if (username == null || password == null) {
    return Response.json(
      body: {'error': 'username and password are required'},
      statusCode: 400,
    );
  }

  if (username.length < 3 || username.length > 50) {
    return Response.json(
      body: {'error': 'username must be between 3 and 50 characters'},
      statusCode: 400,
    );
  }

  if (password.length < 6) {
    return Response.json(
      body: {'error': 'password must be at least 6 characters'},
      statusCode: 400,
    );
  }

  final store = context.read<UserStore>();
  final hasher = context.read<PasswordHasher>();

  final existing = await store.findByUsername(username);
  if (existing != null) {
    return Response.json(
      body: {'error': 'username already taken'},
      statusCode: 409,
    );
  }

  final now = DateTime.now();
  final user = User(
    id: const Uuid().v4(),
    username: username,
    email: email,
    passwordHash: hasher.hash(password),
    createdAt: now,
    updatedAt: now,
  );

  await store.createUser(user);
  return Response.json(body: user.toJson(), statusCode: 201);
}
