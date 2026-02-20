/// Sealed result type for validation outcomes.
///
/// Pattern match to handle both cases:
/// ```dart
/// switch (result) {
///   case ValidResult(:final value):
///     // value is fully typed
///   case InvalidResult(:final fieldErrors):
///     // fieldErrors is Map<String, List<String>>
/// }
/// ```
sealed class EndorseResult<T> {
  /// Base constructor for result types.
  const EndorseResult();
}

/// Validation succeeded. Contains the immutable, validated instance.
class ValidResult<T> extends EndorseResult<T> {
  /// The validated, immutable instance of type [T].
  final T value;

  /// Creates a successful validation result wrapping [value].
  const ValidResult(this.value);

  @override
  String toString() => 'ValidResult($value)';
}

/// Validation failed. Contains field-level error messages.
///
/// Keys are field names (dot-pathed for nested: `"address.street"`,
/// indexed for lists: `"items.0.name"`).
/// Values are lists of human-readable error messages.
class InvalidResult<T> extends EndorseResult<T> {
  /// Per-field error messages. Keys are field names, values are error lists.
  final Map<String, List<String>> fieldErrors;

  /// Creates a failed validation result with the given [fieldErrors].
  const InvalidResult(this.fieldErrors);

  @override
  String toString() => 'InvalidResult($fieldErrors)';
}
