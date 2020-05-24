import 'dart:async';

import 'package:endorse/src/validation_error.dart';
import 'package:endorse/src/rule_set.dart';

class Value {
  bool _valid;

  get isValid => _valid;

  dynamic _value;

  get value => _value;

  bool _validated = false;

  get isValidated => _validated;

  List<ValidationError> _errors = List<ValidationError>();

  Value(this._value);

  dynamic _cast(dynamic value, bool castToNum) {
    if (castToNum != true) return value;
    if (castToNum == true && value is String) {
      return num.tryParse(value);
    } else if (castToNum == true && value is num) {
      return null;
    }
    return null;
  }

  Future<List<ValidationError>> _processRuleSet(
      RuleSet ruleSet, bool castToNum) async {
    var errs = List<ValidationError>();
    for (var rule in ruleSet.rules) {
      ValidationError e = await rule(_cast(_value, castToNum));
      errs.add(e);
    }
    ;
    return errs;
  }

  Future<void> validate(RuleSet ruleSet) async {
    if (_validated || ruleSet == null) return null;
    var castToNum = ruleSet.castToNum;
    while (ruleSet != null) {
      if (ruleSet.castToNum) castToNum = ruleSet.castToNum;
      var e = await _processRuleSet(ruleSet, castToNum);
      _errors.addAll(e);
      ruleSet = ruleSet.next;
    }
    bool _val = true;
    _errors.forEach((e) {
      if (e != null) _val = false;
    });
    _valid = _val;
    _validated = true;
    return null;
  }

  List<dynamic> errorMessages() {
    if (_errors == null || _errors.isEmpty) return [];
    var r = List<dynamic>();
    for (var e in _errors) {
      if (e != null) {
        r.add(e.msg);
      }
    }
    return r;
  }

  Map<String, dynamic> errorMap() {
    if (_errors == null || _errors.isEmpty) return {};
    var r = Map<String, dynamic>();
    _errors.forEach((e) {
      if (e != null) {
        e.map.forEach((k, v) {
          r[k] = v;
        });
      }
    });
    return r;
  }

  List<Map<String, dynamic>> allErrors() {
    if (_errors == null || _errors.isEmpty) return [];
    var r = List<Map<String, dynamic>>();
    _errors.forEach((e) {
      var i = Map<String, dynamic>();
      if (e != null) {
        i['msg'] = e.msg;
        i['map'] = e.map;
      }
      if (i.isNotEmpty) r.add(i);
    });
    return r;
  }
}
