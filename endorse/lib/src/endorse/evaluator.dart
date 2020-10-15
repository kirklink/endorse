import 'package:endorse/src/endorse/validation_error.dart';
import 'package:endorse/src/endorse/rules.dart';
import 'package:endorse/src/endorse/rule_holder.dart';
import 'package:endorse/src/endorse/value_result.dart';

class Evaluator {
  final List<RuleHolder> rules;
  final Object _input;
  Object _inputCast;
  String _field;
  var _bail = false;
  final _errors = <ValidationError>[];

  Evaluator(this.rules, this._input, this._field) {
    _inputCast = _input;
  }

  ValueResult evaluate() {
    for (final rule in rules) {
      _runRule(rule.rule, rule.test);
    }
    return ValueResult(_field, _input, _errors);
  }

  void _runRule(ValueRule rule, [Object test = null]) {
    if (_bail && !rule.escapesBail) {
      return;
    }
    if (_inputCast == null && rule.skipIfNull) {
      return;
    }
    final ruleGot = rule.got(_input, test);
    final got = ruleGot != null ? ruleGot : _input;
    final ruleWant = rule.want(_input, test);
    final want = ruleWant != null ? ruleWant : test;
    if (!rule.pass(_inputCast, test)) {
      _errors.add(
          ValidationError(rule.name, rule.errorMsg(_input, test), got, want));
      if (rule.causesBail) {
        _bail = true;
      }
    }
    _inputCast = rule.cast(_inputCast);
  }
}
