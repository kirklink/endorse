import 'patterns.dart';

/// The class that all validations extend.
///
/// This class structure provides a template for the fields that every
/// validation requires. These templates are used by the endorse_builder
/// code generator to know which rules should be called on a value to
/// validate that value.
abstract class ValidationBase {
  /// The rule to be called by the validator.
  final String call = '';

  /// The types that this validation can be used on.
  final validOnTypes = const <Type>[];
  const ValidationBase();
}

/// Generates the isRequired rule.
class Required extends ValidationBase {
  @override
  final String call = 'isRequired()';
  const Required();
}

/// Generates the isRequired rule.
class IsNotNull extends ValidationBase {
  @override
  final String call = 'isNotNull()';
  const IsNotNull();
}

// class ToString extends Validation {
//   @override
//   final String call = 'makeString()';
//   @override
//   final validOnTypes = const [String];
//   const ToString();
// }

/// Generates the makeString rule (from an int).
class ToStringFromInt extends ValidationBase {
  @override
  final String call = 'makeString()';

  /// Valid on String
  @override
  final validOnTypes = const [String];
  const ToStringFromInt();
}

/// Generates the makeString rule (from a double).
class ToStringFromDouble extends ValidationBase {
  @override
  final String call = 'makeString()';

  /// Valid on String.
  @override
  final validOnTypes = const [String];
  const ToStringFromDouble();
}

/// Generates the makeString rule (from a num).
class ToStringFromNum extends ValidationBase {
  @override
  final String call = 'makeString()';

  /// Valid on String.
  @override
  final validOnTypes = const [String];
  const ToStringFromNum();
}

/// Generates the makeString rule (from a bool).
class ToStringFromBool extends ValidationBase {
  @override
  final String call = 'makeString()';

  /// Valid on String.
  @override
  final validOnTypes = const [String];
  const ToStringFromBool();
}

/// Generates the intFromString rule.
class IntFromString extends ValidationBase {
  @override
  final String call = 'intFromString()';

  /// Valid on int.
  @override
  final validOnTypes = const [int];
  const IntFromString();
}

/// Generates the doubleFromString rule.
class DoubleFromString extends ValidationBase {
  @override
  final String call = 'doubleFromString()';

  /// Valid on double.
  @override
  final validOnTypes = const [double];
  const DoubleFromString();
}

/// Generates the numFromString rule.
class NumFromString extends ValidationBase {
  @override
  final String call = 'numFromString()';

  /// Valid on int, double and num
  @override
  final validOnTypes = const [int, double, num];
  const NumFromString();
}

/// Generates the boolFromString rule.
class BoolFromString extends ValidationBase {
  @override
  final String call = 'boolFromString()';

  /// Valid on bool.
  @override
  final validOnTypes = const [bool];
  const BoolFromString();
}

/// Generates the maxLength rule.
class MaxLength extends ValidationBase {
  @override
  final String call = 'maxLength(@)';
  @override

  /// Valid on String
  final validOnTypes = const [String];
  final int value;
  const MaxLength(this.value);
}

/// Generates the minLength rule.
class MinLength extends ValidationBase {
  @override
  final String call = 'minLength(@)';

  /// Valid on String.
  @override
  final validOnTypes = const [String];
  final int value;
  const MinLength(this.value);
}

/// Generates the startsWith rule.
class StartsWith extends ValidationBase {
  @override
  final String call = 'startsWith(@)';

  /// Valid on String.
  @override
  final validOnTypes = const [String];
  final String value;
  const StartsWith(this.value);
}

/// Generates the endsWith rule.
class EndsWith extends ValidationBase {
  @override
  final String call = 'endsWith(@)';

  /// Valid on String.
  @override
  final validOnTypes = const [String];
  final String value;
  const EndsWith(this.value);
}

/// Generates the contains rule.
class Contains extends ValidationBase {
  @override
  final String call = 'contains(@)';
  @override

  /// Valid on String.
  final validOnTypes = const [String];
  final String value;
  const Contains(this.value);
}

/// Generates the matches rule.
class Matches extends ValidationBase {
  @override
  final String call = 'matches(@)';

  /// Valid on String.
  @override
  final validOnTypes = const [String];
  final String value;
  const Matches(this.value);
}

/// Generates the isLessThan rule.
class IsLessThan extends ValidationBase {
  @override
  final String call = 'isLessThan(@)';

  /// Valid on int, double and num.
  @override
  final validOnTypes = const [int, double, num];
  final num value;
  const IsLessThan(this.value);
}

/// Generates the isGreaterThan rule.
class IsGreaterThan extends ValidationBase {
  @override
  final String call = 'isGreaterThan(@)';

  /// Valid on int, double and num.
  @override
  final validOnTypes = const [int, double, num];
  final num value;
  const IsGreaterThan(this.value);
}

/// Generates the isEqualTo rule.
class IsEqualTo extends ValidationBase {
  @override
  final String call = 'isEqualTo(@)';

  /// Valid on int, double and num.
  @override
  final validOnTypes = const [int, double, num];
  final num value;
  const IsEqualTo(this.value);
}

/// Generates the isNotEqualTo rule.
class IsNotEqualTo extends ValidationBase {
  @override
  final String call = 'isNotEqualTo(@)';

  /// Valid on int, double and num.
  @override
  final validOnTypes = const [int, double, num];
  final num value;
  const IsNotEqualTo(this.value);
}

/// Generates the isTrue rule.
class IsTrue extends ValidationBase {
  @override
  final String call = 'isTrue()';

  /// Valid on bool.
  @override
  final validOnTypes = const [bool];
  const IsTrue();
}

/// Generates the isFalse rule.
class IsFalse extends ValidationBase {
  @override
  final String call = 'isFalse()';

  /// Valid on bool.
  @override
  final validOnTypes = const [bool];
  const IsFalse();
}

/// Generates the isBefore rule.
class IsBefore extends ValidationBase {
  @override
  final String call = 'isBefore(@)';

  /// Valid on DateTime.
  @override
  final validOnTypes = const [DateTime];
  final String value;
  const IsBefore(this.value);
  const IsBefore.now() : value = 'now';
}

/// Generates the isAfter rule.
class IsAfter extends ValidationBase {
  @override
  final String call = 'isAfter(@)';

  /// Valid on DateTime.
  @override
  final validOnTypes = const [DateTime];
  final String value;
  const IsAfter(this.value);
  const IsAfter.now() : value = 'now';
}

/// Generates the isAtMoment rule.
class IsAtMoment extends ValidationBase {
  @override
  final String call = 'isAtMoment(@)';

  /// Valid on DateTime.
  @override
  final validOnTypes = const [DateTime];
  final String value;
  const IsAtMoment(this.value);
  const IsAtMoment.now() : value = 'now';
}

/// Generates the isSameDateAs rule.
class IsSameDateAs extends ValidationBase {
  @override
  final String call = 'isSameDateAs(@)';

  /// Valid on DateTime.
  @override
  final validOnTypes = const [DateTime];
  final String value;
  const IsSameDateAs(this.value);
  const IsSameDateAs.now() : value = 'now';
}

/// Generates the matchesPattern rule.
class MatchesPattern extends ValidationBase {
  @override
  final String call = 'matchesPattern(r@)';

  /// Valid on String.
  @override
  final validOnTypes = const [String];
  final String value;
  const MatchesPattern(this.value);
}

/// Generates the matchesPattern rule and accepts a raw string.
class MatchesRawPattern extends ValidationBase {
  @override
  final String call = 'matchesPattern(r@)';

  /// Valid on String.
  @override
  final validOnTypes = const [String];
  final String value;
  const MatchesRawPattern(this.value);
}

/// Generates the matchesPattern rule and accepts an escaped string.
class MatchesEscapedPattern extends ValidationBase {
  @override
  final String call = 'matchesPattern(@)';

  /// Valid on String.
  @override
  final validOnTypes = const [String];
  final String value;
  const MatchesEscapedPattern(this.value);
}

/// Generates the isEmail rule.
class IsEmail extends ValidationBase {
  @override
  final String call = 'isEmail(r@)';

  /// Valid on String.
  @override
  final validOnTypes = const [String];
  final String value = Patterns.email;
  const IsEmail();
}

// ============================================================================
// String validation
// ============================================================================

/// Generates the isNotEmpty rule. Rejects empty strings.
class IsNotEmpty extends ValidationBase {
  @override
  final String call = 'isNotEmpty()';
  @override
  final validOnTypes = const [String];
  const IsNotEmpty();
}

/// Generates the exactLength rule. String must be exactly N characters.
class ExactLength extends ValidationBase {
  @override
  final String call = 'exactLength(@)';
  @override
  final validOnTypes = const [String];
  final int value;
  const ExactLength(this.value);
}

/// Generates the isAlpha rule. String must contain only letters.
class IsAlpha extends ValidationBase {
  @override
  final String call = 'isAlpha()';
  @override
  final validOnTypes = const [String];
  const IsAlpha();
}

/// Generates the isAlphanumeric rule. String must contain only letters and digits.
class IsAlphanumeric extends ValidationBase {
  @override
  final String call = 'isAlphanumeric()';
  @override
  final validOnTypes = const [String];
  const IsAlphanumeric();
}

/// Generates the trim coercion rule. Trims whitespace before subsequent rules.
class Trim extends ValidationBase {
  @override
  final String call = 'trim()';
  @override
  final validOnTypes = const [String];
  const Trim();
}

// ============================================================================
// Numeric comparison
// ============================================================================

/// Generates the isGreaterThanOrEqual rule.
class IsGreaterThanOrEqual extends ValidationBase {
  @override
  final String call = 'isGreaterThanOrEqual(@)';
  @override
  final validOnTypes = const [int, double, num];
  final num value;
  const IsGreaterThanOrEqual(this.value);
}

/// Generates the isLessThanOrEqual rule.
class IsLessThanOrEqual extends ValidationBase {
  @override
  final String call = 'isLessThanOrEqual(@)';
  @override
  final validOnTypes = const [int, double, num];
  final num value;
  const IsLessThanOrEqual(this.value);
}

// ============================================================================
// Enum / allowlist
// ============================================================================

/// Generates the isOneOf rule. Value must be one of the allowed values.
class IsOneOf extends ValidationBase {
  @override
  final String call = 'isOneOf(@)';
  @override
  final validOnTypes = const [String];
  final List<String> value;
  const IsOneOf(this.value);
}

// ============================================================================
// Collection rules
// ============================================================================

/// Generates the minElements rule for lists.
class MinElements extends ValidationBase {
  @override
  final String call = 'minElements(@)';
  @override
  final validOnTypes = const [List];
  final int value;
  const MinElements(this.value);
}

/// Generates the maxElements rule for lists.
class MaxElements extends ValidationBase {
  @override
  final String call = 'maxElements(@)';
  @override
  final validOnTypes = const [List];
  final int value;
  const MaxElements(this.value);
}

// ============================================================================
// Pattern-based rules
// ============================================================================

/// Generates the isUrl rule.
class IsUrl extends ValidationBase {
  @override
  final String call = 'isUrl()';
  @override
  final validOnTypes = const [String];
  const IsUrl();
}

/// Generates the isUuid rule.
class IsUuid extends ValidationBase {
  @override
  final String call = 'isUuid()';
  @override
  final validOnTypes = const [String];
  const IsUuid();
}

/// Generates the isPhoneNumber rule.
class IsPhoneNumber extends ValidationBase {
  @override
  final String call = 'isPhoneNumber()';
  @override
  final validOnTypes = const [String];
  const IsPhoneNumber();
}
