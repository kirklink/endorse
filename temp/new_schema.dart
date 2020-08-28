class _$TestValidationRules {

  ValueResult someString(Object value) => (ValidateValue()..isString()..maxLength(10)).from(value);
  ValueResult someInt(Object value) => (ValidateValue()..isInt()..isGreaterThan(5)).from(value);
  ClassResult someMap(Object value) => (ValidateValue()..isMap())

}

class _$TestValidationResult extends ClassResult {
  final ValueResult someString;
  final ValueResult someInt;

   _$TestValidationResult(
      Map<String, ResultObject> fields, ValueResult mapResult,
      [this.someString,
      this.someInt,])
      : super(fields, mapResult);


}

class _$TestValidator {


  final $rules = _$TestValidationRules();

  _$TestValidationResult validate(Map<String, Object> input) {
    final r = <String, Object>{
      'someString': $rules.someString(input['someString']),
      'someInt': $rules.someInt(input['someInt']),
    };
    
    _$TestValidationResult(r, null, r['someString'], r['someInt']);

  }

}