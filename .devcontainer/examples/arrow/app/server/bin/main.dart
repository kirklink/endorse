import 'dart:async';

import 'package:arrow/arrow.dart';

import 'package:arrow_server/src/router_config.dart';



Future main() async {

  Arrow arrow = Arrow();

  await arrow.run(router(), port: 8080, printRoutes: true);

}