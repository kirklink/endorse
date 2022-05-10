import 'patterns.dart';

abstract class ValidationBase {
  final String call = '';
  final validOnTypes = const <Type>[];
  final notValidOnTypes = const <Type>[];
  const ValidationBase();
}

class Required extends ValidationBase {
  @override
  final String call = 'isRequired()';
  const Required();
}

// class ToString extends Validation {
//   @override
//   final String call = 'makeString()';
//   @override
//   final validOnTypes = const [String];
//   const ToString();
// }

class ToStringFromInt extends ValidationBase {
  @override
  final String call = 'makeString()';
  @override
  final validOnTypes = const [String];
  const ToStringFromInt();
}

class ToStringFromDouble extends ValidationBase {
  @override
  final String call = 'makeString()';
  @override
  final validOnTypes = const [String];
  const ToStringFromDouble();
}

class ToStringFromNum extends ValidationBase {
  @override
  final String call = 'makeString()';
  @override
  final validOnTypes = const [String];
  const ToStringFromNum();
}

class ToStringFromBool extends ValidationBase {
  @override
  final String call = 'makeString()';
  @override
  final validOnTypes = const [String];
  const ToStringFromBool();
}

class IntFromString extends ValidationBase {
  @override
  final String call = 'intFromString()';
  @override
  final validOnTypes = const [int];
  const IntFromString();
}

class DoubleFromString extends ValidationBase {
  @override
  final String call = 'doubleFromString()';
  @override
  final validOnTypes = const [double];
  const DoubleFromString();
}

class NumFromString extends ValidationBase {
  @override
  final String call = 'numFromString()';
  @override
  final validOnTypes = const [int, double, num];
  const NumFromString();
}

class BoolFromString extends ValidationBase {
  @override
  final String call = 'boolFromString()';
  @override
  final validOnTypes = const [bool];
  const BoolFromString();
}

class MaxLength extends ValidationBase {
  @override
  final String call = 'maxLength(@)';
  @override
  final validOnTypes = const [String];
  final int value;
  const MaxLength(this.value);
}

class MinLength extends ValidationBase {
  @override
  final String call = 'minLength(@)';
  @override
  final validOnTypes = const [String];
  final int value;
  const MinLength(this.value);
}

class StartsWith extends ValidationBase {
  @override
  final String call = 'startsWith(@)';
  @override
  final validOnTypes = const [String];
  final String value;
  const StartsWith(this.value);
}

class EndsWith extends ValidationBase {
  @override
  final String call = 'endsWith(@)';
  @override
  final validOnTypes = const [String];
  final String value;
  const EndsWith(this.value);
}

class Contains extends ValidationBase {
  @override
  final String call = 'contains(@)';
  @override
  final validOnTypes = const [String];
  final String value;
  const Contains(this.value);
}

class Matches extends ValidationBase {
  @override
  final String call = 'matches(@)';
  @override
  final validOnTypes = const [String];
  final String value;
  const Matches(this.value);
}

class IsLessThan extends ValidationBase {
  @override
  final String call = 'isLessThan(@)';
  @override
  final validOnTypes = const [int, double, num];
  final num value;
  const IsLessThan(this.value);
}

class IsGreaterThan extends ValidationBase {
  @override
  final String call = 'isGreaterThan(@)';
  @override
  final validOnTypes = const [int, double, num];
  final num value;
  const IsGreaterThan(this.value);
}

class IsEqualTo extends ValidationBase {
  @override
  final String call = 'isEqualTo(@)';
  @override
  final validOnTypes = const [int, double, num];
  final num value;
  const IsEqualTo(this.value);
}

class IsNotEqualTo extends ValidationBase {
  @override
  final String call = 'isNotEqualTo(@)';
  @override
  final validOnTypes = const [int, double, num];
  final num value;
  const IsNotEqualTo(this.value);
}

class IsTrue extends ValidationBase {
  @override
  final String call = 'isTrue()';
  @override
  final validOnTypes = const [bool];
  const IsTrue();
}

class IsFalse extends ValidationBase {
  @override
  final String call = 'isFalse()';
  @override
  final validOnTypes = const [bool];
  const IsFalse();
}

class IsBefore extends ValidationBase {
  @override
  final String call = 'isBefore(@)';
  @override
  final validOnTypes = const [DateTime];
  final String value;
  const IsBefore(this.value);
}

class IsAfter extends ValidationBase {
  @override
  final String call = 'isAfter(@)';
  @override
  final validOnTypes = const [DateTime];
  final String value;
  const IsAfter(this.value);
}

class IsAtMoment extends ValidationBase {
  @override
  final String call = 'isAtMoment(@)';
  @override
  final validOnTypes = const [DateTime];
  final String value;
  const IsAtMoment(this.value);
}

class IsSameDateAs extends ValidationBase {
  @override
  final String call = 'isSameDateAs(@)';
  @override
  final validOnTypes = const [DateTime];
  final String value;
  const IsSameDateAs(this.value);
}

class MatchesPattern extends ValidationBase {
  @override
  final String call = 'matchesPattern(r@)';
  @override
  final validOnTypes = const [String];
  final String value;
  const MatchesPattern(this.value);
}

class MatchesRawPattern extends ValidationBase {
  @override
  final String call = 'matchesPattern(r@)';
  @override
  final validOnTypes = const [String];
  final String value;
  const MatchesRawPattern(this.value);
}

class MatchesEscapedPattern extends ValidationBase {
  @override
  final String call = 'matchesPattern(@)';
  @override
  final validOnTypes = const [String];
  final String value;
  const MatchesEscapedPattern(this.value);
}

class IsEmail extends ValidationBase {
  @override
  final String call = 'isEmail(r@)';
  @override
  final validOnTypes = const [String];
  final String value = Patterns.email;
  const IsEmail();
}
