import 'package:test/test.dart';
import 'package:endorse/annotations.dart';

void main() {
  // ── EndorseEntity ─────────────────────────────────────────────────

  group('EndorseEntity', () {
    test('default values', () {
      const e = EndorseEntity();
      expect(e.useCase, Case.none);
      expect(e.requireAll, isFalse);
    });

    test('custom values', () {
      const e = EndorseEntity(useCase: Case.snakeCase, requireAll: true);
      expect(e.useCase, Case.snakeCase);
      expect(e.requireAll, isTrue);
    });
  });

  // ── EndorseField ──────────────────────────────────────────────────

  group('EndorseField', () {
    test('default values', () {
      const f = EndorseField();
      expect(f.validate, isEmpty);
      expect(f.itemValidate, isEmpty);
      expect(f.ignore, isFalse);
      expect(f.useCase, Case.none);
      expect(f.name, '');
    });

    test('with validation rules', () {
      const f = EndorseField(validate: [Required(), MaxLength(50)]);
      expect(f.validate, hasLength(2));
    });

    test('with item validation', () {
      const f = EndorseField(itemValidate: [Required()]);
      expect(f.itemValidate, hasLength(1));
    });

    test('ignore flag', () {
      const f = EndorseField(ignore: true);
      expect(f.ignore, isTrue);
    });

    test('custom name', () {
      const f = EndorseField(name: 'custom_name');
      expect(f.name, 'custom_name');
    });
  });

  // ── EndorseMap ────────────────────────────────────────────────────

  group('EndorseMap', () {
    test('can be instantiated', () {
      const m = EndorseMap();
      expect(m, isNotNull);
    });
  });

  // ── Validation annotations ────────────────────────────────────────

  group('Validation annotations', () {
    test('Required', () {
      const v = Required();
      expect(v.call, 'isRequired()');
    });

    test('IsNotNull', () {
      const v = IsNotNull();
      expect(v.call, 'isNotNull()');
    });

    test('MaxLength', () {
      const v = MaxLength(50);
      expect(v.call, 'maxLength(@)');
      expect(v.value, 50);
      expect(v.validOnTypes, contains(String));
    });

    test('MinLength', () {
      const v = MinLength(5);
      expect(v.call, 'minLength(@)');
      expect(v.value, 5);
    });

    test('StartsWith', () {
      const v = StartsWith('hello');
      expect(v.call, 'startsWith(@)');
      expect(v.value, 'hello');
    });

    test('EndsWith', () {
      const v = EndsWith('world');
      expect(v.call, 'endsWith(@)');
      expect(v.value, 'world');
    });

    test('Contains', () {
      const v = Contains('foo');
      expect(v.call, 'contains(@)');
      expect(v.value, 'foo');
    });

    test('Matches', () {
      const v = Matches('exact');
      expect(v.call, 'matches(@)');
      expect(v.value, 'exact');
    });

    test('IsLessThan', () {
      const v = IsLessThan(10);
      expect(v.call, 'isLessThan(@)');
      expect(v.value, 10);
      expect(v.validOnTypes, contains(int));
    });

    test('IsGreaterThan', () {
      const v = IsGreaterThan(0);
      expect(v.call, 'isGreaterThan(@)');
      expect(v.value, 0);
    });

    test('IsEqualTo', () {
      const v = IsEqualTo(42);
      expect(v.call, 'isEqualTo(@)');
      expect(v.value, 42);
    });

    test('IsNotEqualTo', () {
      const v = IsNotEqualTo(0);
      expect(v.call, 'isNotEqualTo(@)');
      expect(v.value, 0);
    });

    test('IsTrue', () {
      const v = IsTrue();
      expect(v.call, 'isTrue()');
      expect(v.validOnTypes, contains(bool));
    });

    test('IsFalse', () {
      const v = IsFalse();
      expect(v.call, 'isFalse()');
    });

    test('IntFromString', () {
      const v = IntFromString();
      expect(v.call, 'intFromString()');
      expect(v.validOnTypes, contains(int));
    });

    test('DoubleFromString', () {
      const v = DoubleFromString();
      expect(v.call, 'doubleFromString()');
      expect(v.validOnTypes, contains(double));
    });

    test('NumFromString', () {
      const v = NumFromString();
      expect(v.call, 'numFromString()');
      expect(v.validOnTypes, contains(num));
    });

    test('BoolFromString', () {
      const v = BoolFromString();
      expect(v.call, 'boolFromString()');
      expect(v.validOnTypes, contains(bool));
    });

    test('ToStringFromInt', () {
      const v = ToStringFromInt();
      expect(v.call, 'makeString()');
      expect(v.validOnTypes, contains(String));
    });

    test('ToStringFromDouble', () {
      const v = ToStringFromDouble();
      expect(v.call, 'makeString()');
    });

    test('ToStringFromNum', () {
      const v = ToStringFromNum();
      expect(v.call, 'makeString()');
    });

    test('ToStringFromBool', () {
      const v = ToStringFromBool();
      expect(v.call, 'makeString()');
    });

    test('IsBefore', () {
      const v = IsBefore('2024-01-01');
      expect(v.call, 'isBefore(@)');
      expect(v.value, '2024-01-01');
      expect(v.validOnTypes, contains(DateTime));
    });

    test('IsBefore.now', () {
      const v = IsBefore.now();
      expect(v.value, 'now');
    });

    test('IsAfter', () {
      const v = IsAfter('2024-01-01');
      expect(v.call, 'isAfter(@)');
      expect(v.value, '2024-01-01');
    });

    test('IsAfter.now', () {
      const v = IsAfter.now();
      expect(v.value, 'now');
    });

    test('IsAtMoment', () {
      const v = IsAtMoment('2024-06-15');
      expect(v.call, 'isAtMoment(@)');
      expect(v.value, '2024-06-15');
    });

    test('IsAtMoment.now', () {
      const v = IsAtMoment.now();
      expect(v.value, 'now');
    });

    test('IsSameDateAs', () {
      const v = IsSameDateAs('2024-06-15');
      expect(v.call, 'isSameDateAs(@)');
      expect(v.value, '2024-06-15');
    });

    test('IsSameDateAs.now', () {
      const v = IsSameDateAs.now();
      expect(v.value, 'now');
    });

    test('MatchesPattern', () {
      const v = MatchesPattern(r'^\d+$');
      expect(v.call, 'matchesPattern(r@)');
      expect(v.value, r'^\d+$');
      expect(v.validOnTypes, contains(String));
    });

    test('MatchesRawPattern', () {
      const v = MatchesRawPattern(r'^\w+$');
      expect(v.call, 'matchesPattern(r@)');
      expect(v.value, r'^\w+$');
    });

    test('MatchesEscapedPattern', () {
      const v = MatchesEscapedPattern(r'test');
      expect(v.call, 'matchesPattern(@)');
    });

    test('IsEmail', () {
      const v = IsEmail();
      expect(v.call, 'isEmail(r@)');
      expect(v.value, isNotEmpty);
    });
  });
}
