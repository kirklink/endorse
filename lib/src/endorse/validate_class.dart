import 'package:endorse/annotations.dart';
// import 'package:endorse/src/endorse/validate_value.dart';
// import 'package:endorse/src/endorse/endorse_class_validator.dart';
// import 'package:endorse/src/endorse/class_result.dart';

class ValidateClass {
  final ValidateValue _fieldRules;
  EndorseClassValidator _validator;

  ValidateClass(this._fieldRules, this._validator);

  ClassResult from(Object? map, String fieldName) {
    final fieldResult = _fieldRules.from(map, fieldName);
    if (!fieldResult.$isValid) {
      return ClassResult(const {}, fieldName, fieldResult);
    } else {
      return _validator.validate(map as Map<String, Object>);
    }
  }
}
