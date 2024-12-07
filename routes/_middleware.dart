import 'package:dart_frog/dart_frog.dart';
import 'package:tasklist_backend/repository/items/item_repository.dart';
import 'package:tasklist_backend/repository/lists/list_repository.dart';

// handler - handles request and returns handler
Handler middleware(Handler handler) {
  // we have other predefined middlewares and these are injucted in use method
  // return handler.use(requestLogger()).use(authentication()).use(callsFunction());

  // requestLogger() - Is a defined middleware which prints
  // the time of request, request method, response status code and request folder(/items) from (localhost:8080/items)

  // authentication() - Is a defined middleware which checks if the user is authenticated or not

  // provider - dependency middleware a type of middleware
  // accepts request context (here String) and returns a response context to a root handler
  // In root handler context.read<String>();
  // Therefore, we can use provider middleware to inject a value into the request context
  // this is depentency injection
  return handler
      .use(requestLogger())
      .use(provider<TaskListRepository>((context) => TaskListRepository()))
      .use(provider<TaskItemRepository>((context) => TaskItemRepository()));
}
