
abstract class Rule {
  final String part = '';
  const Rule();
}

abstract class StringRule extends Rule {
  @override
  final String part = '';
  const StringRule();
}

abstract class NumberRule extends Rule {
  @override
  final String part = '';
  const NumberRule();
}

abstract class BoolRule extends Rule {
  @override
  final String part = '';
  const BoolRule();
}

abstract class DateTimeRule extends Rule {
  @override
  final String part = '';
  const DateTimeRule();
}

class MaxLength extends StringRule {
  final int value;
  @override
  final String part = '.max(@)';
  const MaxLength(this.value);
}

class MinLength extends StringRule {
  final int value;
  @override
  final String part = '.min(@)';
  const MinLength(this.value);
}

class StartsWith extends StringRule {
  final String value;
  @override
  final String part = '.startsWith(@)';
  const StartsWith(this.value);
}

class EndsWith extends StringRule {
  final String value;
  @override
  final String part = '.endsWith(@)';
  const EndsWith(this.value);
}

class Contains extends StringRule {
  final String value;
  @override
  final String part = '.contains(@)';
  const Contains(this.value);
}

class Matches extends StringRule {
  final String value;
  @override
  final String part = '.matches(@)';
  const Matches(this.value);
}

class MaxValue extends NumberRule {
  final int value;
  @override
  final String part = '.max(@)';
  const MaxValue(this.value);
}

class MinValue extends NumberRule {
  final int value;
  @override
  final String part = '.min(@)';
  const MinValue(this.value);
}

class IsEqualTo extends NumberRule {
  final int value;
  @override
  final String part = '.isEqualTo(@)';
  const IsEqualTo(this.value);
}

class IsNotEqualTo extends NumberRule {
  final int value;
  @override
  final String part = '.isNotEqualTo(@)';
  const IsNotEqualTo(this.value);
}

class IsTrue extends BoolRule {
  @override
  final String part = '.isTrue()';
  const IsTrue();
}

class IsFalse extends BoolRule {
  @override
  final String part = '.isFalse()';
  const IsFalse();
}

class IsBefore extends DateTimeRule {
  final DateTime value;
  @override
  final String part = '.isBefore(@)';
  const IsBefore(this.value);
}

class IsAfter extends DateTimeRule {
  final DateTime value;
  @override
  final String part = '.isAfter(@)';
  const IsAfter(this.value);
}

