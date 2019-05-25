import 'dart:async';

import 'package:endorse/src/rule_set.dart';
import 'package:endorse/src/validation.dart';
import 'package:endorse/src/value.dart';

import 'package:bottom_line/bottom_line.dart' as _;

abstract class Endorsable {
  static EndorseSchema endorse;
}

class ValueListDetails {
  final TypeRuleSet ruleSet;
  final String errorMsg;
  final Map<String, dynamic> errorMap;

  ValueListDetails(this.ruleSet, this.errorMsg, this.errorMap);
}

class EndorseSchemaDetails {
  final EndorseSchema endorse;
  final String errorMsg;
  final Map<String, dynamic> errorMap;

  EndorseSchemaDetails(this.endorse, this.errorMsg, this.errorMap);
}

abstract class Endorse {}

class EndorseSchema {
  EndorseSchema();

  Map<String, RuleSet> _values;
  Map<String, EndorseSchemaDetails> _maps;
  Map<String, EndorseSchemaDetails> _objectLists;
  Map<String, ValueListDetails> _valueLists;

  bool _isLocked = false;

  get isLocked => _isLocked;

  TypeRuleSet field(String field) {
    if (_isLocked) throw StateError('Cannot add rules to a locked Endorse.');
    if (_values == null) _values = Map<String, RuleSet>();
    _values[field] = TypeRuleSet();
    return _values[field];
  }

  EndorseSchema map(String field, {String msg, Map<String, dynamic> map}) {
    if (_isLocked) throw StateError('Cannot add rules to a locked Endorse.');
    if (_maps == null) _maps = Map<String, EndorseSchemaDetails>();
    if (_maps.containsKey(field)) return _maps[field].endorse;
    var e = EndorseSchema();
    var d = EndorseSchemaDetails(e, msg, map);
    _maps[field] = d;
    return d.endorse;
  }

  EndorseSchema objectList(String field,
      {String msg, Map<String, dynamic> map}) {
    if (_isLocked) throw StateError('Cannot add rules to a locked Endorse.');
    if (_objectLists == null)
      _objectLists = Map<String, EndorseSchemaDetails>();
    if (_objectLists.containsKey(field)) return _objectLists[field].endorse;
    var e = EndorseSchema();
    var d = EndorseSchemaDetails(e, msg, map);
    _objectLists[field] = d;
    return d.endorse;
  }

  TypeRuleSet valueList(String field, {String msg, Map<String, dynamic> map}) {
    if (_isLocked) throw StateError('Cannot add rules to a locked Endorse.');
    if (_valueLists == null) _valueLists = Map<String, ValueListDetails>();
    var r = TypeRuleSet();
    var d = ValueListDetails(r, msg, map);
    _valueLists[field] = d;
    return _valueLists[field].ruleSet;
  }

  void lock() {
    _isLocked = true;
  }

  Future<ValidationSchema> validate(Map<String, dynamic> input) async {
    if (_values == null && _maps == null) {
      throw StateError('EndorseSchema has no rules set.');
    }
    var result = await _crawl(input);
    return result;
  }

  Future<ValidationSchema> _crawl(dynamic input) async {
    var values = Map<String, Value>();
    var maps = Map<String, ValidationSchema>();
    var valueLists = Map<String, List<Value>>();
    var objectLists = Map<String, List<ValidationSchema>>();
    if (input == null)
      return ValidationSchema(values, valueLists, objectLists, maps);
    if (_values != null && _values.isNotEmpty) {
      for (var k in _values.keys) {
        var i = input[k];
        var v = Value(i);
        await v.validate(_values[k]);
        values[k] = v;
      }
    }
    if (_valueLists != null && _valueLists.isNotEmpty) {
      for (var k in _valueLists.keys) {
        var valueList = _valueLists[k];
        var i = input[k];
        var rs = ListMetaRuleSet()
          ..isValueList(msg: valueList.errorMsg, map: valueList.errorMap);
        var list = Value(i);
        await list.validate(rs);
        if (list.errorMessages().length > 0) {
          values[k] = list;
        } else {
          var l = List<Value>();
          for (var item in i) {
            var v = Value(item);
            await v.validate(valueList.ruleSet);
            l.add(v);
          }
          valueLists[k] = l;
        }
      }
    }
    if (_objectLists != null && _objectLists.isNotEmpty) {
      for (var k in _objectLists.keys) {
        var objectList = _objectLists[k];
        var i = input[k];
        var rs = ListMetaRuleSet()
          ..isList(msg: objectList.errorMsg, map: objectList.errorMap);
        var list = Value(i);
        await list.validate(rs);
        if (list.errorMessages().length > 0) {
          values[k] = list;
        } else {
          var l = List<ValidationSchema>();
          for (var item in i) {
            l.add(await objectList.endorse._crawl(item));
          }
          objectLists[k] = l;
        }
      }
    }
    if (_maps != null && _maps.isNotEmpty) {
      for (var k in _maps.keys) {
        var m = _maps[k];
        var i = input[k];
        var rs = MapMetaRuleSet()..isMap(msg: m.errorMsg, map: m.errorMap);
        var map = Value(i);
        await map.validate(rs);
        if (map.errorMessages().length > 0) {
          values[k] = map;
        } else {
          maps[k] = await m.endorse._crawl(i);
        }
      }
    }
    return ValidationSchema(values, valueLists, objectLists, maps);
  }

  RuleSet _findRule(List<String> pathToField) {
    if (pathToField.length == 0) return null;
    EndorseSchemaDetails e;
    for (var i = 0; i < pathToField.length; i++) {
      var field = pathToField[i];
      if (i == pathToField.length - 1) {
        if (!_values.containsKey(field)) return null;
        return _values[field];
      } else {
        if (!_maps.containsKey(field)) return null;
        e = e.endorse._maps[field];
      }
    }
    return null;
  }

  Future<ValidationValue> validateField(
      List<String> pathToField, Map<String, dynamic> input) async {
    var r = _findRule(pathToField);
    if (r == null)
      throw ArgumentError(
          'RuleSet does not exist in schema for: ${pathToField.toString()}');
    var v = _.JsonTool(input).toMap().grab(pathToField).value;
    if (v == null) return null;
    var value = Value(v);
    await value.validate(r);
    ValidationValue result = ValidationValue(value);
    return result;
  }

  List<String> fields() {
    throw UnimplementedError('EndorseSchema.fields');
    // return _ruleSet.keys.toList();
  }

  bool hasField(List<String> pathToField) {
    return (_findRule(pathToField) != null) ? true : false;
  }
}

class EndorseValue {
  RuleSet _ruleSet;

  TypeRuleSet check() {
    if (_ruleSet == null) _ruleSet = TypeRuleSet();
    return _ruleSet;
  }

  Future<ValidationValue> validate(dynamic input) async {
    if (_ruleSet == null) throw StateError('EndorseValue has no rules.');
    if (input == null) return null;
    var value = Value(input);
    await value.validate(_ruleSet);
    Validation result = ValidationValue(value);
    return result;
  }
}
