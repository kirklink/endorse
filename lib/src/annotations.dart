import 'rules.dart';

/// Marks a class for validation code generation.
///
/// ```dart
/// @Endorse()
/// class CreateItemRequest {
///   final String name;
///   final int quantity;
///
///   const CreateItemRequest._({required this.name, required this.quantity});
///   static final $endorse = _$CreateItemRequestValidator();
/// }
/// ```
class Endorse {
  /// If true, all fields are treated as required regardless of nullability.
  final bool requireAll;

  /// Groups of field names where at least one must be present.
  /// Example: `either: [['email', 'phone']]` — email or phone required.
  final List<List<String>> either;

  const Endorse({this.requireAll = false, this.either = const []});
}

/// Annotates a field with validation rules and metadata.
///
/// ```dart
/// @EndorseField(rules: [MinLength(1), MaxLength(100)])
/// final String name;
/// ```
class EndorseField {
  /// Validation rules for this field.
  final List<Rule> rules;

  /// Validation rules for items within a list field.
  final List<Rule> itemRules;

  /// Override the JSON key name (defaults to the Dart field name).
  final String? name;

  /// Skip this field entirely during validation.
  final bool ignore;

  /// Conditional validation — only validate when a sibling field meets a condition.
  final When? when;

  const EndorseField({
    this.rules = const [],
    this.itemRules = const [],
    this.name,
    this.ignore = false,
    this.when,
  });
}

/// Conditional validation: controls whether a field's rules run.
///
/// The condition is evaluated against a sibling field in the same input map.
/// When the condition is NOT met, validation is skipped (field treated as optional).
///
/// Exactly one condition should be provided:
/// ```dart
/// @EndorseField(
///   rules: [Required()],
///   when: When('country', equals: 'US'),
/// )
/// final String state;
/// ```
class When {
  /// Name of the sibling field to check.
  final String field;

  /// Condition: sibling field must equal this value.
  final Object? equals;

  /// Condition: sibling field must not be null.
  final bool isNotNull;

  /// Condition: sibling field must be one of these values.
  final List<Object>? isOneOf;

  const When(this.field, {this.equals, this.isNotNull = false, this.isOneOf});
}
