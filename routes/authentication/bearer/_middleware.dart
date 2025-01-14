import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:tasklist_backend/repository/session/session_repository.dart';
import 'package:tasklist_backend/repository/user/user_repository.dart';

/// Define repositories as global instances
final userRepository = UserRepository();
final sessionRepository = SessionRepository();

/// Middleware function to add session and user authentication
Handler middleware(Handler handler) {
  return handler
      .use(
        bearerAuthentication<User>(
          // Use bearer token authentication
          /// Authenticator function to validate session and retrieve user
          authenticator: (context, sessionToken) async {
            final sessionRepo = context.read<SessionRepository>();
            final userRepo = context.read<UserRepository>();

            // Retrieve session from token using the session repository
            final session = sessionRepo.getSessionFromHeader(sessionToken);

            if (session != null) {
              final user = userRepo.userFromId(session.userId);
              return user; // Return user if session is valid
            }

            return null; // Return null if session is invalid or expired
          },

          /// Apply middleware for all HTTP methods except POST and GET
          applies: (RequestContext context) async => ![
            HttpMethod.post,
            HttpMethod.get
          ].contains(context.request.method),
        ),
      )
      // Provide UserRepository to the context
      .use(provider<UserRepository>((_) => userRepository))

      // Provide SessionRepository to the context
      .use(provider<SessionRepository>((_) => sessionRepository));
}
