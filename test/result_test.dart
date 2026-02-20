import 'package:endorse/endorse.dart';
import 'package:test/test.dart';

void main() {
  group('EndorseResult', () {
    test('ValidResult holds value', () {
      const result = ValidResult<String>('hello');
      expect(result.value, 'hello');
    });

    test('InvalidResult holds field errors', () {
      const result = InvalidResult<String>({
        'name': ['is required'],
        'age': ['must be at least 0'],
      });
      expect(result.fieldErrors, hasLength(2));
      expect(result.fieldErrors['name'], ['is required']);
    });

    test('pattern matching works', () {
      EndorseResult<String> result = const ValidResult('hello');

      final output = switch (result) {
        ValidResult(:final value) => 'valid: $value',
        InvalidResult(:final fieldErrors) => 'invalid: $fieldErrors',
      };
      expect(output, 'valid: hello');

      result = const InvalidResult({'name': ['is required']});
      final output2 = switch (result) {
        ValidResult(:final value) => 'valid: $value',
        InvalidResult(:final fieldErrors) =>
          'invalid: ${fieldErrors.length} errors',
      };
      expect(output2, 'invalid: 1 errors');
    });

    test('toString is readable', () {
      expect(
        const ValidResult<String>('hello').toString(),
        'ValidResult(hello)',
      );
      expect(
        const InvalidResult<String>({
          'name': ['is required']
        }).toString(),
        contains('InvalidResult'),
      );
    });
  });
}
