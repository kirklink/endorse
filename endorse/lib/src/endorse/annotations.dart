import 'package:endorse/src/endorse/validations.dart';
import 'package:endorse/src/endorse/case.dart';

/// The annotation to convert a Dart class into a Endorse validated object.
///
/// [useCase]: automatically convert the object field names to different case schemas.
class EndorseEntity {
  final Case useCase;
  final bool requireAll;
  const EndorseEntity({
    this.useCase = Case.none,
    this.requireAll = false,
  });
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
  final List<ValidationBase> validate;
  final List<ValidationBase> itemValidate;
  final bool ignore;
  final Case useCase;
  final String name;
  const EndorseField(
      {this.validate = const <ValidationBase>[],
      this.itemValidate = const <ValidationBase>[],
      this.ignore = false,
      this.useCase = Case.none,
      this.name = ''});
}

class EndorseMap {
  const EndorseMap();
}
