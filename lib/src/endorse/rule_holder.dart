import 'package:endorse/src/endorse/rule.dart';

class RuleHolder {
  final Rule rule;
  final Object test;
  RuleHolder(this.rule, [this.test = null]);
}
