import 'package:dart_frog/dart_frog.dart';
import 'package:redis/redis.dart';

// Outside Handler are private variable
// String? greeting; // using as temporary cache

final conn = RedisConnection();

Handler middleware(Handler handler) {
  // greeting = 'Hi';
  // return handler.use(provider<String>((context) => greeting ??= 'Hello'));

  return (context) async {
    Response response;

    // host port:8091 and redis port: 6379
    try {
      final command = await conn.connect('localhost', 8091);

      try {
        await command.send_object(
          ['AUTH', 'default', 'Manojredis123'],
        );

        response =
            await handler.use(provider<Command>((_) => command)).call(context);
      } catch (e) {
        response = Response.json(
          body: {'success': false, 'message': e.toString()},
        );
      }
    } catch (e) {
      response = Response.json(
        body: {'success': false, 'message': 'Failed to connect to Redis'},
      );
    }

    return response;
  };
}
