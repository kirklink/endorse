import 'package:endorse/annotations.dart';
import 'package:endorse/src/endorse/rules.dart';
import 'package:endorse/src/endorse/value_result.dart';
import 'package:endorse/src/endorse/rule_holder.dart';
import 'package:endorse/src/endorse/evaluator.dart';

class ValidateValue {
  final rules = <RuleHolder>[];

  ValueResult from(Object input, String field) {
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

  void isString({bool toString = false}) {
    if (toString) {
      rules.add(RuleHolder(CanStringRule()));
    } else {
      rules.add(RuleHolder(IsStringRule()));
    }
  }

  void makeString() {
    rules.add(RuleHolder(ToStringRule()));
  }

  void isNumber() {
    rules.add(RuleHolder(IsNumRule()));
  }

  void isInt({bool fromString = false}) {
    if (fromString) {
      rules.add(RuleHolder(CanIntFromStringRule()));
    } else {
      rules.add(RuleHolder(IsIntRule()));
    }
  }

  void isDouble({bool fromString = false}) {
    if (fromString) {
      rules.add(RuleHolder(CanDoubleFromStringRule()));
    } else {
      rules.add(RuleHolder(IsDoubleRule()));
    }
  }

  void isNum({bool fromString = false}) {
    if (fromString) {
      rules.add(RuleHolder(CanNumFromStringRule()));
    } else {
      rules.add(RuleHolder(IsNumRule()));
    }
  }

  void isBoolean({bool fromString = false}) {
    if (fromString) {
      rules.add(RuleHolder(CanBoolFromStringRule()));
    } else {
      rules.add(RuleHolder(IsBoolRule()));
    }
  }

  void intFromString() {
    rules.add(RuleHolder(IntFromStringRule()));
  }

  void doubleFromString() {
    rules.add(RuleHolder(DoubleFromStringRule()));
  }

  void numFromString() {
    rules.add(RuleHolder(NumFromStringRule()));
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

  void isBefore(Object test) {
    rules.add(RuleHolder(IsBeforeRule(), test));
  }

  void isAfter(Object test) {
    rules.add(RuleHolder(IsAfterRule(), test));
  }

  void isAtMoment(Object test) {
    rules.add(RuleHolder(IsAtMomentRule(), test));
  }

  void isSameDateAs(Object test) {
    rules.add(RuleHolder(IsSameDateAsRule(), test));
  }

  void matchesPattern(String test) {
    rules.add(RuleHolder(MatchesPatternRule(), test));
  }

  void isEmail(String test) {
    rules.add(RuleHolder(IsEmailRule(), test));
  }
}
