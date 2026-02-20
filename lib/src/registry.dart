import 'validator.dart';

/// Maps request types to their validators. Populated at startup.
///
/// ```dart
/// void main() {
///   EndorseRegistry.instance
///     ..register<CreateItemRequest>(CreateItemRequest.$endorse)
///     ..register<UpdateItemRequest>(UpdateItemRequest.$endorse);
/// }
/// ```
class EndorseRegistry {
  static final instance = EndorseRegistry._();
  EndorseRegistry._();

  final _validators = <Type, EndorseValidator<Object>>{};

  /// Register a validator for type [T].
  void register<T extends Object>(EndorseValidator<T> validator) {
    _validators[T] = validator;
  }

  /// Retrieve the validator for type [T].
  /// Throws [StateError] if no validator is registered.
  EndorseValidator<T> get<T extends Object>() {
    final v = _validators[T];
    if (v == null) throw StateError('No validator registered for $T');
    return v as EndorseValidator<T>;
  }

  /// Check if a validator is registered for type [T].
  bool has<T extends Object>() => _validators.containsKey(T);

  /// Retrieve the validator for [type], or null if not registered.
  ///
  /// Non-generic alternative to [get] for contexts where the type parameter
  /// is not available at compile time (e.g., framework pipelines).
  EndorseValidator<Object>? getForType(Type type) => _validators[type];

  /// Remove all registered validators (useful for testing).
  void clear() => _validators.clear();
}
