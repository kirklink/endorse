import 'package:endorse/src/endorse/error_expander.dart';


abstract class ResultObject {
  Object get value;
  Object get errors;
  bool get isValid;
}

class ValueResult implements ResultObject {
  final String field;
  final Object value;
  final List<ErrorExpander> _errorExpanders;
  
  ValueResult(this.value, this._errorExpanders, [this.field = '']);

  bool get isValid => _errorExpanders.isEmpty;

  Object get errors {
    final list = _errorExpanders.map((i) => i.expand()).toList();
    return list;
  }
}


class ListResult implements ResultObject {
  final String field;
  final ValueResult valueResult;
  final List<ValueResult> _itemResults;

  ListResult(this.valueResult, this._itemResults, [this.field]);

  bool get isValid {
    if (!valueResult.isValid) {
      return false;
    }
    for (var i in _itemResults) {
      if (!i.isValid) {
        return false;
      }
    }
    return true;
  }

  Object get value {
    return _itemResults.map((i) => i.value).toList();
  }

  Object get errors {
    final itemErrors = <Object>[];
    for (var item in _itemResults) {
      print(item.errors);
      print(item.value);
      itemErrors.add(item.errors);
    }
    final result = {
      'list': valueResult.errors,
      'items': itemErrors
    };
    return result;
  }

}
