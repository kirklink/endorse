import 'package:endorse/src/endorse/result_object.dart';
import 'package:endorse/src/endorse/endorse_exception.dart';
import 'package:endorse/src/endorse/error_object.dart';
import 'package:endorse/src/endorse/rules.dart';




class ApplyRulesToList {
  final ApplyRulesToField _fieldRules;
  final ApplyRulesToField _itemRules;
  ValueResult _fieldErrors;
  

  // ApplyRulesToList(this._fieldRules, this._itemRules);

  ApplyRulesToList.fromCore(this._fieldRules, this._itemRules);


  ListResult done(List items, [String field = '']) {
    _fieldErrors = _fieldRules.done(items, field);
    final result = <ErrorObject>[];
    for (final item in items) {
      final r = _itemRules.done(item);
      result.add(r.errors);
    }
    return ListResult(_fieldErrors, items, result);
  }


}

class RuleHolder {
  final Rule rule;
  final Object test;
  RuleHolder(this.rule, [this.test = null]);
}


class ApplyRulesToField {
  String _field;
  Object _input;
  Object _inputCast;
  final _errors = <ErrorObject>[];
  final rules = <RuleHolder>[];
  var _bail = false;

  
  ValueResult done(Object input, [String field = '']) {
    _input = input;
    _field = field;
    _inputCast = input;
    for (final rule in rules) {
      _runRule(rule.rule, rule.test);
    }
    return ValueResult(_field, _input, _inputCast, _errors);
  }

  void _runRule(ValueRule rule, [Object test = null]) {
    if (_bail && !rule.escapesBail) {
      return;
    }
    if (!rule.restriction(_inputCast)) {
      throw EndorseException('${rule.name} ${rule.restrictionError}.');
    }
    final ruleGot = rule.got(_input, test);
    final got = ruleGot != null ? ruleGot : _input;
    final ruleWant = rule.want(_input, test);
    final want = ruleWant != null ? ruleWant : test;
    if (!rule.pass(_inputCast, test)) {
      _errors.add(ErrorObject(_field, got, rule.name, rule.errorMsg, test, want));
      if (rule.causesBail) {
        _bail = true;
      }
    }
  }

  
  void isRequired() {
    rules.add(RuleHolder(IsRequiredRule()));
  }

  void isList() {
    rules.add(RuleHolder(IsListRule()));
  }

  void isString() {
    rules.add(RuleHolder(IsStringRule()));
  }

  void isInt({bool fromString = false}) {
    if (fromString) {
      final cast = int.tryParse(_inputCast);
      if (cast == null) {
        _errors.add(ErrorObject(_field, _input, 'intFromString', 'Could not cast to int from String'));
        _bail = true;
      } else {
        _inputCast = cast;
      }
    }
    rules.add(RuleHolder(IsIntRule()));
  }

  void isDouble({bool fromString = false}) {
    if (fromString) {
      final cast = double.tryParse(_inputCast);
      if (cast == null) {
        _errors.add(ErrorObject(_field, _input, 'doubleFromString', 'Could not cast to double from String'));
        _bail = true;
      } else {
        _inputCast = cast;
      }
    }
    rules.add(RuleHolder(IsDoubleRule()));
  }

  void isBoolean({bool fromString = false}) {
    if (fromString) {
      final isTrue = _inputCast == 'true' ? true : null;
      final isFalse = _inputCast == 'false' ? false : null;
      if (isTrue == null && isFalse == null) {
        _errors.add(ErrorObject(_field, _input, 'boolFromString', 'Could not cast to bool from String'));
        _bail = true;
      } else {
        _inputCast = isTrue == null ? isFalse : isTrue;
      }
    }
    rules.add(RuleHolder(IsBoolRule()));
  }

  void maxLength(int test) {
    rules.add(RuleHolder(MaxLengthRule(), test));
  }

  void minLength(int test) {
    rules.add(RuleHolder(MinLengthRule(), test));
  }

  void matches(String test) {
    rules.add(RuleHolder(MatchesRule(), test));
  }

  void contains(String test) {
    rules.add(RuleHolder(ContainsRule(), test));
  }

  void startsWith(String test) {
    rules.add(RuleHolder(StartsWithRule(), test));
  }

  void endsWith(String test) {
    rules.add(RuleHolder(EndsWithRule(), test));
  }
 
  void isEqualTo(num test) {
    rules.add(RuleHolder(IsEqualToRule(), test));
  }

  void isNotEqualTo(num test) {
    rules.add(RuleHolder(IsNotEqualToRule(), test));
  }

  void isGreaterThan(num test) {
    rules.add(RuleHolder(IsGreaterThanRule(), test));
  }

  void isLessThan(num test) {
    rules.add(RuleHolder(IsLessThanRule(), test));
  }

  void isTrue() {
    rules.add(RuleHolder(IsTrueRule()));
  }

  void isFalse() {
    rules.add(RuleHolder(IsFalseRule()));
  }

  


}

