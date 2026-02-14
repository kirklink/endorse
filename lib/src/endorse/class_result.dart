import 'package:endorse/src/endorse/result_object.dart';
import 'package:endorse/src/endorse/validation_error.dart';

class ClassResult extends ResultObject {
  final Map<String, ResultObject> _elements;
  final String _fieldName;
  bool? _isValid;
  bool? _hasElementErrors;

  ClassResult(Map<String, ResultObject> fieldMap, [this._fieldName = ""])
      : _elements = fieldMap;

  String get $fieldName => _fieldName;

  bool get $isValid {
    if (_isValid == null) {
      _isValid = !$hasElementErrors;
    }
    return _isValid!;
  }

  bool get $isNotValid => !$isValid;

  bool get $hasElementErrors {
    if (_hasElementErrors == null) {
      _hasElementErrors = false;
      for (final element in _elements.values) {
        if (!element.$isValid) {
          _hasElementErrors = true;
          break;
        }
      }
    }
    return _hasElementErrors!;
  }

  List<ValidationError> get $errors {
    final errors = <ValidationError>[];
    for (final element in _elements.values) {
      errors.addAll(element.$errors);
    }
    return errors;
  }

  @override
  Object? get $value {
    // ClassResult doesn't have a single value, it has multiple field values
    throw UnsupportedError('ClassResult does not have a \$value. Use entity() instead.');
  }
}
