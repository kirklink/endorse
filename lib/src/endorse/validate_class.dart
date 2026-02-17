import 'package:endorse/src/endorse/validate_value.dart';
import 'package:endorse/src/endorse/endorse_class_validator.dart';
import 'package:endorse/src/endorse/class_result.dart';

class ValidateClass {
  final ValidateValue _fieldRules;
  final EndorseClassValidator _validator;

  ValidateClass(this._fieldRules, this._validator);

  ClassResult from(Object? map, String fieldName) {
    final fieldResult = _fieldRules.from(map, fieldName);
    if (map is Map<String, Object?> && fieldResult.$isValid) {
      return _validator.validate(map);
    } else {
      // Always return the typed result class so generated code casts work.
      // With an empty map, each sub-field will report its own errors.
      return _validator.validate(const <String, Object?>{});
    }
  }
}
