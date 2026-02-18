import 'patterns.dart';

class RuleError {
  final String errorName;
  final String errorDetail;

  const RuleError(this.errorName, [this.errorDetail = '']);
  const RuleError.empty()
      : errorName = '',
        errorDetail = '';

  bool get isEmpty => errorDetail.isEmpty && errorName.isEmpty;
}

// Base Rule class with full interface for Evaluator
abstract class Rule {
  const Rule();

  // Rule metadata
  String get name => '';
  bool get skipIfNull => true;
  bool get causesBail => false;
  bool get escapesBail => false;

  // Validation methods
  String check(Object? input, Object? test) => '';
  bool pass(Object? input, Object? test);
  String got(Object? input, Object? test) => '';
  String want(Object? input, Object? test) => '';
  String errorMsg(Object? input, Object? test);
  Object? cast(Object? input) => input;

  RuleError evaluate(Object? input) {
    if (!pass(input, null)) {
      return RuleError(name, errorMsg(input, null));
    }
    return RuleError.empty();
  }
}

abstract class ShortCircuitRule extends Rule {
  const ShortCircuitRule();

  @override
  bool get causesBail => true;
}

abstract class RuleWithNumTest extends Rule {
  final num test;
  const RuleWithNumTest(this.test);
}

abstract class RuleWithStringTest extends Rule {
  final String test;
  const RuleWithStringTest(this.test);
}

// ============================================================================
// Required / Type Checking
// ============================================================================

class Required extends Rule {
  const Required();

  @override
  String get name => 'Required';

  @override
  bool get skipIfNull => false;

  @override
  bool get causesBail => true;

  @override
  bool pass(Object? input, Object? test) => input != null;

  @override
  String errorMsg(Object? input, Object? test) => 'Required.';
}

class IsString extends ShortCircuitRule {
  const IsString();

  @override
  String get name => 'IsString';

  @override
  bool pass(Object? input, Object? test) => input is String;

  @override
  String errorMsg(Object? input, Object? test) => 'Must be a String.';

  @override
  String got(Object? input, Object? test) => input.runtimeType.toString();

  @override
  String want(Object? input, Object? test) => 'String';
}

class IsMap extends ShortCircuitRule {
  const IsMap();

  @override
  String get name => 'IsMap';

  @override
  bool pass(Object? input, Object? test) => input is Map;

  @override
  String errorMsg(Object? input, Object? test) =>
      'Must be a Map<String, Object>.';

  @override
  String got(Object? input, Object? test) => input.runtimeType.toString();

  @override
  String want(Object? input, Object? test) => 'Map<String, Object>';
}

class IsList extends ShortCircuitRule {
  const IsList();

  @override
  String get name => 'IsList';

  @override
  bool pass(Object? input, Object? test) => input is List;

  @override
  String errorMsg(Object? input, Object? test) => 'Must be a List.';

  @override
  String got(Object? input, Object? test) => input.runtimeType.toString();

  @override
  String want(Object? input, Object? test) => 'List';
}

// ============================================================================
// Numeric Type Checking
// ============================================================================

class IsInt extends ShortCircuitRule {
  const IsInt();

  @override
  String get name => 'IsInt';

  @override
  bool pass(Object? input, Object? test) => input is int;

  @override
  String errorMsg(Object? input, Object? test) => 'Must be an integer.';

  @override
  String got(Object? input, Object? test) => input.runtimeType.toString();

  @override
  String want(Object? input, Object? test) => 'int';
}

class IsDouble extends ShortCircuitRule {
  const IsDouble();

  @override
  String get name => 'IsDouble';

  @override
  bool pass(Object? input, Object? test) => input is double;

  @override
  String errorMsg(Object? input, Object? test) => 'Must be a double.';

  @override
  String got(Object? input, Object? test) => input.runtimeType.toString();

  @override
  String want(Object? input, Object? test) => 'double';
}

class IsNum extends ShortCircuitRule {
  const IsNum();

  @override
  String get name => 'IsNum';

  @override
  bool pass(Object? input, Object? test) => input is num;

  @override
  String errorMsg(Object? input, Object? test) => 'Must be a number.';

  @override
  String got(Object? input, Object? test) => input.runtimeType.toString();

  @override
  String want(Object? input, Object? test) => 'num';
}

// ============================================================================
// Boolean Type Checking
// ============================================================================

class IsBool extends ShortCircuitRule {
  const IsBool();

  @override
  String get name => 'IsBool';

  @override
  bool pass(Object? input, Object? test) => input is bool;

  @override
  String errorMsg(Object? input, Object? test) => 'Must be a boolean.';

  @override
  String got(Object? input, Object? test) => input.runtimeType.toString();

  @override
  String want(Object? input, Object? test) => 'bool';
}

// ============================================================================
// DateTime Type Checking
// ============================================================================

class IsDateTime extends ShortCircuitRule {
  const IsDateTime();

  @override
  String get name => 'IsDateTime';

  @override
  bool pass(Object? input, Object? test) => _inputDateConverter(input) != null;

  @override
  String errorMsg(Object? input, Object? test) => 'Must be a datetime.';

  @override
  Object? cast(Object? input) => _inputDateConverter(input);
}

// ============================================================================
// String-from-type coercion (check + cast)
// ============================================================================

class CanIntFromString extends ShortCircuitRule {
  const CanIntFromString();

  @override
  String get name => 'IntFromString';

  @override
  bool pass(Object? input, Object? test) =>
      input is String && int.tryParse(input) != null;

  @override
  String errorMsg(Object? input, Object? test) =>
      'Could not cast to integer from ${input.runtimeType}.';

  @override
  String got(Object? input, Object? test) => input.runtimeType.toString();

  @override
  String want(Object? input, Object? test) => 'String parseable to int';
}

class IntFromStringCast extends ShortCircuitRule {
  const IntFromStringCast();

  @override
  String get name => 'IntFromString';

  @override
  bool pass(Object? input, Object? test) =>
      input is String && int.tryParse(input) != null;

  @override
  String errorMsg(Object? input, Object? test) =>
      'Could not cast to integer from string.';

  @override
  Object? cast(Object? input) =>
      input is String ? int.tryParse(input) : input;
}

class CanDoubleFromString extends ShortCircuitRule {
  const CanDoubleFromString();

  @override
  String get name => 'DoubleFromString';

  @override
  bool pass(Object? input, Object? test) =>
      input is String && double.tryParse(input) != null;

  @override
  String errorMsg(Object? input, Object? test) =>
      'Could not cast to double from ${input.runtimeType}.';

  @override
  String got(Object? input, Object? test) => input.runtimeType.toString();

  @override
  String want(Object? input, Object? test) => 'String parseable to double';
}

class DoubleFromStringCast extends ShortCircuitRule {
  const DoubleFromStringCast();

  @override
  String get name => 'DoubleFromString';

  @override
  bool pass(Object? input, Object? test) =>
      input is String && double.tryParse(input) != null;

  @override
  String errorMsg(Object? input, Object? test) =>
      'Could not cast to double from string.';

  @override
  Object? cast(Object? input) =>
      input is String ? double.tryParse(input) : input;
}

class CanNumFromString extends ShortCircuitRule {
  const CanNumFromString();

  @override
  String get name => 'NumFromString';

  @override
  bool pass(Object? input, Object? test) =>
      input is String && num.tryParse(input) != null;

  @override
  String errorMsg(Object? input, Object? test) =>
      'Could not cast to number from ${input.runtimeType}.';

  @override
  String got(Object? input, Object? test) => input.runtimeType.toString();

  @override
  String want(Object? input, Object? test) => 'String parseable to num';
}

class NumFromStringCast extends ShortCircuitRule {
  const NumFromStringCast();

  @override
  String get name => 'NumFromString';

  @override
  bool pass(Object? input, Object? test) =>
      input is String && num.tryParse(input) != null;

  @override
  String errorMsg(Object? input, Object? test) =>
      'Could not cast to number from string.';

  @override
  Object? cast(Object? input) =>
      input is String ? num.tryParse(input) : input;
}

class CanBoolFromString extends ShortCircuitRule {
  const CanBoolFromString();

  @override
  String get name => 'BoolFromString';

  @override
  bool pass(Object? input, Object? test) =>
      input is String && (input == 'true' || input == 'false');

  @override
  String errorMsg(Object? input, Object? test) =>
      'Could not cast to boolean from ${input.runtimeType}.';
}

class BoolFromStringCast extends ShortCircuitRule {
  const BoolFromStringCast();

  @override
  String get name => 'BoolFromString';

  @override
  bool pass(Object? input, Object? test) =>
      input is String && (input == 'true' || input == 'false');

  @override
  String errorMsg(Object? input, Object? test) =>
      'Could not cast to boolean from string.';

  @override
  String got(Object? input, Object? test) => input.runtimeType.toString();

  @override
  String want(Object? input, Object? test) => 'String';

  @override
  Object? cast(Object? input) => input == 'true' ? true : false;
}

class ToStringCast extends ShortCircuitRule {
  const ToStringCast();

  @override
  String get name => 'ToString';

  @override
  bool pass(Object? input, Object? test) => true;

  @override
  String errorMsg(Object? input, Object? test) =>
      'Cannot be coerced to String.';

  @override
  Object? cast(Object? input) => input?.toString();
}

// ============================================================================
// String Rules
// ============================================================================

class MaxLength extends RuleWithNumTest {
  const MaxLength(int test) : super(test);

  @override
  String get name => 'MaxLength';

  @override
  bool pass(Object? input, Object? testParam) =>
      input is String && input.length <= test;

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Length must be less than or equal to $test.';

  @override
  String got(Object? input, Object? testParam) =>
      input is String ? input.length.toString() : 'not a string';

  @override
  String want(Object? input, Object? testParam) => '<= $test';
}

class MinLength extends RuleWithNumTest {
  const MinLength(int test) : super(test);

  @override
  String get name => 'MinLength';

  @override
  bool pass(Object? input, Object? testParam) =>
      input is String && input.length >= test;

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Length must be greater than or equal to $test.';

  @override
  String got(Object? input, Object? testParam) =>
      input is String ? input.length.toString() : 'not a string';

  @override
  String want(Object? input, Object? testParam) => '>= $test';
}

class MatchesValue extends RuleWithStringTest {
  const MatchesValue(String test) : super(test);

  @override
  String get name => 'Matches';

  @override
  bool pass(Object? input, Object? testParam) =>
      input is String && input == test;

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Must match: "$test".';
}

class ContainsValue extends RuleWithStringTest {
  const ContainsValue(String test) : super(test);

  @override
  String get name => 'Contains';

  @override
  bool pass(Object? input, Object? testParam) =>
      input is String && input.contains(test);

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Must contain: "$test".';
}

class StartsWithValue extends RuleWithStringTest {
  const StartsWithValue(String test) : super(test);

  @override
  String get name => 'StartsWith';

  @override
  bool pass(Object? input, Object? testParam) =>
      input is String && input.startsWith(test);

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Must start with: "$test".';

  @override
  String got(Object? input, Object? testParam) {
    if (input is! String) return 'not a string';
    final length = input.length < test.length ? input.length : test.length;
    return input.substring(0, length);
  }
}

class EndsWithValue extends RuleWithStringTest {
  const EndsWithValue(String test) : super(test);

  @override
  String get name => 'EndsWith';

  @override
  bool pass(Object? input, Object? testParam) =>
      input is String && input.endsWith(test);

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Must end with: "$test".';

  @override
  String got(Object? input, Object? testParam) {
    if (input is! String) return 'not a string';
    final length = input.length < test.length ? input.length : test.length;
    return input.substring(input.length - length);
  }
}

// ============================================================================
// Numeric Comparison Rules
// ============================================================================

class IsLessThan extends RuleWithNumTest {
  const IsLessThan(int test) : super(test);

  @override
  String get name => 'IsLessThan';

  @override
  bool pass(Object? input, Object? testParam) =>
      input is num && input < test;

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Must be less than $test.';

  @override
  String want(Object? input, Object? testParam) => '< $test';
}

class IsGreaterThan extends RuleWithNumTest {
  const IsGreaterThan(int test) : super(test);

  @override
  String get name => 'IsGreaterThan';

  @override
  bool pass(Object? input, Object? testParam) =>
      input is num && input > test;

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Must be greater than $test.';

  @override
  String want(Object? input, Object? testParam) => '> $test';
}

class IsEqualTo extends RuleWithNumTest {
  const IsEqualTo(num test) : super(test);

  @override
  String get name => 'IsEqualTo';

  @override
  bool pass(Object? input, Object? testParam) => input == test;

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Must equal $test.';
}

class IsNotEqualTo extends RuleWithNumTest {
  const IsNotEqualTo(num test) : super(test);

  @override
  String get name => 'IsNotEqualTo';

  @override
  bool pass(Object? input, Object? testParam) => input != test;

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Must not equal $test.';
}

// ============================================================================
// Boolean Rules
// ============================================================================

class IsTrueRule extends Rule {
  const IsTrueRule();

  @override
  String get name => 'IsTrue';

  @override
  bool pass(Object? input, Object? test) => input == true;

  @override
  String errorMsg(Object? input, Object? test) => 'Must be true.';

  @override
  String want(Object? input, Object? test) => 'true';
}

class IsFalseRule extends Rule {
  const IsFalseRule();

  @override
  String get name => 'IsFalse';

  @override
  bool pass(Object? input, Object? test) => input == false;

  @override
  String errorMsg(Object? input, Object? test) => 'Must be false.';

  @override
  String want(Object? input, Object? test) => 'false';
}

// ============================================================================
// Collection Rules
// ============================================================================

class MaxElements extends RuleWithNumTest {
  const MaxElements(int test) : super(test);

  @override
  String get name => 'MaxElements';

  @override
  bool pass(Object? input, Object? testParam) =>
      input is List && input.length <= test;

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Max element count is $test.';

  @override
  String want(Object? input, Object? testParam) => '<= $test elements';
}

class MinElements extends RuleWithNumTest {
  const MinElements(int test) : super(test);

  @override
  String get name => 'MinElements';

  @override
  bool pass(Object? input, Object? testParam) =>
      input is List && input.length >= test;

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Min element count is $test.';

  @override
  String want(Object? input, Object? testParam) => '>= $test elements';
}

// ============================================================================
// DateTime Rules
// ============================================================================

class IsBeforeRule extends RuleWithStringTest {
  const IsBeforeRule(String test) : super(test);

  @override
  String get name => 'IsBefore';

  @override
  String check(Object? input, Object? testParam) {
    final converted = _testDateConverter(test);
    return converted != null ? '' : 'Could not parse "$test" to DateTime.';
  }

  @override
  bool pass(Object? input, Object? testParam) {
    final inputDt = _inputDateConverter(input);
    final testDt = _testDateConverter(test);
    return inputDt != null && testDt != null && inputDt.isBefore(testDt);
  }

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Must be before $test.';

  @override
  String want(Object? input, Object? testParam) => '< $test';

  @override
  String got(Object? input, Object? testParam) {
    final converted = _inputDateConverter(input);
    return converted?.toIso8601String() ?? 'null';
  }
}

class IsAfterRule extends RuleWithStringTest {
  const IsAfterRule(String test) : super(test);

  @override
  String get name => 'IsAfter';

  @override
  String check(Object? input, Object? testParam) {
    final converted = _testDateConverter(test);
    return converted != null ? '' : 'Could not parse "$test" to DateTime.';
  }

  @override
  bool pass(Object? input, Object? testParam) {
    final inputDt = _inputDateConverter(input);
    final testDt = _testDateConverter(test);
    return inputDt != null && testDt != null && inputDt.isAfter(testDt);
  }

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Must be after $test.';

  @override
  String want(Object? input, Object? testParam) => '> $test';

  @override
  String got(Object? input, Object? testParam) {
    final converted = _inputDateConverter(input);
    return converted?.toIso8601String() ?? 'null';
  }
}

class IsAtMomentRule extends RuleWithStringTest {
  const IsAtMomentRule(String test) : super(test);

  @override
  String get name => 'IsAtMoment';

  @override
  String check(Object? input, Object? testParam) {
    final converted = _testDateConverter(test);
    return converted != null ? '' : 'Could not parse "$test" to DateTime.';
  }

  @override
  bool pass(Object? input, Object? testParam) {
    final inputDt = _inputDateConverter(input);
    final testDt = _testDateConverter(test);
    return inputDt != null &&
        testDt != null &&
        inputDt.isAtSameMomentAs(testDt);
  }

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Must be at moment $test.';

  @override
  String want(Object? input, Object? testParam) => '== $test';
}

class IsSameDateAsRule extends RuleWithStringTest {
  const IsSameDateAsRule(String test) : super(test);

  @override
  String get name => 'IsSameDateAs';

  @override
  String check(Object? input, Object? testParam) {
    final converted = _testDateConverter(test);
    return converted != null ? '' : 'Could not parse "$test" to DateTime.';
  }

  @override
  bool pass(Object? input, Object? testParam) {
    final inputDt = _inputDateConverter(input);
    final testDt = _testDateConverter(test);
    if (inputDt == null || testDt == null) return false;
    return inputDt.year == testDt.year &&
        inputDt.month == testDt.month &&
        inputDt.day == testDt.day;
  }

  @override
  String errorMsg(Object? input, Object? testParam) {
    final testDt = _testDateConverter(test);
    if (testDt == null) return 'Must be on same date as $test.';
    return 'Must be on ${testDt.year}-${testDt.month}-${testDt.day}.';
  }

  @override
  String got(Object? input, Object? testParam) {
    final date = _inputDateConverter(input);
    if (date == null) return 'null';
    return '${date.year}-${date.month}-${date.day}';
  }
}

// ============================================================================
// Pattern Matching Rules
// ============================================================================

class MatchesPatternRule extends RuleWithStringTest {
  const MatchesPatternRule(String test) : super(test);

  @override
  String get name => 'MatchesPattern';

  @override
  String check(Object? input, Object? testParam) {
    try {
      RegExp(test);
    } catch (e) {
      return 'Pattern "$test" is not a valid RegExp.';
    }
    return '';
  }

  @override
  bool pass(Object? input, Object? testParam) =>
      input is String && RegExp(test).hasMatch(input);

  @override
  String errorMsg(Object? input, Object? testParam) =>
      '$test does not have a match in $input.';

  @override
  String want(Object? input, Object? testParam) => 'Has match with $test';

  @override
  String got(Object? input, Object? testParam) =>
      'No matches in $input';
}

class IsEmailRule extends MatchesPatternRule {
  const IsEmailRule() : super(Patterns.email);

  @override
  String get name => 'IsEmail';

  @override
  String errorMsg(Object? input, Object? testParam) =>
      '$input is not a valid email address.';

  @override
  String want(Object? input, Object? testParam) => 'A valid email.';

  @override
  String got(Object? input, Object? testParam) => input.toString();
}

// ============================================================================
// New String Rules
// ============================================================================

class IsNotEmpty extends Rule {
  const IsNotEmpty();

  @override
  String get name => 'IsNotEmpty';

  @override
  bool pass(Object? input, Object? test) =>
      input is String && input.isNotEmpty;

  @override
  String errorMsg(Object? input, Object? test) => 'Must not be empty.';
}

class ExactLengthRule extends RuleWithNumTest {
  const ExactLengthRule(int test) : super(test);

  @override
  String get name => 'ExactLength';

  @override
  bool pass(Object? input, Object? testParam) =>
      input is String && input.length == test;

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Length must be exactly ${test.toInt()}.';

  @override
  String got(Object? input, Object? testParam) =>
      input is String ? input.length.toString() : 'not a string';

  @override
  String want(Object? input, Object? testParam) => '== ${test.toInt()}';
}

class IsAlphaRule extends Rule {
  const IsAlphaRule();

  static final _pattern = RegExp(Patterns.alphaWord);

  @override
  String get name => 'IsAlpha';

  @override
  bool pass(Object? input, Object? test) =>
      input is String && _pattern.hasMatch(input);

  @override
  String errorMsg(Object? input, Object? test) =>
      'Must contain only letters.';
}

class IsAlphanumericRule extends Rule {
  const IsAlphanumericRule();

  static final _pattern = RegExp(Patterns.alphanumericWord);

  @override
  String get name => 'IsAlphanumeric';

  @override
  bool pass(Object? input, Object? test) =>
      input is String && _pattern.hasMatch(input);

  @override
  String errorMsg(Object? input, Object? test) =>
      'Must contain only letters and digits.';
}

class TrimRule extends Rule {
  const TrimRule();

  @override
  String get name => 'Trim';

  @override
  bool pass(Object? input, Object? test) => true;

  @override
  String errorMsg(Object? input, Object? test) => '';

  @override
  Object? cast(Object? input) => input is String ? input.trim() : input;
}

// ============================================================================
// New Numeric Comparison Rules
// ============================================================================

class IsGreaterThanOrEqual extends RuleWithNumTest {
  const IsGreaterThanOrEqual(num test) : super(test);

  @override
  String get name => 'IsGreaterThanOrEqual';

  @override
  bool pass(Object? input, Object? testParam) =>
      input is num && input >= test;

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Must be greater than or equal to $test.';

  @override
  String want(Object? input, Object? testParam) => '>= $test';
}

class IsLessThanOrEqual extends RuleWithNumTest {
  const IsLessThanOrEqual(num test) : super(test);

  @override
  String get name => 'IsLessThanOrEqual';

  @override
  bool pass(Object? input, Object? testParam) =>
      input is num && input <= test;

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Must be less than or equal to $test.';

  @override
  String want(Object? input, Object? testParam) => '<= $test';
}

// ============================================================================
// Enum / Allowlist Rules
// ============================================================================

class IsOneOfRule extends Rule {
  final List<String> allowed;
  const IsOneOfRule(this.allowed);

  @override
  String get name => 'IsOneOf';

  @override
  bool pass(Object? input, Object? test) =>
      input is String && allowed.contains(input);

  @override
  String errorMsg(Object? input, Object? test) =>
      'Must be one of: ${allowed.join(', ')}.';

  @override
  String want(Object? input, Object? test) => allowed.join(', ');

  @override
  String got(Object? input, Object? test) => input.toString();
}

// ============================================================================
// Collection Rules
// ============================================================================

class MinElementsRule extends RuleWithNumTest {
  const MinElementsRule(int test) : super(test);

  @override
  String get name => 'MinElements';

  @override
  bool pass(Object? input, Object? testParam) =>
      input is List && input.length >= test;

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Must have at least ${test.toInt()} element(s).';

  @override
  String got(Object? input, Object? testParam) =>
      input is List ? input.length.toString() : 'not a list';

  @override
  String want(Object? input, Object? testParam) => '>= ${test.toInt()}';
}

class MaxElementsRule extends RuleWithNumTest {
  const MaxElementsRule(int test) : super(test);

  @override
  String get name => 'MaxElements';

  @override
  bool pass(Object? input, Object? testParam) =>
      input is List && input.length <= test;

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Must have at most ${test.toInt()} element(s).';

  @override
  String got(Object? input, Object? testParam) =>
      input is List ? input.length.toString() : 'not a list';

  @override
  String want(Object? input, Object? testParam) => '<= ${test.toInt()}';
}

// ============================================================================
// New Pattern-based Rules
// ============================================================================

class IsUrlRule extends Rule {
  const IsUrlRule();

  static final _pattern = RegExp(
    r'^https?://'
    r'(([a-zA-Z0-9$_.+!*,;/?:@&~=-])|%[0-9a-fA-F]{2})+'
    r'(\b|$)',
    caseSensitive: false,
  );

  @override
  String get name => 'IsUrl';

  @override
  bool pass(Object? input, Object? test) {
    if (input is! String) return false;
    final uri = Uri.tryParse(input);
    return uri != null && uri.hasScheme && _pattern.hasMatch(input);
  }

  @override
  String errorMsg(Object? input, Object? test) =>
      'Must be a valid URL.';
}

class IsUuidRule extends Rule {
  const IsUuidRule();

  static final _pattern = RegExp(UUID.all, caseSensitive: false);

  @override
  String get name => 'IsUuid';

  @override
  bool pass(Object? input, Object? test) =>
      input is String && _pattern.hasMatch(input);

  @override
  String errorMsg(Object? input, Object? test) =>
      'Must be a valid UUID.';
}

class IsPhoneNumberRule extends MatchesPatternRule {
  const IsPhoneNumberRule() : super(Patterns.phone10digit);

  @override
  String get name => 'IsPhoneNumber';

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Must be a valid 10-digit phone number.';
}

// ============================================================================
// DateTime Helper Functions
// ============================================================================

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
    final safeDate = DateTime.utc(now.year, now.month, now.day);
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

// ============================================================================
// Custom validation rule
// ============================================================================

/// A rule that delegates validation to a user-supplied function.
///
/// Used by [ValidateValue.custom] for ad-hoc validation logic,
/// both in programmatic usage and in code generated from
/// [CustomValidation] annotations.
class CustomRule extends Rule {
  final String _name;
  final bool Function(Object?) _test;
  final String _errorMessage;

  CustomRule(this._name, this._test, this._errorMessage);

  @override
  String get name => _name;

  @override
  bool pass(Object? input, Object? test) => _test(input);

  @override
  String errorMsg(Object? input, Object? test) => _errorMessage;

  @override
  String got(Object? input, Object? test) => input.toString();

  @override
  String want(Object? input, Object? test) => _errorMessage;
}
