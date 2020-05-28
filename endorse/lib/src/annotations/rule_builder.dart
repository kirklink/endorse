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



// abstract class ValidationResult implements ResultObject {
//   Map<String, Object> get values;
//   // bool get isValid;
// }










abstract class Validator {
  ResultObject validate(Map<String, Object> input);
}

class ValidationRules {
  final String _field;
  final Object _input;
  Object _inputCast;
  final _errors = <TestError>[];
  var _bail = false;

  ValidationRules(this._field, this._input) {
    _inputCast = _input;
  }

  void _runRule(Rule rule, [Object test = null]) {
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

  ValueResult done() => ValueResult(_field, _input, _inputCast, _errors);

  void isRequired() {
    _runRule(IsRequiredRule());
  }

  void isString() {
    _runRule(IsStringRule());
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
    _runRule(IsIntRule());
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
    _runRule(IsDoubleRule());
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
    _runRule(IsBoolRule());
  }

  void maxLength(int test) {
    _runRule(MaxLengthRule(), test);
  }

  void minLength(int test) {
    _runRule(MinLengthRule(), test);
  }

  void matches(String test) {
    _runRule(MatchesRule(), test);
  }

  void contains(String test) {
    _runRule(ContainsRule(), test);
  }

  void startsWith(String test) {
    _runRule(StartsWithRule(), test);
  }

  void endsWith(String test) {
    _runRule(EndsWithRule(), test);
  }
 
  void isEqualTo(num test) {
    _runRule(IsEqualToRule(), test);
  }

  void isNotEqualTo(num test) {
    _runRule(IsNotEqualToRule(), test);
  }

  void isGreaterThan(num test) {
    _runRule(IsGreaterThanRule(), test);
  }

  void isLessThan(num test) {
    _runRule(IsLessThanRule(), test);
  }

  void isTrue() {
    _runRule(IsTrueRule());
  }

  void isFalse() {
    _runRule(IsFalseRule());
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

class IsRequiredRule extends Rule {
  final name = 'required';
  final causesBail = true;
  final pass = (input, test) => input != null;
  final errorMsg = 'is required';
}

class IsStringRule extends Rule {
  final name = 'IsString';
  final causesBail = true;
  final pass = (input, test) => input is String;
  final errorMsg = 'must be a String';
}

class IsIntRule extends Rule {
  final name = 'IsInt';
  final causesBail = true;
  final pass = (input, test) => input is int;
  final errorMsg = 'must be an integer';
}

class IsDoubleRule extends Rule {
  final name = 'IsDouble';
  final causesBail = true;
  final pass = (input, test) => input is double;
  final errorMsg = 'must be a double';
}

class IsBoolRule extends Rule {
  final name = 'IsBool';
  final causesBail = true;
  final pass = (input, test) => input is bool;
  final errorMsg = 'must be a boolean';  
}

class MaxLengthRule extends Rule {
  final name = 'MaxLength';
  final pass = (input, test) => (input as String).length < test;
  final restriction = (input) => input is String;
  final restrictionError = 'can only be used on Strings';
  final got = (input, test) => (input as String).length;
  final errorMsg = 'length must be less than';
}

class MinLengthRule extends Rule {
  final name = 'MinLength';
  final pass = (input, test) => (input as String).length > test;
  final restriction = (input) => input is String;
  final restrictionError = 'can only be used on Strings';
  final got = (input, test) => (input as String).length;
  final errorMsg = 'length must be greater than';
}

class MatchesRule extends Rule {
  final name = 'Matches';
  final pass = (input, test) => (input as String) == test;
  final restriction = (input) => input is String;
  final restrictionError = 'can only be used on Strings';
  final errorMsg = 'must match:';
}

class ContainsRule extends Rule {
  final name = 'Contains';
  final pass = (input, test) => (input as String).contains(test);
  final restriction = (input) => input is String;
  final restrictionError = 'can only be used on Strings';
  final errorMsg = 'must contain:';
}

class StartsWithRule extends Rule {
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

class EndsWithRule extends Rule {
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

class IsEqualToRule extends Rule {
  final name = 'IsEqualTo';
  final pass = (input, test) => input == test;
  final restriction = (input) => input is num;
  final restrictionError = 'can only be used on numbers';
  final errorMsg = 'must equal';
}

class IsNotEqualToRule extends Rule {
  final name = 'IsNotEqualTo';
  final pass = (input, test) => input != test;
  final restriction = (input) => input is num;
  final restrictionError = 'can only be used on numbers';
  final errorMsg = 'must not equal';
}

class IsLessThanRule extends Rule {
  final name = 'IsLessThan';
  final pass = (input, test) => input as num < test;
  final restriction = (input) => input is num;
  final restrictionError = 'can only be used on numbers';
  final errorMsg = 'must be less than';
}

class IsGreaterThanRule extends Rule {
  final name = 'IsGreaterThan';
  final pass = (input, test) => input as num > test;
  final restriction = (input) => input is num;
  final restrictionError = 'can only be used on numbers';
  final errorMsg = 'must be greater than';
}

class IsTrueRule extends Rule {
  final name = 'IsTrue';
  final pass = (input, test) => input as bool == true;
  final restriction = (input) => input is bool;
  final restrictionError = 'can only be used on booleans';
  final errorMsg = 'must be';
  final want = (input, test) => true;
}

class IsFalseRule extends Rule {
  final name = 'IsFalse';
  final pass = (input, test) => input as bool == false;
  final restriction = (input) => input is bool;
  final restrictionError = 'can only be used on booleans';
  final errorMsg = 'must be';
  final want = (input, test) => false;
}





abstract class Validation {
  final String call = '';
  const Validation();
}


class MaxLength implements Validation {
  final int value;
  @override
  final String call = 'maxLength(@)';
  const MaxLength(this.value);
}

class MinLength implements Validation {
  final int value;
  @override
  final String call = 'minLength(@)';
  const MinLength(this.value);
}

class StartsWith implements Validation {
  final String value;
  @override
  final String call = 'startsWith(@)';
  const StartsWith(this.value);
}

class EndsWith implements Validation {
  final String value;
  @override
  final String call = 'endsWith(@)';
  const EndsWith(this.value);
}

class Contains implements Validation {
  final String value;
  @override
  final String call = 'contains(@)';
  const Contains(this.value);
}

class Matches implements Validation {
  final String value;
  @override
  final String call = 'matches(@)';
  const Matches(this.value);
}

class IsLessThan implements Validation {
  final num value;
  @override
  final String call = 'isLessThan(@)';
  const IsLessThan(this.value);
}

class IsGreaterThan implements Validation {
  final num value;
  @override
  final String call = 'isGreaterThan(@)';
  const IsGreaterThan(this.value);
}

class IsEqualTo implements Validation {
  final num value;
  @override
  final String call = 'isEqualTo(@)';
  const IsEqualTo(this.value);
}

class IsNotEqualTo implements Validation {
  final num value;
  @override
  final String call = 'isNotEqualTo(@)';
  const IsNotEqualTo(this.value);
}

class IsTrue implements Validation {
  @override
  final String call = 'isTrue()';
  const IsTrue();
}

class IsFalse implements Validation {
  @override
  final String call = 'isFalse()';
  const IsFalse();
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

