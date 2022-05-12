import 'package:endorse/src/endorse/rule.dart';

class RuleHolder {
  final Rule rule;
  final Object? test;
  const RuleHolder(this.rule, [this.test]);
}
