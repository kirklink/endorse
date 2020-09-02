import 'package:endorse/src/endorse/validate_value.dart';
import 'package:endorse/src/endorse/endorse_class_validator.dart';
import 'package:endorse/src/endorse/class_result.dart';

class ValidateMap<T extends ClassResult> {
  final ValidateValue _fieldRules;
  EndorseClassValidator _validator;

  ValidateMap(this._fieldRules, this._validator);

  T from(Object map, [String field = '']) {
    
    var _fieldResult = _fieldRules.from(map, field);

    if (!_fieldResult.isValid) {
      // return _validator.invalid(_fieldResult);
    } else {
      // handle if it's null
      return _validator.validate(map);
    }
    
  }


}