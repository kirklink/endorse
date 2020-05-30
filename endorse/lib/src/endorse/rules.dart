
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

