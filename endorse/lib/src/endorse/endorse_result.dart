import 'package:endorse/annotations.dart';
import 'package:endorse/src/endorse/result_object.dart';
import 'package:endorse/src/endorse/validation_error.dart';

abstract class EndorseResult {
  Map<String, ResultObject> _fields;

  EndorseResult(this._fields);

  bool get $isNotValid => _fields.values.any((e) => e.$isNotValid);
  bool get $isValid => !$isNotValid;

  Object get $value {
    final r = <String, Object>{};
    if (_fields == null) {
      return null;
    }
    for (final k in _fields.keys) {
      final value = _fields[k].$value;
      if (value == null) {
        continue;
      }
      r[k] = _fields[k].$value;
    }
    return r;
  }

  Object get $errorsJson {
    final r = <String, Object>{};
    for (final k in _fields.keys) {
      if (!_fields[k].$isValid) {
        r[k] = _fields[k].$errorsJson;
      }
    }
    return r;
  }
}
