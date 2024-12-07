import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:tasklist_backend/hash_extension.dart';

/// In Memory Database
@visibleForTesting
Map<String, Session> sessionDb = {};

/// Session Class
class Session extends Equatable {
  /// - Documentation
  /// constructor
  const Session({
    required this.token,
    required this.userId,
    required this.createdAt,
    required this.expiryDate,
  });

  // String? id;
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
    final session = Session(
      token: generateToken(userId),
      userId: userId,
      expiryDate: DateTime.now().add(const Duration(hours: 24)),
      createdAt: DateTime.now(),
    );

    sessionDb[session.token] = session;
    return session;
  }

  /// Get a session by token
  String generateToken(String userId) {
    return '${userId}_${DateTime.now().toIso8601String()}'.hashValue;
  }

  /// Search a session of perticular token
  Session? sessionFromToken(String token) {
    final session = sessionDb[token];

    if (session != null && session.expiryDate.isAfter(DateTime.now())) {
      return session;
    } else {
      return null;
    }
  }
}
