class EndorseException implements Exception {
  final String cause;
  EndorseException(this.cause);
  @override
  String toString() => cause;
}



class TestError {
  final String field;
  final Object input;
  final String testruleName;
  final String msg;
  final Object testValue;
  
  TestError(this.field, this.input, this.testruleName, this.msg, {this.testValue});
  
  @override
  String toString() {
    if (testValue == null) {
      return '$field $msg.';
    } else {
      return '$field $msg ${testValue.toString()}.';
    }
  } 
  
  Map<String, Object> map() {
    if (testValue == null) {
      return {
        'msg': this.toString(),
        testruleName: {
          'got': input.toString()
        }
      };
    } else {
      return {
        'msg': this.toString(),
        testruleName: {
          'test': testValue.toString(),
          'got': input.toString()
        }
      };
    }
  }

}

class ValueResult {
  final String field;
  final Object value;
  final Object valueCast;
  final List<TestError> errors;
  
  ValueResult(this.field, this.value, this.valueCast, this.errors);

  bool get isValid => errors.isEmpty;

  Map<String, Object> get errorsMap {
    final list = List.from(errors.map((i) => i.map()));
    return {field: list};
  }


}

abstract class Validator {
  ValidationResult validate(Map<String, Object> input);
}

abstract class ValidationResult {
  Map<String, Object> get values;
  bool get isValid;
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
    if (!rule.pass(_inputCast, test)) {
      _errors.add(TestError(_field, _input, rule.name, rule.errorMsg, testValue: test));
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


}


typedef bool PassFuntion(Object input, Object test);
typedef bool RestrictFunction(Object input);

abstract class Rule {
  final String name = '';
  final bool causesBail = false;
  final bool escapesBail = false;
  final PassFuntion pass = (input, test) => true; 
  final RestrictFunction restriction = (input) => true;
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
  final name = 'isString';
  final causesBail = true;
  final pass = (input, test) => input is String;
  final errorMsg = 'must be a String';
}

class IsIntRule extends Rule {
  final name = 'isInt';
  final causesBail = true;
  final pass = (input, test) => input is int;
  final errorMsg = 'must be an integer';
}

class IsDoubleRule extends Rule {
  final name = 'isDouble';
  final causesBail = true;
  final pass = (input, test) => input is double;
  final errorMsg = 'must be a double';
}

class IsBoolRule extends Rule {
  final name = 'isBool';
  final causesBail = true;
  final pass = (input, test) => input is bool;
  final errorMsg = 'must be a boolean';
  
}

class IsEqualToRule extends Rule {
  final name = 'isEqualTo';
  final pass = (input, test) => input == test;
  final restriction = (input) => input is num;
  final restrictionError = 'can only be used on numbers';
  final errorMsg = 'must equal';
}

class IsNotEqualToRule extends Rule {
  final name = 'isNotEqualTo';
  final pass = (input, test) => input != test;
  final restriction = (input) => input is num;
  final restrictionError = 'can only be used on numbers';
  final errorMsg = 'must not equal';
}

class IsLessThanRule extends Rule {
  final name = 'isLessThan';
  final pass = (input, test) => input as num < test;
  final restriction = (input) => input is num;
  final restrictionError = 'can only be used on numbers';
  final errorMsg = 'must be less than';
}

class IsGreaterThanRule extends Rule {
  final name = 'isGreaterThan';
  final pass = (input, test) => input as num > test;
  final restriction = (input) => input is num;
  final restrictionError = 'can only be used on numbers';
  final errorMsg = 'must be greater than';
}




// final int value;
//   @override
//   final String part = 'isEqualTo(@)';
//   const IsEqualTo(this.value);

// class TestValidationResult implements ValidationResult {
//   @override
//   final Map<String, Object> values;
//   @override
//   final bool isValid;
//   final ValueResult i;
//   TestValidationResult(this.isValid, this.values, this.i);
// }

// class TestEndorseValidator implements Validator {
  
//   TestValidationResult validate(Map<String, Object> input) {
//     final r = <String, ValueResult>{};
//     final v = <String, Object>{};
//     var isValid = true;
//     r['i'] = (Validate('i', input['i'])..isInt()..isEqualTo(10)).done();
//     v['i'] = {
//       'i': List.from(r['i'].errors.map((i) => i.map()))
//     };
//     isValid = isValid == false ? false : r['i'].isValid;
//     return TestValidationResult(isValid, v, r['i']);
//   }




  


  





abstract class Validation {
  final String part = '';
  const Validation();
}

// abstract class StringRule extends Validation {
//   @override
//   final String part = '';
//   const StringRule();
// }

// abstract class NumberRule extends Validation {
//   @override
//   final String part = '';
//   const NumberRule();
// }

// abstract class BoolRule extends Validation {
//   @override
//   final String part = '';
//   const BoolRule();
// }

// abstract class DateTimeRule extends Validation {
//   @override
//   final String part = '';
//   const DateTimeRule();
// }

// class MaxLength extends StringRule {
//   final int value;
//   @override
//   final String part = '.max(@)';
//   const MaxLength(this.value);
// }

// class MinLength extends StringRule {
//   final int value;
//   @override
//   final String part = '.min(@)';
//   const MinLength(this.value);
// }

// class StartsWith extends StringRule {
//   final String value;
//   @override
//   final String part = '.startsWith(@)';
//   const StartsWith(this.value);
// }

// class EndsWith extends StringRule {
//   final String value;
//   @override
//   final String part = '.endsWith(@)';
//   const EndsWith(this.value);
// }

// class Contains extends StringRule {
//   final String value;
//   @override
//   final String part = '.contains(@)';
//   const Contains(this.value);
// }

// class Matches extends StringRule {
//   final String value;
//   @override
//   final String part = '.matches(@)';
//   const Matches(this.value);
// }

class IsLessThan implements Validation {
  final num value;
  @override
  final String part = 'isLessThan(@)';
  const IsLessThan(this.value);
}

class IsGreaterThan implements Validation {
  final num value;
  @override
  final String part = 'isGreaterThan(@)';
  const IsGreaterThan(this.value);
}

class IsEqualTo implements Validation {
  final num value;
  @override
  final String part = 'isEqualTo(@)';
  const IsEqualTo(this.value);
}

class IsNotEqualTo implements Validation {
  final num value;
  @override
  final String part = 'isNotEqualTo(@)';
  const IsNotEqualTo(this.value);
}

// class IsTrue extends BoolRule {
//   @override
//   final String part = '.isTrue()';
//   const IsTrue();
// }

// class IsFalse extends BoolRule {
//   @override
//   final String part = '.isFalse()';
//   const IsFalse();
// }

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

