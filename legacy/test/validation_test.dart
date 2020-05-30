import 'package:test/test.dart';

import 'package:endorse/src/rule_set.dart';
import 'package:endorse/src/validation.dart';
import 'package:endorse/src/value.dart';
import 'package:endorse/src/endorse.dart';

main() {
  group('Validation', () {
    test('Validation.valid is true when an input value validates.', () async {
      var i = {'test': 1};
      var e = EndorseSchema();
      e.field('test').integer().isEqualTo(1);
      var validation = await ValidationSchema.validate(e, i);
      expect(validation.isValid, isTrue);
    });
    test('Validation.valid is false when an input value does not validate.',
        () async {
      var i = {'test': 1};
      var e = EndorseSchema();
      e.field('test').integer().isEqualTo(2);
      var validation = await ValidationSchema.validate(e, i);
      expect(validation.isValid, isFalse);
    });
    test(
        'Validation.source provides the original values if the validation is valid.',
        () async {
      var i = {'test': 1};
      var e = EndorseSchema();
      e.field('test').integer().isEqualTo(1);
      var validation = await ValidationSchema.validate(e, i);
      expect(validation.values(), equals(i));
    });
    test('Validation.source provides null if the validation failed.', () async {
      var i = {'test': 1};
      var e = EndorseSchema();
      e.field('test').integer().isEqualTo(2);
      var validation = await ValidationSchema.validate(e, i);
      expect(validation.values(), isNull);
    });
    test(
        'Validation.source provides the original values if the validation failed but the unsafe parameter is true.',
        () async {
      var i = {'test': 1};
      var e = EndorseSchema();
      e.field('test').integer().isEqualTo(1);
      var validation = await ValidationSchema.validate(e, i);
      expect(validation.values(unsafe: true), equals(i));
    });
    test(
        'Validation.errorMessages returns an empty list when the input validates.',
        () async {
      var i = {'test': 1};
      var e = EndorseSchema();
      e.field('test').integer().isEqualTo(1);
      var validation = await ValidationSchema.validate(e, i);
      expect(validation.errorMessages(), isEmpty);
    });
    test(
        'Validation.errorMessages provides error messages when an input is invalid.',
        () async {
      var i = {'test': 1};
      var e = EndorseSchema();
      e.field('test').integer().isEqualTo(2);
      var validation = await ValidationSchema.validate(e, i);
      expect(validation.errorMessages(), isNotEmpty);
    });
    test('Validation.errorMaps returns an empty map when the input validates.',
        () async {
      var i = {'test': 1};
      var e = EndorseSchema();
      e.field('test').integer().isEqualTo(1);
      var validation = await ValidationSchema.validate(e, i);
      expect(validation.errorMessages(), isEmpty);
    });
    test(
        'Validation.errorMaps provides error messages when an input is invalid.',
        () async {
      var i = {'test': 1};
      var e = EndorseSchema();
      e.field('test').integer().isEqualTo(2);
      var validation = await ValidationSchema.validate(e, i);
      expect(
          validation.errorMap(),
          equals({
            'test': {
              'isEqualTo': {'test': 2, 'got': 1}
            }
          }));
    });
  });

  group('ValidationValue', () {
    test('ValidationValue.valid is true when an input value validates.',
        () async {
      int v = 1;
      var value = Value(v);
      var s = NumRuleSet();
      s.isEqualTo(1);
      await value.validate(s);
      var validation = ValidationValue(value);
      expect(validation.isValid, isTrue);
    });
    test(
        'ValidationValue.valid is false when an input value does not validate.',
        () async {
      int v = 1;
      var value = Value(v);
      var s = NumRuleSet();
      s.isEqualTo(2);
      await value.validate(s);
      var validation = ValidationValue(value);
      expect(validation.isValid, isFalse);
    });
    test(
        'ValidationValue.source provides the original values if the validation is valid.',
        () async {
      int v = 1;
      var value = Value(v);
      var s = NumRuleSet();
      s.isEqualTo(1);
      await value.validate(s);
      var validation = ValidationValue(value);
      expect(validation.values(), equals(v));
    });
    test('ValidationValue.source provides null if the validation failed.',
        () async {
      int v = 1;
      var value = Value(v);
      var s = NumRuleSet();
      s.isEqualTo(2);
      await value.validate(s);
      var validation = ValidationValue(value);
      expect(validation.values(), isNull);
    });
    test(
        'ValidationValue.source provides the original values if the validation failed but the unsafe parameter is true.',
        () async {
      int v = 1;
      var value = Value(v);
      var s = NumRuleSet();
      s.isEqualTo(2);
      await value.validate(s);
      var validation = ValidationValue(value);
      expect(validation.values(unsafe: true), equals(v));
    });
    test(
        'ValidationValue.errorMessages returns an empty list when the input validates.',
        () async {
      int v = 1;
      var value = Value(v);
      var s = NumRuleSet();
      s.isEqualTo(1);
      await value.validate(s);
      var validation = ValidationValue(value);
      expect(validation.errorMessages(), isEmpty);
    });
    test(
        'ValidationValue.errorMessages provides error messages when an input is invalid.',
        () async {
      int v = 1;
      var value = Value(v);
      var s = NumRuleSet();
      s.isEqualTo(2);
      await value.validate(s);
      var validation = ValidationValue(value);
      expect(validation.errorMessages(), isNotEmpty);
    });
    test(
        'ValidationValue.errorMaps returns an empty map when the input validates.',
        () async {
      int v = 1;
      var value = Value(v);
      var s = NumRuleSet();
      s.isEqualTo(1);
      await value.validate(s);
      var validation = ValidationValue(value);
      expect(validation.errorMessages(), isEmpty);
    });
    test(
        'ValidationValue.errorMaps provides error messages when an input is invalid.',
        () async {
      int v = 1;
      var value = Value(v);
      var s = NumRuleSet();
      s.isEqualTo(2, expand: {'test': false});
      await value.validate(s);
      var validation = ValidationValue(value);
      expect(validation.errorMap(), equals({'test': false}));
    });
  });
}
