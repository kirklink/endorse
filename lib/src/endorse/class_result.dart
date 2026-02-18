import 'package:endorse/src/endorse/result_object.dart';
import 'package:endorse/src/endorse/validation_error.dart';
import 'package:endorse/src/endorse/value_result.dart';

class ClassResult extends ResultObject {
  final Map<String, ResultObject> _elements;
  final String _fieldName;
  final ValueResult? _fieldResult;
  final List<ValidationError> _crossErrors;
  bool? _isValid;
  bool? _hasElementErrors;

  ClassResult(Map<String, ResultObject> fieldMap,
      [this._fieldName = "",
      this._fieldResult,
      this._crossErrors = const []])
      : _elements = fieldMap;

  @override
  String get $fieldName => _fieldName;

  @override
  bool get $isValid {
    if (_isValid == null) {
      if (_fieldResult != null && _fieldResult!.$isNotValid) {
        _isValid = false;
      } else {
        _isValid = !$hasElementErrors && _crossErrors.isEmpty;
      }
    }
    return _isValid!;
  }

  @override
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

  List<ValidationError> get $crossErrors => _crossErrors;

  @override
  List<ValidationError> get $errors {
    final errors = <ValidationError>[];
    if (_fieldResult != null) {
      errors.addAll(_fieldResult!.$errors);
    }
    for (final element in _elements.values) {
      errors.addAll(element.$errors);
    }
    errors.addAll(_crossErrors);
    return errors;
  }

  @override
  Object? get $value {
    throw UnsupportedError(
        'ClassResult does not have a \$value. Use entity() instead.');
  }
}
