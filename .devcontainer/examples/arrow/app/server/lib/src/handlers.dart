import 'dart:async';

import 'package:keychain/keychain.dart';

import 'package:arrow/arrow.dart';


Future<Response> echo(Request req) async {
  // print(json.encode(req.content.map));
  final res = req.response;

  
  return res.send.ok(req.content.map);
}
