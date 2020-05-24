import 'package:arrow/arrow.dart';
import 'package:arrow/middleware.dart';

import 'handlers.dart';

Router router() {

  final Handler notFoundHandler = (req) async {
    var res = req.response;
    res.messenger.addError('Not found!');
    res.send.notFound();
    return res;
  };

  final cors = Cors(
    allowedOrigins: const ['http://localhost:4200'],
    allowedHeaders: const ['Origin', 'Accept', 'Content-Type', 'Authorization'],
    allowedMethods: ['GET', 'POST', 'PUT', 'DELETE']
  );

  Router r = Router()
    ..NOT_FOUND(notFoundHandler)
    ..RECOVER()
    ..useSerial(pre: loggerIn(), post: loggerOut(messages: true), useAlways: true)
    ..useSerial(pre: enforceJsonContentType)
    ..useSerial(pre: readJsonContent)
    ..POST('/echo', echo);

  return r;
}