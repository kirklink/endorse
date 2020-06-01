import 'package:endorse/src/endorse/result_object.dart';
import 'package:endorse/src/endorse/endorse_exception.dart';
import 'package:endorse/src/endorse/error_expander.dart';
import 'package:endorse/src/endorse/rules.dart';




class ApplyRulesToList {
  final ApplyRulesToValue _fieldRules;
  final ApplyRulesToValue _itemRules;
  ValueResult _fieldResult;

  ApplyRulesToList.fromCore(this._fieldRules, this._itemRules);


  ListResult done(List<Object> items, [String field = '']) {
    _fieldResult = _fieldRules.done(items, field);
    final result = <ValueResult>[];
    items.asMap().forEach((index, item) {
      var r = _itemRules.done(item, '[$index]');
      result.add(r);
    });
    return ListResult(_fieldResult, result);
  }


}

class RuleHolder {
  final Rule rule;
  final Object test;
  RuleHolder(this.rule, [this.test = null]);
}


class ApplyRulesToValue {
  final rules = <RuleHolder>[];
  
  ValueResult done(Object input, [String field = '']) {

    final evaluator = Evaluator(this.rules, input, field);
    return evaluator.evaluate();
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
      rules.add(RuleHolder(IntFromStringRule()));
    }
    rules.add(RuleHolder(IsIntRule()));
  }

  void isDouble({bool fromString = false}) {
    if (fromString) {
      rules.add(RuleHolder(DoubleFromStringRule()));
    }
    rules.add(RuleHolder(IsDoubleRule()));
  }

  void isBoolean({bool fromString = false}) {
    if (fromString) {
      rules.add(RuleHolder(BoolFromStringRule()));
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


class Evaluator {
  final List<RuleHolder> rules;
  final Object _input;
  Object _inputCast;
  final String _field;
  var _bail = false;
  final _errors = <ErrorExpander>[];

  Evaluator(this.rules, this._input, [this._field = '']) {
    _inputCast = _input;
  }

  ValueResult evaluate() {
    for (final rule in rules) {
      _runRule(rule.rule, rule.test);
    }
    return ValueResult(_input, _errors, _field);
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
      _errors.add(ErrorExpander(_field, got, rule.name, rule.errorMsg, want));
      if (rule.causesBail) {
        _bail = true;
      }
    }
    _inputCast = rule.cast(_inputCast);
  }

  
  


}




