import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Handler middleware(Handler handler) {
  return (context) async {
    final db = await Db.create(
      'mongodb+srv://ManojAtlas123:ManojAtlas123@manojatlascluster1.wt9sl.mongodb.net/TaskListDartFrog?retryWrites=true&w=majority&appName=ManojAtlasCluster1',
    );

    if (!db.isConnected) {
      await db.open();
    }

    final response = await handler.use(provider<Db>((_) => db)).call(context);

    await db.close();

    return response;
  };
}
