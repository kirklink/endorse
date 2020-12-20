import 'package:endorse/src/endorse/rule.dart';
import 'package:endorse/src/endorse/endorse_exception.dart';

abstract class ValueRule extends Rule {}

class IsRequiredRule extends ValueRule {
  final name = 'IsRequired';
  final skipIfNull = false;
  final causesBail = true;
  final pass = (input, test) => input != null;
  final errorMsg = (input, test) => 'Required.';
}

class IsMapRule extends ValueRule {
  final name = 'IsMap';
  final causesBail = true;
  final pass = (input, test) => input is Map<String, Object>;
  final errorMsg = (input, test) => 'Must be a Map<String, Object>.';
  final want = (input, test) => 'Map<String, Object>';
  final got = (input, test) => input.runtimeType;
}

class IsListRule extends ValueRule {
  final name = 'IsList';
  final causesBail = true;
  final pass = (input, test) => input is List;
  final errorMsg = (input, test) => 'Must be a List.';
  final want = (input, test) => 'List';
  final got = (input, test) => input.runtimeType;
}

class IsStringRule extends ValueRule {
  final name = 'IsString';
  final causesBail = true;
  final pass = (input, test) => input is String;
  final errorMsg = (input, test) => 'Must be a String';
  final want = (input, test) => 'String';
  final got = (input, test) => input.runtimeType;
}

class CanStringRule extends ValueRule {
  final name = 'IsString';
  final causesBail = true;
  final pass = (input, test) {
    try {
      input.toString();
      return true;
    } catch (e) {
      return false;
    }
  };
  final errorMsg = (input, test) => 'Cannot be coerced to String.';
  final want = (input, test) => 'String';
  final got = (input, test) => input.runtimeType;
}

class ToStringRule extends ValueRule {
  final name = 'ToString';
  final causesBail = true;
  final pass = (input, test) {
    try {
      input.toString();
      return true;
    } catch (e) {
      return false;
    }
  };
  final errorMsg = (input, test) => 'Cannot be coerced to String.';
  final want = (input, test) => 'object with toString() method';
  final got = (input, test) => input.runtimeType;
  final cast = (input) => input.toString();
}

class IsNumRule extends ValueRule {
  final name = 'IsNum';
  final causesBail = true;
  final pass = (input, test) => input is num;
  final errorMsg = (input, test) => 'Must be a number.';
  final want = (input, test) => 'num';
  final got = (input, test) => input.runtimeType;
}

class IsIntRule extends ValueRule {
  final name = 'IsInt';
  final causesBail = true;
  final pass = (input, test) => input is int;
  final errorMsg = (input, test) => 'Must be an integer.';
  final want = (input, test) => 'int';
  final got = (input, test) => input.runtimeType;
}

class IsDoubleRule extends ValueRule {
  final name = 'IsDouble';
  final causesBail = true;
  final pass = (input, test) => input is double;
  final errorMsg = (input, test) => 'Must be a double.';
  final want = (input, test) => 'double';
  final got = (input, test) => input.runtimeType;
}

class IsBoolRule extends ValueRule {
  final name = 'IsBool';
  final causesBail = true;
  final pass = (input, test) => input is bool;
  final errorMsg = (input, test) => 'Must be a boolean.';
  final want = (input, test) => 'bool';
  final got = (input, test) => input.runtimeType;
}

class IsDateTimeRule extends ValueRule {
  final name = 'IsDateTime';
  final causesBail = true;
  final pass = (input, test) => _inputDateConverter(input) != null;
  final errorMsg = (input, test) => 'Must be a datetime.';
  final cast = (input) => _inputDateConverter(input);
}

class CanIntFromStringRule extends ValueRule {
  final name = 'IntFromString';
  final causesBail = true;
  final pass = (input, test) => input is String && int.tryParse(input) != null;
  final errorMsg =
      (input, test) => 'Could not cast to integer from ${input.runtimeType}.';
  final want = (input, test) => 'String';
  final got = (input, test) => input.runtimeType;
}

class IntFromStringRule extends ValueRule {
  final name = 'IntFromString';
  final causesBail = true;
  final pass = (input, test) => int.tryParse(input) != null;
  final errorMsg = (input, test) => 'Could not cast to integer from string.';
  final cast = (input) => int.parse(input);
}

class CanDoubleFromStringRule extends ValueRule {
  final name = 'DoubleFromString';
  final causesBail = true;
  final pass =
      (input, test) => input is String && double.tryParse(input) != null;
  final errorMsg =
      (input, test) => 'Could not cast to double from ${input.runtimeType}.';
  final want = (input, test) => 'String';
  final got = (input, test) => input.runtimeType;
}

class DoubleFromStringRule extends ValueRule {
  final name = 'DoubleFromString';
  final causesBail = true;
  final pass = (input, test) => double.tryParse(input) != null;
  final errorMsg = (input, test) => 'Could not cast to double from string.';
  final cast = (input) => double.parse(input);
}

class CanNumFromStringRule extends ValueRule {
  final name = 'NumFromString';
  final causesBail = true;
  final pass = (input, test) => input is String && num.tryParse(input) != null;
  final errorMsg =
      (input, test) => 'Could not cast to number from ${input.runtimeType}.';
  final want = (input, test) => 'String';
  final got = (input, test) => input.runtimeType;
}

class NumFromStringRule extends ValueRule {
  final name = 'NumFromString';
  final causesBail = true;
  final pass = (input, test) => num.tryParse(input) != null;
  final errorMsg = (input, test) => 'Could not cast to number from string.';
  final cast = (input) => num.parse(input);
}

class CanBoolFromStringRule extends ValueRule {
  final name = 'BoolFromString';
  final causesBail = true;
  final pass =
      (input, test) => input is String && (input == 'true' || input == 'false');
  final errorMsg =
      (input, test) => 'Could not cast to boolean from ${input.runtimeType}.';
}

class BoolFromStringRule extends ValueRule {
  final name = 'BoolFromString';
  final causesBail = true;
  final pass = (input, test) => input == 'true' || input == 'false';
  final errorMsg = (input, test) => 'Could not cast to boolean from string.';
  final cast = (input) => input == 'true' ? true : false;
  final want = (input, test) => 'String';
  final got = (input, test) => input.runtimeType;
}

class MaxLengthRule extends ValueRule {
  final name = 'MaxLength';
  final pass = (input, test) => (input as String).length <= test;
  final got = (input, test) => (input as String).length;
  final want = (input, test) => '< ${test}';
  final errorMsg = (input, test) => 'Length must be less than ${test}.';
}

class MinLengthRule extends ValueRule {
  final name = 'MinLength';
  final pass = (input, test) => (input as String).length >= test;
  final got = (input, test) => (input as String).length;
  final want = (input, test) => '> ${test}';
  final errorMsg = (input, test) => 'Length must be greater than ${test}.';
}

class MatchesRule extends ValueRule {
  final name = 'Matches';
  final pass = (input, test) => (input as String) == test;
  final errorMsg = (input, test) => 'Must match: "${test}".';
}

class ContainsRule extends ValueRule {
  final name = 'Contains';
  final pass = (input, test) => (input as String).contains(test);
  final errorMsg = (input, test) => 'Must contain: "${test}".';
}

class StartsWithRule extends ValueRule {
  final name = 'StartsWith';
  final pass = (input, test) => (input as String).startsWith(test);
  final restriction = (input) => input is String;
  final errorMsg = (input, test) => 'Must start with: "${test}".';
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
  final errorMsg = (input, test) => 'Must end with: "${test}".';
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
  final errorMsg = (input, test) => 'Must equal ${test}.';
}

class IsNotEqualToRule extends ValueRule {
  final name = 'IsNotEqualTo';
  final pass = (input, test) => input != test;
  final errorMsg = (input, test) => 'Must not equal ${test}.';
}

class IsLessThanRule extends ValueRule {
  final name = 'IsLessThan';
  final pass = (input, test) => input as num < test;
  final errorMsg = (input, test) => 'Must be less than ${test}.';
  final want = (input, test) => '< $test';
}

class IsGreaterThanRule extends ValueRule {
  final name = 'IsGreaterThan';
  final pass = (input, test) => input as num > test;
  final errorMsg = (input, test) => 'Must be greater than ${test}.';
  final want = (input, test) => '> $test';
}

class IsTrueRule extends ValueRule {
  final name = 'IsTrue';
  final pass = (input, test) => input as bool == true;
  final errorMsg = (input, test) => 'Must be true.';
  final want = (input, test) => true;
}

class IsFalseRule extends ValueRule {
  final name = 'IsFalse';
  final pass = (input, test) => input as bool == false;
  final errorMsg = (input, test) => 'Must be false.';
  final want = (input, test) => false;
}

class IsBeforeRule extends ValueRule {
  final name = 'IsBefore';
  static DateTime _test;
  final check = (input, test) {
    _test = _testDateConverter(test);
    return _test != null ? '' : 'Could not parse "$test" to DateTime.';
  };
  final pass = (input, test) => _inputDateConverter(input).isBefore(_test);
  final want = (input, test) => '< ${_test}';
  final got =
      (input, test) => '${_inputDateConverter(input).toIso8601String()}';
  final errorMsg = (input, test) => 'Must be before ${_test}.';
  final cleanup = () => _test = null;
}

class IsAfterRule extends ValueRule {
  final name = 'IsAfter';
  static DateTime _test;
  final check = (input, test) {
    _test = _testDateConverter(test);
    return _test != null ? '' : 'Could not parse "$test" to DateTime.';
  };
  final pass = (input, test) =>
      _inputDateConverter(input).isAfter(_testDateConverter(test));
  final want = (input, test) => '> ${_test}';
  final got = (input, test) => '${_inputDateConverter(input)}';
  final errorMsg = (input, test) => 'Must be after ${_test}.';
  final cleanup = () => _test = null;
}

class IsAtMomentRule extends ValueRule {
  final name = 'IsAtMoment';
  static DateTime _test;
  final check = (input, test) {
    _test = _testDateConverter(test);
    return _test != null ? '' : 'Could not parse "$test" to DateTime.';
  };
  final pass = (input, test) =>
      _inputDateConverter(input).isAtSameMomentAs(_testDateConverter(test));
  final want = (input, test) => '== ${_test}';
  final got = (input, test) => '${input as DateTime}';
  final errorMsg = (input, test) => 'Must be after ${_test}.';
  final cleanup = () => _test = null;
}

class IsSameDateAsRule extends ValueRule {
  final name = 'IsSameDateAs';
  static DateTime _test;
  final check = (input, test) {
    _test = _testDateConverter(test);
    return _test != null ? '' : 'Could not parse "$test" to DateTime.';
  };
  final pass = (input, test) {
    final inputDt = _inputDateConverter(input);
    // final testDt = _testDateConverter(test);
    return inputDt.year == _test.year &&
        inputDt.month == _test.month &&
        inputDt.day == _test.day;
  };
  final want = (input, test) => '${_test.year}-${_test.month}-${_test.day}';
  final got = (input, test) {
    final date = _inputDateConverter(input);
    return '${date.year}-${date.month}-${date.day}';
  };
  final errorMsg =
      (input, test) => 'Must be on ${_test.year}-${_test.month}-${_test.day}';
  final cleanup = () => _test = null;
}

class MatchesPatternRule extends ValueRule {
  final name = 'MatchesPattern';
  final check = (input, test) {
    try {
      final regExp = RegExp(test);
    } catch (e) {
      return 'Pattern "$test" is not a valid RegExp';
    }
    return '';
  };
  final pass = (input, test) {
    return RegExp(test as String).hasMatch(input as String);
  };
  final want = (input, test) => 'Has match with ${test as String}';
  final got = (input, test) => 'No matches in ${input as String}';
  final errorMsg = (input, test) =>
      '${test as String} does not have a match in ${input as String}';
}

/********************/
/* HELPER FUNCTIONS */
/********************/

DateTime _inputDateConverter(Object input) {
  if (input is DateTime) {
    return input.toUtc();
  } else if (input is String) {
    try {
      return DateTime.parse(input).toUtc();
    } catch (e) {
      return null;
    }
  } else {
    return null;
  }
}

DateTime _testDateConverter(String test) {
  if ('now' == test.toLowerCase()) {
    return DateTime.now();
  } else if (test.startsWith('today')) {
    final now = DateTime.now();
    final nowYear = now.year;
    final nowMonth = now.month;
    final nowDay = now.day;
    final safeDate = DateTime.utc(nowYear, nowMonth, nowDay);
    if (test == 'today') {
      return safeDate;
    }
    final forward = test.split('+');
    if (forward.length == 2 &&
        forward[0] == 'today' &&
        int.tryParse(forward[1]) != null) {
      return safeDate.add(Duration(days: int.parse(forward[1])));
    }
    final back = test.split('-');
    if (back.length == 2 &&
        back[0] == 'today' &&
        int.tryParse(back[1]) != null) {
      return safeDate.subtract(Duration(days: int.parse(back[1])));
    }
  } else if (DateTime.tryParse(test) != null) {
    return DateTime.parse(test);
  }
  return null;
}
