import 'package:endorse/src/endorse/result_object.dart';


class ClassResult implements ResultObject {
  final Map<String, ResultObject> _fields;
  
  ClassResult(this._fields);

  bool get isValid => !(_fields.values.any((e) => e.isValid == false));

  Object get value {
    final r = <String, Object>{};
    for (final k in _fields.keys) {
      r[k] = _fields[k].value;
    }
    return r;
  }

  Object get errors {
    final r = <String, Object>{};
    for (final k in _fields.keys) {
      if (!_fields[k].isValid) {
        r[k] = _fields[k].errors;
      }
    }
    return r;
  }
}