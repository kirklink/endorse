import 'package:endorse/src/endorse/value_result.dart';
import 'package:endorse/src/endorse/result_object.dart';
import 'package:endorse/src/endorse/validation_error.dart';

class ClassResult extends ResultObject {
  final Map<String, ResultObject> _elements;
  final ValueResult? _field;
  final String _fieldName;
  bool? _isValid;
  bool? _hasElementErrors;

  ClassResult(this._elements, [this._fieldName = "", this._field]);

  String get $fieldName => _fieldName;

  bool get $isValid {
    if (_isValid == null) {
      _isValid = (_field == null || _field!.$isValid) && !$hasElementErrors;
    }
    return _isValid!;
  }

  bool get $isNotValid => !$isValid;

  bool get $hasElementErrors {
    if (_hasElementErrors == null) {
      _hasElementErrors = _elements.values.any((e) => e.$isNotValid);
    }
    return _hasElementErrors!;
  }

  List<ValidationError> get $errors {
    if ($isValid) {
      return const [];
    } else if (_field != null) {
      if ($hasElementErrors) {
        var errorFields = '';
        var count = 0;
        _elements.forEach((key, value) {
          if (value.$isNotValid) {
            errorFields =
                errorFields + "${errorFields.isNotEmpty ? ',' : ''}" + key;
            count++;
          }
        });
        final elementError = ValidationError(
            'ElementErrors',
            'Validation failed for $count element(s).',
            errorFields,
            '0 errors.');
        final errors = List<ValidationError>.from(_field!.$errors);
        errors.add(elementError);
        return errors;
      } else {
        return _field!.$errors;
      }
    } else {
      return const [];
    }
  }

  Object get $value {
    final r = <String, Object?>{};
    if (_elements.keys.isNotEmpty) {
      for (final k in _elements.keys) {
        final value = _elements[k]!.$value;
        r[k] = value;
      }
    }
    return r;
  }

  Object get $errorsJson {
    if (_field != null && _field!.$isNotValid) {
      return _field!.$errorsJson;
    } else {
      final r = <String, Object>{};
      if (_elements.keys.isNotEmpty) {
        for (final k in _elements.keys) {
          if (_elements[k]!.$isNotValid) {
            r[k] = _elements[k]!.$errorsJson;
          }
        }
      }
      return r;
    }
  }
}
