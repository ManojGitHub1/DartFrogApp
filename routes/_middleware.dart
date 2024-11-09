import 'package:dart_frog/dart_frog.dart';

// calls function middleware
// handler - handles request and returns handler
Handler middleware(Handler handler) {
  // we have other predefined middlewares and these are injucted in use method
  // return handler.use(requestLogger()).use(authentication()).use(callsFunction());

  // requestLogger() - Is a defined middleware which prints
  // the time of request, request method, response status code and request folder(/items) from (localhost:8080/items)
  // provider - dependency middleware a type of middleware
  // accepts request context (here String) and returns a response context to a root handler
  // In root handler context.read<String>();
  // Therefore, we can use provider middleware to inject a value into the request context
  // this is depentency injection
  return handler
      .use(requestLogger())
      .use(provider<String>((context) => 'Dart Frog'));
}
