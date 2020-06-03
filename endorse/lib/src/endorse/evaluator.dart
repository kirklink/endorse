import 'package:endorse/src/endorse/endorse_exception.dart';
import 'package:endorse/src/endorse/error_expander.dart';
import 'package:endorse/src/endorse/rules.dart';
import 'package:endorse/src/endorse/rule_holder.dart';
import 'package:endorse/src/endorse/value_result.dart';

class Evaluator {
  final List<RuleHolder> rules;
  final Object _input;
  Object _inputCast;
  String _field;
  var _bail = false;
  final _errors = <ErrorExpander>[];

  Evaluator(this.rules, this._input, [this._field = '']) {
    _inputCast = _input;
  }

  ValueResult evaluate() {
    for (final rule in rules) {
      _runRule(rule.rule, rule.test);
    }
    return ValueResult(_input, _errors);
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




