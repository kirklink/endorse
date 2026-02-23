import 'package:endorse/endorse.dart';
import 'package:test/test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // checkRules utility
  // ---------------------------------------------------------------------------
  group('checkRules', () {
    test('returns empty errors for valid value', () {
      final (errors, value) =
          checkRules('hello', const [Required(), IsString()]);
      expect(errors, isEmpty);
      expect(value, 'hello');
    });

    test('bails on Required failure', () {
      final (errors, _) = checkRules(
          null, const [Required(), IsString(), MinLength(1)]);
      expect(errors, ['is required']);
    });

    test('bails on type check failure', () {
      final (errors, _) =
          checkRules(123, const [Required(), IsString(), MinLength(1)]);
      expect(errors, ['must be a string']);
    });

    test('collects all non-bail errors', () {
      final (errors, _) =
          checkRules('', const [Required(), IsString(), MinLength(3), MaxLength(1)]);
      // Required bails on empty string
      expect(errors, ['is required']);
    });

    test('collects multiple non-bail errors', () {
      final (errors, _) =
          checkRules('ab', const [IsString(), MinLength(3), MaxLength(1)]);
      expect(errors, containsAll([
        'must be at least 3 characters',
        'must be at most 1 characters',
      ]));
    });
  });

  // ---------------------------------------------------------------------------
  // Required
  // ---------------------------------------------------------------------------
  group('Required', () {
    const rule = Required();

    test('fails on null', () {
      expect(rule.check(null), 'is required');
    });

    test('fails on empty string', () {
      expect(rule.check(''), 'is required');
    });

    test('fails on whitespace-only string', () {
      expect(rule.check('  '), 'is required');
    });

    test('passes on non-empty string', () {
      expect(rule.check('hello'), isNull);
    });

    test('passes on zero', () {
      expect(rule.check(0), isNull);
    });

    test('passes on false', () {
      expect(rule.check(false), isNull);
    });

    test('passes on empty list', () {
      // Required checks for null/empty string only, not empty collections
      expect(rule.check([]), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Type rules with coercion
  // ---------------------------------------------------------------------------
  group('IsString', () {
    const rule = IsString();

    test('passes on string', () {
      expect(rule.check('hello'), isNull);
    });

    test('passes on null (skips)', () {
      expect(rule.check(null), isNull);
    });

    test('fails on int', () {
      expect(rule.check(42), 'must be a string');
    });
  });

  group('IsInt', () {
    const rule = IsInt();

    test('passes on int', () {
      expect(rule.check(42), isNull);
    });

    test('coerces whole double to int', () {
      expect(rule.coerce(5.0), 5);
      expect(rule.coerce(5.0), isA<int>());
    });

    test('does not coerce fractional double', () {
      expect(rule.coerce(5.5), 5.5);
      expect(rule.check(5.5), 'must be an integer');
    });

    test('coerces string to int', () {
      expect(rule.coerce('42'), 42);
    });

    test('fails on non-parseable string', () {
      final coerced = rule.coerce('abc');
      expect(rule.check(coerced), 'must be an integer');
    });

    test('passes on null (skips)', () {
      expect(rule.check(null), isNull);
    });
  });

  group('IsDouble', () {
    const rule = IsDouble();

    test('passes on double', () {
      expect(rule.check(3.14), isNull);
    });

    test('coerces int to double', () {
      expect(rule.coerce(5), 5.0);
      expect(rule.coerce(5), isA<double>());
    });

    test('coerces string to double', () {
      expect(rule.coerce('3.14'), 3.14);
    });
  });

  group('IsNum', () {
    const rule = IsNum();

    test('passes on int', () {
      expect(rule.check(42), isNull);
    });

    test('passes on double', () {
      expect(rule.check(3.14), isNull);
    });

    test('coerces string to num', () {
      expect(rule.coerce('42'), 42);
      expect(rule.coerce('3.14'), 3.14);
    });
  });

  group('IsBool', () {
    const rule = IsBool();

    test('passes on bool', () {
      expect(rule.check(true), isNull);
      expect(rule.check(false), isNull);
    });

    test('coerces string true/false', () {
      expect(rule.coerce('true'), true);
      expect(rule.coerce('false'), false);
      expect(rule.coerce('TRUE'), true);
    });

    test('coerces string 1/0', () {
      expect(rule.coerce('1'), true);
      expect(rule.coerce('0'), false);
    });

    test('coerces int 1/0', () {
      expect(rule.coerce(1), true);
      expect(rule.coerce(0), false);
    });

    test('fails on non-coercible', () {
      final coerced = rule.coerce('maybe');
      expect(rule.check(coerced), 'must be a boolean');
    });
  });

  group('IsDateTime', () {
    const rule = IsDateTime();

    test('passes on DateTime', () {
      expect(rule.check(DateTime(2024)), isNull);
    });

    test('coerces ISO string', () {
      final coerced = rule.coerce('2024-01-15T10:30:00Z');
      expect(coerced, isA<DateTime>());
    });

    test('fails on non-parseable string', () {
      final coerced = rule.coerce('not-a-date');
      expect(rule.check(coerced), 'must be a valid date/time');
    });
  });

  group('IsMap', () {
    const rule = IsMap();

    test('passes on Map', () {
      expect(rule.check({'a': 1}), isNull);
    });

    test('fails on non-Map', () {
      expect(rule.check('hello'), 'must be an object');
    });
  });

  group('IsList', () {
    const rule = IsList();

    test('passes on List', () {
      expect(rule.check([1, 2]), isNull);
    });

    test('fails on non-List', () {
      expect(rule.check('hello'), 'must be a list');
    });
  });

  // ---------------------------------------------------------------------------
  // String rules
  // ---------------------------------------------------------------------------
  group('MinLength', () {
    test('passes when at least min', () {
      expect(const MinLength(3).check('abc'), isNull);
    });

    test('fails when shorter', () {
      expect(const MinLength(3).check('ab'), 'must be at least 3 characters');
    });

    test('min=1 uses special message', () {
      expect(const MinLength(1).check(''), 'must not be empty');
    });

    test('skips non-string', () {
      expect(const MinLength(3).check(42), isNull);
    });
  });

  group('MaxLength', () {
    test('passes when at most max', () {
      expect(const MaxLength(5).check('hello'), isNull);
    });

    test('fails when longer', () {
      expect(const MaxLength(3).check('hello'), 'must be at most 3 characters');
    });
  });

  group('Matches', () {
    test('passes on match', () {
      expect(const Matches(r'^\d+$').check('123'), isNull);
    });

    test('fails on non-match', () {
      expect(const Matches(r'^\d+$').check('abc'), isNotNull);
    });

    test('uses custom message', () {
      expect(
        const Matches(r'^\d{5}$', message: 'must be a 5-digit zip code')
            .check('abc'),
        'must be a 5-digit zip code',
      );
    });
  });

  group('Email', () {
    test('passes valid email', () {
      expect(const Email().check('user@example.com'), isNull);
    });

    test('fails invalid email', () {
      expect(const Email().check('not-an-email'), isNotNull);
    });

    test('fails email without domain', () {
      expect(const Email().check('user@'), isNotNull);
    });
  });

  group('Url', () {
    test('passes valid URL', () {
      expect(const Url().check('https://example.com'), isNull);
    });

    test('fails on bare string', () {
      expect(const Url().check('not-a-url'), isNotNull);
    });
  });

  group('Uuid', () {
    test('passes valid UUID', () {
      expect(
        const Uuid().check('550e8400-e29b-41d4-a716-446655440000'),
        isNull,
      );
    });

    test('fails invalid UUID', () {
      expect(const Uuid().check('not-a-uuid'), isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Numeric rules
  // ---------------------------------------------------------------------------
  group('Min', () {
    test('passes when >= min', () {
      expect(const Min(0).check(0), isNull);
      expect(const Min(0).check(1), isNull);
    });

    test('fails when < min', () {
      expect(const Min(0).check(-1), 'must be at least 0');
    });

    test('works with doubles', () {
      expect(const Min(1.5).check(1.5), isNull);
      expect(const Min(1.5).check(1.0), 'must be at least 1.5');
    });

    test('fails on NaN', () {
      expect(const Min(0).check(double.nan), 'must be at least 0');
    });

    test('fails on NaN with custom message', () {
      expect(const Min(0, message: 'bad').check(double.nan), 'bad');
    });
  });

  group('Max', () {
    test('passes when <= max', () {
      expect(const Max(100).check(100), isNull);
      expect(const Max(100).check(50), isNull);
    });

    test('fails when > max', () {
      expect(const Max(100).check(101), 'must be at most 100');
    });

    test('fails on NaN', () {
      expect(const Max(100).check(double.nan), 'must be at most 100');
    });

    test('fails on NaN with custom message', () {
      expect(const Max(100, message: 'bad').check(double.nan), 'bad');
    });
  });

  // ---------------------------------------------------------------------------
  // Collection rules
  // ---------------------------------------------------------------------------
  group('MinElements', () {
    test('passes with enough elements', () {
      expect(const MinElements(2).check([1, 2]), isNull);
    });

    test('fails with too few', () {
      expect(const MinElements(2).check([1]),
          'must have at least 2 elements');
    });

    test('min=1 uses special message', () {
      expect(const MinElements(1).check([]), 'must not be empty');
    });
  });

  group('MaxElements', () {
    test('passes with few enough', () {
      expect(const MaxElements(3).check([1, 2]), isNull);
    });

    test('fails with too many', () {
      expect(const MaxElements(2).check([1, 2, 3]),
          'must have at most 2 elements');
    });
  });

  group('UniqueElements', () {
    test('passes with unique elements', () {
      expect(const UniqueElements().check([1, 2, 3]), isNull);
    });

    test('fails with duplicates', () {
      expect(const UniqueElements().check([1, 2, 2]),
          'must contain unique elements');
    });
  });

  // ---------------------------------------------------------------------------
  // OneOf
  // ---------------------------------------------------------------------------
  group('OneOf', () {
    test('passes when value in list', () {
      expect(const OneOf(['a', 'b', 'c']).check('b'), isNull);
    });

    test('fails when value not in list', () {
      expect(const OneOf(['a', 'b', 'c']).check('d'),
          'must be one of: a, b, c');
    });

    test('passes on null (skips)', () {
      expect(const OneOf(['a', 'b']).check(null), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Custom messages
  // ---------------------------------------------------------------------------
  group('Custom messages', () {
    test('Required custom message', () {
      const rule = Required(message: 'field is mandatory');
      expect(rule.check(null), 'field is mandatory');
      expect(rule.check(''), 'field is mandatory');
      expect(rule.check('ok'), isNull);
    });

    test('MinLength custom message', () {
      const rule = MinLength(3, message: 'too short');
      expect(rule.check('ab'), 'too short');
      expect(rule.check('abc'), isNull);
    });

    test('MaxLength custom message', () {
      const rule = MaxLength(3, message: 'too long');
      expect(rule.check('abcd'), 'too long');
      expect(rule.check('abc'), isNull);
    });

    test('Email custom message', () {
      const rule = Email(message: 'invalid email format');
      expect(rule.check('bad'), 'invalid email format');
      expect(rule.check('a@b.com'), isNull);
    });

    test('Url custom message', () {
      const rule = Url(message: 'not a URL');
      expect(rule.check('bad'), 'not a URL');
      expect(rule.check('https://x.com'), isNull);
    });

    test('Uuid custom message', () {
      const rule = Uuid(message: 'bad uuid');
      expect(rule.check('bad'), 'bad uuid');
      expect(rule.check('550e8400-e29b-41d4-a716-446655440000'), isNull);
    });

    test('Min custom message', () {
      const rule = Min(10, message: 'at least 10 required');
      expect(rule.check(5), 'at least 10 required');
      expect(rule.check(10), isNull);
    });

    test('Max custom message', () {
      const rule = Max(10, message: 'no more than 10');
      expect(rule.check(11), 'no more than 10');
      expect(rule.check(10), isNull);
    });

    test('MinElements custom message', () {
      const rule = MinElements(2, message: 'need more items');
      expect(rule.check([1]), 'need more items');
      expect(rule.check([1, 2]), isNull);
    });

    test('MaxElements custom message', () {
      const rule = MaxElements(2, message: 'too many items');
      expect(rule.check([1, 2, 3]), 'too many items');
      expect(rule.check([1, 2]), isNull);
    });

    test('UniqueElements custom message', () {
      const rule = UniqueElements(message: 'no dupes allowed');
      expect(rule.check([1, 1]), 'no dupes allowed');
      expect(rule.check([1, 2]), isNull);
    });

    test('OneOf custom message', () {
      const rule = OneOf(['a', 'b'], message: 'pick a or b');
      expect(rule.check('c'), 'pick a or b');
      expect(rule.check('a'), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Trim
  // ---------------------------------------------------------------------------
  group('Trim', () {
    const rule = Trim();

    test('trims whitespace from string', () {
      expect(rule.coerce('  hello  '), 'hello');
    });

    test('passes through non-string', () {
      expect(rule.coerce(42), 42);
    });

    test('passes through null', () {
      expect(rule.coerce(null), isNull);
    });

    test('check always returns null', () {
      expect(rule.check('anything'), isNull);
      expect(rule.check(null), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // LowerCase
  // ---------------------------------------------------------------------------
  group('LowerCase', () {
    const rule = LowerCase();

    test('converts string to lowercase', () {
      expect(rule.coerce('Hello WORLD'), 'hello world');
    });

    test('passes through non-string', () {
      expect(rule.coerce(42), 42);
    });

    test('passes through null', () {
      expect(rule.coerce(null), isNull);
    });

    test('check always returns null', () {
      expect(rule.check('ANYTHING'), isNull);
      expect(rule.check(null), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // UpperCase
  // ---------------------------------------------------------------------------
  group('UpperCase', () {
    const rule = UpperCase();

    test('converts string to uppercase', () {
      expect(rule.coerce('Hello world'), 'HELLO WORLD');
    });

    test('passes through non-string', () {
      expect(rule.coerce(42), 42);
    });

    test('passes through null', () {
      expect(rule.coerce(null), isNull);
    });

    test('check always returns null', () {
      expect(rule.check('anything'), isNull);
      expect(rule.check(null), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // StripHtml
  // ---------------------------------------------------------------------------
  group('StripHtml', () {
    const rule = StripHtml();

    test('strips HTML tags from string', () {
      expect(rule.coerce('<b>hello</b>'), 'hello');
    });

    test('strips nested and multiple tags', () {
      expect(rule.coerce('<div><p>text</p></div>'), 'text');
    });

    test('strips self-closing tags', () {
      expect(rule.coerce('line<br/>break'), 'linebreak');
    });

    test('strips tags with attributes', () {
      expect(rule.coerce('<a href="#">link</a>'), 'link');
    });

    test('passes through plain text', () {
      expect(rule.coerce('no tags here'), 'no tags here');
    });

    test('passes through non-string', () {
      expect(rule.coerce(42), 42);
    });

    test('passes through null', () {
      expect(rule.coerce(null), isNull);
    });

    test('check always returns null', () {
      expect(rule.check('<b>anything</b>'), isNull);
      expect(rule.check(null), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // CollapseWhitespace
  // ---------------------------------------------------------------------------
  group('CollapseWhitespace', () {
    const rule = CollapseWhitespace();

    test('collapses multiple spaces', () {
      expect(rule.coerce('hello   world'), 'hello world');
    });

    test('collapses tabs and newlines', () {
      expect(rule.coerce('hello\t\n  world'), 'hello world');
    });

    test('trims leading and trailing whitespace', () {
      expect(rule.coerce('  hello  '), 'hello');
    });

    test('handles mixed whitespace', () {
      expect(rule.coerce('  a  \n\n  b  \t  c  '), 'a b c');
    });

    test('passes through non-string', () {
      expect(rule.coerce(42), 42);
    });

    test('passes through null', () {
      expect(rule.coerce(null), isNull);
    });

    test('check always returns null', () {
      expect(rule.check('anything'), isNull);
      expect(rule.check(null), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // NormalizeNewlines
  // ---------------------------------------------------------------------------
  group('NormalizeNewlines', () {
    const rule = NormalizeNewlines();

    test('replaces \\r\\n with \\n', () {
      expect(rule.coerce('line1\r\nline2'), 'line1\nline2');
    });

    test('replaces lone \\r with \\n', () {
      expect(rule.coerce('line1\rline2'), 'line1\nline2');
    });

    test('preserves existing \\n', () {
      expect(rule.coerce('line1\nline2'), 'line1\nline2');
    });

    test('handles mixed line endings', () {
      expect(rule.coerce('a\r\nb\rc\nd'), 'a\nb\nc\nd');
    });

    test('passes through non-string', () {
      expect(rule.coerce(42), 42);
    });

    test('passes through null', () {
      expect(rule.coerce(null), isNull);
    });

    test('check always returns null', () {
      expect(rule.check('anything'), isNull);
      expect(rule.check(null), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Truncate
  // ---------------------------------------------------------------------------
  group('Truncate', () {
    test('truncates string longer than max', () {
      const rule = Truncate(5);
      expect(rule.coerce('hello world'), 'hello');
    });

    test('preserves string at exact max', () {
      const rule = Truncate(5);
      expect(rule.coerce('hello'), 'hello');
    });

    test('preserves string shorter than max', () {
      const rule = Truncate(10);
      expect(rule.coerce('hello'), 'hello');
    });

    test('truncates to zero', () {
      const rule = Truncate(0);
      expect(rule.coerce('hello'), '');
    });

    test('passes through non-string', () {
      const rule = Truncate(5);
      expect(rule.coerce(42), 42);
    });

    test('passes through null', () {
      const rule = Truncate(5);
      expect(rule.coerce(null), isNull);
    });

    test('check always returns null', () {
      const rule = Truncate(5);
      expect(rule.check('anything'), isNull);
      expect(rule.check(null), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // TransformRule (runtime wrapper)
  // ---------------------------------------------------------------------------
  group('TransformRule', () {
    test('applies transform function', () {
      final rule = TransformRule((v) => v is String ? v.toUpperCase() : v);
      expect(rule.coerce('hello'), 'HELLO');
    });

    test('passes through null when transform allows it', () {
      final rule = TransformRule((v) => v);
      expect(rule.coerce(null), isNull);
    });

    test('check always returns null', () {
      final rule = TransformRule((v) => v);
      expect(rule.check('anything'), isNull);
      expect(rule.check(null), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // DateTime rules — Date (day granularity)
  // ---------------------------------------------------------------------------
  group('IsBeforeDate', () {
    test('passes when date is before', () {
      final rule = IsBeforeDate('2025-06-15');
      expect(rule.check(DateTime(2025, 6, 14)), isNull);
    });

    test('fails when date is same', () {
      final rule = IsBeforeDate('2025-06-15');
      expect(rule.check(DateTime(2025, 6, 15)), 'must be before 2025-06-15');
    });

    test('fails when date is after', () {
      final rule = IsBeforeDate('2025-06-15');
      expect(rule.check(DateTime(2025, 6, 16)), 'must be before 2025-06-15');
    });

    test('ignores time component', () {
      final rule = IsBeforeDate('2025-06-15');
      // Same day but late time — still not "before"
      expect(rule.check(DateTime(2025, 6, 15, 23, 59)), isNotNull);
      // Day before with late time — still "before"
      expect(rule.check(DateTime(2025, 6, 14, 23, 59)), isNull);
    });

    test('skips non-DateTime', () {
      expect(const IsBeforeDate('2025-06-15').check('not a date'), isNull);
      expect(const IsBeforeDate('2025-06-15').check(null), isNull);
    });

    test('custom message', () {
      final rule = IsBeforeDate('2025-06-15', message: 'too late');
      expect(rule.check(DateTime(2025, 6, 16)), 'too late');
    });
  });

  group('IsAfterDate', () {
    test('passes when date is after', () {
      final rule = IsAfterDate('2025-06-15');
      expect(rule.check(DateTime(2025, 6, 16)), isNull);
    });

    test('fails when date is same', () {
      final rule = IsAfterDate('2025-06-15');
      expect(rule.check(DateTime(2025, 6, 15)), 'must be after 2025-06-15');
    });

    test('fails when date is before', () {
      final rule = IsAfterDate('2025-06-15');
      expect(rule.check(DateTime(2025, 6, 14)), 'must be after 2025-06-15');
    });

    test('custom message', () {
      final rule = IsAfterDate('2025-06-15', message: 'too early');
      expect(rule.check(DateTime(2025, 6, 14)), 'too early');
    });
  });

  group('IsSameDate', () {
    test('passes when same date', () {
      final rule = IsSameDate('2025-06-15');
      expect(rule.check(DateTime(2025, 6, 15)), isNull);
    });

    test('passes when same date different time', () {
      final rule = IsSameDate('2025-06-15');
      expect(rule.check(DateTime(2025, 6, 15, 14, 30)), isNull);
    });

    test('fails when different date', () {
      final rule = IsSameDate('2025-06-15');
      expect(rule.check(DateTime(2025, 6, 16)),
          'must be the same date as 2025-06-15');
    });

    test('custom message', () {
      final rule = IsSameDate('2025-06-15', message: 'wrong date');
      expect(rule.check(DateTime(2025, 6, 16)), 'wrong date');
    });
  });

  group('IsBeforeDate/IsAfterDate with today spec', () {
    test('today spec resolves to current date', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      expect(const IsBeforeDate('today+2').check(tomorrow), isNull);
      expect(const IsAfterDate('today-2').check(yesterday), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // DateTime rules — Datetime (full precision)
  // ---------------------------------------------------------------------------
  group('IsFutureDatetime', () {
    test('passes for future datetime', () {
      final future = DateTime.now().add(const Duration(hours: 1));
      expect(const IsFutureDatetime().check(future), isNull);
    });

    test('fails for past datetime', () {
      final past = DateTime.now().subtract(const Duration(hours: 1));
      expect(const IsFutureDatetime().check(past), 'must be in the future');
    });

    test('custom message', () {
      final past = DateTime.now().subtract(const Duration(hours: 1));
      expect(const IsFutureDatetime(message: 'needs to be later').check(past),
          'needs to be later');
    });

    test('skips non-DateTime', () {
      expect(const IsFutureDatetime().check(null), isNull);
      expect(const IsFutureDatetime().check('string'), isNull);
    });
  });

  group('IsPastDatetime', () {
    test('passes for past datetime', () {
      final past = DateTime.now().subtract(const Duration(hours: 1));
      expect(const IsPastDatetime().check(past), isNull);
    });

    test('fails for future datetime', () {
      final future = DateTime.now().add(const Duration(hours: 1));
      expect(const IsPastDatetime().check(future), 'must be in the past');
    });

    test('custom message', () {
      final future = DateTime.now().add(const Duration(hours: 1));
      expect(const IsPastDatetime(message: 'must be historical').check(future),
          'must be historical');
    });
  });

  group('IsSameDatetime', () {
    test('passes for same moment', () {
      const rule = IsSameDatetime('2025-06-15T10:30:00.000');
      expect(rule.check(DateTime(2025, 6, 15, 10, 30)), isNull);
    });

    test('fails for different moment', () {
      const rule = IsSameDatetime('2025-06-15T10:30:00.000');
      expect(rule.check(DateTime(2025, 6, 15, 10, 31)),
          'must be the same moment as 2025-06-15T10:30:00.000');
    });

    test('custom message', () {
      const rule = IsSameDatetime('2025-06-15T10:30:00.000',
          message: 'wrong time');
      expect(rule.check(DateTime(2025, 6, 15, 11, 0)), 'wrong time');
    });
  });

  // ---------------------------------------------------------------------------
  // IpAddress
  // ---------------------------------------------------------------------------
  group('IpAddress', () {
    const rule = IpAddress();

    test('passes valid IPv4', () {
      expect(rule.check('192.168.1.1'), isNull);
      expect(rule.check('0.0.0.0'), isNull);
      expect(rule.check('255.255.255.255'), isNull);
    });

    test('fails invalid IPv4', () {
      expect(rule.check('256.1.1.1'), isNotNull);
      expect(rule.check('192.168.1'), isNotNull);
      expect(rule.check('not-an-ip'), isNotNull);
    });

    test('passes valid IPv6', () {
      expect(rule.check('::1'), isNull);
      expect(rule.check('2001:0db8:85a3:0000:0000:8a2e:0370:7334'), isNull);
      expect(rule.check('fe80::1'), isNull);
    });

    test('fails invalid IPv6', () {
      expect(rule.check('2001:xyz::1'), isNotNull);
    });

    test('custom message', () {
      const custom = IpAddress(message: 'bad IP');
      expect(custom.check('bad'), 'bad IP');
    });

    test('skips non-string', () {
      expect(rule.check(42), isNull);
      expect(rule.check(null), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // NoControlChars
  // ---------------------------------------------------------------------------
  group('NoControlChars', () {
    const rule = NoControlChars();

    test('passes clean text', () {
      expect(rule.check('hello world'), isNull);
      expect(rule.check('Hello, World! 123'), isNull);
      expect(rule.check(''), isNull);
    });

    test('allows tabs, newlines, carriage returns', () {
      expect(rule.check('line1\nline2'), isNull);
      expect(rule.check('col1\tcol2'), isNull);
      expect(rule.check('line1\r\nline2'), isNull);
    });

    test('fails for null byte', () {
      expect(rule.check('hello\x00world'), isNotNull);
    });

    test('fails for C0 controls (except tab/LF/CR)', () {
      expect(rule.check('abc\x01def'), isNotNull); // SOH
      expect(rule.check('abc\x08def'), isNotNull); // BS
      expect(rule.check('abc\x0Bdef'), isNotNull); // VT
      expect(rule.check('abc\x0Cdef'), isNotNull); // FF
      expect(rule.check('abc\x1Fdef'), isNotNull); // US
    });

    test('fails for DEL', () {
      expect(rule.check('abc\x7Fdef'), isNotNull);
    });

    test('fails for C1 controls', () {
      expect(rule.check('abc\x80def'), isNotNull);
      expect(rule.check('abc\x9Fdef'), isNotNull);
    });

    test('fails for zero-width characters', () {
      expect(rule.check('abc\u200Bdef'), isNotNull); // ZWSP
      expect(rule.check('abc\u200Fdef'), isNotNull); // RLM
    });

    test('fails for directional formatting', () {
      expect(rule.check('abc\u202Adef'), isNotNull); // LRE
      expect(rule.check('abc\u202Edef'), isNotNull); // RLO
    });

    test('fails for directional isolates', () {
      expect(rule.check('abc\u2066def'), isNotNull); // LRI
      expect(rule.check('abc\u2069def'), isNotNull); // PDI
    });

    test('fails for object replacement', () {
      expect(rule.check('abc\uFFFCdef'), isNotNull);
    });

    test('custom message', () {
      const custom = NoControlChars(message: 'bad chars');
      expect(custom.check('abc\x00def'), 'bad chars');
    });

    test('skips non-string', () {
      expect(rule.check(42), isNull);
      expect(rule.check(null), isNull);
    });
  });

  group('NoControlChars.containsControlChars', () {
    test('returns false for clean text', () {
      expect(NoControlChars.containsControlChars('hello'), isFalse);
    });

    test('returns true for text with control chars', () {
      expect(NoControlChars.containsControlChars('a\x00b'), isTrue);
      expect(NoControlChars.containsControlChars('\u200B'), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Full chain integration
  // ---------------------------------------------------------------------------
  group('Full chain', () {
    test('required string with length constraints', () {
      final rules = [
        const Required(),
        const IsString(),
        const MinLength(2),
        const MaxLength(10),
      ];

      final (e1, _) = checkRules(null, rules);
      expect(e1, ['is required']);

      final (e2, _) = checkRules(42, rules);
      expect(e2, ['must be a string']);

      final (e3, _) = checkRules('a', rules);
      expect(e3, ['must be at least 2 characters']);

      final (e4, v4) = checkRules('hello', rules);
      expect(e4, isEmpty);
      expect(v4, 'hello');
    });

    test('required int with min/max and auto-coercion', () {
      final rules = [
        const Required(),
        const IsInt(),
        const Min(0),
        const Max(100),
      ];

      // String coerced to int
      final (e1, v1) = checkRules('42', rules);
      expect(e1, isEmpty);
      expect(v1, 42);

      // Double coerced to int
      final (e2, v2) = checkRules(5.0, rules);
      expect(e2, isEmpty);
      expect(v2, 5);

      // Out of range
      final (e3, _) = checkRules(101, rules);
      expect(e3, ['must be at most 100']);

      // Invalid string
      final (e4, _) = checkRules('abc', rules);
      expect(e4, ['must be an integer']);
    });

    test('optional field (no Required)', () {
      final rules = [const IsString(), const Email()];

      // null is fine — no errors
      final (e1, _) = checkRules(null, rules);
      expect(e1, isEmpty);

      // Valid email
      final (e2, _) = checkRules('a@b.com', rules);
      expect(e2, isEmpty);

      // Invalid email
      final (e3, _) = checkRules('bad', rules);
      expect(e3, ['must be a valid email address']);
    });
  });
}
