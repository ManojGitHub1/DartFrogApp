import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Handler middleware(Handler handler) {
  return (context) async {
    // Create a PostgreSQL connection instance
    final conn = await Connection.open(
      Endpoint(
        host: 'localhost',
        port: 5431,
        database: 'mytasklists',
        username: 'postgres',
        password: 'ManojDockerPostgres',
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );

    final response =
        await handler.use(provider<Connection>((_) => conn)).call(context);

    await conn.close();

    return response;
  };
}
