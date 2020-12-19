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
  final pass = (input, test) =>
      input is DateTime || DateTime.tryParse(input as String) != null;
  final errorMsg = (input, test) => 'Must be a datetime.';
  final cast =
      (input) => input is DateTime ? input : DateTime.parse(input as String);
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
  final pass = (input, test) {
    if (test == null || DateTime.tryParse(test) == null) {
      throw Exception(
          'The test string "$test" could not be parsed to DateTime.');
    }
    return (input as DateTime).isBefore(DateTime.parse(test));
  };
  final want =
      (input, test) => '< ${DateTime.parse(test as String).toIso8601String()}';
  final got = (input, test) => '${(input as DateTime).toIso8601String()}';
  final errorMsg = (input, test) =>
      'Must be before ${DateTime.parse(test as String).toIso8601String()}.';
}

class IsAfterRule extends ValueRule {
  final name = 'IsAfter';
  final pass = (input, test) {
    if (test == null || DateTime.tryParse(test) == null) {
      throw EndorseException(
          'The test string "$test" could not be parsed to DateTime.');
    }
    return (input as DateTime).isAfter(DateTime.parse(test));
  };
  final want =
      (input, test) => '> ${DateTime.parse(test as String).toIso8601String()}';
  final got = (input, test) => '${(input as DateTime).toIso8601String()}';
  final errorMsg = (input, test) =>
      'Must be after ${DateTime.parse(test as String).toIso8601String()}.';
}

class IsAtMomentRule extends ValueRule {
  final name = 'IsAtMoment';
  final pass = (input, test) {
    if (test == null || DateTime.tryParse(test) == null) {
      throw EndorseException(
          'The test string "$test" could not be parsed to DateTime.');
    }
    return (input as DateTime).isAtSameMomentAs(DateTime.parse(test));
  };
  final want =
      (input, test) => '== ${DateTime.parse(test as String).toIso8601String()}';
  final got = (input, test) => '${(input as DateTime).toIso8601String()}';
  final errorMsg = (input, test) =>
      'Must be after ${DateTime.parse(test as String).toIso8601String()}.';
}

class IsSameDateAsRule extends ValueRule {
  final name = 'IsSameDateAs';
  final pass = (input, test) {
    if (test == null || DateTime.tryParse(test) == null) {
      throw EndorseException(
          'The test string "$test" could not be parsed to DateTime.');
    }
    final inputDateTime = input as DateTime;
    final testDateTime = DateTime.parse(test as String);
    return inputDateTime.year == testDateTime.year &&
        inputDateTime.month == testDateTime.month &&
        inputDateTime.day == testDateTime.day;
  };
  final want = (input, test) {
    final date = DateTime.parse(test as String);
    return '${date.year}-${date.month}-${date.day}';
  };
  final got = (input, test) {
    final date = input as DateTime;
    return '${date.year}-${date.month}-${date.day}';
  };
  final errorMsg = (input, test) {
    final date = input as DateTime;
    return 'Must be on ${date.year}-${date.month}-${date.day}';
  };
}

class MatchesPatternRule extends ValueRule {
  final name = 'MatchesPattern';
  final pass = (input, test) {
    RegExp regExp;
    try {
      regExp = RegExp(test);
    } catch (e) {
      throw EndorseException('Pattern "test" is not a valid RegExp');
    }
    return regExp.hasMatch(input as String);
  };
  final want = (input, test) => 'Has match with ${test as String}';
  final got = (input, test) => 'No matches in ${input as String}';
  final errorMsg = (input, test) =>
      '${test as String} does not have a match in ${input as String}';
}
