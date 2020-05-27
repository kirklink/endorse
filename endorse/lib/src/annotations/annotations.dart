import 'package:endorse/src/annotations/rule_builder.dart';

/// The annotation to convert a Dart class into a Endorse validated object.
///
/// [name]: rename the Stanza table to correspond with a database table name.
/// [snakeCase]: automatically convert the object field names to snake_case.
class EndorseEntity {
  final String name;
  final bool snakeCase;
  const EndorseEntity({this.name = '', this.snakeCase = false});
}

/// The annotation to enhance a Dart class property with Endorse metadata.
///
/// [EndorseField] is not required and only necessary if additional annotations are required
/// on the field. Otherwise, Dart class properties of a [EndorseEntity] are automatically applied
/// to fields.
///
/// [name]: sets an explict name from the object if different than the class field name.
/// [ignore]: will ignore this field completely; it will not be included in the validation.
class EndorseField {
  final List<Validation> validations;
  final bool require;
  final bool fromString;
  const EndorseField({
    this.validations = const <Validation>[],
    this.require = false,
    this.fromString
  });
}
