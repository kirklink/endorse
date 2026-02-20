import 'result.dart';

/// Interface that all validators must implement.
///
/// Supports both full-object validation (server pipeline) and
/// single-field validation (frontend forms).
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
}
