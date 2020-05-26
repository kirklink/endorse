import 'package:endorse/src/endorse/rule.dart';
import 'package:endorse/src/endorse/validation_error.dart';
import 'package:endorse/src/endorse/endorse.dart';

class RuleSet {
  RuleSet _next;

  get next => _next;

  List<Rule> _rules = List<Rule>();

  get rules => _rules;
  List<ListRule> _listRules = List<ListRule>();

  get listRules => _listRules;

  bool _castToNum = false;

  get castToNum => _castToNum;

  String _messageOverride(String message, String override) {
    return override != null ? override : message;
  }

  Map<String, dynamic> _mapOverride(
      Map<String, dynamic> map, Map<String, dynamic> override) {
    return override != null ? override : map;
  }

  bool _goodString(dynamic value) {
    if (value == null) return false;
    if (value is String) return true;
    return false;
  }

  bool _goodNum(dynamic value) {
    if (value == null) return false;
    if (value is num) return true;
    return false;
  }

  bool _goodList(dynamic value) {
    if (value == null) return false;
    if (value is List) return true;
    return false;
  }

  bool _goodBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return true;
    return false;
  }

  RuleSet required({String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      bool emptyObject;
      try {
        emptyObject = value.isEmpty;
      } catch (e) {
        emptyObject = false;
      }
      if (value != null && !emptyObject) return null;
      final s = 'Required.';
      final m = {'required': true, 'exists': false};
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    return this;
  }

  RuleSet custom(Rule rule, {String msg, Map<String, dynamic> map}) {
    _rules.add(rule);
    _next = RuleSet();
    // _next._castToNum = _castToNum;
    return _next;
  }
}

class TypeRuleSet extends RuleSet {
  StringRuleSet string({String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (value is String || value == null) return null;
      final s = 'Must be a string.';
      final m = {'isString': false};
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    _next = StringRuleSet();
    return _next;
  }

  NumRuleSet number({String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (value is num || value == null) return null;
      final s = 'Must be a number.';
      final m = {'isNum': false};
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    _next = NumRuleSet();
    // _next._castToNum = _castToNum;
    return _next;
  }

  NumRuleSet integer({String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (value is int || value == null) return null;
      final s = 'Must be an integer.';
      final m = {'isInt': false};
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    _next = NumRuleSet();
    // _next._castToNum = _castToNum;
    return _next;
  }

  NumRuleSet float({String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if ((value is num && value * 1.0 is double) || value == null) return null;
      final s = 'Must be a float.';
      final m = {'isFloat': false};
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    _next = NumRuleSet();
    // _next._castToNum = _castToNum;
    return _next;
  }

  NumRuleSet stringIsNum({String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (value == null) return null;
      if (value is! String) {
        final s = 'Must be a number as a string.';
        final m = {'stringIsNum': false};
        msg = _messageOverride(s, msg);
        map = _mapOverride(m, map);
        var r = ValidationError(msg, map);
        return r;
      }
      ;
      final s = 'Cannot cast to number.';
      final m = {'stringIsNum': false};
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      try {
        num.parse(value);
        return null;
      } catch (e) {
        return r;
      }
    };
    _rules.add(rule);
    _next = NumRuleSet();
    _next._castToNum = true;
    return _next;
  }

  BoolRuleSet boolean({String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (value is bool || value == null) return null;
      final s = 'Must be a boolean.';
      final m = {'isBoolean': false};
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    _next = BoolRuleSet();
    return _next;
  }
}

class StringRuleSet extends RuleSet {
  StringRuleSet max(int max, {String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (!_goodString(value)) return null;
      if (value.length <= max) return null;
      final s = 'Max length is $max.';
      final m = {
        'maxLength': {'max': max, 'got': value.length}
      };
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    return this;
  }

  StringRuleSet min(int min, {String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (!_goodString(value)) return null;
      if (value.length >= min) return null;
      final s = 'Min length is $min.';
      final m = {
        'minLength': {'min': min, 'got': value.length}
      };
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    return this;
  }

  StringRuleSet matchesRegex(RegExp exp, {String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (!_goodString(value)) return null;
      if (exp.hasMatch(value)) return null;
      final s = 'Does not match pattern.';
      final m = {'matchesRegex': false};
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    return this;
  }

  StringRuleSet matches(String string, {String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (!_goodString(value)) return null;
      if ((value as String) == string) return null;
      final s = 'Does not match string.';
      final m = {'matches': false};
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    return this;
  }

  StringRuleSet contains(String string, {String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (!_goodString(value)) return null;
      if ((value as String).contains(string)) return null;
      final s = 'Does not contain string.';
      final m = {'contains': false};
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    return this;
  }

  StringRuleSet startsWith(String string, {String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (!_goodString(value)) return null;
      if ((value as String).startsWith(string)) return null;
      final s = 'Does not start with string.';
      final m = {'startsWith': false};
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    return this;
  }

  StringRuleSet endsWith(String string, {String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (!_goodString(value)) return null;
      if ((value as String).endsWith(string)) return null;
      final s = 'Does not end with string.';
      final m = {'endsWith': false};
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    return this;
  }
}

class NumRuleSet extends RuleSet {
  NumRuleSet integer({String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (value is int) return null;
      final s = 'Must be an integer.';
      final m = {'isInt': false};
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    return this;
  }

  NumRuleSet float({String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (value is double) return null;
      final s = 'Must be a float.';
      final m = {'isFloat': false};
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    return this;
  }

  NumRuleSet max(num max, {String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (value == null) return null;
      if (!_goodNum(value)) return null;
      if (value <= max) return null;
      final s = 'Max is $max.';
      final m = {
        'maxNum': {'max': max, 'got': value}
      };
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    return this;
  }

  NumRuleSet min(num min, {String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (value == null) return null;
      if (!_goodNum(value)) return null;
      if (value >= min) return null;
      final s = 'Min is $min.';
      final m = {
        'minNum': {'min': min, 'got': value}
      };
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    return this;
  }

  NumRuleSet isEqualTo(num input, {String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (value == null) return null;
      if (!_goodNum(value)) return null;
      if (value == input) return null;
      final s = 'Must equal $input.';
      final m = {
        'isEqualTo': {'test': input, 'got': value}
      };
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    return this;
  }

  NumRuleSet isNotEqualTo(num input, {String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (value == null) return null;
      if (!_goodNum(value)) return null;
      if (value != input) return null;
      final s = 'Must not equal $input.';
      final m = {
        'isNotEqualTo': {
          'test': input,
          'got': value,
        }
      };
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    return this;
  }
}

class IntRuleSet extends NumRuleSet {}

class DoubleRuleSet extends NumRuleSet {}

class BoolRuleSet extends RuleSet {
  BoolRuleSet isTrue({String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (value == null) return null;
      if (!_goodBool(value)) return null;
      if (value == true) return null;
      final s = 'Must be true.';
      final m = {'isTrue': false};
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    return this;
  }

  BoolRuleSet isFalse({String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (value == null) return null;
      if (!_goodBool(value)) return null;
      if (value == false) return null;
      final s = 'Must be false.';
      final m = {'isFalse': false};
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    return this;
  }
}

class ListRuleSet extends RuleSet {
  ListRuleSet containsOnlyType(String type,
      {String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (!_goodList(value)) return null;
      bool isValid = true;
      String _type;
      switch (type) {
        case 'String':
        case 'string':
          _type = 'String';
          for (var v in value) {
            if (v is! String) {
              isValid = false;
              break;
            }
          }
          ;
          break;
        case 'int':
        case 'integer':
          _type = 'int';
          for (var v in value) {
            if (v is! int) {
              isValid = false;
              break;
            }
          }
          ;
          break;
        case 'num':
        case 'number':
          _type = 'num';
          for (var v in value) {
            if (v is! num) {
              isValid = false;
              break;
            }
          }
          ;
          break;
        case 'float':
          _type = 'float';
          for (var v in value) {
            if (v is! double) {
              isValid = false;
              break;
            }
          }
          ;
          break;
        default:
          throw ArgumentError(
              'Bad type provided: $type. Only "String", "int", "num" and "float" allowed.');
      }
      if (isValid) return null;
      final s = 'Must only contain $_type.';
      final m = {
        'containsOnlyType': {
          'type': _type,
          'valid': false,
        }
      };
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    return this;
  }

  ListRuleSet containsOnly(EndorseSchema endorse,
      {String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (!_goodList(value)) return null;
      bool isValid = true;
      // var r = List<dynamic>();
      // for (var v in value) {
      //   var val = await endorse.validate(v);
      //   if (val == null || val.isValid) {
      //     r.add(null);
      //   } else {
      //     isValid = false;
      //     r.add(val);
      //   }
      // }
      var v = await endorse.validate(value);
      if (v.errorMessages().length == 0) return null;
      // TODO: consider input endorse error messages here
      final s = 'Contains invalid objects.';
      final m = {'containsOnly': false};
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    return this;
  }
}

class ListMetaRuleSet extends RuleSet {
  TypeRuleSet isList({String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (value is! List) {
        final s = 'Must be a list.';
        final m = {'isList': false};
        msg = _messageOverride(s, msg);
        map = _mapOverride(m, map);
        var r = ValidationError(msg, map);
        return r;
      }
      return null;
    };
    _rules.add(rule);
    _next = TypeRuleSet();
    return _next;
  }

  TypeRuleSet isValueList({String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (value is! List) {
        final s = 'Must be a list.';
        final m = {'isList': false};
        msg = _messageOverride(s, msg);
        map = _mapOverride(m, map);
        var r = ValidationError(msg, map);
        return r;
      }
      bool noObjects = true;
      for (var item in value) {
        if (item is Map || item is List) {
          noObjects = false;
          break;
        }
      }
      if (noObjects) {
        return null;
      } else {
        final s = 'Value list cannot contain objects.';
        final m = {'isValueList': false};
        msg = _messageOverride(s, msg);
        map = _mapOverride(m, map);
        var r = ValidationError(msg, map);
        return r;
      }
    };
    _rules.add(rule);
    _next = TypeRuleSet();
    return _next;
  }
}

class MapMetaRuleSet extends RuleSet {
  TypeRuleSet isMap({String msg, Map<String, dynamic> map}) {
    Rule rule = (dynamic value) async {
      if (value is Map) return null;
      final s = 'Must be a map.';
      final m = {'isMap': false};
      msg = _messageOverride(s, msg);
      map = _mapOverride(m, map);
      var r = ValidationError(msg, map);
      return r;
    };
    _rules.add(rule);
    _next = TypeRuleSet();
    return _next;
  }
}
