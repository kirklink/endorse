import 'package:endorse/src/endorse/rule.dart';

class RuleHolder {
  final Rule rule;
  final Object? test;
  final String? customMessage;
  const RuleHolder(this.rule, [this.test, this.customMessage]);
}
