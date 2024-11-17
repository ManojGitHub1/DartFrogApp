import 'package:dart_frog/dart_frog.dart';

// Outside Handler are private variable
String? greeting; // using as temporary cache

Handler middleware(Handler handler) {
  greeting = 'Hi';
  return handler.use(provider<String>((context) => greeting ??= 'Hello'));
}
