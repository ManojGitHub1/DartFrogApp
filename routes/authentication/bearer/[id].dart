import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:intl/intl.dart';
import 'package:tasklist_backend/repository/session/session_repository.dart';
import 'package:tasklist_backend/repository/user/user_repository.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  return switch (context.request.method) {
    HttpMethod.get => _getUser(context, id),
    HttpMethod.patch => _updateUser(context, id),
    HttpMethod.delete => _deleteUser(context, id),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getUser(RequestContext context, String id) async {
  final sessionRepo = context.read<SessionRepository>();
  final userRepo = context.read<UserRepository>();
  final authHeader = context.request.headers['authorization'];

  // Step 1: Validate Authorization header
  if (authHeader == null) {
    return Response(
      statusCode: HttpStatus.unauthorized,
      body: 'Missing Authorization header',
    );
  }

  final token = getBearerToken({'authorization': authHeader});
  if (token == null) {
    return Response(
      statusCode: HttpStatus.unauthorized,
      body: 'Invalid Authorization header',
    );
  }

  print('Token extracted: $token');

  // Step 2: Retrieve and validate the session using the SessionRepository method
  final session = sessionRepo.getSessionFromHeader(authHeader);
  if (session == null) {
    print('Session not found or expired for token: $token');
    return Response(
      statusCode: HttpStatus.unauthorized,
      body: 'Invalid or expired session',
    );
  }

  print('Session found: ${session.token}, Expiry: ${session.expiryDate}');

  // Step 3: Retrieve the user using the UserRepository method
  final user = await userRepo.userFromId(id);
  if (user == null) {
    return Response(
      statusCode: HttpStatus.notFound,
      body: 'User not found',
    );
  }

  // Step 4: Validate user access
  if (user.id != session.userId) {
    return Response(
      statusCode: HttpStatus.forbidden,
      body: 'Access denied',
    );
  }

  // Step 5: Return user information
  return Response.json(
    body: {
      'id': user.id,
      'name': user.name,
      'username': user.username,
      'sessionToken': session.token,
      'sessionCreatedAt': _formatDateTime(session.createdAt),
      'sessionExpiryDate': _formatDateTime(session.expiryDate),
    },
  );
}

/// Helper function to extract Bearer token
String? getBearerToken(Map<String, String> headers) {
  final authorizationHeader = headers['authorization'];
  if (authorizationHeader == null ||
      !authorizationHeader.startsWith('Bearer ')) {
    return null; // Invalid or missing Authorization header
  }
  return authorizationHeader.substring(7); // Extract the token after 'Bearer '
}

// Helper function to format DateTime to the desired format (yyyy-MM-dd hh:mm:ss)
String _formatDateTime(DateTime dateTime) {
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  return dateFormat.format(dateTime); // Example: "2025-01-14 23:34:29"
}

Future<Response> _updateUser(RequestContext context, String id) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final name = body['name'] as String?;
  final username = body['username'] as String?;
  final password = body['password'] as String?;

  final userRepository = context.read<UserRepository>();

  if (name != null || username != null || password != null) {
    await userRepository.updateUser(
      id: id,
      name: name,
      username: username,
      password: password,
    );
    return Response(statusCode: HttpStatus.ok);
  } else {
    return Response(statusCode: HttpStatus.badRequest);
  }
}

Future<Response> _deleteUser(RequestContext context, String id) async {
  final user = await context.read<UserRepository>().userFromId(id);
  if (user == null) {
    return Response(statusCode: HttpStatus.notFound);
  } else {
    if (user.id != id) {
      return Response(statusCode: HttpStatus.forbidden);
    }
    await context.read<UserRepository>().deleteUser(id);

    return Response(statusCode: HttpStatus.noContent);
  }
}
