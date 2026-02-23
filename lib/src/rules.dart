/// All validation rules and the rule chain runner.
///
/// Rules are const-constructable so they can be used in annotations.
/// The codegen infers type rules (IsString, IsInt, etc.) automatically
/// from the Dart field type — users only specify validation rules.
library;

// ---------------------------------------------------------------------------
// Base
// ---------------------------------------------------------------------------

/// Base class for all validation rules.
///
/// Subclasses must implement [check]. Override [bail] to stop the chain
/// on failure, and [coerce] to transform the value before checking.
abstract class Rule {
  /// Creates a rule.
  const Rule();

  /// If true, validation stops when this rule fails.
  bool get bail => false;

  /// Transform the value before [check] runs (e.g., String -> int).
  /// Default: identity (returns [value] unchanged).
  Object? coerce(Object? value) => value;

  /// Returns null if valid, a human-readable error message if invalid.
  String? check(Object? value);
}

// ---------------------------------------------------------------------------
// Presence
// ---------------------------------------------------------------------------

/// Value must be non-null (and non-empty if a String).
class Required extends Rule {
  /// Custom error message. Defaults to `'is required'`.
  final String? message;

  /// Creates a required-presence rule.
  const Required({this.message});

  @override
  bool get bail => true;

  @override
  String? check(Object? value) {
    if (value == null) return message ?? 'is required';
    if (value is String && value.trim().isEmpty) return message ?? 'is required';
    return null;
  }
}

// ---------------------------------------------------------------------------
// Type rules (with auto-coercion) — generated implicitly by codegen
// ---------------------------------------------------------------------------

/// Value must be a String.
class IsString extends Rule {
  /// Creates a string type check rule.
  const IsString();

  @override
  bool get bail => true;

  @override
  String? check(Object? value) {
    if (value == null) return null;
    if (value is! String) return 'must be a string';
    return null;
  }
}

/// Value must be an int. Coerces from double (if whole) and String.
class IsInt extends Rule {
  /// Creates an int type check rule with auto-coercion.
  const IsInt();

  @override
  bool get bail => true;

  @override
  Object? coerce(Object? value) {
    if (value is int) return value;
    if (value is double && value == value.roundToDouble()) return value.toInt();
    if (value is String) return int.tryParse(value) ?? value;
    return value;
  }

  @override
  String? check(Object? value) {
    if (value == null) return null;
    if (value is! int) return 'must be an integer';
    return null;
  }
}

/// Value must be a double. Coerces from int and String.
class IsDouble extends Rule {
  /// Creates a double type check rule with auto-coercion.
  const IsDouble();

  @override
  bool get bail => true;

  @override
  Object? coerce(Object? value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? value;
    return value;
  }

  @override
  String? check(Object? value) {
    if (value == null) return null;
    if (value is! double) return 'must be a number';
    return null;
  }
}

/// Value must be a num. Coerces from String.
class IsNum extends Rule {
  /// Creates a num type check rule with auto-coercion.
  const IsNum();

  @override
  bool get bail => true;

  @override
  Object? coerce(Object? value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? value;
    return value;
  }

  @override
  String? check(Object? value) {
    if (value == null) return null;
    if (value is! num) return 'must be a number';
    return null;
  }
}

/// Value must be a bool. Coerces from String ('true'/'false', '1'/'0')
/// and int (1/0).
class IsBool extends Rule {
  /// Creates a bool type check rule with auto-coercion.
  const IsBool();

  @override
  bool get bail => true;

  @override
  Object? coerce(Object? value) {
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    if (value is int) {
      if (value == 1) return true;
      if (value == 0) return false;
    }
    return value;
  }

  @override
  String? check(Object? value) {
    if (value == null) return null;
    if (value is! bool) return 'must be a boolean';
    return null;
  }
}

/// Value must be a DateTime. Coerces from String via [DateTime.tryParse].
class IsDateTime extends Rule {
  /// Creates a DateTime type check rule with auto-coercion.
  const IsDateTime();

  @override
  bool get bail => true;

  @override
  Object? coerce(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? value;
    return value;
  }

  @override
  String? check(Object? value) {
    if (value == null) return null;
    if (value is! DateTime) return 'must be a valid date/time';
    return null;
  }
}

/// Value must be a Map.
class IsMap extends Rule {
  /// Creates a Map type check rule.
  const IsMap();

  @override
  bool get bail => true;

  @override
  String? check(Object? value) {
    if (value == null) return null;
    if (value is! Map) return 'must be an object';
    return null;
  }
}

/// Value must be a List.
class IsList extends Rule {
  /// Creates a List type check rule.
  const IsList();

  @override
  bool get bail => true;

  @override
  String? check(Object? value) {
    if (value == null) return null;
    if (value is! List) return 'must be a list';
    return null;
  }
}

// ---------------------------------------------------------------------------
// String rules
// ---------------------------------------------------------------------------

/// String must have at least [min] characters.
class MinLength extends Rule {
  /// Minimum number of characters.
  final int min;

  /// Custom error message. Defaults to `'must not be empty'` (when min is 1)
  /// or `'must be at least N characters'`.
  final String? message;

  /// Creates a minimum-length string rule.
  const MinLength(this.min, {this.message});

  @override
  String? check(Object? value) {
    if (value is! String) return null;
    if (value.length < min) {
      return message ??
          (min == 1
              ? 'must not be empty'
              : 'must be at least $min characters');
    }
    return null;
  }
}

/// String must have at most [max] characters.
class MaxLength extends Rule {
  /// Maximum number of characters.
  final int max;

  /// Custom error message. Defaults to `'must be at most N characters'`.
  final String? message;

  /// Creates a maximum-length string rule.
  const MaxLength(this.max, {this.message});

  @override
  String? check(Object? value) {
    if (value is! String) return null;
    if (value.length > max) return message ?? 'must be at most $max characters';
    return null;
  }
}

/// String must match the given regex [pattern].
class Matches extends Rule {
  /// The regex pattern to match against.
  final String pattern;

  /// Custom error message. Defaults to `'must match pattern ...'`.
  final String? message;

  /// Creates a regex pattern matching rule.
  const Matches(this.pattern, {this.message});

  @override
  String? check(Object? value) {
    if (value is! String) return null;
    if (!RegExp(pattern).hasMatch(value)) {
      return message ?? 'must match pattern $pattern';
    }
    return null;
  }
}

/// String must be a valid email address.
class Email extends Rule {
  /// Custom error message. Defaults to `'must be a valid email address'`.
  final String? message;

  /// Creates an email format validation rule.
  const Email({this.message});

  static final _re =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  @override
  String? check(Object? value) {
    if (value is! String) return null;
    if (!_re.hasMatch(value)) return message ?? 'must be a valid email address';
    return null;
  }
}

/// String must be a valid URL with scheme and authority.
class Url extends Rule {
  /// Custom error message. Defaults to `'must be a valid URL'`.
  final String? message;

  /// Creates a URL format validation rule.
  const Url({this.message});

  @override
  String? check(Object? value) {
    if (value is! String) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return message ?? 'must be a valid URL';
    }
    return null;
  }
}

/// String must be a valid UUID (v1–v5, lowercase or uppercase hex).
class Uuid extends Rule {
  /// Custom error message. Defaults to `'must be a valid UUID'`.
  final String? message;

  /// Creates a UUID format validation rule.
  const Uuid({this.message});

  static final _re = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  @override
  String? check(Object? value) {
    if (value is! String) return null;
    if (!_re.hasMatch(value)) return message ?? 'must be a valid UUID';
    return null;
  }
}

// ---------------------------------------------------------------------------
// Numeric rules
// ---------------------------------------------------------------------------

/// Number must be >= [min].
class Min extends Rule {
  /// Minimum allowed value (inclusive).
  final num min;

  /// Custom error message. Defaults to `'must be at least N'`.
  final String? message;

  /// Creates a minimum-value numeric rule.
  const Min(this.min, {this.message});

  @override
  String? check(Object? value) {
    if (value is! num) return null;
    if (value.isNaN) return message ?? 'must be at least $min';
    if (value < min) return message ?? 'must be at least $min';
    return null;
  }
}

/// Number must be <= [max].
class Max extends Rule {
  /// Maximum allowed value (inclusive).
  final num max;

  /// Custom error message. Defaults to `'must be at most N'`.
  final String? message;

  /// Creates a maximum-value numeric rule.
  const Max(this.max, {this.message});

  @override
  String? check(Object? value) {
    if (value is! num) return null;
    if (value.isNaN) return message ?? 'must be at most $max';
    if (value > max) return message ?? 'must be at most $max';
    return null;
  }
}

// ---------------------------------------------------------------------------
// Collection rules
// ---------------------------------------------------------------------------

/// List must have at least [min] elements.
class MinElements extends Rule {
  /// Minimum number of elements.
  final int min;

  /// Custom error message. Defaults to `'must not be empty'` (when min is 1)
  /// or `'must have at least N elements'`.
  final String? message;

  /// Creates a minimum-elements collection rule.
  const MinElements(this.min, {this.message});

  @override
  String? check(Object? value) {
    if (value is! List) return null;
    if (value.length < min) {
      return message ??
          (min == 1
              ? 'must not be empty'
              : 'must have at least $min elements');
    }
    return null;
  }
}

/// List must have at most [max] elements.
class MaxElements extends Rule {
  /// Maximum number of elements.
  final int max;

  /// Custom error message. Defaults to `'must have at most N elements'`.
  final String? message;

  /// Creates a maximum-elements collection rule.
  const MaxElements(this.max, {this.message});

  @override
  String? check(Object? value) {
    if (value is! List) return null;
    if (value.length > max) return message ?? 'must have at most $max elements';
    return null;
  }
}

/// All list elements must be distinct.
class UniqueElements extends Rule {
  /// Custom error message. Defaults to `'must contain unique elements'`.
  final String? message;

  /// Creates a unique-elements collection rule.
  const UniqueElements({this.message});

  @override
  String? check(Object? value) {
    if (value is! List) return null;
    if (value.length != value.toSet().length) {
      return message ?? 'must contain unique elements';
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Enum / allowlist
// ---------------------------------------------------------------------------

/// Value must be one of the [allowed] values.
class OneOf extends Rule {
  /// The set of allowed values.
  final List<Object> allowed;

  /// Custom error message. Defaults to `'must be one of: ...'`.
  final String? message;

  /// Creates an allowlist validation rule.
  const OneOf(this.allowed, {this.message});

  @override
  String? check(Object? value) {
    if (value == null) return null;
    if (!allowed.contains(value)) {
      return message ?? 'must be one of: ${allowed.join(', ')}';
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Custom validation
// ---------------------------------------------------------------------------

/// References a static method on the annotated class for custom validation.
///
/// The method must have the signature `static bool methodName(Object? value)`.
/// Returns true if valid, false if invalid.
///
/// ```dart
/// @EndorseField(rules: [Custom('isEven', message: 'must be even')])
/// final int count;
///
/// static bool isEven(Object? value) => value is int && value.isEven;
/// ```
class Custom extends Rule {
  /// The name of the static validation method on the annotated class.
  final String methodName;

  /// Error message shown when the custom check fails.
  final String? message;

  /// Creates a custom validation rule referencing [methodName].
  const Custom(this.methodName, {this.message});

  @override
  String? check(Object? value) => throw UnsupportedError(
        'Custom rules are resolved at build time by the code generator.',
      );
}

/// Runtime wrapper for custom validation functions.
/// Generated by codegen — not used directly in annotations.
class CustomRule extends Rule {
  /// The validation function. Returns true if the value is valid.
  final bool Function(Object?) test;
  final String _message;

  /// Creates a runtime custom rule with the given [test] function.
  CustomRule(this.test, [this._message = 'is invalid']);

  @override
  String? check(Object? value) {
    if (value == null) return null;
    if (!test(value)) return _message;
    return null;
  }
}

// ---------------------------------------------------------------------------
// Transform rules
// ---------------------------------------------------------------------------

/// Trims whitespace from both ends of a String. Transform only — never fails.
class Trim extends Rule {
  /// Creates a trim transform rule.
  const Trim();

  @override
  Object? coerce(Object? value) => value is String ? value.trim() : value;

  @override
  String? check(Object? value) => null;
}

/// Converts a String to lowercase. Transform only — never fails.
class LowerCase extends Rule {
  /// Creates a lowercase transform rule.
  const LowerCase();

  @override
  Object? coerce(Object? value) =>
      value is String ? value.toLowerCase() : value;

  @override
  String? check(Object? value) => null;
}

/// Converts a String to uppercase. Transform only — never fails.
class UpperCase extends Rule {
  /// Creates an uppercase transform rule.
  const UpperCase();

  @override
  Object? coerce(Object? value) =>
      value is String ? value.toUpperCase() : value;

  @override
  String? check(Object? value) => null;
}

/// Strips HTML tags from a String using a simple regex. Transform only — never fails.
///
/// This is a naive strip (removes `<...>` sequences). For security-critical
/// sanitization that preserves safe tags, use a dedicated library like
/// `package:disinfect` via [Transform].
class StripHtml extends Rule {
  /// Creates an HTML tag stripping rule.
  const StripHtml();

  static final _tagRe = RegExp(r'<[^>]*>');

  @override
  Object? coerce(Object? value) =>
      value is String ? value.replaceAll(_tagRe, '') : value;

  @override
  String? check(Object? value) => null;
}

/// Collapses runs of whitespace into a single space and trims.
/// Transform only — never fails.
class CollapseWhitespace extends Rule {
  /// Creates a whitespace collapsing rule.
  const CollapseWhitespace();

  static final _wsRe = RegExp(r'\s+');

  @override
  Object? coerce(Object? value) =>
      value is String ? value.replaceAll(_wsRe, ' ').trim() : value;

  @override
  String? check(Object? value) => null;
}

/// Normalizes line endings to `\n`. Transform only — never fails.
///
/// Replaces `\r\n` and lone `\r` with `\n`.
class NormalizeNewlines extends Rule {
  /// Creates a newline normalization rule.
  const NormalizeNewlines();

  @override
  Object? coerce(Object? value) =>
      value is String
          ? value.replaceAll('\r\n', '\n').replaceAll('\r', '\n')
          : value;

  @override
  String? check(Object? value) => null;
}

/// Truncates a String to [max] characters. Transform only — never fails.
class Truncate extends Rule {
  /// Maximum number of characters to keep.
  final int max;

  /// Creates a string truncation rule.
  const Truncate(this.max);

  @override
  Object? coerce(Object? value) =>
      value is String && value.length > max
          ? value.substring(0, max)
          : value;

  @override
  String? check(Object? value) => null;
}

// ---------------------------------------------------------------------------
// Custom transform
// ---------------------------------------------------------------------------

/// References a static method on the annotated class that transforms the value.
///
/// The method must have the signature `static Object? methodName(Object? value)`.
/// This is the coerce-only counterpart to [Custom].
///
/// ```dart
/// @EndorseField(rules: [Transform('sanitizeBio'), MinLength(1)])
/// final String bio;
///
/// static Object? sanitizeBio(Object? value) =>
///     value is String ? disinfect(value) : value;
/// ```
class Transform extends Rule {
  /// The name of the static transform method on the annotated class.
  final String methodName;

  /// Creates a transform rule referencing [methodName].
  const Transform(this.methodName);

  @override
  Object? coerce(Object? value) => throw UnsupportedError(
        'Transform rules are resolved at build time by the code generator.',
      );

  @override
  String? check(Object? value) => null;
}

/// Runtime wrapper for custom transform functions.
/// Generated by codegen — not used directly in annotations.
class TransformRule extends Rule {
  /// The transform function.
  final Object? Function(Object?) _transform;

  /// Creates a runtime transform rule with the given function.
  TransformRule(this._transform);

  @override
  Object? coerce(Object? value) => _transform(value);

  @override
  String? check(Object? value) => null;
}

// ---------------------------------------------------------------------------
// DateTime rules — Date (day granularity) and Datetime (full precision)
// ---------------------------------------------------------------------------

/// Strips time component, leaving only year/month/day.
DateTime _toDateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// Parses a date spec string: 'now', 'today', 'today+N', 'today-N', or ISO 8601.
DateTime _parseDateSpec(String spec) {
  if (spec == 'now') return DateTime.now();
  if (spec == 'today') return _toDateOnly(DateTime.now());
  if (spec.startsWith('today+')) {
    return _toDateOnly(DateTime.now())
        .add(Duration(days: int.parse(spec.substring(6))));
  }
  if (spec.startsWith('today-')) {
    return _toDateOnly(DateTime.now())
        .subtract(Duration(days: int.parse(spec.substring(6))));
  }
  return DateTime.parse(spec);
}

/// DateTime must be before [date] (day-level comparison, time zeroed).
class IsBeforeDate extends Rule {
  /// Date spec to compare against (`'today'`, `'today+N'`, `'today-N'`,
  /// or ISO 8601).
  final String date;

  /// Custom error message. Defaults to `'must be before ...'`.
  final String? message;

  /// Creates a before-date rule comparing at day granularity.
  const IsBeforeDate(this.date, {this.message});

  @override
  String? check(Object? value) {
    if (value is! DateTime) return null;
    if (!_toDateOnly(value).isBefore(_toDateOnly(_parseDateSpec(date)))) {
      return message ?? 'must be before $date';
    }
    return null;
  }
}

/// DateTime must be after [date] (day-level comparison, time zeroed).
class IsAfterDate extends Rule {
  /// Date spec to compare against (`'today'`, `'today+N'`, `'today-N'`,
  /// or ISO 8601).
  final String date;

  /// Custom error message. Defaults to `'must be after ...'`.
  final String? message;

  /// Creates an after-date rule comparing at day granularity.
  const IsAfterDate(this.date, {this.message});

  @override
  String? check(Object? value) {
    if (value is! DateTime) return null;
    if (!_toDateOnly(value).isAfter(_toDateOnly(_parseDateSpec(date)))) {
      return message ?? 'must be after $date';
    }
    return null;
  }
}

/// DateTime must be the same date as [date] (day-level comparison, time zeroed).
class IsSameDate extends Rule {
  /// Date spec to compare against (`'today'`, `'today+N'`, `'today-N'`,
  /// or ISO 8601).
  final String date;

  /// Custom error message. Defaults to `'must be the same date as ...'`.
  final String? message;

  /// Creates a same-date rule comparing at day granularity.
  const IsSameDate(this.date, {this.message});

  @override
  String? check(Object? value) {
    if (value is! DateTime) return null;
    if (!_toDateOnly(value)
        .isAtSameMomentAs(_toDateOnly(_parseDateSpec(date)))) {
      return message ?? 'must be the same date as $date';
    }
    return null;
  }
}

/// DateTime must be in the future (full precision).
class IsFutureDatetime extends Rule {
  /// Custom error message. Defaults to `'must be in the future'`.
  final String? message;

  /// Creates a future-datetime rule.
  const IsFutureDatetime({this.message});

  @override
  String? check(Object? value) {
    if (value is! DateTime) return null;
    if (!value.isAfter(DateTime.now())) {
      return message ?? 'must be in the future';
    }
    return null;
  }
}

/// DateTime must be in the past (full precision).
class IsPastDatetime extends Rule {
  /// Custom error message. Defaults to `'must be in the past'`.
  final String? message;

  /// Creates a past-datetime rule.
  const IsPastDatetime({this.message});

  @override
  String? check(Object? value) {
    if (value is! DateTime) return null;
    if (!value.isBefore(DateTime.now())) {
      return message ?? 'must be in the past';
    }
    return null;
  }
}

/// DateTime must be exactly the same moment as [date] (full precision).
class IsSameDatetime extends Rule {
  /// ISO 8601 date string to compare against.
  final String date;

  /// Custom error message. Defaults to `'must be the same moment as ...'`.
  final String? message;

  /// Creates a same-datetime rule at full precision.
  const IsSameDatetime(this.date, {this.message});

  @override
  String? check(Object? value) {
    if (value is! DateTime) return null;
    if (!value.isAtSameMomentAs(DateTime.parse(date))) {
      return message ?? 'must be the same moment as $date';
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// String format rules
// ---------------------------------------------------------------------------

/// String must be a valid IPv4 or IPv6 address.
class IpAddress extends Rule {
  /// Custom error message. Defaults to `'must be a valid IP address'`.
  final String? message;

  /// Creates an IP address format validation rule.
  const IpAddress({this.message});

  static final _ipv4Re = RegExp(
    r'^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$',
  );

  @override
  String? check(Object? value) {
    if (value is! String) return null;
    if (_ipv4Re.hasMatch(value)) return null;
    // Basic IPv6: 2-8 groups of hex separated by colons, or contains ::
    if (value.contains(':') && !value.contains(' ')) {
      final parts = value.split(':');
      if (parts.length >= 2 && parts.length <= 9) {
        final allHex = parts.every(
            (p) => p.isEmpty || RegExp(r'^[0-9a-fA-F]{1,4}$').hasMatch(p));
        if (allHex) return null;
      }
    }
    return message ?? 'must be a valid IP address';
  }
}

// ---------------------------------------------------------------------------
// Security rules
// ---------------------------------------------------------------------------

/// String must not contain control characters (null bytes, zero-width spaces,
/// directional overrides, etc.).
///
/// Allows tab (0x09), newline (0x0A), and carriage return (0x0D) which are
/// legitimate in text fields. Rejects all other C0/C1 controls, DEL,
/// zero-width marks, directional formatting, and object replacement.
class NoControlChars extends Rule {
  /// Custom error message. Defaults to `'must not contain control characters'`.
  final String? message;

  /// Creates a control character rejection rule.
  const NoControlChars({this.message});

  /// Returns true if [codeUnit] is a rejected control character.
  ///
  /// Rejects: C0 controls (except tab/LF/CR), DEL, C1 controls,
  /// zero-width/directional marks, directional formatting,
  /// directional isolates, object replacement.
  static bool isControlChar(int codeUnit) {
    // C0 controls except HT (0x09), LF (0x0A), CR (0x0D).
    if (codeUnit <= 0x08) return true;
    if (codeUnit == 0x0B || codeUnit == 0x0C) return true;
    if (codeUnit >= 0x0E && codeUnit <= 0x1F) return true;
    // DEL.
    if (codeUnit == 0x7F) return true;
    // C1 controls.
    if (codeUnit >= 0x80 && codeUnit <= 0x9F) return true;
    // Zero-width and directional marks.
    if (codeUnit >= 0x200B && codeUnit <= 0x200F) return true;
    // Directional formatting.
    if (codeUnit >= 0x202A && codeUnit <= 0x202E) return true;
    // Directional isolates.
    if (codeUnit >= 0x2066 && codeUnit <= 0x2069) return true;
    // Object replacement.
    if (codeUnit == 0xFFFC) return true;
    return false;
  }

  /// Returns true if [value] contains any rejected control character.
  static bool containsControlChars(String value) {
    for (var i = 0; i < value.length; i++) {
      if (isControlChar(value.codeUnitAt(i))) return true;
    }
    return false;
  }

  @override
  String? check(Object? value) {
    if (value is! String) return null;
    if (containsControlChars(value)) {
      return message ?? 'must not contain control characters';
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Rule chain runner
// ---------------------------------------------------------------------------

/// Runs a chain of [rules] against [value], applying coercion and
/// collecting errors.
///
/// Returns a record of `(errorMessages, coercedValue)`.
///
/// Bail rules (Required, type checks) stop the chain on first failure.
/// Non-bail rules collect all errors.
(List<String>, Object?) checkRules(Object? value, List<Rule> rules) {
  final errors = <String>[];
  var current = value;
  for (final rule in rules) {
    current = rule.coerce(current);
    final error = rule.check(current);
    if (error != null) {
      errors.add(error);
      if (rule.bail) return (errors, current);
    }
  }
  return (errors, current);
}
