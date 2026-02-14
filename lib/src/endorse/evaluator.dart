import 'package:endorse/src/endorse/endorse_exception.dart';
import 'package:endorse/src/endorse/validation_error.dart';
import 'package:endorse/src/endorse/rule.dart' hide ValidationError;
import 'package:endorse/src/endorse/rule_holder.dart';
import 'package:endorse/src/endorse/value_result.dart';

class Evaluator {
  final List<RuleHolder> rules;
  final Object? _input;
  // modified (casted) input value Object between runRule iterations
  Object? _inputCast;
  final String _field;
  var _bail = false;
  final _errors = <ValidationError>[];

  Evaluator(this.rules, this._input, this._field) : _inputCast = _input;

  ValueResult evaluate() {
    for (final rule in rules) {
      _runRule(rule.rule, rule.test);
    }
    return ValueResult(_field, _inputCast, _errors);
  }

  void _runRule(Rule rule, [Object? test]) {
    if (_bail && !rule.escapesBail) {
      return;
    }
    if (_inputCast == null && rule.skipIfNull) {
      return;
    }
    final precondition = rule.check(_inputCast, test);
    if (precondition.isNotEmpty) {
      throw EndorseException('Precondition failed: $precondition');
    }
    final ruleGot = rule.got(_input, test);
    final got = ruleGot.isNotEmpty ? ruleGot : _input.toString();
    final ruleWant = rule.want(_input, test);
    final want = ruleWant.isNotEmpty ? ruleWant : test.toString();
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
