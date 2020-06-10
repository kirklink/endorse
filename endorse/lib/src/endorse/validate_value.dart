import 'package:endorse/src/endorse/rules.dart';
import 'package:endorse/src/endorse/value_result.dart';
import 'package:endorse/src/endorse/rule_holder.dart';
import 'package:endorse/src/endorse/evaluator.dart';


class ValidateValue {
  final rules = <RuleHolder>[];
  
  ValueResult from(Object input, [String field = '']) {
    final evaluator = Evaluator(this.rules, input, field);
    return evaluator.evaluate();
  }

  void isRequired() {
    rules.add(RuleHolder(IsRequiredRule()));
  }

  void isMap() {
    rules.add(RuleHolder(IsMapRule()));
  }

  void isList() {
    rules.add(RuleHolder(IsListRule()));
  }

  void isString() {
    rules.add(RuleHolder(IsStringRule()));
  }

  void isNumber() {
    rules.add(RuleHolder(IsNumRule()));
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

  void isDateTime() {
    rules.add(RuleHolder(IsDateTimeRule()));
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