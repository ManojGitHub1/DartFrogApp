import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:tasklist_backend/repository/user/user_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _createUser(context),
    _ => Future.value(Response(statusCode: HttpStatus.notImplemented)),
  };
}

Future<Response> _createUser(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final name = body['name'] as String?;
  final username = body['username'] as String?;
  final password = body['password'] as String?;

  // Inject the UserRepository
  final userRepository = context.read<UserRepository>();

  if (name != null && username != null && password != null) {
    final id = await userRepository.createUser(
      name: name,
      username: username,
      password: password,
    );

    return Response.json(body: {'id': id});
  } else {
    return Response(statusCode: HttpStatus.badRequest);
  }
}
