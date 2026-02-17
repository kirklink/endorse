import 'package:test/test.dart';
import 'package:endorse/endorse.dart';
import 'package:endorse/src/endorse/validation_error.dart';
import 'package:endorse/src/endorse/endorse_exception.dart';
import 'package:endorse/src/endorse/evaluator.dart';
import 'package:endorse/src/endorse/rule.dart';
import 'package:endorse/src/endorse/rule_holder.dart';

/// Helper to create a validator, apply rules, and return the result.
ValueResult validate(Object? input, void Function(ValidateValue v) setup) {
  final v = ValidateValue();
  setup(v);
  return v.from(input, 'field');
}

void main() {
  // ── ValidationError ───────────────────────────────────────────────

  group('ValidationError', () {
    test('toString returns message', () {
      final e = ValidationError('IsString', 'Must be a String.', 'int');
      expect(e.toString(), 'Must be a String.');
    });

    test('toJson includes rule, message, and got', () {
      final e = ValidationError('IsString', 'Must be a String.', 'int');
      final json = e.toJson();
      expect(json['IsString']!['message'], 'Must be a String.');
      expect(json['IsString']!['got'], 'int');
    });

    test('toJson includes want when non-empty', () {
      final e =
          ValidationError('MaxLength', 'Too long.', '15', '<= 10');
      final json = e.toJson();
      expect(json['MaxLength']!['want'], '<= 10');
    });

    test('toJson omits want when empty', () {
      final e = ValidationError('Required', 'Required.', null);
      final json = e.toJson();
      expect(json['Required']!.containsKey('want'), isFalse);
    });

    test('fields are accessible', () {
      final e =
          ValidationError('Rule', 'msg', 'gotValue', 'wantValue');
      expect(e.rule, 'Rule');
      expect(e.message, 'msg');
      expect(e.got, 'gotValue');
      expect(e.want, 'wantValue');
    });
  });

  // ── EndorseException ──────────────────────────────────────────────

  group('EndorseException', () {
    test('toString returns cause', () {
      final e = EndorseException('Something went wrong');
      expect(e.toString(), 'Something went wrong');
    });

    test('is an Exception', () {
      expect(EndorseException('test'), isA<Exception>());
    });
  });

  // ── Evaluator precondition failure ────────────────────────────────

  group('Evaluator', () {
    test('throws EndorseException on precondition failure', () {
      // MatchesPatternRule.check() returns error for invalid regex
      // But we can test via an invalid DateTime rule test param
      final rules = [RuleHolder(IsBeforeRule('not-a-date'))];
      final evaluator = Evaluator(rules, DateTime(2024, 1, 1), 'field');
      expect(() => evaluator.evaluate(), throwsA(isA<EndorseException>()));
    });
  });

  // ── ValueResult ───────────────────────────────────────────────────

  group('ValueResult', () {
    test('\$errorsJson returns list of json maps', () {
      final r = validate(null, (v) => v.isRequired());
      expect(r.$errorsJson, isA<List>());
      final list = r.$errorsJson as List;
      expect(list, isNotEmpty);
      expect(list.first, isA<Map>());
    });

    test('\$errorsJson is empty when valid', () {
      final r = validate('hello', (v) => v.isRequired());
      expect(r.$errorsJson, isA<List>());
      expect((r.$errorsJson as List), isEmpty);
    });
  });

  // ── ListResult ────────────────────────────────────────────────────

  group('ListResult \$errorsJson', () {
    test('returns empty when valid', () {
      final fieldResult =
          (ValidateValue()..isRequired()).from([1, 2], 'ids');
      final elem1 = (ValidateValue()..isInt()).from(1, '[0]');
      final elem2 = (ValidateValue()..isInt()).from(2, '[1]');
      final result = ListResult('ids', fieldResult, [elem1, elem2]);
      // $errorsJson not directly on ListResult, but $errors is empty
      expect(result.$isValid, isTrue);
    });
  });

  // ── Rule got/want/errorMsg coverage ───────────────────────────────

  group('Rule error details', () {
    test('IsString reports got and want', () {
      final r = validate(42, (v) => v.isString());
      expect(r.$isNotValid, isTrue);
      final err = r.$errors.first;
      expect(err.got, isNotEmpty);
      expect(err.want, 'String');
    });

    test('IsMap reports got and want', () {
      final r = validate('x', (v) => v.isMap());
      final err = r.$errors.first;
      expect(err.got, 'String');
      expect(err.want, 'Map<String, Object>');
    });

    test('IsList reports got and want', () {
      final r = validate('x', (v) => v.isList());
      final err = r.$errors.first;
      expect(err.got, 'String');
      expect(err.want, 'List');
    });

    test('IsInt reports got and want', () {
      final r = validate('x', (v) => v.isInt());
      final err = r.$errors.first;
      expect(err.got, 'String');
      expect(err.want, 'int');
    });

    test('IsDouble reports got and want', () {
      final r = validate('x', (v) => v.isDouble());
      final err = r.$errors.first;
      expect(err.got, 'String');
      expect(err.want, 'double');
    });

    test('IsNum reports got and want', () {
      final r = validate('x', (v) => v.isNum());
      final err = r.$errors.first;
      expect(err.got, 'String');
      expect(err.want, 'num');
    });

    test('IsBool reports got and want', () {
      final r = validate('x', (v) => v.isBoolean());
      final err = r.$errors.first;
      expect(err.got, 'String');
      expect(err.want, 'bool');
    });

    test('MaxLength reports got and want', () {
      final r = validate('toolong', (v) => v.maxLength(3));
      final err = r.$errors.first;
      expect(err.got, '7');
      expect(err.want, '<= 3');
    });

    test('MaxLength got reports non-string', () {
      // MaxLength on non-string - won't match, reports 'not a string'
      final v = ValidateValue()..maxLength(3);
      final r = v.from(12345, 'f');
      final err = r.$errors.first;
      expect(err.got, 'not a string');
    });

    test('MinLength reports got and want', () {
      final r = validate('ab', (v) => v.minLength(5));
      final err = r.$errors.first;
      expect(err.got, '2');
      expect(err.want, '>= 5');
    });

    test('MinLength got reports non-string', () {
      final v = ValidateValue()..minLength(3);
      final r = v.from(12, 'f');
      final err = r.$errors.first;
      expect(err.got, 'not a string');
    });

    test('IsLessThan reports want', () {
      final r = validate(10, (v) => v.isLessThan(5));
      final err = r.$errors.first;
      expect(err.want, '< 5');
    });

    test('IsGreaterThan reports want', () {
      final r = validate(1, (v) => v.isGreaterThan(5));
      final err = r.$errors.first;
      expect(err.want, '> 5');
    });

    test('IsTrue reports want', () {
      final r = validate(false, (v) => v.isTrue());
      expect(r.$errors.first.want, 'true');
    });

    test('IsFalse reports want', () {
      final r = validate(true, (v) => v.isFalse());
      expect(r.$errors.first.want, 'false');
    });

    test('MaxElements reports want', () {
      final v = ValidateValue();
      v.rules.add(RuleHolder(MaxElements(2)));
      final r = v.from([1, 2, 3], 'f');
      expect(r.$errors.first.want, '<= 2 elements');
    });

    test('MinElements reports want', () {
      final v = ValidateValue();
      v.rules.add(RuleHolder(MinElements(3)));
      final r = v.from([1], 'f');
      expect(r.$errors.first.want, '>= 3 elements');
    });
  });

  // ── StartsWith/EndsWith got() coverage ────────────────────────────

  group('StartsWith/EndsWith got details', () {
    test('StartsWith got shows prefix of input', () {
      final r = validate('hello', (v) => v.startsWith('xyz'));
      final err = r.$errors.first;
      expect(err.got, 'hel');
    });

    test('StartsWith got handles shorter input', () {
      final r = validate('hi', (v) => v.startsWith('xyz'));
      final err = r.$errors.first;
      expect(err.got, 'hi');
    });

    test('StartsWith got handles non-string', () {
      final v = ValidateValue();
      v.rules.add(RuleHolder(StartsWithValue('x')));
      final r = v.from(123, 'f');
      expect(r.$errors.first.got, 'not a string');
    });

    test('EndsWith got shows suffix of input', () {
      final r = validate('hello', (v) => v.endsWith('xyz'));
      final err = r.$errors.first;
      expect(err.got, 'llo');
    });

    test('EndsWith got handles shorter input', () {
      final r = validate('hi', (v) => v.endsWith('xyz'));
      final err = r.$errors.first;
      expect(err.got, 'hi');
    });

    test('EndsWith got handles non-string', () {
      final v = ValidateValue();
      v.rules.add(RuleHolder(EndsWithValue('x')));
      final r = v.from(123, 'f');
      expect(r.$errors.first.got, 'not a string');
    });
  });

  // ── CanXFromString got/want coverage ──────────────────────────────

  group('CanXFromString error details', () {
    test('CanIntFromString reports got and want', () {
      final r = validate('abc', (v) => v.isInt(fromString: true));
      final err = r.$errors.first;
      expect(err.got, 'String');
      expect(err.want, 'String parseable to int');
    });

    test('CanDoubleFromString reports got and want', () {
      final r = validate('abc', (v) => v.isDouble(fromString: true));
      final err = r.$errors.first;
      expect(err.got, 'String');
      expect(err.want, 'String parseable to double');
    });

    test('CanNumFromString reports got and want', () {
      final r = validate('abc', (v) => v.isNum(fromString: true));
      final err = r.$errors.first;
      expect(err.got, 'String');
      expect(err.want, 'String parseable to num');
    });

    test('BoolFromStringCast reports got and want', () {
      final v = ValidateValue();
      v.rules.add(RuleHolder(BoolFromStringCast()));
      final r = v.from('yes', 'f');
      final err = r.$errors.first;
      expect(err.got, 'String');
      expect(err.want, 'String');
    });
  });

  // ── DateTime rule error details ───────────────────────────────────

  group('DateTime rule error details', () {
    test('IsBefore got shows ISO string', () {
      final r = validate(
        DateTime(2025, 6, 1),
        (v) => v.isBefore('2024-01-01'),
      );
      final err = r.$errors.first;
      expect(err.got, contains('2025'));
    });

    test('IsBefore got shows null for non-date', () {
      final v = ValidateValue();
      v.rules.add(RuleHolder(IsBeforeRule('2024-01-01')));
      final r = v.from('not-a-date', 'f');
      // pass() returns false because _inputDateConverter returns null
      expect(r.$errors.first.got, 'null');
    });

    test('IsAfter got shows ISO string', () {
      final r = validate(
        DateTime(2023, 1, 1),
        (v) => v.isAfter('2024-01-01'),
      );
      expect(r.$errors.first.got, contains('2023'));
    });

    test('IsSameDateAs got shows date', () {
      final r = validate(
        DateTime(2024, 3, 15),
        (v) => v.isSameDateAs('2024-06-01'),
      );
      expect(r.$errors.first.got, contains('2024'));
    });

    test('IsSameDateAs got shows null for non-date', () {
      final v = ValidateValue();
      v.rules.add(RuleHolder(IsSameDateAsRule('2024-01-01')));
      final r = v.from('bad', 'f');
      expect(r.$errors.first.got, 'null');
    });

    test('IsSameDateAs errorMsg shows date parts', () {
      final r = validate(
        DateTime(2024, 3, 15),
        (v) => v.isSameDateAs('2024-06-01'),
      );
      expect(r.$errors.first.message, contains('2024'));
    });

    test('IsBefore with today keyword works', () {
      final r = validate(
        DateTime(2099, 1, 1),
        (v) => v.isBefore('today'),
      );
      expect(r.$isNotValid, isTrue);
    });

    test('IsBefore with today+N works', () {
      final r = validate(
        DateTime(2099, 1, 1),
        (v) => v.isBefore('today+7'),
      );
      expect(r.$isNotValid, isTrue);
    });

    test('IsBefore with today-N works', () {
      final r = validate(
        DateTime(2099, 1, 1),
        (v) => v.isBefore('today-7'),
      );
      expect(r.$isNotValid, isTrue);
    });

    test('IsDateTime casts string to DateTime', () {
      final r = validate('2024-06-15', (v) => v.isDateTime());
      expect(r.$isValid, isTrue);
      expect(r.$value, isA<DateTime>());
    });
  });

  // ── MatchesPattern error details ──────────────────────────────────

  group('MatchesPattern error details', () {
    test('reports got and want', () {
      final r = validate('abc', (v) => v.matchesPattern(r'^\d+$'));
      final err = r.$errors.first;
      expect(err.got, contains('abc'));
      expect(err.want, contains(r'^\d+$'));
    });

    test('check rejects invalid regex', () {
      final rule = MatchesPatternRule('[invalid');
      final checkResult = rule.check('test', null);
      expect(checkResult, isNotEmpty);
    });
  });

  // ── IsEmail error details ─────────────────────────────────────────

  group('IsEmail error details', () {
    test('reports got and want', () {
      final r = validate('bad', (v) => v.isEmail(''));
      final err = r.$errors.first;
      expect(err.got, 'bad');
      expect(err.want, contains('email'));
    });
  });

  // ── RuleError ─────────────────────────────────────────────────────

  group('RuleError', () {
    test('empty constructor', () {
      final e = RuleError.empty();
      expect(e.isEmpty, isTrue);
      expect(e.errorName, '');
      expect(e.errorDetail, '');
    });

    test('non-empty', () {
      final e = RuleError('rule', 'detail');
      expect(e.isEmpty, isFalse);
    });
  });

  // ── Rule.evaluate() ───────────────────────────────────────────────

  group('Rule.evaluate()', () {
    test('returns empty RuleError when passes', () {
      final rule = Required();
      final result = rule.evaluate('value');
      expect(result.isEmpty, isTrue);
    });

    test('returns RuleError when fails', () {
      final rule = Required();
      final result = rule.evaluate(null);
      expect(result.isEmpty, isFalse);
      expect(result.errorName, 'Required');
    });
  });
}
