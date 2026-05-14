import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dardo/auth/user.dart';
import 'package:dardo/auth/user_store.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final store = context.read<UserStore>();

  switch (context.request.method) {
    case HttpMethod.get:
      final user = await store.findById(id);
      if (user == null) {
        return Response.json(
          body: {'error': 'User not found'},
          statusCode: 404,
        );
      }
      return Response.json(body: user.toJson());

    case HttpMethod.put:
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

      final user = await store.findById(id);
      if (user == null) {
        return Response.json(
          body: {'error': 'User not found'},
          statusCode: 404,
        );
      }

      final updated = User(
        id: user.id,
        username: data['username'] as String? ?? user.username,
        email: data['email'] as String? ?? user.email,
        passwordHash: user.passwordHash,
        role: data['role'] as String? ?? user.role,
        createdAt: user.createdAt,
        updatedAt: DateTime.now(),
      );

      await store.updateUser(updated);
      return Response.json(body: updated.toJson());

    case HttpMethod.delete:
      final user = await store.findById(id);
      if (user == null) {
        return Response.json(
          body: {'error': 'User not found'},
          statusCode: 404,
        );
      }
      await store.deleteUser(id);
      return Response.json(body: {'message': 'User deleted'});

    case _:
      return Response.json(
        body: {'error': 'Method not allowed'},
        statusCode: 405,
      );
  }
}
