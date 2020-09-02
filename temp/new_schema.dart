class _$TestValidationRules {

  ValueResult someString(Object value) => (ValidateValue()..isString()..maxLength(10)).from(value);
  ValueResult someInt(Object value) => (ValidateValue()..isInt()..isGreaterThan(5)).from(value);
  ClassResult someMap(Object value) => (ValidateValue()..isMap());

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

















// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// EndorseEntityGenerator
// **************************************************************************






class _$TestValidationResult extends ClassResult {
  final ValueResult some_string;
  final ValueResult i;
  final ValueResult d;
  final ValueResult b;
  final ListResult lotsaList;
  final ValueResult dt;
  final ValueResult random_name;
  final ListResult scores;
  final _$ScoresValidationResult score_map;
  _$TestValidationResult(
      Map<String, ResultObject> fields, ValueResult mapResult,
      [this.some_string,
      this.i,
      this.d,
      this.b,
      this.lotsaList,
      this.dt,
      this.random_name,
      this.scores,
      this.score_map])
      : super(fields, mapResult);
}

class _$TestEndorse implements EndorseClassValidator {
  @override
  _$TestValidationResult validate(Map<String, Object> input) {
    final r = <String, ResultObject>{};
    r['some_string'] = (ValidateValue()
          ..isRequired()
          ..isString()
          ..minLength(2)
          ..contains('hello')
          ..startsWith('xxx'))
        .from(input['some_string'], 'some_string');
    r['i'] = (ValidateValue()
          ..isInt()
          ..isEqualTo(10)
          ..isNotEqualTo(11)
          ..isGreaterThan(1)
          ..isLessThan(100))
        .from(input['i'], 'i');
    r['d'] = (ValidateValue()
          ..isDouble()
          ..isEqualTo(10))
        .from(input['d'], 'd');
    r['b'] = (ValidateValue()
          ..isBoolean()
          ..isFalse())
        .from(input['b'], 'b');
    r['lotsaList'] = (ValidateList.fromCore(
            ValidateValue()
              ..isRequired()
              ..isList(),
            ValidateValue()
              ..isRequired()
              ..isString()))
        .from(input['lotsaList'], 'lotsaList');
    r['dt'] = (ValidateValue()..isDateTime()).from(input['dt'], 'dt');
    r['random_name'] = (ValidateValue()
          ..isString(toString: true)
          ..isNum()
          ..isGreaterThan(0)
          ..makeString())
        .from(input['random_name'], 'random_name');
    r['scores'] =
        (ValidateList.fromEndorse(ValidateValue()..isList(), _$ScoresEndorse()))
            .from(input['scores'], 'scores');
    r['score_map'] = (ValidateMap<_$ScoresValidationResult>(
            ValidateValue()..isMap(), _$ScoresEndorse()))
        .from(input['score_map'], 'score_map');
    return _$TestValidationResult(
        r,
        null,
        r['some_string'],
        r['i'],
        r['d'],
        r['b'],
        r['lotsaList'],
        r['dt'],
        r['random_name'],
        r['scores'],
        r['score_map']);
  }

  @override
  _$TestValidationResult invalid(ValueResult mapResult) {
    return _$TestValidationResult(null, mapResult);
  }
}

class _$ScoresValidationResult extends ClassResult {
  final ValueResult math;
  final ValueResult science;
  final _$ScoresInnerValidationResult scoresInner;
  _$ScoresValidationResult(
      Map<String, ResultObject> fields, ValueResult mapResult,
      [this.math, this.science, this.scoresInner])
      : super(fields, mapResult);
}

class _$ScoresEndorse implements EndorseClassValidator {
  @override
  _$ScoresValidationResult validate(Map<String, Object> input) {
    final r = <String, ResultObject>{};
    r['math'] = (ValidateValue()
          ..isInt()
          ..isEqualTo(10)
          ..isGreaterThan(8))
        .from(input['math'], 'math');
    r['science'] = (ValidateValue()
          ..isInt()
          ..isEqualTo(10))
        .from(input['science'], 'science');
    r['scoresInner'] = (ValidateMap<_$ScoresInnerValidationResult>(
            ValidateValue()..isMap(), _$ScoresInnerEndorse()))
        .from(input['scoresInner'], 'scoresInner');
    return _$ScoresValidationResult(
        r, null, r['math'], r['science'], r['scoresInner']);
  }

  @override
  _$ScoresValidationResult invalid(ValueResult mapResult) {
    return _$ScoresValidationResult(null, mapResult);
  }
}

class _$ScoresInnerValidationResult extends ClassResult {
  final ValueResult textCount;
  _$ScoresInnerValidationResult(
      Map<String, ResultObject> fields, ValueResult mapResult,
      [this.textCount])
      : super(fields, mapResult);
}

class _$ScoresInnerEndorse implements EndorseClassValidator {
  @override
  _$ScoresInnerValidationResult validate(Map<String, Object> input) {
    final r = <String, ResultObject>{};
    r['textCount'] = (ValidateValue()
          ..isInt()
          ..isEqualTo(10)
          ..isGreaterThan(8))
        .from(input['textCount'], 'textCount');
    return _$ScoresInnerValidationResult(r, null, r['textCount']);
  }

  @override
  _$ScoresInnerValidationResult invalid(ValueResult mapResult) {
    return _$ScoresInnerValidationResult(null, mapResult);
  }
}
