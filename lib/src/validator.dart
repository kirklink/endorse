import 'result.dart';

/// Interface that all generated validators implement.
///
/// Supports full-object validation (server pipeline), single-field
/// validation (frontend forms), and form metadata (HTML5 attributes,
/// client-side rule descriptors).
abstract interface class EndorseValidator<T> {
  /// Validate an entire object from a raw map.
  /// Used by the server pipeline.
  EndorseResult<T> validate(Map<String, Object?> input);

  /// Validate a single field by name.
  /// Used by frontend forms for per-field validation as the user types.
  /// Returns a list of error messages, or an empty list if valid.
  List<String> validateField(String fieldName, Object? value);

  /// All field names this validator knows about.
  Set<String> get fieldNames;

  /// HTML5 validation attributes per field.
  ///
  /// Keys are field names (matching [fieldNames]).
  /// Values are attribute maps suitable for rendering on `<input>` elements:
  /// `{'required': '', 'minlength': '2', 'type': 'email'}`.
  ///
  /// Only includes fields that have rules mappable to HTML5 constraints.
  /// Fields with no mappable rules are omitted from the map.
  Map<String, Map<String, String>> get html5Attrs;

  /// Client-side validation rule descriptors per field.
  ///
  /// JSON-serializable. Keys are field names.
  /// Each rule descriptor is a map with `'rule'` (type name), optional
  /// `'message'` (custom error text), and rule-specific params:
  ///
  /// ```dart
  /// {
  ///   'name': [
  ///     {'rule': 'Required'},
  ///     {'rule': 'MinLength', 'min': 2, 'message': 'Too short'},
  ///   ],
  /// }
  /// ```
  ///
  /// The swoop_pages JS runtime evaluates these to validate fields
  /// client-side. Transform-only rules and [Custom]/[Transform] rules
  /// are excluded since they can't run in the browser.
  Map<String, List<Map<String, Object?>>> get clientRules;
}
