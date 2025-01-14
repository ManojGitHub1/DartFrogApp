import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:tasklist_backend/repository/user/user_repository.dart';

final userRepository = UserRepository();

Handler middleware(Handler handler) {
  return handler
      .use(
        basicAuthentication<User>(
          authenticator: (context, username, password) {
            final repository = context.read<UserRepository>();
            return repository.userFromCredentials(username, password);
          },
          // Make sure that all necessary endpoints require authentication
          // except the ones explicitly exempted (like POST).
          applies: (RequestContext context) async =>
              context.request.method != HttpMethod.post,
        ),
      )
      .use(provider<UserRepository>((_) => userRepository));
}
