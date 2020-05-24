import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:endorse/src/rule_set.dart';
import 'package:endorse/src/rule.dart';
import 'package:endorse/src/patterns.dart';
import 'package:endorse/src/validation_error.dart';

class MockRuleSet extends Mock implements RuleSet {}

main() {
  group('RuleSet', () {
    test('RuleSet.required returns null if value provided.', () async {
      var s = RuleSet();
      s.required();
      Rule r = s.rules[0];
      expect(await r(1), isNull);
    });
    test('RuleSet.required returns an error if no valued provided.', () async {
      var s = RuleSet();
      s.required();
      Rule r = s.rules[0];
      expect(await r(null), isNotNull);
    });
    test('RuleSet.required returns a custom error message.', () async {
      var s = RuleSet();
      s.required(msg: 'Error!');
      Rule r = s.rules[0];
      expect((await r(null)).msg, equals('Error!'));
    });
    test('RuleSet.custom facilitates a custom Rule.', () async {
      var s = RuleSet();
      NumRule rule = (num number, {String msg, Map<String, dynamic> map}) {
        return (dynamic value) async {
          if (value != number) return ValidationError(msg, map);
        };
      };
      s.custom(rule(1, msg: 'Error!'));
      Rule r = s.rules[0];
      expect((await r(2)).msg, equals('Error!'));
    });
  });

  group('TypeRuleSet', () {
    test('TypeRuleSet.string returns null if string provided.', () async {
      var s = TypeRuleSet();
      s.string();
      Rule r = s.rules[0];
      expect(await r('test'), isNull);
    });
    test('TypeRuleSet.string returns an error if number is provided.',
        () async {
      var s = TypeRuleSet();
      s.string();
      Rule r = s.rules[0];
      expect(await r(1.25), isNotNull);
    });
    test('TypeRuleSet.string returns an error if [] is provided.', () async {
      var s = TypeRuleSet();
      s.string();
      Rule r = s.rules[0];
      expect(await r([]), isNotNull);
    });
    test('TypeRuleSet.string returns an error if {} is provided.', () async {
      var s = TypeRuleSet();
      s.string();
      Rule r = s.rules[0];
      expect(await r({}), isNotNull);
    });
    test('TypeRuleSet.string returns an error if null is provided.', () async {
      var s = TypeRuleSet();
      s.string();
      Rule r = s.rules[0];
      expect(await r(null), isNotNull);
    });
    test('TypeRuleSet.number returns null if number provided.', () async {
      var s = TypeRuleSet();
      s.number();
      Rule r = s.rules[0];
      expect(await r(1), isNull);
    });
    test('TypeRuleSet.number returns an error if string is provided.',
        () async {
      var s = TypeRuleSet();
      s.number();
      Rule r = s.rules[0];
      expect(await r('test'), isNotNull);
    });
    test('TypeRuleSet.number returns an error if [] is provided.', () async {
      var s = TypeRuleSet();
      s.number();
      Rule r = s.rules[0];
      expect(await r([]), isNotNull);
    });
    test('TypeRuleSet.number returns an error if {} is provided.', () async {
      var s = TypeRuleSet();
      s.number();
      Rule r = s.rules[0];
      expect(await r({}), isNotNull);
    });
    test('TypeRuleSet.number returns an error if null is provided.', () async {
      var s = TypeRuleSet();
      s.number();
      Rule r = s.rules[0];
      expect(await r(null), isNotNull);
    });
    test('TypeRuleSet.integer returns null if integer provided.', () async {
      var s = TypeRuleSet();
      s.integer();
      Rule r = s.rules[0];
      expect(await r(1), isNull);
    });
    test('TypeRuleSet.integer returns an error if string is provided.',
        () async {
      var s = TypeRuleSet();
      s.integer();
      Rule r = s.rules[0];
      expect(await r('test'), isNotNull);
    });
    test('TypeRuleSet.integer returns an error if float is provided.',
        () async {
      var s = TypeRuleSet();
      s.integer();
      Rule r = s.rules[0];
      expect(await r(1.25), isNotNull);
    });
    test('TypeRuleSet.integer returns an error if [] is provided.', () async {
      var s = TypeRuleSet();
      s.integer();
      Rule r = s.rules[0];
      expect(await r([]), isNotNull);
    });
    test('TypeRuleSet.integer returns an error if {} is provided.', () async {
      var s = TypeRuleSet();
      s.integer();
      Rule r = s.rules[0];
      expect(await r({}), isNotNull);
    });
    test('TypeRuleSet.integer returns an error if null is provided.', () async {
      var s = TypeRuleSet();
      s.integer();
      Rule r = s.rules[0];
      expect(await r(null), isNotNull);
    });
    test('TypeRuleSet.float returns null if float provided.', () async {
      var s = TypeRuleSet();
      s.float();
      Rule r = s.rules[0];
      expect(await r(1.1), isNull);
    });
    test('TypeRuleSet.float returns an error if string is provided.', () async {
      var s = TypeRuleSet();
      s.float();
      Rule r = s.rules[0];
      expect(await r('test'), isNotNull);
    });
    test('TypeRuleSet.float returns an error if integer is provided.',
        () async {
      var s = TypeRuleSet();
      s.float();
      Rule r = s.rules[0];
      expect(await r(1), isNotNull);
    });
    test('TypeRuleSet.float returns an error if [] is provided.', () async {
      var s = TypeRuleSet();
      s.float();
      Rule r = s.rules[0];
      expect(await r([]), isNotNull);
    });
    test('TypeRuleSet.float returns an error if {} is provided.', () async {
      var s = TypeRuleSet();
      s.float();
      Rule r = s.rules[0];
      expect(await r({}), isNotNull);
    });
    test('TypeRuleSet.float returns an error if null is provided.', () async {
      var s = TypeRuleSet();
      s.float();
      Rule r = s.rules[0];
      expect(await r(null), isNotNull);
    });
  });

  group('StringRuleSet', () {
    test('StringRuleSet.max returns null if string is less length.', () async {
      var s = StringRuleSet();
      s.max(5);
      Rule r = s.rules[0];
      expect(await r('1234'), isNull);
    });
    test('StringRuleSet.max returns an error if string is greater length.',
        () async {
      var s = StringRuleSet();
      s.max(5);
      Rule r = s.rules[0];
      expect(await r('123456'), isNotNull);
    });
    test('StringRuleSet.min returns null if string is greater length.',
        () async {
      var s = StringRuleSet();
      s.min(3);
      Rule r = s.rules[0];
      expect(await r('1234'), isNull);
    });
    test('StringRuleSet.min returns an error if string is lesser length.',
        () async {
      var s = StringRuleSet();
      s.min(5);
      Rule r = s.rules[0];
      expect(await r('1234'), isNotNull);
    });
    test('StringRuleSet.matches returns null if string matches the pattern.',
        () async {
      var s = StringRuleSet();
      s.matches(Patterns.alphaWord);
      Rule r = s.rules[0];
      expect(await r('abcd'), isNull);
    });
    test(
        'StringRuleSet.matches returns an error if string doesn\'t match the patter.',
        () async {
      var s = StringRuleSet();
      s.matches(Patterns.alphaWord);
      Rule r = s.rules[0];
      expect(await r('1234'), isNotNull);
    });
    test('TypeRuleSet.stringIsNum returns null if string can be cast to num.',
        () async {
      var s = TypeRuleSet();
      s.stringIsNum();
      Rule r = s.rules[0];
      expect(await r('1234.1234'), isNull);
    });
    test(
        'TypeRuleSet.stringIsNum returns an error if string cannot be cast to num.',
        () async {
      var s = TypeRuleSet();
      s.stringIsNum();
      Rule r = s.rules[0];
      expect(await r('test'), isNotNull);
    });
    test(
        'TypeRuleSet.stringIsNum sets the resulting ruleset castToNum to true.',
        () async {
      var s = TypeRuleSet();
      s.stringIsNum();
      RuleSet r = s.next;
      expect(r.castToNum, isTrue);
    });
  });

  group('NumRuleSet', () {
    test('NumRuleSet.max returns null if input number is less.', () async {
      var s = NumRuleSet();
      s.max(5);
      Rule r = s.rules[0];
      expect(await r(5), isNull);
    });
    test('NumRuleSet.max returns an error if input number is greater.',
        () async {
      var s = NumRuleSet();
      s.max(5);
      Rule r = s.rules[0];
      expect(await r(6), isNotNull);
    });
    test('NumRuleSet.min returns null if input number is greater.', () async {
      var s = NumRuleSet();
      s.min(5);
      Rule r = s.rules[0];
      expect(await r(5), isNull);
    });
    test('NumRuleSet.min returns an error if input number is less.', () async {
      var s = NumRuleSet();
      s.min(5);
      Rule r = s.rules[0];
      expect(await r(4), isNotNull);
    });
    test('NumRuleSet.isEqualTo returns null if input number is equal.',
        () async {
      var s = NumRuleSet();
      s.isEqualTo(5);
      Rule r = s.rules[0];
      expect(await r(5), isNull);
    });
    test('NumRuleSet.isEqualTo returns an error if input number is not equal.',
        () async {
      var s = NumRuleSet();
      s.isEqualTo(5);
      Rule r = s.rules[0];
      expect(await r(4), isNotNull);
    });
    test('NumRuleSet.isNotEqualTo returns null if input number is not equal.',
        () async {
      var s = NumRuleSet();
      s.isNotEqualTo(5);
      Rule r = s.rules[0];
      expect(await r(6.6), isNull);
    });
    test('NumRuleSet.isNotEqualTo returns an error if input number is equal.',
        () async {
      var s = NumRuleSet();
      s.isNotEqualTo(5.5);
      Rule r = s.rules[0];
      expect(await r(5.5), isNotNull);
    });
  });
}
