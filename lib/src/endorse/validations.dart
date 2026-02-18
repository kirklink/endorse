import 'patterns.dart';

/// Base class for all validation annotations.
///
/// Each annotation declares:
/// - [method]: the name of the ValidateValue method to call
/// - [validOnTypes]: which Dart types this annotation can be used on
/// - [rawString]: whether string values should be emitted as raw string
///   literals (r'...') in generated code
/// - [message]: optional custom error message override
///
/// Subclasses may also define a [value] field for parameterized rules.
/// The builder reads these fields to generate validation code.
abstract class ValidationBase {
  /// The ValidateValue method name to call in generated code.
  final String method = '';

  /// The types that this validation can be used on.
  final List<Type> validOnTypes = const [];

  /// The types that this validation cannot be used on.
  final List<Type> notValidOnTypes = const [];

  /// Whether string values should be emitted as raw string literals.
  final bool rawString = false;

  /// Optional custom error message. When set, this message is used instead
  /// of the rule's default error message when validation fails.
  final String? message = null;

  const ValidationBase();
}

/// Generates the isRequired rule.
class Required extends ValidationBase {
  @override
  final String method = 'isRequired';
  @override
  final String? message;
  const Required({this.message});
}

/// Generates the isNotNull rule.
class IsNotNull extends ValidationBase {
  @override
  final String method = 'isNotNull';
  @override
  final String? message;
  const IsNotNull({this.message});
}

/// Generates the makeString rule (from an int).
class ToStringFromInt extends ValidationBase {
  @override
  final String method = 'makeString';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  const ToStringFromInt({this.message});
}

/// Generates the makeString rule (from a double).
class ToStringFromDouble extends ValidationBase {
  @override
  final String method = 'makeString';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  const ToStringFromDouble({this.message});
}

/// Generates the makeString rule (from a num).
class ToStringFromNum extends ValidationBase {
  @override
  final String method = 'makeString';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  const ToStringFromNum({this.message});
}

/// Generates the makeString rule (from a bool).
class ToStringFromBool extends ValidationBase {
  @override
  final String method = 'makeString';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  const ToStringFromBool({this.message});
}

/// Generates the intFromString rule.
class IntFromString extends ValidationBase {
  @override
  final String method = 'intFromString';
  @override
  final List<Type> validOnTypes = const [int];
  @override
  final String? message;
  const IntFromString({this.message});
}

/// Generates the doubleFromString rule.
class DoubleFromString extends ValidationBase {
  @override
  final String method = 'doubleFromString';
  @override
  final List<Type> validOnTypes = const [double];
  @override
  final String? message;
  const DoubleFromString({this.message});
}

/// Generates the numFromString rule.
class NumFromString extends ValidationBase {
  @override
  final String method = 'numFromString';
  @override
  final List<Type> validOnTypes = const [int, double, num];
  @override
  final String? message;
  const NumFromString({this.message});
}

/// Generates the boolFromString rule.
class BoolFromString extends ValidationBase {
  @override
  final String method = 'boolFromString';
  @override
  final List<Type> validOnTypes = const [bool];
  @override
  final String? message;
  const BoolFromString({this.message});
}

/// Generates the maxLength rule.
class MaxLength extends ValidationBase {
  @override
  final String method = 'maxLength';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  final int value;
  const MaxLength(this.value, {this.message});
}

/// Generates the minLength rule.
class MinLength extends ValidationBase {
  @override
  final String method = 'minLength';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  final int value;
  const MinLength(this.value, {this.message});
}

/// Generates the startsWith rule.
class StartsWith extends ValidationBase {
  @override
  final String method = 'startsWith';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  final String value;
  const StartsWith(this.value, {this.message});
}

/// Generates the endsWith rule.
class EndsWith extends ValidationBase {
  @override
  final String method = 'endsWith';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  final String value;
  const EndsWith(this.value, {this.message});
}

/// Generates the contains rule.
class Contains extends ValidationBase {
  @override
  final String method = 'contains';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  final String value;
  const Contains(this.value, {this.message});
}

/// Generates the matches rule.
class Matches extends ValidationBase {
  @override
  final String method = 'matches';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  final String value;
  const Matches(this.value, {this.message});
}

/// Generates the isLessThan rule.
class IsLessThan extends ValidationBase {
  @override
  final String method = 'isLessThan';
  @override
  final List<Type> validOnTypes = const [int, double, num];
  @override
  final String? message;
  final num value;
  const IsLessThan(this.value, {this.message});
}

/// Generates the isGreaterThan rule.
class IsGreaterThan extends ValidationBase {
  @override
  final String method = 'isGreaterThan';
  @override
  final List<Type> validOnTypes = const [int, double, num];
  @override
  final String? message;
  final num value;
  const IsGreaterThan(this.value, {this.message});
}

/// Generates the isEqualTo rule.
class IsEqualTo extends ValidationBase {
  @override
  final String method = 'isEqualTo';
  @override
  final List<Type> validOnTypes = const [int, double, num];
  @override
  final String? message;
  final num value;
  const IsEqualTo(this.value, {this.message});
}

/// Generates the isNotEqualTo rule.
class IsNotEqualTo extends ValidationBase {
  @override
  final String method = 'isNotEqualTo';
  @override
  final List<Type> validOnTypes = const [int, double, num];
  @override
  final String? message;
  final num value;
  const IsNotEqualTo(this.value, {this.message});
}

/// Generates the isTrue rule.
class IsTrue extends ValidationBase {
  @override
  final String method = 'isTrue';
  @override
  final List<Type> validOnTypes = const [bool];
  @override
  final String? message;
  const IsTrue({this.message});
}

/// Generates the isFalse rule.
class IsFalse extends ValidationBase {
  @override
  final String method = 'isFalse';
  @override
  final List<Type> validOnTypes = const [bool];
  @override
  final String? message;
  const IsFalse({this.message});
}

/// Generates the isBefore rule.
class IsBefore extends ValidationBase {
  @override
  final String method = 'isBefore';
  @override
  final List<Type> validOnTypes = const [DateTime];
  @override
  final String? message;
  final String value;
  const IsBefore(this.value, {this.message});
  const IsBefore.now({this.message}) : value = 'now';
}

/// Generates the isAfter rule.
class IsAfter extends ValidationBase {
  @override
  final String method = 'isAfter';
  @override
  final List<Type> validOnTypes = const [DateTime];
  @override
  final String? message;
  final String value;
  const IsAfter(this.value, {this.message});
  const IsAfter.now({this.message}) : value = 'now';
}

/// Generates the isAtMoment rule.
class IsAtMoment extends ValidationBase {
  @override
  final String method = 'isAtMoment';
  @override
  final List<Type> validOnTypes = const [DateTime];
  @override
  final String? message;
  final String value;
  const IsAtMoment(this.value, {this.message});
  const IsAtMoment.now({this.message}) : value = 'now';
}

/// Generates the isSameDateAs rule.
class IsSameDateAs extends ValidationBase {
  @override
  final String method = 'isSameDateAs';
  @override
  final List<Type> validOnTypes = const [DateTime];
  @override
  final String? message;
  final String value;
  const IsSameDateAs(this.value, {this.message});
  const IsSameDateAs.now({this.message}) : value = 'now';
}

/// Generates the matchesPattern rule.
class MatchesPattern extends ValidationBase {
  @override
  final String method = 'matchesPattern';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final bool rawString = true;
  @override
  final String? message;
  final String value;
  const MatchesPattern(this.value, {this.message});
}

/// Generates the matchesPattern rule and accepts a raw string.
class MatchesRawPattern extends ValidationBase {
  @override
  final String method = 'matchesPattern';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final bool rawString = true;
  @override
  final String? message;
  final String value;
  const MatchesRawPattern(this.value, {this.message});
}

/// Generates the matchesPattern rule and accepts an escaped string.
class MatchesEscapedPattern extends ValidationBase {
  @override
  final String method = 'matchesPattern';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  final String value;
  const MatchesEscapedPattern(this.value, {this.message});
}

/// Generates the isEmail rule.
class IsEmail extends ValidationBase {
  @override
  final String method = 'isEmail';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final bool rawString = true;
  @override
  final String? message;
  final String value = Patterns.email;
  const IsEmail({this.message});
}

// ============================================================================
// String validation
// ============================================================================

/// Generates the isNotEmpty rule. Rejects empty strings.
class IsNotEmpty extends ValidationBase {
  @override
  final String method = 'isNotEmpty';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  const IsNotEmpty({this.message});
}

/// Generates the exactLength rule. String must be exactly N characters.
class ExactLength extends ValidationBase {
  @override
  final String method = 'exactLength';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  final int value;
  const ExactLength(this.value, {this.message});
}

/// Generates the isAlpha rule. String must contain only letters.
class IsAlpha extends ValidationBase {
  @override
  final String method = 'isAlpha';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  const IsAlpha({this.message});
}

/// Generates the isAlphanumeric rule. String must contain only letters and digits.
class IsAlphanumeric extends ValidationBase {
  @override
  final String method = 'isAlphanumeric';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  const IsAlphanumeric({this.message});
}

/// Generates the trim coercion rule. Trims whitespace before subsequent rules.
class Trim extends ValidationBase {
  @override
  final String method = 'trim';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  const Trim({this.message});
}

// ============================================================================
// Numeric comparison
// ============================================================================

/// Generates the isGreaterThanOrEqual rule.
class IsGreaterThanOrEqual extends ValidationBase {
  @override
  final String method = 'isGreaterThanOrEqual';
  @override
  final List<Type> validOnTypes = const [int, double, num];
  @override
  final String? message;
  final num value;
  const IsGreaterThanOrEqual(this.value, {this.message});
}

/// Generates the isLessThanOrEqual rule.
class IsLessThanOrEqual extends ValidationBase {
  @override
  final String method = 'isLessThanOrEqual';
  @override
  final List<Type> validOnTypes = const [int, double, num];
  @override
  final String? message;
  final num value;
  const IsLessThanOrEqual(this.value, {this.message});
}

// ============================================================================
// Enum / allowlist
// ============================================================================

/// Generates the isOneOf rule. Value must be one of the allowed values.
class IsOneOf extends ValidationBase {
  @override
  final String method = 'isOneOf';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  final List<String> value;
  const IsOneOf(this.value, {this.message});
}

// ============================================================================
// Collection rules
// ============================================================================

/// Generates the minElements rule for lists.
class MinElements extends ValidationBase {
  @override
  final String method = 'minElements';
  @override
  final List<Type> validOnTypes = const [List];
  @override
  final String? message;
  final int value;
  const MinElements(this.value, {this.message});
}

/// Generates the maxElements rule for lists.
class MaxElements extends ValidationBase {
  @override
  final String method = 'maxElements';
  @override
  final List<Type> validOnTypes = const [List];
  @override
  final String? message;
  final int value;
  const MaxElements(this.value, {this.message});
}

// ============================================================================
// Pattern-based rules
// ============================================================================

/// Generates the isUrl rule.
class IsUrl extends ValidationBase {
  @override
  final String method = 'isUrl';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  const IsUrl({this.message});
}

/// Generates the isUuid rule.
class IsUuid extends ValidationBase {
  @override
  final String method = 'isUuid';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  const IsUuid({this.message});
}

/// Generates the isPhoneNumber rule.
class IsPhoneNumber extends ValidationBase {
  @override
  final String method = 'isPhoneNumber';
  @override
  final List<Type> validOnTypes = const [String];
  @override
  final String? message;
  const IsPhoneNumber({this.message});
}
