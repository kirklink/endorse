import 'package:endorse/endorse.dart';
import 'package:test/test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Sanitize (strip all HTML)
  // ---------------------------------------------------------------------------
  group('Sanitize()', () {
    const rule = Sanitize();

    test('is a transform — never fails', () {
      expect(rule.check(null), isNull);
      expect(rule.check('hello'), isNull);
      expect(rule.check('<script>alert(1)</script>'), isNull);
    });

    test('passes non-string values through', () {
      expect(rule.coerce(null), isNull);
      expect(rule.coerce(42), 42);
      expect(rule.coerce(true), true);
    });

    test('strips all HTML tags from plain text', () {
      expect(rule.coerce('hello <b>world</b>'), 'hello world');
    });

    test('strips script tags and content', () {
      expect(rule.coerce('before<script>alert(1)</script>after'),
          'beforeafter');
    });

    test('strips style tags and content', () {
      expect(rule.coerce('text<style>body{color:red}</style>more'),
          'textmore');
    });

    test('strips iframe tags and content', () {
      expect(rule.coerce('a<iframe src="evil.com">x</iframe>b'), 'ab');
    });

    test('returns empty string when input is only tags', () {
      expect(rule.coerce('<div><p></p></div>'), '');
    });

    test('preserves plain text without HTML', () {
      expect(rule.coerce('just plain text'), 'just plain text');
    });

    test('escapes angle brackets in attribute values', () {
      // Disinfect with empty whitelist strips everything
      final result = rule.coerce('<img src="x" onerror="alert(1)">');
      expect(result, isA<String>());
      expect(result as String, isNot(contains('<img')));
      expect(result, isNot(contains('onerror')));
    });

    test('works in a rule chain', () {
      final (errors, value) = checkRules(
        'hello <b>world</b>',
        const [IsString(), Sanitize(), MinLength(5)],
      );
      expect(errors, isEmpty);
      expect(value, 'hello world');
    });

    test('chain: sanitize then length check on stripped value', () {
      final (errors, value) = checkRules(
        '<b>hi</b>',
        const [IsString(), Sanitize(), MinLength(5)],
      );
      expect(errors, ['must be at least 5 characters']);
      expect(value, 'hi');
    });
  });

  // ---------------------------------------------------------------------------
  // Sanitize.rich (allow safe HTML subset)
  // ---------------------------------------------------------------------------
  group('Sanitize.rich()', () {
    const rule = Sanitize.rich();

    test('is a transform — never fails', () {
      expect(rule.check(null), isNull);
      expect(rule.check('hello'), isNull);
    });

    test('passes non-string values through', () {
      expect(rule.coerce(null), isNull);
      expect(rule.coerce(42), 42);
    });

    test('allows safe tags like p, b, i, a', () {
      final result = rule.coerce('<p>Hello <b>world</b></p>') as String;
      expect(result, contains('<p>'));
      expect(result, contains('<b>'));
      expect(result, contains('</b>'));
      expect(result, contains('</p>'));
    });

    test('allows links with safe href', () {
      final result =
          rule.coerce('<a href="https://example.com">link</a>') as String;
      expect(result, contains('<a'));
      expect(result, contains('href'));
      expect(result, contains('link</a>'));
    });

    test('strips script tags and content', () {
      final result =
          rule.coerce('text<script>alert(1)</script>more') as String;
      expect(result, isNot(contains('<script')));
      expect(result, isNot(contains('alert')));
      expect(result, contains('text'));
      expect(result, contains('more'));
    });

    test('strips style tags and content', () {
      final result =
          rule.coerce('text<style>body{color:red}</style>more') as String;
      expect(result, isNot(contains('<style')));
      expect(result, isNot(contains('color:red')));
    });

    test('strips iframe tags and content', () {
      final result =
          rule.coerce('a<iframe src="evil.com">x</iframe>b') as String;
      expect(result, isNot(contains('<iframe')));
      expect(result, isNot(contains('evil.com')));
    });

    test('strips dangerous attributes like onerror', () {
      final result = rule.coerce('<img src="x" onerror="alert(1)">') as String;
      expect(result, isNot(contains('onerror')));
    });

    test('preserves plain text', () {
      expect(rule.coerce('just text'), 'just text');
    });

    test('allowHtml field is true', () {
      expect(rule.allowHtml, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Constructor defaults
  // ---------------------------------------------------------------------------
  group('constructor', () {
    test('default constructor has allowHtml = false', () {
      expect(const Sanitize().allowHtml, isFalse);
    });

    test('rich constructor has allowHtml = true', () {
      expect(const Sanitize.rich().allowHtml, isTrue);
    });
  });
}
