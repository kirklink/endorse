import 'package:test/test.dart';
import 'package:endorse/endorse.dart';
import 'package:endorse/annotations.dart';

void main() {
  // ── ClassResult cross-errors ───────────────────────────────────

  group('ClassResult with cross-errors', () {
    ValueResult makeValid(String name) =>
        (ValidateValue()..isString()).from('value', name);

    ValueResult makeInvalid(String name) =>
        (ValidateValue()..isRequired()).from(null, name);

    test('is valid when no cross-errors and fields valid', () {
      final r = ClassResult({'name': makeValid('name')}, '', null, const []);
      expect(r.$isValid, isTrue);
      expect(r.$crossErrors, isEmpty);
    });

    test('is invalid when cross-errors present', () {
      final crossError =
          ValidationError('CrossField', 'fields conflict', null, '');
      final r =
          ClassResult({'name': makeValid('name')}, '', null, [crossError]);
      expect(r.$isNotValid, isTrue);
    });

    test('cross-errors appear in \$errors', () {
      final crossError =
          ValidationError('CrossField', 'fields conflict', null, '');
      final r =
          ClassResult({'name': makeValid('name')}, '', null, [crossError]);
      expect(r.$errors, contains(crossError));
    });

    test('\$crossErrors getter returns cross-field errors', () {
      final crossError =
          ValidationError('CrossField', 'fields conflict', null, '');
      final r =
          ClassResult({'name': makeValid('name')}, '', null, [crossError]);
      expect(r.$crossErrors, hasLength(1));
      expect(r.$crossErrors[0].rule, 'CrossField');
    });

    test('\$errors includes both field errors and cross-errors', () {
      final crossError = ValidationError('Cross', 'cross error', null, '');
      final r = ClassResult(
          {'name': makeInvalid('name')}, '', null, [crossError]);
      expect(r.$isNotValid, isTrue);
      // Should have both the field error(s) and the cross error
      expect(r.$errors.length, greaterThanOrEqualTo(2));
      expect(r.$errors.any((e) => e.rule == 'Cross'), isTrue);
      // The field error comes from isRequired() failing on null
      expect(r.$errors.any((e) => e.rule != 'Cross'), isTrue);
    });

    test('multiple cross-errors all appear', () {
      final errors = [
        ValidationError('Either', 'need one of email/phone', null, ''),
        ValidationError('DateOrder', 'end must be after start', null, ''),
      ];
      final r = ClassResult({'name': makeValid('name')}, '', null, errors);
      expect(r.$isNotValid, isTrue);
      expect(r.$crossErrors, hasLength(2));
      expect(r.$errors.where((e) => e.rule == 'Either'), hasLength(1));
      expect(r.$errors.where((e) => e.rule == 'DateOrder'), hasLength(1));
    });
  });

  group('ClassResult backwards compatibility', () {
    test('1-arg constructor still works', () {
      final valid =
          (ValidateValue()..isString()).from('hello', 'name');
      final r = ClassResult({'name': valid});
      expect(r.$isValid, isTrue);
      expect(r.$crossErrors, isEmpty);
      expect(r.$fieldName, '');
    });

    test('3-arg constructor still works', () {
      final fieldResult =
          (ValidateValue()..isRequired()).from(null, 'person');
      final r = ClassResult(const {}, 'person', fieldResult);
      expect(r.$isNotValid, isTrue);
      expect(r.$crossErrors, isEmpty);
      expect(r.$fieldName, 'person');
    });

    test('4-arg constructor with empty cross-errors is valid', () {
      final valid =
          (ValidateValue()..isString()).from('hello', 'name');
      final r = ClassResult({'name': valid}, '', null, const []);
      expect(r.$isValid, isTrue);
    });
  });

  // ── When annotation ────────────────────────────────────────────

  group('When annotation', () {
    test('isEqualTo stores value', () {
      const w = When('country', isEqualTo: 'US');
      expect(w.field, 'country');
      expect(w.isEqualTo, 'US');
      expect(w.isNotNull, isFalse);
      expect(w.isOneOf, isNull);
    });

    test('isEqualTo with int value', () {
      const w = When('type', isEqualTo: 1);
      expect(w.field, 'type');
      expect(w.isEqualTo, 1);
    });

    test('isEqualTo with bool value', () {
      const w = When('hasDiscount', isEqualTo: true);
      expect(w.field, 'hasDiscount');
      expect(w.isEqualTo, true);
    });

    test('isNotNull stores true', () {
      const w = When('discount', isNotNull: true);
      expect(w.field, 'discount');
      expect(w.isNotNull, isTrue);
      expect(w.isEqualTo, isNull);
      expect(w.isOneOf, isNull);
    });

    test('isOneOf stores list', () {
      const w = When('status', isOneOf: ['active', 'pending']);
      expect(w.field, 'status');
      expect(w.isOneOf, ['active', 'pending']);
      expect(w.isEqualTo, isNull);
      expect(w.isNotNull, isFalse);
    });
  });

  group('EndorseField with when', () {
    test('when parameter is optional and defaults to null', () {
      const f = EndorseField(validate: [Required()]);
      expect(f.when, isNull);
    });

    test('when parameter accepts When', () {
      const f = EndorseField(
        validate: [Required()],
        when: When('country', isEqualTo: 'US'),
      );
      expect(f.when, isNotNull);
      expect(f.when!.field, 'country');
      expect(f.when!.isEqualTo, 'US');
    });
  });

  group('EndorseEntity with either', () {
    test('either parameter is optional and defaults to empty', () {
      const e = EndorseEntity();
      expect(e.either, isEmpty);
    });

    test('either accepts list of field groups', () {
      const e = EndorseEntity(either: [
        ['email', 'phone']
      ]);
      expect(e.either, hasLength(1));
      expect(e.either[0], ['email', 'phone']);
    });

    test('either accepts multiple groups', () {
      const e = EndorseEntity(either: [
        ['email', 'phone'],
        ['name', 'alias']
      ]);
      expect(e.either, hasLength(2));
      expect(e.either[0], ['email', 'phone']);
      expect(e.either[1], ['name', 'alias']);
    });
  });
}
