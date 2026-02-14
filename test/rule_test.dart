import 'package:test/test.dart';
import 'package:endorse/src/endorse/validate_value.dart';
import 'package:endorse/src/endorse/value_result.dart';

/// Helper to create a validator, apply rules, and return the result.
ValueResult validate(Object? input, void Function(ValidateValue v) setup) {
  final v = ValidateValue();
  setup(v);
  return v.from(input, 'field');
}

void main() {
  // ── Required / Null Checking ──────────────────────────────────────

  group('Required', () {
    test('passes with non-null value', () {
      final r = validate('hello', (v) => v.isRequired());
      expect(r.$isValid, isTrue);
    });

    test('fails with null', () {
      final r = validate(null, (v) => v.isRequired());
      expect(r.$isNotValid, isTrue);
    });

    test('passes with empty string (Required checks null, not empty)', () {
      final r = validate('', (v) => v.isRequired());
      expect(r.$isValid, isTrue);
    });

    test('isNotNull behaves like isRequired', () {
      final r = validate(null, (v) => v.isNotNull());
      expect(r.$isNotValid, isTrue);
    });
  });

  // ── Type Checking ─────────────────────────────────────────────────

  group('isString', () {
    test('passes with string', () {
      final r = validate('hello', (v) => v.isString());
      expect(r.$isValid, isTrue);
    });

    test('fails with non-string', () {
      final r = validate(42, (v) => v.isString());
      expect(r.$isNotValid, isTrue);
    });

    test('toString option casts to string', () {
      final r = validate(42, (v) => v.isString(toString: true));
      expect(r.$isValid, isTrue);
      expect(r.$value, '42');
    });
  });

  group('makeString', () {
    test('casts any value to string', () {
      final r = validate(123, (v) => v.makeString());
      expect(r.$isValid, isTrue);
      expect(r.$value, '123');
    });
  });

  group('isMap', () {
    test('passes with map', () {
      final r = validate({'key': 'value'}, (v) => v.isMap());
      expect(r.$isValid, isTrue);
    });

    test('fails with non-map', () {
      final r = validate('not a map', (v) => v.isMap());
      expect(r.$isNotValid, isTrue);
    });
  });

  group('isList', () {
    test('passes with list', () {
      final r = validate([1, 2, 3], (v) => v.isList());
      expect(r.$isValid, isTrue);
    });

    test('fails with non-list', () {
      final r = validate('not a list', (v) => v.isList());
      expect(r.$isNotValid, isTrue);
    });
  });

  // ── Numeric Type Checking ─────────────────────────────────────────

  group('isInt', () {
    test('passes with int', () {
      final r = validate(42, (v) => v.isInt());
      expect(r.$isValid, isTrue);
    });

    test('fails with double', () {
      final r = validate(3.14, (v) => v.isInt());
      expect(r.$isNotValid, isTrue);
    });

    test('fails with string', () {
      final r = validate('42', (v) => v.isInt());
      expect(r.$isNotValid, isTrue);
    });

    test('fromString passes with parseable string', () {
      final r = validate('42', (v) => v.isInt(fromString: true));
      expect(r.$isValid, isTrue);
    });

    test('fromString fails with non-parseable string', () {
      final r = validate('abc', (v) => v.isInt(fromString: true));
      expect(r.$isNotValid, isTrue);
    });
  });

  group('isDouble', () {
    test('passes with double', () {
      final r = validate(3.14, (v) => v.isDouble());
      expect(r.$isValid, isTrue);
    });

    test('fails with string', () {
      final r = validate('3.14', (v) => v.isDouble());
      expect(r.$isNotValid, isTrue);
    });

    test('fromString passes with parseable string', () {
      final r = validate('3.14', (v) => v.isDouble(fromString: true));
      expect(r.$isValid, isTrue);
    });

    test('fromString fails with non-parseable string', () {
      final r = validate('abc', (v) => v.isDouble(fromString: true));
      expect(r.$isNotValid, isTrue);
    });
  });

  group('isNum', () {
    test('passes with int', () {
      final r = validate(42, (v) => v.isNum());
      expect(r.$isValid, isTrue);
    });

    test('passes with double', () {
      final r = validate(3.14, (v) => v.isNum());
      expect(r.$isValid, isTrue);
    });

    test('fails with string', () {
      final r = validate('42', (v) => v.isNum());
      expect(r.$isNotValid, isTrue);
    });

    test('fromString passes with parseable string', () {
      final r = validate('3.14', (v) => v.isNum(fromString: true));
      expect(r.$isValid, isTrue);
    });

    test('fromString fails with non-parseable string', () {
      final r = validate('abc', (v) => v.isNum(fromString: true));
      expect(r.$isNotValid, isTrue);
    });
  });

  group('isNumber', () {
    test('passes with num', () {
      final r = validate(42, (v) => v.isNumber());
      expect(r.$isValid, isTrue);
    });

    test('fails with non-num', () {
      final r = validate('hello', (v) => v.isNumber());
      expect(r.$isNotValid, isTrue);
    });
  });

  // ── Type Coercion (cast) ──────────────────────────────────────────

  group('intFromString', () {
    test('casts parseable string to int', () {
      final r = validate('42', (v) => v.intFromString());
      expect(r.$isValid, isTrue);
      expect(r.$value, 42);
    });

    test('fails with non-parseable string', () {
      final r = validate('abc', (v) => v.intFromString());
      expect(r.$isNotValid, isTrue);
    });
  });

  group('doubleFromString', () {
    test('casts parseable string to double', () {
      final r = validate('3.14', (v) => v.doubleFromString());
      expect(r.$isValid, isTrue);
      expect(r.$value, 3.14);
    });

    test('fails with non-parseable string', () {
      final r = validate('abc', (v) => v.doubleFromString());
      expect(r.$isNotValid, isTrue);
    });
  });

  group('numFromString', () {
    test('casts parseable int string to num', () {
      final r = validate('42', (v) => v.numFromString());
      expect(r.$isValid, isTrue);
      expect(r.$value, 42);
    });

    test('casts parseable double string to num', () {
      final r = validate('3.14', (v) => v.numFromString());
      expect(r.$isValid, isTrue);
      expect(r.$value, 3.14);
    });

    test('fails with non-parseable string', () {
      final r = validate('abc', (v) => v.numFromString());
      expect(r.$isNotValid, isTrue);
    });
  });

  // ── Boolean ───────────────────────────────────────────────────────

  group('isBoolean', () {
    test('passes with bool', () {
      final r = validate(true, (v) => v.isBoolean());
      expect(r.$isValid, isTrue);
    });

    test('fails with non-bool', () {
      final r = validate('true', (v) => v.isBoolean());
      expect(r.$isNotValid, isTrue);
    });

    test('fromString passes with "true"', () {
      final r = validate('true', (v) => v.isBoolean(fromString: true));
      expect(r.$isValid, isTrue);
    });

    test('fromString passes with "false"', () {
      final r = validate('false', (v) => v.isBoolean(fromString: true));
      expect(r.$isValid, isTrue);
    });

    test('fromString fails with non-bool string', () {
      final r = validate('yes', (v) => v.isBoolean(fromString: true));
      expect(r.$isNotValid, isTrue);
    });
  });

  group('isTrue', () {
    test('passes with true', () {
      final r = validate(true, (v) => v.isTrue());
      expect(r.$isValid, isTrue);
    });

    test('fails with false', () {
      final r = validate(false, (v) => v.isTrue());
      expect(r.$isNotValid, isTrue);
    });
  });

  group('isFalse', () {
    test('passes with false', () {
      final r = validate(false, (v) => v.isFalse());
      expect(r.$isValid, isTrue);
    });

    test('fails with true', () {
      final r = validate(true, (v) => v.isFalse());
      expect(r.$isNotValid, isTrue);
    });
  });

  // ── String Rules ──────────────────────────────────────────────────

  group('maxLength', () {
    test('passes when under limit', () {
      final r = validate('hi', (v) => v.maxLength(5));
      expect(r.$isValid, isTrue);
    });

    test('passes when at limit', () {
      final r = validate('hello', (v) => v.maxLength(5));
      expect(r.$isValid, isTrue);
    });

    test('fails when over limit', () {
      final r = validate('hello world', (v) => v.maxLength(5));
      expect(r.$isNotValid, isTrue);
    });
  });

  group('minLength', () {
    test('passes when over limit', () {
      final r = validate('hello', (v) => v.minLength(3));
      expect(r.$isValid, isTrue);
    });

    test('passes when at limit', () {
      final r = validate('hi!', (v) => v.minLength(3));
      expect(r.$isValid, isTrue);
    });

    test('fails when under limit', () {
      final r = validate('hi', (v) => v.minLength(3));
      expect(r.$isNotValid, isTrue);
    });
  });

  group('matches', () {
    test('passes when strings match', () {
      final r = validate('hello', (v) => v.matches('hello'));
      expect(r.$isValid, isTrue);
    });

    test('fails when strings differ', () {
      final r = validate('hello', (v) => v.matches('world'));
      expect(r.$isNotValid, isTrue);
    });
  });

  group('contains', () {
    test('passes when substring found', () {
      final r = validate('hello world', (v) => v.contains('world'));
      expect(r.$isValid, isTrue);
    });

    test('fails when substring not found', () {
      final r = validate('hello world', (v) => v.contains('xyz'));
      expect(r.$isNotValid, isTrue);
    });
  });

  group('startsWith', () {
    test('passes when string starts with value', () {
      final r = validate('hello world', (v) => v.startsWith('hello'));
      expect(r.$isValid, isTrue);
    });

    test('fails when string does not start with value', () {
      final r = validate('hello world', (v) => v.startsWith('world'));
      expect(r.$isNotValid, isTrue);
    });
  });

  group('endsWith', () {
    test('passes when string ends with value', () {
      final r = validate('hello world', (v) => v.endsWith('world'));
      expect(r.$isValid, isTrue);
    });

    test('fails when string does not end with value', () {
      final r = validate('hello world', (v) => v.endsWith('hello'));
      expect(r.$isNotValid, isTrue);
    });
  });

  // ── Numeric Comparison ────────────────────────────────────────────

  group('isEqualTo', () {
    test('passes when equal', () {
      final r = validate(42, (v) => v.isEqualTo(42));
      expect(r.$isValid, isTrue);
    });

    test('fails when not equal', () {
      final r = validate(42, (v) => v.isEqualTo(43));
      expect(r.$isNotValid, isTrue);
    });
  });

  group('isNotEqualTo', () {
    test('passes when not equal', () {
      final r = validate(42, (v) => v.isNotEqualTo(43));
      expect(r.$isValid, isTrue);
    });

    test('fails when equal', () {
      final r = validate(42, (v) => v.isNotEqualTo(42));
      expect(r.$isNotValid, isTrue);
    });
  });

  group('isGreaterThan', () {
    test('passes when greater', () {
      final r = validate(10, (v) => v.isGreaterThan(5));
      expect(r.$isValid, isTrue);
    });

    test('fails when equal', () {
      final r = validate(5, (v) => v.isGreaterThan(5));
      expect(r.$isNotValid, isTrue);
    });

    test('fails when less', () {
      final r = validate(3, (v) => v.isGreaterThan(5));
      expect(r.$isNotValid, isTrue);
    });
  });

  group('isLessThan', () {
    test('passes when less', () {
      final r = validate(3, (v) => v.isLessThan(5));
      expect(r.$isValid, isTrue);
    });

    test('fails when equal', () {
      final r = validate(5, (v) => v.isLessThan(5));
      expect(r.$isNotValid, isTrue);
    });

    test('fails when greater', () {
      final r = validate(10, (v) => v.isLessThan(5));
      expect(r.$isNotValid, isTrue);
    });
  });

  // ── DateTime ──────────────────────────────────────────────────────

  group('isDateTime', () {
    test('passes with DateTime object', () {
      final r = validate(DateTime(2024, 1, 1), (v) => v.isDateTime());
      expect(r.$isValid, isTrue);
    });

    test('passes with parseable date string', () {
      final r = validate('2024-01-01', (v) => v.isDateTime());
      expect(r.$isValid, isTrue);
    });

    test('fails with non-date value', () {
      final r = validate('not a date', (v) => v.isDateTime());
      expect(r.$isNotValid, isTrue);
    });

    test('fails with number', () {
      final r = validate(42, (v) => v.isDateTime());
      expect(r.$isNotValid, isTrue);
    });
  });

  group('isBefore', () {
    test('passes when date is before test date', () {
      final r = validate(
        DateTime(2024, 1, 1),
        (v) => v.isBefore('2024-06-01'),
      );
      expect(r.$isValid, isTrue);
    });

    test('fails when date is after test date', () {
      final r = validate(
        DateTime(2024, 12, 1),
        (v) => v.isBefore('2024-06-01'),
      );
      expect(r.$isNotValid, isTrue);
    });

    test('works with "now" keyword', () {
      final r = validate(
        DateTime(2020, 1, 1),
        (v) => v.isBefore('now'),
      );
      expect(r.$isValid, isTrue);
    });
  });

  group('isAfter', () {
    test('passes when date is after test date', () {
      final r = validate(
        DateTime(2024, 12, 1),
        (v) => v.isAfter('2024-06-01'),
      );
      expect(r.$isValid, isTrue);
    });

    test('fails when date is before test date', () {
      final r = validate(
        DateTime(2024, 1, 1),
        (v) => v.isAfter('2024-06-01'),
      );
      expect(r.$isNotValid, isTrue);
    });
  });

  group('isAtMoment', () {
    test('passes when dates match', () {
      final dt = DateTime(2024, 6, 15, 10, 30);
      final r = validate(dt, (v) => v.isAtMoment('2024-06-15T10:30:00.000'));
      expect(r.$isValid, isTrue);
    });

    test('fails when dates differ', () {
      final r = validate(
        DateTime(2024, 6, 15),
        (v) => v.isAtMoment('2024-06-16'),
      );
      expect(r.$isNotValid, isTrue);
    });
  });

  group('isSameDateAs', () {
    test('passes when same date, different time', () {
      final r = validate(
        DateTime(2024, 6, 15, 10, 30),
        (v) => v.isSameDateAs('2024-06-15T23:59:59.000'),
      );
      expect(r.$isValid, isTrue);
    });

    test('fails when different date', () {
      final r = validate(
        DateTime(2024, 6, 15),
        (v) => v.isSameDateAs('2024-06-16'),
      );
      expect(r.$isNotValid, isTrue);
    });
  });

  // ── Pattern Matching ──────────────────────────────────────────────

  group('matchesPattern', () {
    test('passes when pattern matches', () {
      final r = validate('abc123', (v) => v.matchesPattern(r'^[a-z]+\d+$'));
      expect(r.$isValid, isTrue);
    });

    test('fails when pattern does not match', () {
      final r = validate('ABC', (v) => v.matchesPattern(r'^\d+$'));
      expect(r.$isNotValid, isTrue);
    });
  });

  group('isEmail', () {
    test('passes with valid email', () {
      final r = validate('user@example.com', (v) => v.isEmail(''));
      expect(r.$isValid, isTrue);
    });

    test('fails with invalid email', () {
      final r = validate('not-an-email', (v) => v.isEmail(''));
      expect(r.$isNotValid, isTrue);
    });
  });

  // ── Combined Rules ────────────────────────────────────────────────

  group('Combined validation', () {
    test('required + string + maxLength passes', () {
      final v = ValidateValue()
        ..isRequired()
        ..isString()
        ..maxLength(10);
      final r = v.from('hello', 'name');
      expect(r.$isValid, isTrue);
    });

    test('required + string + maxLength fails on null', () {
      final v = ValidateValue()
        ..isRequired()
        ..isString()
        ..maxLength(10);
      final r = v.from(null, 'name');
      expect(r.$isNotValid, isTrue);
    });

    test('required + int + greaterThan passes', () {
      final v = ValidateValue()
        ..isRequired()
        ..isInt()
        ..isGreaterThan(0);
      final r = v.from(5, 'age');
      expect(r.$isValid, isTrue);
    });

    test('required + int + greaterThan fails on zero', () {
      final v = ValidateValue()
        ..isRequired()
        ..isInt()
        ..isGreaterThan(0);
      final r = v.from(0, 'age');
      expect(r.$isNotValid, isTrue);
    });

    test('required bails early on null - skips further rules', () {
      final v = ValidateValue()
        ..isRequired()
        ..isString()
        ..minLength(5);
      final r = v.from(null, 'field');
      // Should only have the required error, not string/minLength errors
      expect(r.$isNotValid, isTrue);
      expect(r.$errors.length, 1);
    });

    test('intFromString coercion followed by numeric check', () {
      final v = ValidateValue()
        ..isRequired()
        ..intFromString()
        ..isGreaterThan(0);
      final r = v.from('42', 'age');
      expect(r.$isValid, isTrue);
      expect(r.$value, 42);
    });

    test('null skips non-required rules', () {
      final v = ValidateValue()
        ..isString()
        ..maxLength(10);
      final r = v.from(null, 'optional');
      // Rules with skipIfNull=true should be skipped
      expect(r.$isValid, isTrue);
    });
  });
}
