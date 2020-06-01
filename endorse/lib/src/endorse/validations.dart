abstract class Validation {
  final String call = '';
  const Validation();
}

class Required implements Validation {
  @override
  final String call = 'isRequired()';
  const Required();
}

class FromString implements Validation {
  @override
  final String call = 'fromString()';
  const FromString();
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