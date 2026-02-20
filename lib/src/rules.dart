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
  final String? message;
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
  final int min;
  final String? message;
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
  final int max;
  final String? message;
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
  final String pattern;
  final String? message;
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
  final String? message;
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
  final String? message;
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
  final String? message;
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
  final num min;
  final String? message;
  const Min(this.min, {this.message});

  @override
  String? check(Object? value) {
    if (value is! num) return null;
    if (value < min) return message ?? 'must be at least $min';
    return null;
  }
}

/// Number must be <= [max].
class Max extends Rule {
  final num max;
  final String? message;
  const Max(this.max, {this.message});

  @override
  String? check(Object? value) {
    if (value is! num) return null;
    if (value > max) return message ?? 'must be at most $max';
    return null;
  }
}

// ---------------------------------------------------------------------------
// Collection rules
// ---------------------------------------------------------------------------

/// List must have at least [min] elements.
class MinElements extends Rule {
  final int min;
  final String? message;
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
  final int max;
  final String? message;
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
  final String? message;
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
  final List<Object> allowed;
  final String? message;
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
  final String methodName;
  final String? message;
  const Custom(this.methodName, {this.message});

  @override
  String? check(Object? value) => throw UnsupportedError(
        'Custom rules are resolved at build time by the code generator.',
      );
}

/// Runtime wrapper for custom validation functions.
/// Generated by codegen — not used directly in annotations.
class CustomRule extends Rule {
  final bool Function(Object?) test;
  final String _message;
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
  const Trim();

  @override
  Object? coerce(Object? value) => value is String ? value.trim() : value;

  @override
  String? check(Object? value) => null;
}

/// Converts a String to lowercase. Transform only — never fails.
class LowerCase extends Rule {
  const LowerCase();

  @override
  Object? coerce(Object? value) =>
      value is String ? value.toLowerCase() : value;

  @override
  String? check(Object? value) => null;
}

/// Converts a String to uppercase. Transform only — never fails.
class UpperCase extends Rule {
  const UpperCase();

  @override
  Object? coerce(Object? value) =>
      value is String ? value.toUpperCase() : value;

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
  final String date;
  final String? message;
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
  final String date;
  final String? message;
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
  final String date;
  final String? message;
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
  final String? message;
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
  final String? message;
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
  final String date;
  final String? message;
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
  final String? message;
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
