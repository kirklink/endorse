import 'package:test/test.dart';
import 'package:endorse/src/endorse/validate_value.dart';
import 'package:endorse/src/endorse/rule_holder.dart';

void main() {
  group('Basic Validation - Structure', () {
    test('ValidateValue can be instantiated', () {
      final validator = ValidateValue();
      expect(validator, isNotNull);
      expect(validator.rules, isEmpty);
    });

    test('ValidateValue can add rules', () {
      final validator = ValidateValue();
      validator.isRequired();
      expect(validator.rules, hasLength(1));
      expect(validator.rules.first, isA<RuleHolder>());
    });

    test('ValidateValue can add multiple rules', () {
      final validator = ValidateValue();
      validator.isRequired();
      validator.isString();
      validator.maxLength(10);
      expect(validator.rules, hasLength(3));
    });
  });

  group('Basic Validation - Execution', () {
    test('Can call from() method on validator', () {
      final validator = ValidateValue();
      validator.isRequired();

      // This will test if the validation pipeline actually works
      expect(
        () => validator.from('test', 'fieldName'),
        returnsNormally,
      );
    });

    test('from() returns a result object', () {
      final validator = ValidateValue();
      validator.isRequired();

      final result = validator.from('test', 'fieldName');
      expect(result, isNotNull);
    });

    test('Multiple rules can be executed', () {
      final validator = ValidateValue();
      validator.isRequired();
      validator.isString();
      validator.maxLength(10);

      expect(
        () => validator.from('test', 'fieldName'),
        returnsNormally,
      );
    });
  });

  group('Validation Rules API', () {
    test('isRequired method exists', () {
      final validator = ValidateValue();
      expect(() => validator.isRequired(), returnsNormally);
    });

    test('isString method exists', () {
      final validator = ValidateValue();
      expect(() => validator.isString(), returnsNormally);
    });

    test('maxLength method exists', () {
      final validator = ValidateValue();
      expect(() => validator.maxLength(10), returnsNormally);
    });

    test('minLength method exists', () {
      final validator = ValidateValue();
      expect(() => validator.minLength(5), returnsNormally);
    });

    test('isInt method exists', () {
      final validator = ValidateValue();
      expect(() => validator.isInt(), returnsNormally);
    });

    test('isBoolean method exists', () {
      final validator = ValidateValue();
      expect(() => validator.isBoolean(), returnsNormally);
    });
  });
}
