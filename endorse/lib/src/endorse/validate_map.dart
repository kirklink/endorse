import 'package:endorse/annotations.dart';
import 'package:endorse/src/endorse/validate_value.dart';
import 'package:endorse/src/endorse/endorse_class_validator.dart';
import 'package:endorse/src/endorse/class_result.dart';

class ValidateMap {
  final ValidateValue _fieldRules;
  EndorseClassValidator _validator;

  ValidateMap(this._fieldRules, this._validator);

  ClassResult from(Object map, [String field = '']) {
    
    var _fieldResult = _fieldRules.from(map, field);

    if (!_fieldResult.isValid) {
      return ClassResult(null, _fieldResult);
    } else {
      // handle if it's null
      return _validator.validate(map);
    }
    
  }


}