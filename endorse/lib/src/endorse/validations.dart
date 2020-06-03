abstract class Validation {
  final String call = '';
  final validOnTypes = const <Type>[];
  const Validation();
}

class Required extends Validation {
  @override
  final String call = 'isRequired()';
  const Required();
}

class FromString extends Validation {
  @override
  final String call = 'fromString()';
  const FromString();
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
  final String value;
  @override
  final String call = 'startsWith(@)';
  const StartsWith(this.value);
}

class EndsWith extends Validation {
  final String value;
  @override
  final String call = 'endsWith(@)';
  const EndsWith(this.value);
}

class Contains extends Validation {
  final String value;
  @override
  final String call = 'contains(@)';
  const Contains(this.value);
}

class Matches extends Validation {
  final String value;
  @override
  final String call = 'matches(@)';
  const Matches(this.value);
}

class IsLessThan extends Validation {
  final num value;
  @override
  final String call = 'isLessThan(@)';
  const IsLessThan(this.value);
}

class IsGreaterThan extends Validation {
  final num value;
  @override
  final String call = 'isGreaterThan(@)';
  const IsGreaterThan(this.value);
}

class IsEqualTo extends Validation {
  final num value;
  @override
  final String call = 'isEqualTo(@)';
  const IsEqualTo(this.value);
}

class IsNotEqualTo extends Validation {
  final num value;
  @override
  final String call = 'isNotEqualTo(@)';
  const IsNotEqualTo(this.value);
}

class IsTrue extends Validation {
  @override
  final String call = 'isTrue()';
  const IsTrue();
}

class IsFalse extends Validation {
  @override
  final String call = 'isFalse()';
  const IsFalse();
}