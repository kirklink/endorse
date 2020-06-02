import 'package:endorse/src/endorse/error_expander.dart';


abstract class ResultObject {
  Object get value;
  Object get errors;
  bool get isValid;
}


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


class ListResult extends ResultObject {
  final ValueResult valueResult;
  final List<ValueResult> _itemResults;

  ListResult(this.valueResult, this._itemResults);

  bool get isValid => valueResult.isValid && _itemResults != null && !(_itemResults.any((e) => e.isValid == false));

  Object get value {
    if (_itemResults == null) {
      return null;
    }
    final r = <Object>[];
    for (final i in _itemResults) {
      r.add(i.value);
    }
    return r;
  }

  List<ValueResult> get list => _itemResults;
  
  Object get errors {
    
    final result = <String, Object>{};

    if (!valueResult.isValid) {
      result['list'] = valueResult.errors;
    }

    if (_itemResults != null && _itemResults.any((e) => !e.isValid)) {
      final itemErrors = <Object>[];
      for (var item in _itemResults) {
        itemErrors.add(item.errors);
      }
      result['items'] = itemErrors;
    }
    return result;
  }

}


class ValueResult extends ResultObject {
  final String field;
  final Object _value;
  final List<ErrorExpander> _errorExpanders;
  
  ValueResult(this._value, this._errorExpanders, [this.field = '']);

  Object get value => _value;

  bool get isValid => _errorExpanders.isEmpty;

  Object get errors {
    final list = _errorExpanders.map((i) => i.expand()).toList();
    return list;
  }
}



