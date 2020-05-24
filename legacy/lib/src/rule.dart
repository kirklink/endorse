import 'dart:async';
import 'package:endorse/src/validation_error.dart';

typedef Future<ValidationError> Rule(dynamic value);
typedef Future<List<ValidationError>> ListRule(dynamic value);

typedef Rule SimpleRule({String msg, Map<String, dynamic> map});
typedef Rule NumRule(num number, {String msg, Map<String, dynamic> map});
typedef Rule IntRule(int number, {String msg, Map<String, dynamic> map});
typedef Rule FloatRule(double number, {String msg, Map<String, dynamic> map});
typedef Rule StringRule(String string, {String msg, Map<String, dynamic> map});
typedef Rule DynamicRule(dynamic d, {String msg, Map<String, dynamic> map});
