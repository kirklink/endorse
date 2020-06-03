import 'package:endorse/src/endorse/result_object.dart';
import 'package:endorse/src/endorse/error_expander.dart';


class ValueResult extends ResultObject {
  final Object _value;
  final List<ErrorExpander> _errorExpanders;
  
  ValueResult(this._value, this._errorExpanders);

  Object get value => _value;

  bool get isValid => _errorExpanders.isEmpty;

  Object get errors {
    final result = <String, Object> {};
    _errorExpanders.forEach((item) => result.addAll(item.expand()));
    return result;
  }
}

