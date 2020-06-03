import 'package:endorse/src/endorse/validate_value.dart';
import 'package:endorse/src/endorse/endorse_class_validator.dart';
import 'package:endorse/src/endorse/value_result.dart';
import 'package:endorse/src/endorse/list_result.dart';
import 'package:endorse/src/endorse/class_result.dart';

class ValidateList {
  final ValidateValue _fieldRules;
  ValidateValue _itemRules;
  EndorseClassValidator _validator;

  ValidateList.fromCore(this._fieldRules, this._itemRules);

  ValidateList.fromEndorse(this._fieldRules, this._validator);


  ListResult from(Object items, [String field = '']) {
    
    var _fieldResult = _fieldRules.from(items);
    
    if (items == null || !(items is List)) {
      return ListResult(_fieldResult, null);
    } else {
      if (_validator != null) {
        final result = <ClassResult>[];
        (items as List).asMap().forEach((index, item) {
          final r = _validator.validate(item);
          result.add(r);
        });
        return ListResult(_fieldResult, result);
      } else {
        final result = <ValueResult>[];
        (items as List).asMap().forEach((index, item) {
          var r = _itemRules.from(item, '[$index]');
          result.add(r);
        });
        return ListResult(_fieldResult, result);      
      }
      
    }
    
  }


}