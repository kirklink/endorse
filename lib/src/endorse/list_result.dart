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

  String get $fieldName => _fieldName;

  bool? get $isValid {
    if (_isValid != null) {
      return _isValid;
    }
    _isValid = _value.$isValid && !$hasElementErrors!;
    return _isValid;
  }

  bool get $isNotValid => !$isValid!;

  bool? get $hasElementErrors {
    if (_hasElementErrors != null) {
      return _hasElementErrors;
    }
    _hasElementErrors = _elements.any((e) => e.$isNotValid);
    return _hasElementErrors;
  }

  List<ValidationError> get $errors {
    if (_isValid!) {
      return const [];
    }
    var errorElements = List<ResultObject>.from(_elements);
    errorElements.retainWhere((e) => e.$isNotValid);
    final errorCount = errorElements.length;
    if (errorCount > 0) {
      final elementError = ValidationError(
          'ElementErrors',
          'Validation failed for ${errorCount} element(s).',
          '0 errors.',
          '${errorCount} errors.');
      final errors = _value.$errors;
      errors.add(elementError);
      return errors;
    } else {
      return _value.$errors;
    }
  }

  List<ResultObject> get $elements => _elements;

  Object get $value {
    return _elements.map((e) => e.$value).toList();
  }

  Object get $errorsJson {
    if ($isValid!) {
      return const [];
    } else {
      return _elements.map((e) => e.$errorsJson).toList();
    }
  }
}
