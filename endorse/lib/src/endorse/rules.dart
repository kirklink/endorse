import 'package:endorse/src/endorse/rule.dart';

abstract class ValueRule extends Rule {}

class IsRequiredRule extends ValueRule {
  final name = 'IsRequired';
  final skipIfNull = false;
  final causesBail = true;
  final PassFunction pass = (input, test) =>
      input != null && (input is String) ? input.isNotEmpty : true;
  final ErrorMessage errorMsg = (input, test) => 'Required.';
}

class IsMapRule extends ValueRule {
  final name = 'IsMap';
  final causesBail = true;
  final PassFunction pass = (input, test) => input is Map<String, Object>;
  final ErrorMessage errorMsg =
      (input, test) => 'Must be a Map<String, Object>.';
  final WantFunction want = (input, test) => 'Map<String, Object>';
  final GotFunction got = (input, test) => input.runtimeType;
}

class IsListRule extends ValueRule {
  final name = 'IsList';
  final causesBail = true;
  final PassFunction pass = (input, test) => input is List;
  final ErrorMessage errorMsg = (input, test) => 'Must be a List.';
  final WantFunction want = (input, test) => 'List';
  final GotFunction got = (input, test) => input.runtimeType;
}

class IsStringRule extends ValueRule {
  final name = 'IsString';
  final causesBail = true;
  final PassFunction pass = (input, test) => input is String;
  final ErrorMessage errorMsg = (input, test) => 'Must be a String';
  final WantFunction want = (input, test) => 'String';
  final GotFunction got = (input, test) => input.runtimeType;
}

class CanStringRule extends ValueRule {
  final name = 'IsString';
  final causesBail = true;
  final PassFunction pass = (input, test) {
    try {
      input.toString();
      return true;
    } catch (e) {
      return false;
    }
  };
  final ErrorMessage errorMsg = (input, test) => 'Cannot be coerced to String.';
  final WantFunction want = (input, test) => 'String';
  final GotFunction got = (input, test) => input.runtimeType;
}

class ToStringRule extends ValueRule {
  final name = 'ToString';
  final causesBail = true;
  final PassFunction pass = (input, test) {
    try {
      input.toString();
      return true;
    } catch (e) {
      return false;
    }
  };
  final ErrorMessage errorMsg = (input, test) => 'Cannot be coerced to String.';
  final WantFunction want = (input, test) => 'object with toString() method';
  final GotFunction got = (input, test) => input.runtimeType;
  final CastFunction cast = (input) => input.toString();
}

class IsNumRule extends ValueRule {
  final name = 'IsNum';
  final causesBail = true;
  final PassFunction pass = (input, test) => input is num;
  final ErrorMessage errorMsg = (input, test) => 'Must be a number.';
  final WantFunction want = (input, test) => 'num';
  final GotFunction got = (input, test) => input.runtimeType;
}

class IsIntRule extends ValueRule {
  final name = 'IsInt';
  final causesBail = true;
  final PassFunction pass = (input, test) => input is int;
  final ErrorMessage errorMsg = (input, test) => 'Must be an integer.';
  final WantFunction want = (input, test) => 'int';
  final GotFunction got = (input, test) => input.runtimeType;
}

class IsDoubleRule extends ValueRule {
  final name = 'IsDouble';
  final causesBail = true;
  final PassFunction pass = (input, test) => input is double;
  final ErrorMessage errorMsg = (input, test) => 'Must be a double.';
  final WantFunction want = (input, test) => 'double';
  final GotFunction got = (input, test) => input.runtimeType;
}

class IsBoolRule extends ValueRule {
  final name = 'IsBool';
  final causesBail = true;
  final PassFunction pass = (input, test) => input is bool;
  final ErrorMessage errorMsg = (input, test) => 'Must be a boolean.';
  final WantFunction want = (input, test) => 'bool';
  final GotFunction got = (input, test) => input.runtimeType;
}

class IsDateTimeRule extends ValueRule {
  final name = 'IsDateTime';
  final causesBail = true;
  final PassFunction pass = (input, test) => _inputDateConverter(input) != null;
  final ErrorMessage errorMsg = (input, test) => 'Must be a datetime.';
  final Object? Function(Object?) cast = (input) => _inputDateConverter(input);
}

class CanIntFromStringRule extends ValueRule {
  final name = 'IntFromString';
  final causesBail = true;
  final PassFunction pass =
      (input, test) => input is String && int.tryParse(input) != null;
  final ErrorMessage errorMsg =
      (input, test) => 'Could not cast to integer from ${input.runtimeType}.';
  final WantFunction want = (input, test) => 'String';
  final GotFunction got = (input, test) => input.runtimeType;
}

class IntFromStringRule extends ValueRule {
  final name = 'IntFromString';
  final causesBail = true;
  final PassFunction pass =
      (input, test) => int.tryParse(input as String) != null;
  final ErrorMessage errorMsg =
      (input, test) => 'Could not cast to integer from string.';
  final CastFunction cast = (input) => int.parse(input as String);
}

class CanDoubleFromStringRule extends ValueRule {
  final name = 'DoubleFromString';
  final causesBail = true;
  final PassFunction pass =
      (input, test) => input is String && double.tryParse(input) != null;
  final ErrorMessage errorMsg =
      (input, test) => 'Could not cast to double from ${input.runtimeType}.';
  final WantFunction want = (input, test) => 'String';
  final GotFunction got = (input, test) => input.runtimeType;
}

class DoubleFromStringRule extends ValueRule {
  final name = 'DoubleFromString';
  final causesBail = true;
  final PassFunction pass =
      (input, test) => double.tryParse(input as String) != null;
  final ErrorMessage errorMsg =
      (input, test) => 'Could not cast to double from string.';
  final CastFunction cast = (input) => double.parse(input as String);
}

class CanNumFromStringRule extends ValueRule {
  final name = 'NumFromString';
  final causesBail = true;
  final PassFunction pass =
      (input, test) => input is String && num.tryParse(input) != null;
  final ErrorMessage errorMsg =
      (input, test) => 'Could not cast to number from ${input.runtimeType}.';
  final WantFunction want = (input, test) => 'String';
  final GotFunction got = (input, test) => input.runtimeType;
}

class NumFromStringRule extends ValueRule {
  final name = 'NumFromString';
  final causesBail = true;
  final PassFunction pass =
      (input, test) => num.tryParse(input as String) != null;
  final ErrorMessage errorMsg =
      (input, test) => 'Could not cast to number from string.';
  final CastFunction cast = (input) => num.parse(input as String);
}

class CanBoolFromStringRule extends ValueRule {
  final name = 'BoolFromString';
  final causesBail = true;
  final PassFunction pass =
      (input, test) => input is String && (input == 'true' || input == 'false');
  final ErrorMessage errorMsg =
      (input, test) => 'Could not cast to boolean from ${input.runtimeType}.';
}

class BoolFromStringRule extends ValueRule {
  final name = 'BoolFromString';
  final causesBail = true;
  final PassFunction pass =
      (input, test) => input == 'true' || input == 'false';
  final ErrorMessage errorMsg =
      (input, test) => 'Could not cast to boolean from string.';
  final CastFunction cast = (input) => input == 'true' ? true : false;
  final WantFunction want = (input, test) => 'String';
  final GotFunction got = (input, test) => input.runtimeType;
}

class MaxLengthRule extends ValueRule {
  final name = 'MaxLength';
  final PassFunction pass =
      (input, test) => (input as String).length <= (test as num);
  final GotFunction got = (input, test) => (input as String).length;
  final WantFunction want = (input, test) => '< ${test}';
  final ErrorMessage errorMsg =
      (input, test) => 'Length must be less than ${test}.';
}

class MinLengthRule extends ValueRule {
  final name = 'MinLength';
  final PassFunction pass =
      (input, test) => (input as String).length >= (test as num);
  final GotFunction got = (input, test) => (input as String).length;
  final WantFunction want = (input, test) => '> ${test}';
  final ErrorMessage errorMsg =
      (input, test) => 'Length must be greater than ${test}.';
}

class MatchesRule extends ValueRule {
  final name = 'Matches';
  final PassFunction pass = (input, test) => (input as String?) == test;
  final ErrorMessage errorMsg = (input, test) => 'Must match: "${test}".';
}

class ContainsRule extends ValueRule {
  final name = 'Contains';
  final PassFunction pass =
      (input, test) => (input as String).contains(test as Pattern);
  final ErrorMessage errorMsg = (input, test) => 'Must contain: "${test}".';
}

class StartsWithRule extends ValueRule {
  final name = 'StartsWith';
  final PassFunction pass =
      (input, test) => (input as String).startsWith(test as Pattern);
  final restriction = (input) => input is String;
  final ErrorMessage errorMsg = (input, test) => 'Must start with: "${test}".';
  final GotFunction got = (input, test) {
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
  final PassFunction pass =
      (input, test) => (input as String).endsWith(test as String);
  final restriction = (input) => input is String;
  final ErrorMessage errorMsg = (input, test) => 'Must end with: "${test}".';
  final GotFunction got = (input, test) {
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
  final PassFunction pass = (input, test) => input == test;
  final ErrorMessage errorMsg = (input, test) => 'Must equal ${test}.';
}

class IsNotEqualToRule extends ValueRule {
  final name = 'IsNotEqualTo';
  final PassFunction pass = (input, test) => input != test;
  final ErrorMessage errorMsg = (input, test) => 'Must not equal ${test}.';
}

class IsLessThanRule extends ValueRule {
  final name = 'IsLessThan';
  final PassFunction pass = (input, test) => (input as num) < (test as num);
  final ErrorMessage errorMsg = (input, test) => 'Must be less than ${test}.';
  final WantFunction want = (input, test) => '< $test';
}

class IsGreaterThanRule extends ValueRule {
  final name = 'IsGreaterThan';
  final PassFunction pass = (input, test) => (input as num) > (test as num);
  final ErrorMessage errorMsg =
      (input, test) => 'Must be greater than ${test}.';
  final WantFunction want = (input, test) => '> $test';
}

class IsTrueRule extends ValueRule {
  final name = 'IsTrue';
  final PassFunction pass =
      (input, test) => input != null && input as bool == true;
  final ErrorMessage errorMsg = (input, test) => 'Must be true.';
  final WantFunction want = (input, test) => true;
}

class IsFalseRule extends ValueRule {
  final name = 'IsFalse';
  final PassFunction pass =
      (input, test) => input != null && input as bool == false;
  final ErrorMessage errorMsg = (input, test) => 'Must be false.';
  final WantFunction want = (input, test) => false;
}

class IsBeforeRule extends ValueRule {
  final name = 'IsBefore';
  static DateTime? _test;
  final PreCondition check = (input, test) {
    _test = _testDateConverter(test as String);
    return _test != null ? '' : 'Could not parse "$test" to DateTime.';
  };
  final PassFunction pass =
      (input, test) => _inputDateConverter(input)!.isBefore(_test!);
  final WantFunction want = (input, test) => '< ${_test}';
  final GotFunction got =
      (input, test) => '${_inputDateConverter(input)!.toIso8601String()}';
  final ErrorMessage errorMsg = (input, test) => 'Must be before ${_test}.';
  final void Function() cleanup = () => _test = null;
}

class IsAfterRule extends ValueRule {
  final name = 'IsAfter';
  static DateTime? _test;
  final PreCondition check = (input, test) {
    _test = _testDateConverter(test as String);
    return _test != null ? '' : 'Could not parse "$test" to DateTime.';
  };
  final PassFunction pass = (input, test) =>
      _inputDateConverter(input)!.isAfter(_testDateConverter(test as String)!);
  final WantFunction want = (input, test) => '> ${_test}';
  final GotFunction got = (input, test) => '${_inputDateConverter(input)}';
  final ErrorMessage errorMsg = (input, test) => 'Must be after ${_test}.';
  final void Function() cleanup = () => _test = null;
}

class IsAtMomentRule extends ValueRule {
  final name = 'IsAtMoment';
  static DateTime? _test;
  final PreCondition check = (input, test) {
    _test = _testDateConverter(test as String);
    return _test != null ? '' : 'Could not parse "$test" to DateTime.';
  };
  final PassFunction pass = (input, test) => _inputDateConverter(input)!
      .isAtSameMomentAs(_testDateConverter(test as String)!);
  final WantFunction want = (input, test) => '== ${_test}';
  final GotFunction got = (input, test) => '${input as DateTime}';
  final ErrorMessage errorMsg = (input, test) => 'Must be at ${_test}.';
  final void Function() cleanup = () => _test = null;
}

class IsSameDateAsRule extends ValueRule {
  final name = 'IsSameDateAs';
  static DateTime? _test;
  final PreCondition check = (input, test) {
    _test = _testDateConverter(test as String);
    return _test != null ? '' : 'Could not parse "$test" to DateTime.';
  };
  final PassFunction pass = (input, test) {
    final inputDt = _inputDateConverter(input)!;
    // final testDt = _testDateConverter(test);
    return inputDt.year == _test!.year &&
        inputDt.month == _test!.month &&
        inputDt.day == _test!.day;
  };
  final WantFunction want =
      (input, test) => '${_test!.year}-${_test!.month}-${_test!.day}';
  final GotFunction got = (input, test) {
    final date = _inputDateConverter(input)!;
    return '${date.year}-${date.month}-${date.day}';
  };
  final ErrorMessage errorMsg = (input, test) =>
      'Must be on ${_test!.year}-${_test!.month}-${_test!.day}';
  final void Function() cleanup = () => _test = null;
}

class MatchesPatternRule extends ValueRule {
  final name = 'MatchesPattern';
  final PreCondition check = (input, test) {
    try {
      final _ = RegExp(test as String);
    } catch (e) {
      return 'Pattern "$test" is not a valid RegExp';
    }
    return '';
  };
  final PassFunction pass = (input, test) {
    return RegExp(test as String).hasMatch(input as String);
  };
  final WantFunction want = (input, test) => 'Has match with ${test as String}';
  final GotFunction got = (input, test) => 'No matches in ${input as String}';
  final ErrorMessage errorMsg = (input, test) =>
      '${test as String} does not have a match in ${input as String}';
}

class IsEmailRule extends MatchesPatternRule {
  final name = 'IsEmail';
  final WantFunction want = (input, test) => 'A valid email.';
  final got = (input, test) => input;
  final ErrorMessage errorMsg =
      (input, test) => '$input is not a valid email address.';
}

/********************/
/* HELPER FUNCTIONS */
/********************/

DateTime? _inputDateConverter(Object? input) {
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

DateTime? _testDateConverter(String test) {
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
