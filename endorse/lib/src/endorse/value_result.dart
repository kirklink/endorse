import 'package:endorse/src/endorse/result_object.dart';
import 'package:endorse/src/endorse/validation_error.dart';

class ValueResult extends ResultObject {
  final Object? _value;
  final String $fieldName;
  final List<ValidationError> _validationErrors;

  ValueResult(this.$fieldName, this._value, this._validationErrors);

  Object? get $value => _validationErrors.isNotEmpty ? null : _value;

  bool get $isValid => _validationErrors.isEmpty;
  bool get $isNotValid => _validationErrors.isNotEmpty;

  Object get $errorsJson => _validationErrors.map((e) => e.toJson()).toList();

  List<ValidationError> get $errors {
    return _validationErrors;
  }
}
