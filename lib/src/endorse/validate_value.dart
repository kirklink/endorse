import 'package:endorse/src/endorse/rule.dart';
import 'package:endorse/src/endorse/value_result.dart';
import 'package:endorse/src/endorse/rule_holder.dart';
import 'package:endorse/src/endorse/evaluator.dart';

class ValidateValue {
  final rules = <RuleHolder>[];

  ValueResult from(Object? input, String field) {
    final evaluator = Evaluator(this.rules, input, field);
    return evaluator.evaluate();
  }

  // Required / Type Checking

  void isRequired() {
    rules.add(RuleHolder(Required()));
  }

  void isNotNull() {
    rules.add(RuleHolder(Required()));
  }

  void isMap() {
    rules.add(RuleHolder(IsMap()));
  }

  void isList() {
    rules.add(RuleHolder(IsList()));
  }

  void isString({bool toString = false}) {
    if (toString) {
      rules.add(RuleHolder(ToStringCast()));
    } else {
      rules.add(RuleHolder(IsString()));
    }
  }

  void makeString() {
    rules.add(RuleHolder(ToStringCast()));
  }

  // Numeric Type Checking

  void isNumber() {
    rules.add(RuleHolder(IsNum()));
  }

  void isInt({bool fromString = false}) {
    if (fromString) {
      rules.add(RuleHolder(CanIntFromString()));
    } else {
      rules.add(RuleHolder(IsInt()));
    }
  }

  void isDouble({bool fromString = false}) {
    if (fromString) {
      rules.add(RuleHolder(CanDoubleFromString()));
    } else {
      rules.add(RuleHolder(IsDouble()));
    }
  }

  void isNum({bool fromString = false}) {
    if (fromString) {
      rules.add(RuleHolder(CanNumFromString()));
    } else {
      rules.add(RuleHolder(IsNum()));
    }
  }

  // Boolean Type Checking

  void isBoolean({bool fromString = false}) {
    if (fromString) {
      rules.add(RuleHolder(CanBoolFromString()));
    } else {
      rules.add(RuleHolder(IsBool()));
    }
  }

  // Type Coercion (cast)

  void intFromString() {
    rules.add(RuleHolder(IntFromStringCast()));
  }

  void doubleFromString() {
    rules.add(RuleHolder(DoubleFromStringCast()));
  }

  void numFromString() {
    rules.add(RuleHolder(NumFromStringCast()));
  }

  // DateTime

  void isDateTime() {
    rules.add(RuleHolder(IsDateTime()));
  }

  // String Rules

  void maxLength(int test) {
    rules.add(RuleHolder(MaxLength(test)));
  }

  void minLength(int test) {
    rules.add(RuleHolder(MinLength(test)));
  }

  void matches(String test) {
    rules.add(RuleHolder(MatchesValue(test)));
  }

  void contains(String test) {
    rules.add(RuleHolder(ContainsValue(test)));
  }

  void startsWith(String test) {
    rules.add(RuleHolder(StartsWithValue(test)));
  }

  void endsWith(String test) {
    rules.add(RuleHolder(EndsWithValue(test)));
  }

  // Numeric Comparison

  void isEqualTo(num test) {
    rules.add(RuleHolder(IsEqualTo(test)));
  }

  void isNotEqualTo(num test) {
    rules.add(RuleHolder(IsNotEqualTo(test)));
  }

  void isGreaterThan(num test) {
    rules.add(RuleHolder(IsGreaterThan(test.toInt())));
  }

  void isLessThan(num test) {
    rules.add(RuleHolder(IsLessThan(test.toInt())));
  }

  // Boolean Rules

  void isTrue() {
    rules.add(RuleHolder(IsTrueRule()));
  }

  void isFalse() {
    rules.add(RuleHolder(IsFalseRule()));
  }

  // DateTime Rules

  void isBefore(Object test) {
    rules.add(RuleHolder(IsBeforeRule(test.toString())));
  }

  void isAfter(Object test) {
    rules.add(RuleHolder(IsAfterRule(test.toString())));
  }

  void isAtMoment(Object test) {
    rules.add(RuleHolder(IsAtMomentRule(test.toString())));
  }

  void isSameDateAs(Object test) {
    rules.add(RuleHolder(IsSameDateAsRule(test.toString())));
  }

  // Pattern Matching

  void matchesPattern(String test) {
    rules.add(RuleHolder(MatchesPatternRule(test)));
  }

  void isEmail(String test) {
    rules.add(RuleHolder(IsEmailRule()));
  }
}
