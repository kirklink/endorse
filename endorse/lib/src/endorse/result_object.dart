import 'package:endorse/src/endorse/error_object.dart';


abstract class ResultObject {
  bool get isValid;
  Object get errors;
  Object get value;
}

class ValueResult implements ResultObject {
  final String field;
  final Object value;
  final Object _valueCast;
  final List<ErrorObject> _errorList;
  
  ValueResult(this.field, this.value, this._valueCast, this._errorList);

  bool get isValid => _errorList.isEmpty;

  Object get errors {
    // final list = {for (var v in _errorList) v.ruleName : v.map()};
    final list = _errorList.map((i) => i.map()).toList();
    return list;
  }
}


class ListResult implements ResultObject {
  final List<ResultObject> value;
  final List<ErrorObject> _errorList;
  final ValueResult fieldErrors;

  ListResult(this.fieldErrors, this.value, this._errorList);

  bool get isValid {
    if (!fieldErrors.isValid) {
      return false;
    }
    for (final v in value) {
      if (!v.isValid) {
        return false;
      }
    }
    return true;
  }

  Object get errors {
    final result = {
      'listErrors': fieldErrors.errors,
      'itemErrors': _errorList.map((i) => i.map()).toList()
    };
    return result;
  }

}
