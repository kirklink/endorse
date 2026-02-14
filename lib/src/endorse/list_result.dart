import 'package:endorse/src/endorse/result_object.dart';
import 'package:endorse/src/endorse/validation_error.dart';
import 'package:endorse/src/endorse/value_result.dart';

class ListResult extends ResultObject {
  final ValueResult _value;
  final List<ResultObject> _elements;
  final String _fieldName;
  bool? _isValid;
  bool? _hasElementErrors;

  ListResult(this._fieldName, this._value, this._elements);

  @override
  String get $fieldName => _fieldName;

  @override
  bool get $isValid {
    if (_isValid == null) {
      _isValid = _value.$isValid && !$hasElementErrors;
    }
    return _isValid!;
  }

  @override
  bool get $isNotValid => !$isValid;

  bool get $hasElementErrors {
    if (_hasElementErrors == null) {
      _hasElementErrors = _elements.any((e) => e.$isNotValid);
    }
    return _hasElementErrors!;
  }

  @override
  List<ValidationError> get $errors {
    if ($isValid) {
      return const [];
    }
    final errors = <ValidationError>[..._value.$errors];
    final errorElements =
        _elements.where((e) => e.$isNotValid).toList();
    if (errorElements.isNotEmpty) {
      errors.add(ValidationError(
          'ElementErrors',
          'Validation failed for ${errorElements.length} element(s).',
          '0 errors.',
          '${errorElements.length} errors.'));
    }
    return errors;
  }

  List<ResultObject> get $elements => _elements;

  @override
  Object get $value {
    return _elements.map((e) => e.$value).toList();
  }
}
