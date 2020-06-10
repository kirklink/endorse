import 'package:endorse/src/endorse/rule.dart';


abstract class ValueRule extends Rule{}

class IsRequiredRule extends ValueRule {
  final name = 'required';
  final causesBail = true;
  final pass = (input, test) => input != null;
  final errorMsg = 'is required';
}

class IsMapRule extends ValueRule {
  final name = 'IsMap';
  final causesBail = true;
  final pass = (input, test) => input is Map<String, Object>;
  final errorMsg = 'must be a';
  final want = (input, test) => 'Map<String, Object>';
  final got = (input, test) => input.runtimeType;
}

class IsListRule extends ValueRule {
  final name = 'IsList';
  final causesBail = true;
  final pass = (input, test) => input is List;
  final errorMsg = 'must be a';
  final want = (input, test) => 'List';
  final got = (input, test) => input.runtimeType;
}

class IsStringRule extends ValueRule {
  final name = 'IsString';
  final causesBail = true;
  final pass = (input, test) => input is String;
  final errorMsg = 'must be a';
  final want = (input, test) => 'String';
  final got = (input, test) => input.runtimeType;
}

class IsNumRule extends ValueRule {
  final name = 'IsNum';
  final causesBail = true;
  final pass = (input, test) => input is num;
  final errorMsg = 'must be an';
  final want = (input, test) => 'num';
  final got = (input, test) => input.runtimeType;
}

class IsIntRule extends ValueRule {
  final name = 'IsInt';
  final causesBail = true;
  final pass = (input, test) => input is int;
  final errorMsg = 'must be an';
  final want = (input, test) => 'int';
  final got = (input, test) => input.runtimeType;
}

class IsDoubleRule extends ValueRule {
  final name = 'IsDouble';
  final causesBail = true;
  final pass = (input, test) => input is double;
  final errorMsg = 'must be a';
  final want = (input, test) => 'double';
  final got = (input, test) => input.runtimeType;
}

class IsBoolRule extends ValueRule {
  final name = 'IsBool';
  final causesBail = true;
  final pass = (input, test) => input is bool;
  final errorMsg = 'must be a';
  final want = (input, test) => 'bool';
  final got = (input, test) => input.runtimeType;
}

class IsDateTimeRule extends ValueRule {
  final name = 'IsDateTime';
  final causesBail = true;
  final pass = (input, test) => DateTime.tryParse(input) != null;
  final errorMsg = 'could not parse a DateTime';
  final cast = (input) => DateTime.parse(input);
}

class IntFromStringRule extends ValueRule {
  final name = 'IntFromString';
  final causesBail = true;
  final pass = (input, test) => int.tryParse(input) != null;
  final errorMsg = 'could not cast to int from String';
  final cast = (input) => int.parse(input);
}

class DoubleFromStringRule extends ValueRule {
  final name = 'DoubleFromString';
  final causesBail = true;
  final pass = (input, test) => double.tryParse(input) != null;
  final errorMsg = 'could not cast to double from String';
  final cast = (input) => double.parse(input);
}

class BoolFromStringRule extends ValueRule {
  final name = 'BoolFromString';
  final causesBail = true;
  final pass = (input, test) => input == 'true' || input == 'false';
  final errorMsg = 'could not cast to bool from String';
  final cast = (input) => input == 'true' ? true : false;
}


class MaxLengthRule extends ValueRule {
  final name = 'MaxLength';
  final pass = (input, test) => (input as String).length < test;
  final got = (input, test) => (input as String).length;
  final errorMsg = 'length must be less than';
}

class MinLengthRule extends ValueRule {
  final name = 'MinLength';
  final pass = (input, test) => (input as String).length > test;
  final got = (input, test) => (input as String).length;
  final errorMsg = 'length must be greater than';
}

class MatchesRule extends ValueRule {
  final name = 'Matches';
  final pass = (input, test) => (input as String) == test;
  final errorMsg = 'must match:';
}

class ContainsRule extends ValueRule {
  final name = 'Contains';
  final pass = (input, test) => (input as String).contains(test);
  final errorMsg = 'must contain:';
}

class StartsWithRule extends ValueRule {
  final name = 'StartsWith';
  final pass = (input, test) => (input as String).startsWith(test);
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
  final errorMsg = 'must equal';
}

class IsNotEqualToRule extends ValueRule {
  final name = 'IsNotEqualTo';
  final pass = (input, test) => input != test;
  final errorMsg = 'must not equal';
}

class IsLessThanRule extends ValueRule {
  final name = 'IsLessThan';
  final pass = (input, test) => input as num < test;
  final errorMsg = 'must be less than';
}

class IsGreaterThanRule extends ValueRule {
  final name = 'IsGreaterThan';
  final pass = (input, test) => input as num > test;
  final errorMsg = 'must be greater than';
}

class IsTrueRule extends ValueRule {
  final name = 'IsTrue';
  final pass = (input, test) => input as bool == true;
  final errorMsg = 'must be';
  final want = (input, test) => true;
}

class IsFalseRule extends ValueRule {
  final name = 'IsFalse';
  final pass = (input, test) => input as bool == false;
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

