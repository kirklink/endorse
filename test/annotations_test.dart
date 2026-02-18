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
      expect(v.method, 'isRequired');
    });

    test('IsNotNull', () {
      const v = IsNotNull();
      expect(v.method, 'isNotNull');
    });

    test('MaxLength', () {
      const v = MaxLength(50);
      expect(v.method, 'maxLength');
      expect(v.value, 50);
      expect(v.validOnTypes, contains(String));
    });

    test('MinLength', () {
      const v = MinLength(5);
      expect(v.method, 'minLength');
      expect(v.value, 5);
    });

    test('StartsWith', () {
      const v = StartsWith('hello');
      expect(v.method, 'startsWith');
      expect(v.value, 'hello');
    });

    test('EndsWith', () {
      const v = EndsWith('world');
      expect(v.method, 'endsWith');
      expect(v.value, 'world');
    });

    test('Contains', () {
      const v = Contains('foo');
      expect(v.method, 'contains');
      expect(v.value, 'foo');
    });

    test('Matches', () {
      const v = Matches('exact');
      expect(v.method, 'matches');
      expect(v.value, 'exact');
    });

    test('IsLessThan', () {
      const v = IsLessThan(10);
      expect(v.method, 'isLessThan');
      expect(v.value, 10);
      expect(v.validOnTypes, contains(int));
    });

    test('IsGreaterThan', () {
      const v = IsGreaterThan(0);
      expect(v.method, 'isGreaterThan');
      expect(v.value, 0);
    });

    test('IsEqualTo', () {
      const v = IsEqualTo(42);
      expect(v.method, 'isEqualTo');
      expect(v.value, 42);
    });

    test('IsNotEqualTo', () {
      const v = IsNotEqualTo(0);
      expect(v.method, 'isNotEqualTo');
      expect(v.value, 0);
    });

    test('IsTrue', () {
      const v = IsTrue();
      expect(v.method, 'isTrue');
      expect(v.validOnTypes, contains(bool));
    });

    test('IsFalse', () {
      const v = IsFalse();
      expect(v.method, 'isFalse');
    });

    test('IntFromString', () {
      const v = IntFromString();
      expect(v.method, 'intFromString');
      expect(v.validOnTypes, contains(int));
    });

    test('DoubleFromString', () {
      const v = DoubleFromString();
      expect(v.method, 'doubleFromString');
      expect(v.validOnTypes, contains(double));
    });

    test('NumFromString', () {
      const v = NumFromString();
      expect(v.method, 'numFromString');
      expect(v.validOnTypes, contains(num));
    });

    test('BoolFromString', () {
      const v = BoolFromString();
      expect(v.method, 'boolFromString');
      expect(v.validOnTypes, contains(bool));
    });

    test('ToStringFromInt', () {
      const v = ToStringFromInt();
      expect(v.method, 'makeString');
      expect(v.validOnTypes, contains(String));
    });

    test('ToStringFromDouble', () {
      const v = ToStringFromDouble();
      expect(v.method, 'makeString');
    });

    test('ToStringFromNum', () {
      const v = ToStringFromNum();
      expect(v.method, 'makeString');
    });

    test('ToStringFromBool', () {
      const v = ToStringFromBool();
      expect(v.method, 'makeString');
    });

    test('IsBefore', () {
      const v = IsBefore('2024-01-01');
      expect(v.method, 'isBefore');
      expect(v.value, '2024-01-01');
      expect(v.validOnTypes, contains(DateTime));
    });

    test('IsBefore.now', () {
      const v = IsBefore.now();
      expect(v.value, 'now');
    });

    test('IsAfter', () {
      const v = IsAfter('2024-01-01');
      expect(v.method, 'isAfter');
      expect(v.value, '2024-01-01');
    });

    test('IsAfter.now', () {
      const v = IsAfter.now();
      expect(v.value, 'now');
    });

    test('IsAtMoment', () {
      const v = IsAtMoment('2024-06-15');
      expect(v.method, 'isAtMoment');
      expect(v.value, '2024-06-15');
    });

    test('IsAtMoment.now', () {
      const v = IsAtMoment.now();
      expect(v.value, 'now');
    });

    test('IsSameDateAs', () {
      const v = IsSameDateAs('2024-06-15');
      expect(v.method, 'isSameDateAs');
      expect(v.value, '2024-06-15');
    });

    test('IsSameDateAs.now', () {
      const v = IsSameDateAs.now();
      expect(v.value, 'now');
    });

    test('MatchesPattern', () {
      const v = MatchesPattern(r'^\d+$');
      expect(v.method, 'matchesPattern');
      expect(v.rawString, isTrue);
      expect(v.value, r'^\d+$');
      expect(v.validOnTypes, contains(String));
    });

    test('MatchesRawPattern', () {
      const v = MatchesRawPattern(r'^\w+$');
      expect(v.method, 'matchesPattern');
      expect(v.rawString, isTrue);
      expect(v.value, r'^\w+$');
    });

    test('MatchesEscapedPattern', () {
      const v = MatchesEscapedPattern(r'test');
      expect(v.method, 'matchesPattern');
      expect(v.rawString, isFalse);
    });

    test('IsEmail', () {
      const v = IsEmail();
      expect(v.method, 'isEmail');
      expect(v.rawString, isTrue);
      expect(v.value, isNotEmpty);
    });

    // ── New Validation Annotations ──────────────────────────────────

    test('IsNotEmpty', () {
      const v = IsNotEmpty();
      expect(v.method, 'isNotEmpty');
      expect(v.validOnTypes, contains(String));
    });

    test('ExactLength', () {
      const v = ExactLength(5);
      expect(v.method, 'exactLength');
      expect(v.value, 5);
      expect(v.validOnTypes, contains(String));
    });

    test('IsAlpha', () {
      const v = IsAlpha();
      expect(v.method, 'isAlpha');
      expect(v.validOnTypes, contains(String));
    });

    test('IsAlphanumeric', () {
      const v = IsAlphanumeric();
      expect(v.method, 'isAlphanumeric');
      expect(v.validOnTypes, contains(String));
    });

    test('Trim', () {
      const v = Trim();
      expect(v.method, 'trim');
      expect(v.validOnTypes, contains(String));
    });

    test('IsGreaterThanOrEqual', () {
      const v = IsGreaterThanOrEqual(10);
      expect(v.method, 'isGreaterThanOrEqual');
      expect(v.value, 10);
      expect(v.validOnTypes, contains(num));
    });

    test('IsLessThanOrEqual', () {
      const v = IsLessThanOrEqual(10);
      expect(v.method, 'isLessThanOrEqual');
      expect(v.value, 10);
      expect(v.validOnTypes, contains(num));
    });

    test('IsOneOf', () {
      const v = IsOneOf(['a', 'b', 'c']);
      expect(v.method, 'isOneOf');
      expect(v.value, ['a', 'b', 'c']);
      expect(v.validOnTypes, contains(String));
    });

    test('MinElements', () {
      const v = MinElements(2);
      expect(v.method, 'minElements');
      expect(v.value, 2);
      expect(v.validOnTypes, contains(List));
    });

    test('MaxElements', () {
      const v = MaxElements(5);
      expect(v.method, 'maxElements');
      expect(v.value, 5);
      expect(v.validOnTypes, contains(List));
    });

    test('IsUrl', () {
      const v = IsUrl();
      expect(v.method, 'isUrl');
      expect(v.validOnTypes, contains(String));
    });

    test('IsUuid', () {
      const v = IsUuid();
      expect(v.method, 'isUuid');
      expect(v.validOnTypes, contains(String));
    });

    test('IsPhoneNumber', () {
      const v = IsPhoneNumber();
      expect(v.method, 'isPhoneNumber');
      expect(v.validOnTypes, contains(String));
    });
  });

  // ── Custom message support ───────────────────────────────────────

  group('Custom message on annotations', () {
    test('message defaults to null', () {
      const v = Required();
      expect(v.message, isNull);
    });

    test('Required accepts message', () {
      const v = Required(message: 'Name is required');
      expect(v.message, 'Name is required');
    });

    test('MaxLength accepts message', () {
      const v = MaxLength(50, message: 'Too long');
      expect(v.message, 'Too long');
      expect(v.value, 50);
    });

    test('MinLength accepts message', () {
      const v = MinLength(3, message: 'Too short');
      expect(v.message, 'Too short');
    });

    test('IsGreaterThan accepts message', () {
      const v = IsGreaterThan(0, message: 'Must be positive');
      expect(v.message, 'Must be positive');
      expect(v.value, 0);
    });

    test('IsEmail accepts message', () {
      const v = IsEmail(message: 'Invalid email address');
      expect(v.message, 'Invalid email address');
    });

    test('IsBefore accepts message', () {
      const v = IsBefore('2024-01-01', message: 'Must be in the past');
      expect(v.message, 'Must be in the past');
    });

    test('IsBefore.now accepts message', () {
      const v = IsBefore.now(message: 'Must be before now');
      expect(v.message, 'Must be before now');
      expect(v.value, 'now');
    });

    test('IsOneOf accepts message', () {
      const v = IsOneOf(['a', 'b'], message: 'Pick a or b');
      expect(v.message, 'Pick a or b');
    });

    test('MatchesPattern accepts message', () {
      const v = MatchesPattern(r'^\d+$', message: 'Numbers only');
      expect(v.message, 'Numbers only');
    });

    test('no-value annotations accept message', () {
      const v1 = IsNotNull(message: 'Cannot be null');
      const v2 = IsTrue(message: 'Must be true');
      const v3 = IsNotEmpty(message: 'Cannot be empty');
      const v4 = IsUrl(message: 'Must be a URL');
      expect(v1.message, 'Cannot be null');
      expect(v2.message, 'Must be true');
      expect(v3.message, 'Cannot be empty');
      expect(v4.message, 'Must be a URL');
    });
  });

  // ── CustomValidation annotation ──────────────────────────────────

  group('CustomValidation annotation', () {
    test('stores functionName and errorMessage', () {
      const v = CustomValidation('isEven', 'Must be even');
      expect(v.functionName, 'isEven');
      expect(v.errorMessage, 'Must be even');
      expect(v.method, 'custom');
    });

    test('message defaults to null', () {
      const v = CustomValidation('isEven', 'Must be even');
      expect(v.message, isNull);
    });

    test('accepts optional message', () {
      const v = CustomValidation('isEven', 'Must be even',
          message: 'Custom override');
      expect(v.message, 'Custom override');
    });
  });
}
