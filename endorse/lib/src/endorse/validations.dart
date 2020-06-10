abstract class Validation {
  final String call = '';
  final validOnTypes = const <Type>[];
  final notValidOnTypes = const <Type>[];
  const Validation();
}

class Required extends Validation {
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

class ToStringFromInt extends Validation {
  @override
  final String call = 'makeString()';
  @override
  final validOnTypes = const [String];
  const ToStringFromInt();
}

class ToStringFromDouble extends Validation {
  @override
  final String call = 'makeString()';
  @override
  final validOnTypes = const [String];
  const ToStringFromDouble();
}

class ToStringFromNum extends Validation {
  @override
  final String call = 'makeString()';
  @override
  final validOnTypes = const [String];
  const ToStringFromNum();
}

class ToStringFromBool extends Validation {
  @override
  final String call = 'makeString()';
  @override
  final validOnTypes = const [String];
  const ToStringFromBool();
}

class IntFromString extends Validation {
  @override
  final String call = 'intFromString()';
  @override
  final validOnTypes = const [int];
  const IntFromString();
}

class DoubleFromString extends Validation {
  @override
  final String call = 'doubleFromString()';
  @override
  final validOnTypes = const [double];
  const DoubleFromString();
}

class NumFromString extends Validation {
  @override
  final String call = 'numFromString()';
  @override
  final validOnTypes = const [int, double, num];
  const NumFromString();
}

class BoolFromString extends Validation {
  @override
  final String call = 'boolFromString()';
  @override
  final validOnTypes = const [bool];
  const BoolFromString();
}

class MaxLength extends Validation {
  @override
  final String call = 'maxLength(@)';
  @override
  final validOnTypes = const [String];
  final int value;
  const MaxLength(this.value);
}

class MinLength extends Validation {
  @override
  final String call = 'minLength(@)';
  @override
  final validOnTypes = const [String];
  final int value;
  const MinLength(this.value);
}

class StartsWith extends Validation {
  @override
  final String call = 'startsWith(@)';
  @override
  final validOnTypes = const [String];
  final String value;
  const StartsWith(this.value);
}

class EndsWith extends Validation {
  @override
  final String call = 'endsWith(@)';
  @override
  final validOnTypes = const [String];
  final String value;
  const EndsWith(this.value);
}

class Contains extends Validation {
  @override
  final String call = 'contains(@)';
  @override
  final validOnTypes = const [String];
  final String value;
  const Contains(this.value);
}

class Matches extends Validation {
  @override
  final String call = 'matches(@)';
  @override
  final validOnTypes = const [String];
  final String value;
  const Matches(this.value);
}

class IsLessThan extends Validation {
  @override
  final String call = 'isLessThan(@)';
  @override
  final validOnTypes = const [int, double, num];
  final num value;
  const IsLessThan(this.value);
}

class IsGreaterThan extends Validation {
  @override
  final String call = 'isGreaterThan(@)';
  @override
  final validOnTypes = const [int, double, num];
  final num value;
  const IsGreaterThan(this.value);
}

class IsEqualTo extends Validation {
  @override
  final String call = 'isEqualTo(@)';
  @override
  final validOnTypes = const [int, double, num];
  final num value;
  const IsEqualTo(this.value);
}

class IsNotEqualTo extends Validation {
  @override
  final String call = 'isNotEqualTo(@)';
  @override
  final validOnTypes = const [int, double, num];
  final num value;
  const IsNotEqualTo(this.value);
}

class IsTrue extends Validation {
  @override
  final String call = 'isTrue()';
  @override
  final validOnTypes = const [bool];
  const IsTrue();
}

class IsFalse extends Validation {
  @override
  final String call = 'isFalse()';
  @override
  final validOnTypes = const [bool];
  const IsFalse();
}