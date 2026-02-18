import 'package:endorse/src/endorse/validations.dart';
import 'package:endorse/src/endorse/case.dart';

/// The annotation to convert a Dart class into a Endorse validated object.
///
/// [useCase]: automatically convert the object's field names to different case schemas.
/// [requireAll]: shortcut to make all fields required.
/// [either]: list of field groups where at least one field in each group must be non-null.
class EndorseEntity {
  final Case useCase;
  final bool requireAll;
  final List<List<String>> either;
  const EndorseEntity({
    this.useCase = Case.none,
    this.requireAll = false,
    this.either = const [],
  });
}

/// Conditional annotation: controls whether a field's validation rules run.
///
/// The condition is evaluated against a sibling field in the same input map.
/// When the condition is NOT met, validation is skipped and the field is
/// treated as optional (a valid result with the actual input value).
///
/// Exactly one condition type should be provided:
/// - [isEqualTo]: sibling field value must equal this value
/// - [isNotNull]: sibling field value must not be null (set to true)
/// - [isOneOf]: sibling field value must be one of these values
class When {
  final String field;
  final Object? isEqualTo;
  final bool isNotNull;
  final List<Object>? isOneOf;
  const When(this.field, {this.isEqualTo, this.isNotNull = false, this.isOneOf});
}

/// The annotation to enhance a Dart class property with Endorse metadata.
///
/// [EndorseField] is not required and only necessary if additional annotations are required
/// on the field. Otherwise, Dart class properties of a [EndorseEntity] are automatically applied
/// to fields.
///
/// [name]: sets an explict name from the object if different than the class field name.
/// [ignore]: will ignore this field completely; it will not be included in the validation.
/// [useCase]: automatically convert the field name to a different case schema.
/// [validate]: a list of validations to perform on the field.
/// [itemValidate]: a list of validations to perform on the items within a list field.
/// [when]: conditional validation — only run rules when a sibling field meets the condition.
class EndorseField {
  final List<ValidationBase> validate;
  final List<ValidationBase> itemValidate;
  final bool ignore;
  final Case useCase;
  final String name;
  final When? when;
  const EndorseField(
      {this.validate = const <ValidationBase>[],
      this.itemValidate = const <ValidationBase>[],
      this.ignore = false,
      this.useCase = Case.none,
      this.name = '',
      this.when});
}

class EndorseMap {
  const EndorseMap();
}
