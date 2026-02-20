import 'package:endorse/endorse.dart';
import 'package:test/test.dart';

// A minimal validator for testing the registry.
class _TestValidator implements EndorseValidator<String> {
  @override
  Set<String> get fieldNames => const {'value'};

  @override
  EndorseResult<String> validate(Map<String, Object?> input) {
    final value = input['value'];
    if (value is String && value.isNotEmpty) {
      return ValidResult(value);
    }
    return const InvalidResult({
      'value': ['is required'],
    });
  }

  @override
  List<String> validateField(String fieldName, Object? value) {
    if (fieldName != 'value') {
      throw ArgumentError('Unknown field: $fieldName');
    }
    if (value is String && value.isNotEmpty) return [];
    return ['is required'];
  }
}

void main() {
  group('EndorseRegistry', () {
    setUp(() {
      EndorseRegistry.instance.clear();
    });

    test('register and retrieve validator', () {
      EndorseRegistry.instance.register<String>(_TestValidator());
      final validator = EndorseRegistry.instance.get<String>();
      expect(validator, isA<_TestValidator>());
    });

    test('throws on unregistered type', () {
      expect(
        () => EndorseRegistry.instance.get<int>(),
        throwsA(isA<StateError>()),
      );
    });

    test('has returns true for registered type', () {
      EndorseRegistry.instance.register<String>(_TestValidator());
      expect(EndorseRegistry.instance.has<String>(), isTrue);
      expect(EndorseRegistry.instance.has<int>(), isFalse);
    });

    test('clear removes all validators', () {
      EndorseRegistry.instance.register<String>(_TestValidator());
      expect(EndorseRegistry.instance.has<String>(), isTrue);
      EndorseRegistry.instance.clear();
      expect(EndorseRegistry.instance.has<String>(), isFalse);
    });

    test('registered validator works end-to-end', () {
      EndorseRegistry.instance.register<String>(_TestValidator());
      final validator = EndorseRegistry.instance.get<String>();

      final valid = validator.validate({'value': 'hello'});
      expect(valid, isA<ValidResult<String>>());
      expect((valid as ValidResult).value, 'hello');

      final invalid = validator.validate({'value': ''});
      expect(invalid, isA<InvalidResult<String>>());

      // validateField
      expect(validator.validateField('value', 'hello'), isEmpty);
      expect(validator.validateField('value', ''), ['is required']);
    });
  });
}
