class EndorseException implements Exception {
  final String cause;
  EndorseException(this.cause);
  @override
  String toString() => cause;
}



class TestError {
  final String field;
  final Object input;
  final String ruleName;
  final String msg;
  final Object testValue;
  final Object wantValue;
  
  TestError(this.field, this.input, this.ruleName, this.msg, [this.testValue, this.wantValue]);
  
  @override
  String toString() {
    if (testValue == null) {
      return '$field $msg';
    } else {
      return '$field $msg ${testValue.toString()}';
    }
  } 
  
  Map<String, Object> map() {
    if (testValue == null) {
      return {
        'validation': ruleName,
        'message': this.toString(),
        'got': input.toString()
      };
    } else {
      return {
        'validation': ruleName,
        'message': this.toString(),
        'want': wantValue.toString(),
        'got': input.toString()
      };
    }
  }

}





abstract class ResultObject {
  bool get isValid;
  Object get errors;
  Object get value;
}

class ValueResult implements ResultObject {
  final String field;
  final Object value;
  final Object _valueCast;
  final List<TestError> _errorList;
  
  ValueResult(this.field, this.value, this._valueCast, this._errorList);

  bool get isValid => _errorList.isEmpty;

  Object get errors {
    // final list = {for (var v in _errorList) v.ruleName : v.map()};
    final list = _errorList.map((i) => i.map()).toList();
    return list;
  }
}


class ListResult implements ResultObject {
  final List<ResultObject> value;
  final List<TestError> _errorList;
  final ValueResult fieldErrors;

  ListResult(this.fieldErrors, this.value, this._errorList);

  bool get isValid {
    if (!fieldErrors.isValid) {
      return false;
    }
    for (final v in value) {
      if (!v.isValid) {
        return false;
      }
    }
    return true;
  }

  Object get errors {
    final result = {
      'listErrors': fieldErrors.errors,
      'itemErrors': _errorList.map((i) => i.map()).toList()
    };
    return result;
  }

}



// abstract class ValidationResult implements ResultObject {
//   Map<String, Object> get values;
//   // bool get isValid;
// }










abstract class Validator {
  ResultObject validate(Map<String, Object> input);
  List<ResultObject> validateList(List<Object> input);
}






// class ApplyRulesToValue extends ApplyRules {}

class ApplyRulesToList {
  final ApplyRulesToField _fieldRules;
  final ApplyRulesToField _itemRules;
  ValueResult _fieldErrors;
  

  ApplyRulesToList(this._fieldRules, this._itemRules);

  ListResult done(List items, [String field = '']) {
    _fieldErrors = _fieldRules.done(items, field);
    final result = <TestError>[];
    for (final item in items) {
      final r = _itemRules.done(item);
      result.add(r.errors);
    }
    return ListResult(_fieldErrors, items, result);
  }

  // void isList() {
  //   _fieldErrors = (ApplyRulesToField()..isList()).done(_items, _field);
  // }





}

class RuleHolder {
  final Rule rule;
  final Object test;
  RuleHolder(this.rule, [this.test = null]);
}


class ApplyRulesToField {
  String _field;
  Object _input;
  Object _inputCast;
  final _errors = <TestError>[];
  final rules = <RuleHolder>[];
  var _bail = false;

  // ApplyRulesToField(this._field, this._input) {
  //   _inputCast = _input;
  // }

  
  ValueResult done(Object input, [String field = '']) {
    _input = input;
    _field = field;
    _inputCast = input;
    for (final rule in rules) {
      _runRule(rule.rule, rule.test);
    }
    return ValueResult(_field, _input, _inputCast, _errors);
  }

  void _runRule(ValueRule rule, [Object test = null]) {
    if (_bail && !rule.escapesBail) {
      return;
    }
    if (!rule.restriction(_inputCast)) {
      throw EndorseException('${rule.name} ${rule.restrictionError}.');
    }
    final ruleGot = rule.got(_input, test);
    final got = ruleGot != null ? ruleGot : _input;
    final ruleWant = rule.want(_input, test);
    final want = ruleWant != null ? ruleWant : test;
    if (!rule.pass(_inputCast, test)) {
      _errors.add(TestError(_field, got, rule.name, rule.errorMsg, test, want));
      if (rule.causesBail) {
        _bail = true;
      }
    }
  }

  
  void isRequired() {
    rules.add(RuleHolder(IsRequiredRule()));
    // rules.add(RuleHolder(IsRequiredRule());
  }

  void isList() {
    rules.add(RuleHolder(IsListRule()));
    // rules.add(RuleHolder(IsListRule());
  }

  void isString() {
    rules.add(RuleHolder(IsStringRule()));
  }

  void isInt({bool fromString = false}) {
    if (fromString) {
      final cast = int.tryParse(_inputCast);
      if (cast == null) {
        _errors.add(TestError(_field, _input, 'intFromString', 'Could not cast to int from String'));
        _bail = true;
      } else {
        _inputCast = cast;
      }
    }
    rules.add(RuleHolder(IsIntRule()));
  }

  void isDouble({bool fromString = false}) {
    if (fromString) {
      final cast = double.tryParse(_inputCast);
      if (cast == null) {
        _errors.add(TestError(_field, _input, 'doubleFromString', 'Could not cast to double from String'));
        _bail = true;
      } else {
        _inputCast = cast;
      }
    }
    rules.add(RuleHolder(IsDoubleRule()));
  }

  void isBoolean({bool fromString = false}) {
    if (fromString) {
      final isTrue = _inputCast == 'true' ? true : null;
      final isFalse = _inputCast == 'false' ? false : null;
      if (isTrue == null && isFalse == null) {
        _errors.add(TestError(_field, _input, 'boolFromString', 'Could not cast to bool from String'));
        _bail = true;
      } else {
        _inputCast = isTrue == null ? isFalse : isTrue;
      }
    }
    rules.add(RuleHolder(IsBoolRule()));
  }

  void maxLength(int test) {
    rules.add(RuleHolder(MaxLengthRule(), test));
  }

  void minLength(int test) {
    rules.add(RuleHolder(MinLengthRule(), test));
  }

  void matches(String test) {
    rules.add(RuleHolder(MatchesRule(), test));
  }

  void contains(String test) {
    rules.add(RuleHolder(ContainsRule(), test));
  }

  void startsWith(String test) {
    rules.add(RuleHolder(StartsWithRule(), test));
  }

  void endsWith(String test) {
    rules.add(RuleHolder(EndsWithRule(), test));
  }
 
  void isEqualTo(num test) {
    rules.add(RuleHolder(IsEqualToRule(), test));
  }

  void isNotEqualTo(num test) {
    rules.add(RuleHolder(IsNotEqualToRule(), test));
  }

  void isGreaterThan(num test) {
    rules.add(RuleHolder(IsGreaterThanRule(), test));
  }

  void isLessThan(num test) {
    rules.add(RuleHolder(IsLessThanRule(), test));
  }

  void isTrue() {
    rules.add(RuleHolder(IsTrueRule()));
  }

  void isFalse() {
    rules.add(RuleHolder(IsFalseRule()));
  }

  


}


typedef bool PassFuntion(Object input, Object test);
typedef bool RestrictFunction(Object input);
typedef Object GotFunction(Object input, Object test);
typedef Object WantFunction(Object input, Object test);

abstract class Rule {
  final String name = '';
  final bool causesBail = false;
  final bool escapesBail = false;
  final PassFuntion pass = (input, test) => true; 
  final RestrictFunction restriction = (input) => true;
  final GotFunction got = (input, test) => null;
  final WantFunction want = (input, test) => null;
  final String  restrictionError = '';
  final String errorMsg = '';
}

abstract class ValueRule extends Rule{}

class IsRequiredRule extends ValueRule {
  final name = 'required';
  final causesBail = true;
  final pass = (input, test) => input != null;
  final errorMsg = 'is required';
}

class IsListRule extends ValueRule {
  final name = 'IsList';
  final causesBail = true;
  final pass = (input, test) => input is List;
  final errorMsg = 'must be a List';
  final got = (input, test) => input.runtimeType;
}

class IsStringRule extends ValueRule {
  final name = 'IsString';
  final causesBail = true;
  final pass = (input, test) => input is String;
  final errorMsg = 'must be a String';
}

class IsIntRule extends ValueRule {
  final name = 'IsInt';
  final causesBail = true;
  final pass = (input, test) => input is int;
  final errorMsg = 'must be an integer';
}

class IsDoubleRule extends ValueRule {
  final name = 'IsDouble';
  final causesBail = true;
  final pass = (input, test) => input is double;
  final errorMsg = 'must be a double';
}

class IsBoolRule extends ValueRule {
  final name = 'IsBool';
  final causesBail = true;
  final pass = (input, test) => input is bool;
  final errorMsg = 'must be a boolean';  
}

class MaxLengthRule extends ValueRule {
  final name = 'MaxLength';
  final pass = (input, test) => (input as String).length < test;
  final restriction = (input) => input is String;
  final restrictionError = 'can only be used on Strings';
  final got = (input, test) => (input as String).length;
  final errorMsg = 'length must be less than';
}

class MinLengthRule extends ValueRule {
  final name = 'MinLength';
  final pass = (input, test) => (input as String).length > test;
  final restriction = (input) => input is String;
  final restrictionError = 'can only be used on Strings';
  final got = (input, test) => (input as String).length;
  final errorMsg = 'length must be greater than';
}

class MatchesRule extends ValueRule {
  final name = 'Matches';
  final pass = (input, test) => (input as String) == test;
  final restriction = (input) => input is String;
  final restrictionError = 'can only be used on Strings';
  final errorMsg = 'must match:';
}

class ContainsRule extends ValueRule {
  final name = 'Contains';
  final pass = (input, test) => (input as String).contains(test);
  final restriction = (input) => input is String;
  final restrictionError = 'can only be used on Strings';
  final errorMsg = 'must contain:';
}

class StartsWithRule extends ValueRule {
  final name = 'StartsWith';
  final pass = (input, test) => (input as String).startsWith(test);
  final restriction = (input) => input is String;
  final restrictionError = 'can only be used on Strings';
  final errorMsg = 'must start with:';
  final got = (input, test) {
    final i = input as String;
    final t = test as String;
    final length = i.length < t.length ? i.length : t.length;
    final sub = i.substring(0, length);
    return '$sub';
  };
  // final want = (input, test) => '$test';
}

class EndsWithRule extends ValueRule {
  final name = 'EndsWith';
  final pass = (input, test) => (input as String).endsWith(test);
  final restriction = (input) => input is String;
  final restrictionError = 'can only be used on Strings';
  final errorMsg = 'must end with:';
  final got = (input, test) {
    final i = input as String;
    final t = test as String;
    final length = i.length < t.length ? i.length : t.length;
    final sub = i.substring(i.length - length, i.length);
    return '$sub';
  };
  // final want = (input, test) => '$test';
}

class IsEqualToRule extends ValueRule {
  final name = 'IsEqualTo';
  final pass = (input, test) => input == test;
  final restriction = (input) => input is num;
  final restrictionError = 'can only be used on numbers';
  final errorMsg = 'must equal';
}

class IsNotEqualToRule extends ValueRule {
  final name = 'IsNotEqualTo';
  final pass = (input, test) => input != test;
  final restriction = (input) => input is num;
  final restrictionError = 'can only be used on numbers';
  final errorMsg = 'must not equal';
}

class IsLessThanRule extends ValueRule {
  final name = 'IsLessThan';
  final pass = (input, test) => input as num < test;
  final restriction = (input) => input is num;
  final restrictionError = 'can only be used on numbers';
  final errorMsg = 'must be less than';
}

class IsGreaterThanRule extends ValueRule {
  final name = 'IsGreaterThan';
  final pass = (input, test) => input as num > test;
  final restriction = (input) => input is num;
  final restrictionError = 'can only be used on numbers';
  final errorMsg = 'must be greater than';
}

class IsTrueRule extends ValueRule {
  final name = 'IsTrue';
  final pass = (input, test) => input as bool == true;
  final restriction = (input) => input is bool;
  final restrictionError = 'can only be used on booleans';
  final errorMsg = 'must be';
  final want = (input, test) => true;
}

class IsFalseRule extends ValueRule {
  final name = 'IsFalse';
  final pass = (input, test) => input as bool == false;
  final restriction = (input) => input is bool;
  final restrictionError = 'can only be used on booleans';
  final errorMsg = 'must be';
  final want = (input, test) => false;
}







// class IsBefore extends DateTimeRule {
//   final DateTime value;
//   @override
//   final String part = '.isBefore(@)';
//   const IsBefore(this.value);
// }

// class IsAfter extends DateTimeRule {
//   final DateTime value;
//   @override
//   final String part = '.isAfter(@)';
//   const IsAfter(this.value);
// }

