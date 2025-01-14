import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:tasklist_backend/hash_extension.dart';

/// In-Memory Database for Sessions
@visibleForTesting
final Map<String, Session> sessionDb = {};

/// Session Class
class Session extends Equatable {
  /// Constructor
  const Session({
    required this.token,
    required this.userId,
    required this.createdAt,
    required this.expiryDate,
  });

  /// Session token
  final String token;

  /// User's ID
  final String userId;

  /// Session creation date
  final DateTime createdAt;

  /// Session expiry date
  final DateTime expiryDate;
  // String? refreshToken;
  // String? expiresAt;
  // String? createdAt;
  // String? updatedAt;
  // String? status;
  // String? lastLoginAt;
  // String? lastLogoutAt;

  @override
  List<Object?> get props => [token, userId, createdAt, expiryDate];
}

/// Session Repository
class SessionRepository {
  /// Create a new session
  Session createSession(String userId) {
    final String token = generateToken(userId);
    final Session session = Session(
      token: token,
      userId: userId,
      createdAt: DateTime.now(),
      expiryDate: DateTime.now().add(const Duration(hours: 1)),
    );

    sessionDb[token] = session;
    return session;
  }

  /// Generate a unique token for the session
  String generateToken(String userId) {
    return '${userId}_${DateTime.now().toIso8601String()}'.hashValue;
  }

  /// Retrieve a session using the Authorization Bearer token
  Session? getSessionFromHeader(String authorizationHeader) {
    final String? token = extractBearerToken(authorizationHeader);
    if (token == null) {
      return null; // Invalid or missing token
    }
    return _getSession(token);
  }

  /// Helper function to extract Bearer token from Authorization header
  String? extractBearerToken(String authorizationHeader) {
    if (!authorizationHeader.startsWith('Bearer ')) {
      return null; // Invalid Authorization header format
    }
    return authorizationHeader.substring(7); // Extract token after 'Bearer '
  }

  /// Get a session by token
  Session? _getSession(String token) {
    final Session? session = sessionDb[token];

    if (session == null) {
      return null; // No session found for token
    }

    if (session.expiryDate.isBefore(DateTime.now())) {
      sessionDb.remove(token); // Remove expired session
      return null; // Session expired
    }

    return session; // Valid session
  }

  /// Validate if a session is valid based on the token
  bool isValidSession(String token) {
    final Session? session = _getSession(token);
    return session != null;
  }
}
