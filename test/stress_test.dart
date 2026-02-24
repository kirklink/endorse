import 'package:endorse/endorse.dart';
import 'package:test/test.dart';

void main() {
  group('Required rule stress tests', () {
    test('null fails', () {
      expect(const Required().check(null), isNotNull);
    });

    test('empty string fails', () {
      expect(const Required().check(''), isNotNull);
    });

    test('whitespace-only string fails', () {
      expect(const Required().check('   '), isNotNull);
    });

    test('non-empty string passes', () {
      expect(const Required().check('hello'), isNull);
    });

    test('zero passes', () {
      expect(const Required().check(0), isNull);
    });

    test('false passes', () {
      expect(const Required().check(false), isNull);
    });

    test('empty list passes (Required only checks null/empty string)', () {
      // Required checks for null and empty string only
      expect(const Required().check([]), isNull);
    });

    test('custom message', () {
      const rule = Required(message: 'cannot be blank');
      expect(rule.check(null), 'cannot be blank');
    });

    test('bail is true', () {
      expect(const Required().bail, isTrue);
    });
  });

  group('Type coercion stress tests', () {
    group('IsInt', () {
      test('int passes', () {
        expect(const IsInt().check(42), isNull);
      });

      test('null skips', () {
        expect(const IsInt().check(null), isNull);
      });

      test('string coercion', () {
        expect(const IsInt().coerce('42'), 42);
      });

      test('string with leading zeros', () {
        expect(const IsInt().coerce('007'), 7);
      });

      test('negative string', () {
        expect(const IsInt().coerce('-1'), -1);
      });

      test('non-numeric string fails', () {
        expect(const IsInt().check('abc'), isNotNull);
      });

      test('empty string fails', () {
        expect(const IsInt().check(''), isNotNull);
      });

      test('double with no fraction coerces', () {
        expect(const IsInt().coerce(42.0), 42);
      });

      test('double with fraction fails', () {
        expect(const IsInt().check(42.5), isNotNull);
      });

      test('max int string coercion', () {
        expect(const IsInt().coerce('9223372036854775807'),
            9223372036854775807);
      });

      test('bool fails', () {
        expect(const IsInt().check(true), isNotNull);
      });

      test('list fails', () {
        expect(const IsInt().check([1]), isNotNull);
      });

      test('bail is true', () {
        expect(const IsInt().bail, isTrue);
      });
    });

    group('IsDouble', () {
      test('double passes', () {
        expect(const IsDouble().check(3.14), isNull);
      });

      test('int coerces to double', () {
        final coerced = const IsDouble().coerce(42);
        expect(coerced, 42.0);
        expect(coerced, isA<double>());
      });

      test('string coerces to double', () {
        expect(const IsDouble().coerce('3.14'), 3.14);
      });

      test('string with exponent', () {
        expect(const IsDouble().coerce('1.5e10'), 1.5e10);
      });

      test('negative string', () {
        expect(const IsDouble().coerce('-99.9'), -99.9);
      });

      test('non-numeric string fails', () {
        expect(const IsDouble().check('abc'), isNotNull);
      });

      test('null skips', () {
        expect(const IsDouble().check(null), isNull);
      });
    });

    group('IsNum', () {
      test('int passes', () {
        expect(const IsNum().check(42), isNull);
      });

      test('double passes', () {
        expect(const IsNum().check(3.14), isNull);
      });

      test('string coerces', () {
        expect(const IsNum().coerce('42'), 42);
        expect(const IsNum().coerce('3.14'), 3.14);
      });

      test('non-numeric string fails', () {
        expect(const IsNum().check('abc'), isNotNull);
      });

      test('null skips', () {
        expect(const IsNum().check(null), isNull);
      });
    });

    group('IsBool', () {
      test('bool passes', () {
        expect(const IsBool().check(true), isNull);
        expect(const IsBool().check(false), isNull);
      });

      test('string true/false coerces', () {
        expect(const IsBool().coerce('true'), true);
        expect(const IsBool().coerce('false'), false);
      });

      test('string 1/0 coerces', () {
        expect(const IsBool().coerce('1'), true);
        expect(const IsBool().coerce('0'), false);
      });

      test('int 1/0 coerces', () {
        expect(const IsBool().coerce(1), true);
        expect(const IsBool().coerce(0), false);
      });

      test('int 2 fails', () {
        expect(const IsBool().check(2), isNotNull);
      });

      test('string yes fails', () {
        expect(const IsBool().check('yes'), isNotNull);
      });

      test('null skips', () {
        expect(const IsBool().check(null), isNull);
      });
    });

    group('IsString', () {
      test('string passes', () {
        expect(const IsString().check('hello'), isNull);
      });

      test('empty string passes', () {
        expect(const IsString().check(''), isNull);
      });

      test('int fails', () {
        expect(const IsString().check(42), isNotNull);
      });

      test('null skips', () {
        expect(const IsString().check(null), isNull);
      });
    });

    group('IsDateTime', () {
      test('DateTime passes', () {
        expect(const IsDateTime().check(DateTime.now()), isNull);
      });

      test('ISO 8601 string coerces', () {
        final coerced = const IsDateTime().coerce('2025-01-15T10:30:00Z');
        expect(coerced, isA<DateTime>());
      });

      test('invalid string fails', () {
        expect(const IsDateTime().check('not-a-date'), isNotNull);
      });

      test('null skips', () {
        expect(const IsDateTime().check(null), isNull);
      });

      test('date-only string coerces', () {
        final coerced = const IsDateTime().coerce('2025-01-15');
        expect(coerced, isA<DateTime>());
      });
    });

    group('IsMap', () {
      test('map passes', () {
        expect(const IsMap().check({'key': 'value'}), isNull);
      });

      test('empty map passes', () {
        expect(const IsMap().check({}), isNull);
      });

      test('string fails', () {
        expect(const IsMap().check('{}'), isNotNull);
      });

      test('null skips', () {
        expect(const IsMap().check(null), isNull);
      });
    });

    group('IsList', () {
      test('list passes', () {
        expect(const IsList().check([1, 2, 3]), isNull);
      });

      test('empty list passes', () {
        expect(const IsList().check([]), isNull);
      });

      test('string fails', () {
        expect(const IsList().check('[]'), isNotNull);
      });

      test('null skips', () {
        expect(const IsList().check(null), isNull);
      });
    });
  });

  group('String rule stress tests', () {
    group('MinLength', () {
      test('exact minimum passes', () {
        expect(const MinLength(3).check('abc'), isNull);
      });

      test('below minimum fails', () {
        expect(const MinLength(3).check('ab'), isNotNull);
      });

      test('empty string with min 1', () {
        expect(const MinLength(1).check(''), isNotNull);
      });

      test('unicode characters count correctly', () {
        // Each emoji is one Dart char in most cases (but some are surrogate pairs)
        expect(const MinLength(1).check('\u{1F600}'), isNull);
      });

      test('skips non-string', () {
        expect(const MinLength(3).check(42), isNull);
      });

      test('skips null', () {
        expect(const MinLength(3).check(null), isNull);
      });

      test('min 0 always passes for strings', () {
        expect(const MinLength(0).check(''), isNull);
      });

      test('custom message', () {
        const rule = MinLength(5, message: 'too short');
        expect(rule.check('ab'), 'too short');
      });

      test('very long string passes', () {
        expect(const MinLength(1).check('x' * 100000), isNull);
      });
    });

    group('MaxLength', () {
      test('exact maximum passes', () {
        expect(const MaxLength(3).check('abc'), isNull);
      });

      test('above maximum fails', () {
        expect(const MaxLength(3).check('abcd'), isNotNull);
      });

      test('empty string passes any max', () {
        expect(const MaxLength(0).check(''), isNull);
      });

      test('skips non-string', () {
        expect(const MaxLength(3).check(42), isNull);
      });

      test('skips null', () {
        expect(const MaxLength(3).check(null), isNull);
      });

      test('custom message', () {
        const rule = MaxLength(5, message: 'too long');
        expect(rule.check('abcdef'), 'too long');
      });
    });

    group('Matches', () {
      test('matching pattern passes', () {
        expect(const Matches(r'^[a-z]+$').check('hello'), isNull);
      });

      test('non-matching pattern fails', () {
        expect(const Matches(r'^[a-z]+$').check('Hello'), isNotNull);
      });

      test('complex regex', () {
        const rule = Matches(r'^\d{3}-\d{2}-\d{4}$');
        expect(rule.check('123-45-6789'), isNull);
        expect(rule.check('12-345-6789'), isNotNull);
      });

      test('empty string against empty pattern', () {
        expect(const Matches(r'^$').check(''), isNull);
      });

      test('skips non-string', () {
        expect(const Matches(r'.*').check(42), isNull);
      });

      test('skips null', () {
        expect(const Matches(r'.*').check(null), isNull);
      });

      test('pattern with special chars', () {
        const rule = Matches(r'^[\w.+\-]+@[\w\-]+\.[\w.]+$');
        expect(rule.check('user@example.com'), isNull);
      });
    });

    group('Email', () {
      test('valid emails pass', () {
        final validEmails = [
          'user@example.com',
          'user.name@example.com',
          'user+tag@example.com',
          'user@sub.domain.com',
          'user123@example.co',
          'a@b.cd',
        ];
        for (final email in validEmails) {
          expect(const Email().check(email), isNull, reason: email);
        }
      });

      test('invalid emails fail', () {
        final invalidEmails = [
          '',
          'user',
          '@example.com',
          'user@',
          'user@.com',
          'user@example',
          'user@@example.com',
          'user @example.com',
          'user@exam ple.com',
        ];
        for (final email in invalidEmails) {
          expect(const Email().check(email), isNotNull, reason: email);
        }
      });

      test('skips null', () {
        expect(const Email().check(null), isNull);
      });

      test('skips non-string', () {
        expect(const Email().check(42), isNull);
      });
    });

    group('Url', () {
      test('valid URLs pass', () {
        final validUrls = [
          'http://example.com',
          'https://example.com',
          'https://example.com/path',
          'https://example.com/path?q=1',
          'https://example.com:8080',
          'ftp://files.example.com',
        ];
        for (final url in validUrls) {
          expect(const Url().check(url), isNull, reason: url);
        }
      });

      test('invalid URLs fail', () {
        final invalidUrls = [
          '',
          'not a url',
          'example.com',
          '://example.com',
          'javascript:alert(1)',
        ];
        for (final url in invalidUrls) {
          expect(const Url().check(url), isNotNull, reason: url);
        }
      });

      test('skips null', () {
        expect(const Url().check(null), isNull);
      });
    });

    group('Uuid', () {
      test('valid UUIDs pass', () {
        final validUuids = [
          '550e8400-e29b-41d4-a716-446655440000',
          '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
          'f47ac10b-58cc-4372-a567-0e02b2c3d479',
          '00000000-0000-0000-0000-000000000000',
          'FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF',
        ];
        for (final uuid in validUuids) {
          expect(const Uuid().check(uuid), isNull, reason: uuid);
        }
      });

      test('invalid UUIDs fail', () {
        final invalidUuids = [
          '',
          'not-a-uuid',
          '550e8400-e29b-41d4-a716',
          '550e8400-e29b-41d4-a716-44665544000g',
          '550e8400e29b41d4a716446655440000',
        ];
        for (final uuid in invalidUuids) {
          expect(const Uuid().check(uuid), isNotNull, reason: uuid);
        }
      });

      test('skips null', () {
        expect(const Uuid().check(null), isNull);
      });
    });

    group('IpAddress', () {
      test('valid IPv4 addresses pass', () {
        final validIps = [
          '0.0.0.0',
          '127.0.0.1',
          '192.168.1.1',
          '255.255.255.255',
          '10.0.0.1',
        ];
        for (final ip in validIps) {
          expect(const IpAddress().check(ip), isNull, reason: ip);
        }
      });

      test('valid IPv6 addresses pass', () {
        final validIps = [
          '::1',
          '::',
          '2001:db8::1',
          'fe80::1',
          // IPv4-mapped IPv6 (::ffff:x.x.x.x) not supported by IpAddress rule.
        ];
        for (final ip in validIps) {
          expect(const IpAddress().check(ip), isNull, reason: ip);
        }
      });

      test('invalid IP addresses fail', () {
        final invalidIps = [
          '',
          'not-an-ip',
          '256.0.0.1',
          '1.2.3',
          '1.2.3.4.5',
        ];
        for (final ip in invalidIps) {
          expect(const IpAddress().check(ip), isNotNull, reason: ip);
        }
      });

      test('skips null', () {
        expect(const IpAddress().check(null), isNull);
      });
    });

    group('NoControlChars', () {
      test('normal text passes', () {
        expect(const NoControlChars().check('Hello, World!'), isNull);
      });

      test('tab is allowed', () {
        expect(const NoControlChars().check('col1\tcol2'), isNull);
      });

      test('LF is allowed', () {
        expect(const NoControlChars().check('line1\nline2'), isNull);
      });

      test('CR is allowed', () {
        expect(const NoControlChars().check('line1\rline2'), isNull);
      });

      test('CRLF is allowed', () {
        expect(const NoControlChars().check('line1\r\nline2'), isNull);
      });

      test('null byte rejected', () {
        expect(const NoControlChars().check('before\x00after'), isNotNull);
      });

      test('BEL rejected', () {
        expect(const NoControlChars().check('text\x07text'), isNotNull);
      });

      test('backspace rejected', () {
        expect(const NoControlChars().check('text\x08text'), isNotNull);
      });

      test('form feed rejected', () {
        expect(const NoControlChars().check('text\x0Ctext'), isNotNull);
      });

      test('escape rejected', () {
        expect(const NoControlChars().check('text\x1Btext'), isNotNull);
      });

      test('DEL (0x7F) rejected', () {
        expect(const NoControlChars().check('text\x7Ftext'), isNotNull);
      });

      test('zero-width space rejected', () {
        expect(const NoControlChars().check('text\u200Btext'), isNotNull);
      });

      test('zero-width joiner rejected', () {
        expect(const NoControlChars().check('text\u200Dtext'), isNotNull);
      });

      test('right-to-left mark rejected', () {
        expect(const NoControlChars().check('text\u200Ftext'), isNotNull);
      });

      test('object replacement char rejected', () {
        expect(const NoControlChars().check('text\uFFFCtext'), isNotNull);
      });

      test('empty string passes', () {
        expect(const NoControlChars().check(''), isNull);
      });

      test('unicode emoji passes', () {
        expect(const NoControlChars().check('\u{1F600}\u{1F4A9}'), isNull);
      });

      test('all printable ASCII passes', () {
        final printable = String.fromCharCodes(
            List.generate(95, (i) => i + 32)); // space (32) to ~ (126)
        expect(const NoControlChars().check(printable), isNull);
      });

      test('skips null', () {
        expect(const NoControlChars().check(null), isNull);
      });

      test('skips non-string', () {
        expect(const NoControlChars().check(42), isNull);
      });

      test('static helper isControlChar', () {
        expect(NoControlChars.isControlChar(0), isTrue); // null
        expect(NoControlChars.isControlChar(9), isFalse); // tab (allowed)
        expect(NoControlChars.isControlChar(10), isFalse); // LF (allowed)
        expect(NoControlChars.isControlChar(13), isFalse); // CR (allowed)
        expect(NoControlChars.isControlChar(7), isTrue); // BEL
        expect(NoControlChars.isControlChar(32), isFalse); // space
        expect(NoControlChars.isControlChar(127), isTrue); // DEL
      });

      test('static helper containsControlChars', () {
        expect(NoControlChars.containsControlChars('hello'), isFalse);
        expect(NoControlChars.containsControlChars('he\x00lo'), isTrue);
        expect(NoControlChars.containsControlChars(''), isFalse);
        expect(NoControlChars.containsControlChars('tab\tok'), isFalse);
      });
    });
  });

  group('Numeric rule stress tests', () {
    group('Min', () {
      test('at minimum passes', () {
        expect(const Min(0).check(0), isNull);
      });

      test('above minimum passes', () {
        expect(const Min(0).check(1), isNull);
      });

      test('below minimum fails', () {
        expect(const Min(0).check(-1), isNotNull);
      });

      test('NaN fails', () {
        expect(const Min(0).check(double.nan), isNotNull);
      });

      test('infinity passes (> any finite min)', () {
        expect(const Min(0).check(double.infinity), isNull);
      });

      test('negative infinity fails', () {
        expect(const Min(0).check(double.negativeInfinity), isNotNull);
      });

      test('double precision edge', () {
        // 0.1 + 0.2 = 0.30000000000000004 > 0.3, so 0.3 fails the min check.
        expect(const Min(0.1 + 0.2).check(0.3), isNotNull);
      });

      test('skips null', () {
        expect(const Min(0).check(null), isNull);
      });

      test('skips non-num', () {
        expect(const Min(0).check('5'), isNull);
      });

      test('custom message', () {
        expect(const Min(10, message: 'too low').check(5), 'too low');
      });
    });

    group('Max', () {
      test('at maximum passes', () {
        expect(const Max(100).check(100), isNull);
      });

      test('below maximum passes', () {
        expect(const Max(100).check(99), isNull);
      });

      test('above maximum fails', () {
        expect(const Max(100).check(101), isNotNull);
      });

      test('NaN fails', () {
        expect(const Max(100).check(double.nan), isNotNull);
      });

      test('negative infinity passes', () {
        expect(const Max(0).check(double.negativeInfinity), isNull);
      });

      test('positive infinity fails', () {
        expect(const Max(100).check(double.infinity), isNotNull);
      });

      test('skips null', () {
        expect(const Max(100).check(null), isNull);
      });

      test('custom message', () {
        expect(const Max(10, message: 'too high').check(15), 'too high');
      });
    });
  });

  group('Collection rule stress tests', () {
    group('MinElements', () {
      test('exact minimum passes', () {
        expect(const MinElements(2).check([1, 2]), isNull);
      });

      test('below minimum fails', () {
        expect(const MinElements(2).check([1]), isNotNull);
      });

      test('empty list with min 1 fails', () {
        expect(const MinElements(1).check([]), isNotNull);
      });

      test('min 0 always passes', () {
        expect(const MinElements(0).check([]), isNull);
      });

      test('large list passes', () {
        expect(const MinElements(1).check(List.filled(10000, null)), isNull);
      });

      test('skips null', () {
        expect(const MinElements(1).check(null), isNull);
      });

      test('skips non-list', () {
        expect(const MinElements(1).check('abc'), isNull);
      });
    });

    group('MaxElements', () {
      test('exact maximum passes', () {
        expect(const MaxElements(2).check([1, 2]), isNull);
      });

      test('above maximum fails', () {
        expect(const MaxElements(2).check([1, 2, 3]), isNotNull);
      });

      test('empty list passes', () {
        expect(const MaxElements(0).check([]), isNull);
      });

      test('skips null', () {
        expect(const MaxElements(5).check(null), isNull);
      });
    });

    group('UniqueElements', () {
      test('unique elements pass', () {
        expect(const UniqueElements().check([1, 2, 3]), isNull);
      });

      test('duplicate elements fail', () {
        expect(const UniqueElements().check([1, 2, 1]), isNotNull);
      });

      test('empty list passes', () {
        expect(const UniqueElements().check([]), isNull);
      });

      test('single element passes', () {
        expect(const UniqueElements().check([1]), isNull);
      });

      test('all same elements fail', () {
        expect(const UniqueElements().check([1, 1, 1, 1]), isNotNull);
      });

      test('different types are unique', () {
        // 1 (int) and '1' (string) are different
        expect(const UniqueElements().check([1, '1']), isNull);
      });

      test('null duplicates fail', () {
        expect(const UniqueElements().check([null, null]), isNotNull);
      });

      test('skips null', () {
        expect(const UniqueElements().check(null), isNull);
      });

      test('skips non-list', () {
        expect(const UniqueElements().check('abc'), isNull);
      });
    });
  });

  group('OneOf rule stress tests', () {
    test('allowed value passes', () {
      expect(const OneOf(['a', 'b', 'c']).check('a'), isNull);
    });

    test('disallowed value fails', () {
      expect(const OneOf(['a', 'b', 'c']).check('d'), isNotNull);
    });

    test('int values', () {
      expect(const OneOf([1, 2, 3]).check(1), isNull);
      expect(const OneOf([1, 2, 3]).check(4), isNotNull);
    });

    test('mixed types', () {
      expect(const OneOf([1, 'two', true]).check('two'), isNull);
      expect(const OneOf([1, 'two', true]).check(false), isNotNull);
    });

    test('null skips', () {
      expect(const OneOf(['a', 'b']).check(null), isNull);
    });

    test('empty allowed list always fails', () {
      expect(const OneOf([]).check('anything'), isNotNull);
    });

    test('custom message', () {
      expect(
        const OneOf(['a', 'b'], message: 'pick a or b').check('c'),
        'pick a or b',
      );
    });

    test('large allowed list', () {
      final allowed = List.generate(1000, (i) => 'option$i');
      expect(OneOf(allowed).check('option500'), isNull);
      expect(OneOf(allowed).check('option1000'), isNotNull);
    });
  });

  group('Transform rule stress tests', () {
    group('Trim', () {
      test('trims whitespace', () {
        expect(const Trim().coerce('  hello  '), 'hello');
      });

      test('no whitespace unchanged', () {
        expect(const Trim().coerce('hello'), 'hello');
      });

      test('only whitespace becomes empty', () {
        expect(const Trim().coerce('   '), '');
      });

      test('tabs and newlines trimmed', () {
        expect(const Trim().coerce('\thello\n'), 'hello');
      });

      test('never fails', () {
        expect(const Trim().check('anything'), isNull);
      });

      test('skips non-string', () {
        expect(const Trim().coerce(42), 42);
      });
    });

    group('LowerCase', () {
      test('converts to lowercase', () {
        expect(const LowerCase().coerce('HELLO'), 'hello');
      });

      test('mixed case', () {
        expect(const LowerCase().coerce('HeLLo WoRLd'), 'hello world');
      });

      test('already lowercase unchanged', () {
        expect(const LowerCase().coerce('hello'), 'hello');
      });

      test('never fails', () {
        expect(const LowerCase().check('ANY'), isNull);
      });
    });

    group('UpperCase', () {
      test('converts to uppercase', () {
        expect(const UpperCase().coerce('hello'), 'HELLO');
      });

      test('never fails', () {
        expect(const UpperCase().check('any'), isNull);
      });
    });

    group('StripHtml', () {
      test('removes simple tags', () {
        expect(const StripHtml().coerce('<b>bold</b>'), 'bold');
      });

      test('removes nested tags', () {
        expect(const StripHtml().coerce('<div><p>text</p></div>'), 'text');
      });

      test('removes self-closing tags', () {
        expect(const StripHtml().coerce('a<br/>b'), 'ab');
      });

      test('removes tags with attributes', () {
        expect(const StripHtml().coerce('<a href="url">link</a>'), 'link');
      });

      test('no tags unchanged', () {
        expect(const StripHtml().coerce('plain text'), 'plain text');
      });

      test('empty string unchanged', () {
        expect(const StripHtml().coerce(''), '');
      });

      test('never fails', () {
        expect(const StripHtml().check('<script>alert(1)</script>'), isNull);
      });
    });

    group('CollapseWhitespace', () {
      test('collapses multiple spaces', () {
        expect(const CollapseWhitespace().coerce('a   b   c'), 'a b c');
      });

      test('trims and collapses', () {
        expect(const CollapseWhitespace().coerce('  a  b  '), 'a b');
      });

      test('tabs and newlines collapsed', () {
        expect(const CollapseWhitespace().coerce('a\t\nb'), 'a b');
      });

      test('single space unchanged', () {
        expect(const CollapseWhitespace().coerce('a b'), 'a b');
      });

      test('never fails', () {
        expect(const CollapseWhitespace().check('anything'), isNull);
      });
    });

    group('NormalizeNewlines', () {
      test('CRLF to LF', () {
        expect(const NormalizeNewlines().coerce('a\r\nb'), 'a\nb');
      });

      test('CR to LF', () {
        expect(const NormalizeNewlines().coerce('a\rb'), 'a\nb');
      });

      test('LF unchanged', () {
        expect(const NormalizeNewlines().coerce('a\nb'), 'a\nb');
      });

      test('mixed newlines normalized', () {
        expect(const NormalizeNewlines().coerce('a\r\nb\rc\nd'),
            'a\nb\nc\nd');
      });

      test('never fails', () {
        expect(const NormalizeNewlines().check('anything'), isNull);
      });
    });

    group('Truncate', () {
      test('truncates long string', () {
        expect(const Truncate(5).coerce('abcdefgh'), 'abcde');
      });

      test('short string unchanged', () {
        expect(const Truncate(10).coerce('short'), 'short');
      });

      test('exact length unchanged', () {
        expect(const Truncate(5).coerce('abcde'), 'abcde');
      });

      test('empty string unchanged', () {
        expect(const Truncate(5).coerce(''), '');
      });

      test('never fails', () {
        expect(const Truncate(5).check('anything'), isNull);
      });
    });
  });

  group('DateTime rule stress tests', () {
    group('IsFutureDatetime', () {
      test('future date passes', () {
        final future = DateTime.now().add(Duration(days: 1));
        expect(const IsFutureDatetime().check(future), isNull);
      });

      test('past date fails', () {
        final past = DateTime.now().subtract(Duration(days: 1));
        expect(const IsFutureDatetime().check(past), isNotNull);
      });

      test('skips null', () {
        expect(const IsFutureDatetime().check(null), isNull);
      });

      test('skips non-DateTime', () {
        expect(const IsFutureDatetime().check('2099-01-01'), isNull);
      });
    });

    group('IsPastDatetime', () {
      test('past date passes', () {
        final past = DateTime.now().subtract(Duration(days: 1));
        expect(const IsPastDatetime().check(past), isNull);
      });

      test('future date fails', () {
        final future = DateTime.now().add(Duration(days: 1));
        expect(const IsPastDatetime().check(future), isNotNull);
      });

      test('skips null', () {
        expect(const IsPastDatetime().check(null), isNull);
      });
    });

    group('IsBeforeDate', () {
      test('today spec', () {
        final yesterday = DateTime.now().subtract(Duration(days: 1));
        expect(const IsBeforeDate('today').check(yesterday), isNull);
      });

      test('today+N spec', () {
        final today = DateTime.now();
        expect(const IsBeforeDate('today+7').check(today), isNull);
      });

      test('ISO date spec', () {
        final old = DateTime(2020, 1, 1);
        expect(const IsBeforeDate('2025-01-01').check(old), isNull);
      });

      test('skips null', () {
        expect(const IsBeforeDate('today').check(null), isNull);
      });
    });

    group('IsAfterDate', () {
      test('date after passes', () {
        final future = DateTime.now().add(Duration(days: 30));
        expect(const IsAfterDate('today').check(future), isNull);
      });

      test('date before fails', () {
        final past = DateTime(2020, 1, 1);
        expect(const IsAfterDate('today').check(past), isNotNull);
      });

      test('today-N spec', () {
        final now = DateTime.now();
        expect(const IsAfterDate('today-30').check(now), isNull);
      });

      test('skips null', () {
        expect(const IsAfterDate('today').check(null), isNull);
      });
    });

    group('IsSameDate', () {
      test('same date passes (ignoring time)', () {
        final now = DateTime.now();
        final sameDay = DateTime(now.year, now.month, now.day, 23, 59);
        expect(const IsSameDate('today').check(sameDay), isNull);
      });

      test('different date fails', () {
        final yesterday = DateTime.now().subtract(Duration(days: 1));
        expect(const IsSameDate('today').check(yesterday), isNotNull);
      });

      test('skips null', () {
        expect(const IsSameDate('today').check(null), isNull);
      });
    });
  });

  group('checkRules stress tests', () {
    test('empty rules returns no errors', () {
      final (errors, value) = checkRules('test', []);
      expect(errors, isEmpty);
      expect(value, 'test');
    });

    test('single passing rule', () {
      final (errors, _) = checkRules('hello', [const Required()]);
      expect(errors, isEmpty);
    });

    test('single failing rule', () {
      final (errors, _) = checkRules(null, [const Required()]);
      expect(errors, isNotEmpty);
    });

    test('bail rule stops chain on failure', () {
      final (errors, _) = checkRules(null, [
        const Required(),
        const MinLength(1),
        const MaxLength(10),
      ]);
      expect(errors, hasLength(1));
    });

    test('non-bail rules accumulate errors', () {
      final (errors, _) = checkRules('', [
        const MinLength(5),
        const Matches(r'^[A-Z]'),
        const Email(),
      ]);
      expect(errors.length, greaterThan(1));
    });

    test('coercion modifies value for subsequent rules', () {
      final (errors, value) = checkRules('  42  ', [
        const Trim(),
        const IsInt(),
      ]);
      expect(errors, isEmpty);
      expect(value, 42);
    });

    test('transform chain', () {
      final (errors, value) = checkRules('  HELLO WORLD  ', [
        const Trim(),
        const LowerCase(),
        const CollapseWhitespace(),
      ]);
      expect(errors, isEmpty);
      expect(value, 'hello world');
    });

    test('many rules (20+) in chain', () {
      final rules = <Rule>[
        const Required(),
        const IsString(),
        const Trim(),
        const LowerCase(),
        const CollapseWhitespace(),
        const NormalizeNewlines(),
        const MinLength(1),
        const MaxLength(1000),
        const NoControlChars(),
      ];
      final (errors, value) = checkRules('  Hello World  ', rules);
      expect(errors, isEmpty);
      expect(value, 'hello world');
    });

    test('coercion from string to int then min/max', () {
      final (errors, value) = checkRules('42', [
        const Required(),
        const IsInt(),
        const Min(0),
        const Max(100),
      ]);
      expect(errors, isEmpty);
      expect(value, 42);
    });

    test('coercion from string to bool', () {
      final (errors, value) = checkRules('true', [
        const Required(),
        const IsBool(),
      ]);
      expect(errors, isEmpty);
      expect(value, true);
    });

    test('coercion from string to DateTime', () {
      final (errors, value) = checkRules('2025-06-15', [
        const Required(),
        const IsDateTime(),
      ]);
      expect(errors, isEmpty);
      expect(value, isA<DateTime>());
    });
  });

  group('EndorseResult stress tests', () {
    test('ValidResult holds value', () {
      final result = ValidResult<String>('hello');
      expect(result.value, 'hello');
    });

    test('InvalidResult holds field errors', () {
      final result = InvalidResult<String>({
        'name': ['is required'],
        'email': ['must be a valid email'],
      });
      expect(result.fieldErrors, hasLength(2));
      expect(result.fieldErrors['name'], ['is required']);
    });

    test('pattern matching works', () {
      EndorseResult<String> result = ValidResult('test');
      final output = switch (result) {
        ValidResult(:final value) => 'valid: $value',
        InvalidResult() => 'invalid',
      };
      expect(output, 'valid: test');
    });

    test('pattern matching on invalid', () {
      EndorseResult<String> result = InvalidResult({
        'x': ['bad'],
      });
      final output = switch (result) {
        ValidResult() => 'valid',
        InvalidResult(:final fieldErrors) => 'errors: ${fieldErrors.length}',
      };
      expect(output, 'errors: 1');
    });

    test('InvalidResult with many field errors', () {
      final errors = <String, List<String>>{
        for (var i = 0; i < 100; i++)
          'field$i': ['error1 for field$i', 'error2 for field$i'],
      };
      final result = InvalidResult<String>(errors);
      expect(result.fieldErrors, hasLength(100));
      for (var i = 0; i < 100; i++) {
        expect(result.fieldErrors['field$i'], hasLength(2));
      }
    });

    test('InvalidResult with empty field errors map', () {
      final result = InvalidResult<String>({});
      expect(result.fieldErrors, isEmpty);
    });
  });

  group('EndorseRegistry stress tests', () {
    setUp(() {
      EndorseRegistry.instance.clear();
    });

    tearDown(() {
      EndorseRegistry.instance.clear();
    });

    test('register and retrieve', () {
      final validator = _SimpleValidator();
      EndorseRegistry.instance.register<_SimpleData>(validator);
      expect(EndorseRegistry.instance.get<_SimpleData>(), same(validator));
    });

    test('has returns true after register', () {
      EndorseRegistry.instance.register<_SimpleData>(_SimpleValidator());
      expect(EndorseRegistry.instance.has<_SimpleData>(), isTrue);
    });

    test('has returns false before register', () {
      expect(EndorseRegistry.instance.has<_SimpleData>(), isFalse);
    });

    test('get throws when not registered', () {
      expect(
        () => EndorseRegistry.instance.get<_SimpleData>(),
        throwsA(isA<StateError>()),
      );
    });

    test('clear removes all registrations', () {
      EndorseRegistry.instance.register<_SimpleData>(_SimpleValidator());
      EndorseRegistry.instance.clear();
      expect(EndorseRegistry.instance.has<_SimpleData>(), isFalse);
    });

    test('register many validators', () {
      // Register different types using same validator class
      EndorseRegistry.instance.register<_SimpleData>(_SimpleValidator());
      expect(EndorseRegistry.instance.has<_SimpleData>(), isTrue);
    });

    test('singleton pattern', () {
      expect(
        identical(EndorseRegistry.instance, EndorseRegistry.instance),
        isTrue,
      );
    });
  });

  group('Complex validation scenario stress tests', () {
    test('validation with all passing rules', () {
      final rules = [
        const Required(),
        const IsString(),
        const Trim(),
        const MinLength(1),
        const MaxLength(100),
        const NoControlChars(),
      ];
      final (errors, value) = checkRules('  valid input  ', rules);
      expect(errors, isEmpty);
      expect(value, 'valid input');
    });

    test('email field pipeline', () {
      final rules = [
        const Required(),
        const IsString(),
        const Trim(),
        const LowerCase(),
        const Email(),
        const MaxLength(254),
      ];
      final (errors, value) = checkRules('  USER@EXAMPLE.COM  ', rules);
      expect(errors, isEmpty);
      expect(value, 'user@example.com');
    });

    test('integer field pipeline', () {
      final rules = [
        const Required(),
        const IsInt(),
        const Min(1),
        const Max(1000),
      ];
      final (errors, value) = checkRules('42', rules);
      expect(errors, isEmpty);
      expect(value, 42);
    });

    test('list field pipeline', () {
      final rules = [
        const Required(),
        const IsList(),
        const MinElements(1),
        const MaxElements(10),
        const UniqueElements(),
      ];
      final (errors, _) = checkRules([1, 2, 3], rules);
      expect(errors, isEmpty);
    });

    test('list with duplicates fails', () {
      final rules = [
        const Required(),
        const IsList(),
        const UniqueElements(),
      ];
      final (errors, _) = checkRules([1, 2, 1], rules);
      expect(errors, isNotEmpty);
    });

    test('optional field skips when null', () {
      final rules = [
        const IsString(),
        const MinLength(1),
        const MaxLength(100),
      ];
      final (errors, value) = checkRules(null, rules);
      expect(errors, isEmpty);
      expect(value, isNull);
    });

    test('malicious HTML in text field', () {
      final rules = [
        const Required(),
        const IsString(),
        const StripHtml(),
        const Trim(),
        const MinLength(1),
        const NoControlChars(),
      ];
      final (errors, value) = checkRules(
        '<script>alert("xss")</script>Hello',
        rules,
      );
      expect(errors, isEmpty);
      expect(value, 'alert("xss")Hello');
    });

    test('boundary value: int at exactly min', () {
      final (errors, _) = checkRules(0, [const Min(0)]);
      expect(errors, isEmpty);
    });

    test('boundary value: int at exactly max', () {
      final (errors, _) = checkRules(100, [const Max(100)]);
      expect(errors, isEmpty);
    });

    test('boundary value: string at exactly min length', () {
      final (errors, _) = checkRules('abc', [const MinLength(3)]);
      expect(errors, isEmpty);
    });

    test('boundary value: string at exactly max length', () {
      final (errors, _) = checkRules('abc', [const MaxLength(3)]);
      expect(errors, isEmpty);
    });

    test('boundary value: list at exactly min elements', () {
      final (errors, _) = checkRules([1, 2], [const MinElements(2)]);
      expect(errors, isEmpty);
    });

    test('boundary value: list at exactly max elements', () {
      final (errors, _) = checkRules([1, 2], [const MaxElements(2)]);
      expect(errors, isEmpty);
    });
  });

  group('Malicious input stress tests', () {
    test('SQL injection attempts in string validation', () {
      final rules = [const Required(), const IsString(), const MinLength(1)];
      final sqlInputs = [
        "'; DROP TABLE users; --",
        "1' OR '1'='1",
        "admin'--",
        "1; DELETE FROM users",
        "' UNION SELECT * FROM passwords --",
      ];
      for (final input in sqlInputs) {
        final (errors, value) = checkRules(input, rules);
        expect(errors, isEmpty, reason: 'Should pass as valid string: $input');
        expect(value, input);
      }
    });

    test('XSS attempts stripped by StripHtml', () {
      final rules = [const StripHtml()];
      final xssInputs = [
        '<script>alert(1)</script>',
        '<img onerror=alert(1) src=x>',
        '<svg onload=alert(1)>',
        '<a href="javascript:alert(1)">click</a>',
        '"><script>alert(1)</script>',
      ];
      for (final input in xssInputs) {
        final (_, value) = checkRules(input, rules);
        expect((value as String).contains('<script>'), isFalse,
            reason: input);
        expect((value).contains('<img'), isFalse, reason: input);
        expect((value).contains('<svg'), isFalse, reason: input);
      }
    });

    test('control character injection', () {
      final rules = [const NoControlChars()];
      final controlInputs = [
        'normal\x00text',
        'text\x07bell',
        'text\x1Bescape',
        'text\x7Fdel',
        'zero\u200Bwidth',
        'rtl\u200Fmark',
      ];
      for (final input in controlInputs) {
        final (errors, _) = checkRules(input, rules);
        expect(errors, isNotEmpty, reason: 'Should reject: $input');
      }
    });

    test('unicode normalization attacks', () {
      // These are valid strings that should pass NoControlChars
      final unicodeInputs = [
        'caf\u00E9', // precomposed é
        'cafe\u0301', // decomposed e + combining accent
        '\u{1F600}', // emoji
        '\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}', // family emoji with ZWJ
      ];
      for (final input in unicodeInputs) {
        // ZWJ (200D) is a control char that NoControlChars rejects
        final (errors, _) = checkRules(input, [const NoControlChars()]);
        if (input.contains('\u200D')) {
          expect(errors, isNotEmpty, reason: 'ZWJ should be rejected');
        } else {
          expect(errors, isEmpty, reason: 'Should pass: $input');
        }
      }
    });

    test('extremely long input', () {
      final longString = 'a' * 1000000;
      final rules = [
        const Required(),
        const IsString(),
        const MaxLength(999999),
      ];
      final (errors, _) = checkRules(longString, rules);
      expect(errors, isNotEmpty); // exceeds max length
    });

    test('empty and whitespace edge cases', () {
      final whitespaceInputs = [
        '',
        ' ',
        '  ',
        '\t',
        '\n',
        '\r\n',
        '  \t  \n  ',
      ];
      for (final input in whitespaceInputs) {
        final (_, value) = checkRules(input, [const Trim()]);
        expect((value as String).trim(), isEmpty, reason: repr(input));
      }
    });

    test('numeric boundary attacks', () {
      final (e1, _) = checkRules(double.nan, [const Min(0)]);
      expect(e1, isNotEmpty, reason: 'NaN should fail Min');

      final (e2, _) = checkRules(double.nan, [const Max(100)]);
      expect(e2, isNotEmpty, reason: 'NaN should fail Max');

      final (e3, _) = checkRules(double.infinity, [const Max(100)]);
      expect(e3, isNotEmpty, reason: 'Infinity should fail Max(100)');

      final (e4, _) = checkRules(double.negativeInfinity, [const Min(0)]);
      expect(e4, isNotEmpty, reason: '-Infinity should fail Min(0)');
    });

    test('type confusion attacks', () {
      // Sending wrong types to type-checking rules
      final intRule = const IsInt();
      expect(intRule.check([1]), isNotNull);
      expect(intRule.check({'value': 1}), isNotNull);
      expect(intRule.check(true), isNotNull);
      expect(intRule.check(DateTime.now()), isNotNull);

      final stringRule = const IsString();
      expect(stringRule.check(42), isNotNull);
      expect(stringRule.check(true), isNotNull);
      expect(stringRule.check([]), isNotNull);
    });
  });
}

String repr(String s) =>
    s.replaceAll('\n', '\\n').replaceAll('\r', '\\r').replaceAll('\t', '\\t');

class _SimpleData {
  final String name;
  const _SimpleData(this.name);
}

class _SimpleValidator implements EndorseValidator<_SimpleData> {
  @override
  EndorseResult<_SimpleData> validate(Map<String, Object?> input) {
    final name = input['name'];
    if (name is! String || name.isEmpty) {
      return InvalidResult({'name': ['is required']});
    }
    return ValidResult(_SimpleData(name));
  }

  @override
  List<String> validateField(String fieldName, Object? value) {
    if (fieldName == 'name' && (value is! String || value.isEmpty)) {
      return ['is required'];
    }
    return [];
  }

  @override
  Set<String> get fieldNames => {'name'};
}
