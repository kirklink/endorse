import 'package:endorse/annotations.dart';
import 'package:endorse/src/endorse/result_object.dart';


class ClassResult extends ResultObject {
  Map<String, ResultObject> _fields;
  ValueResult _mapMetaResult;
  
  ClassResult(this._fields, [this._mapMetaResult]);
  
  
  bool get isValid => _mapMetaResult?.isValid ?? true && !(_fields.values.any((e) => e.isValid == false));


  Object get value {
    final r = <String, Object>{};
    if (_fields == null) {
      return null;
    }
    for (final k in _fields.keys) {
      final value = _fields[k].value;
      if (value == null) {
        continue;
      }
      r[k] = _fields[k].value;
    }
    return r;
  }

  Object get errors {
    if (_mapMetaResult != null && !_mapMetaResult.isValid) {
      return _mapMetaResult.errors;
    } else {
      final r = <String, Object>{};
      for (final k in _fields.keys) {
        if (!_fields[k].isValid) {
          r[k] = _fields[k].errors;
        }
      }
      return r;
    }
  }
}

