import 'package:endorse/annotations.dart';
// import 'package:endorse/src/endorse/result_object.dart';
import 'package:endorse/src/endorse/validation_error.dart';

class ClassResult extends ResultObject {
  final Map<String, ResultObject> _elements;
  final ValueResult? _field;
  final String _fieldName;
  bool? _isValid;
  final bool _hasElementErrors;
  List<ValidationError> _errors = [];

  ClassResult(this._elements, [this._fieldName = '', this._field])
      : _hasElementErrors = _elements.values.any((e) => e.$isNotValid) {
    _isValid = (_field == null || _field!.$isValid) && !_hasElementErrors;
  }

  String get $fieldName => _fieldName;

  bool? get $isValid => _isValid;

  bool get $isNotValid => !_isValid!;

  bool get $hasElementErrors => _hasElementErrors;

  // List<ValidationError> get $errors => _errors;

  List<ValidationError> get $errors {
    if (_errors.isNotEmpty) return _errors;
    if (_isValid!) {
      return const [];
    } else if (_field != null) {
      if (_hasElementErrors) {
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
        _errors.addAll(errors);
        return _errors;
      } else {
        return _field!.$errors;
      }
    } else {
      return const [];
    }
  }

  Object get $value {
    // Gotta find a way to send a signal that if the field has errors, the
    // object (name and value) should not be included in the $value output.
    // A null value cannot be the signal because a null value might be a
    // legitimate value.
    // Value result needs to signal up that it has errpors.

    final r = <String, Object>{};

    for (final k in _elements.keys) {
      final value = _elements[k]?.$value;
      if (value == null) {
        continue;
      }
      r[k] = value;
    }
    return r;
  }

  Object get $errorsJson {
    if (_field != null && _field!.$isNotValid) {
      return _field!.$errorsJson;
    } else {
      final r = <String, Object>{};
      for (final k in _elements.keys) {
        if (!_elements[k]!.$isValid!) {
          r[k] = _elements[k]!.$errorsJson;
        }
      }
      return r;
    }
  }
}
