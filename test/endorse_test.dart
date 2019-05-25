import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:endorse/endorse.dart';

class MockEndorse extends Mock implements EndorseSchema {}

final input = {
  'test1': 3,
  'test2': 'this is too long',
  'test3': 'sh',
  'test4': '@#',
  'test5': [],
  'test6': {},
  'test8': "4",
  'test9': 'x',
  'test10': 4,
  'test11': null,
  'test12': 1.123,
  'test13': "1.123"
};

void main() {
  group('number input', () {
    test('Endorse finds no error with an expected number.', () async {
      var e = EndorseSchema();
      e.field('test1').number();
      var r = await e.validate(input);
      expect(r.errorMessages(), equals({}));
    });
    test('Endorse finds an error when an expected string is a number.',
        () async {
      var e = EndorseSchema();
      e.field('test1').string();
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test1': ['Must be a string.']
          }));
    });
    test('Endorse finds no error within a minumum and maximum number bounds.',
        () async {
      var e = EndorseSchema();
      e.field('test1').number().min(3).max(3);
      var r = await e.validate(input);
      expect(r.errorMessages(), equals({}));
    });
    test('Endorse finds an error outside of minimum and maximum number bounds.',
        () async {
      var e = EndorseSchema();
      e.field('test1').number().max(2).min(4);
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test1': ['Max is 2.', 'Min is 4.']
          }));
    });
    test('Endorse finds no error when a required number is provided.',
        () async {
      var e = EndorseSchema();
      e.field('test1').number().required();
      var r = await e.validate(input);
      expect(r.errorMessages(), equals({}));
    });
    test('Endorse finds no error when an expected equal number is provided.',
        () async {
      var e = EndorseSchema();
      e.field('test1').number().isEqualTo(3);
      var r = await e.validate(input);
      expect(r.errorMessages(), equals({}));
    });
    test('Endorse finds no error when an expected inequal number is provided.',
        () async {
      var e = EndorseSchema();
      e.field('test1').number().isNotEqualTo(10);
      var r = await e.validate(input);
      expect(r.errorMessages(), equals({}));
    });
    test(
        'Endorse finds an error when a number input is not equal to the expected value.',
        () async {
      var e = EndorseSchema();
      e.field('test1').number().isEqualTo(10);
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test1': ['Must equal 10.']
          }));
    });
    test(
        'Endorse finds an error when a number input is equal to a value, but shouldn\'t be.',
        () async {
      var e = EndorseSchema();
      e.field('test1').number().isNotEqualTo(3);
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test1': ['Must not equal 3.']
          }));
    });
    test('Endorse allows a custom error message for max.', () async {
      var e = EndorseSchema();
      e.field('test1').number().max(0, msg: 'Error!');
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test1': ['Error!']
          }));
    });
    test('Endorse finds no error for a float value.', () async {
      var e = EndorseSchema();
      e.field('test12').number();
      var r = await e.validate(input);
      expect(r.errorMessages(), equals({}));
    });
    test('Endorse finds various errors with float values.', () async {
      var e = EndorseSchema();
      e.field('test12').number().max(1).min(2).isEqualTo(1).isNotEqualTo(1.123);
      var r = await e.validate(input);
      expect(r.errorMessages()['test12'].length, equals(4));
    });
    test('Endorse can identify an integer.', () async {
      var e = EndorseSchema();
      e.field('test1').integer();
      var r = await e.validate(input);
      expect(r.errorMessages(), equals({}));
    });
    test('Endorse can identify a double.', () async {
      var e = EndorseSchema();
      e.field('test12').float();
      var r = await e.validate(input);
      expect(r.errorMessages(), equals({}));
    });
    test('Endorse finds an error if an int is provided but float is expected.',
        () async {
      var e = EndorseSchema();
      e.field('test1').float();
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test1': ['Must be a float.']
          }));
    });
    test(
        'Endorse finds an error if a float is provided but an int is expected.',
        () async {
      var e = EndorseSchema();
      e.field('test12').integer();
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test12': ['Must be an integer.']
          }));
    });
    test('Endorse finds an error if a [] is provided but a number is expected.',
        () async {
      var e = EndorseSchema();
      e.field('test5').number();
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test5': ['Must be a number.']
          }));
    });
    test('Endorse finds an error if a {} is provided but a number is expected.',
        () async {
      var e = EndorseSchema();
      e.field('test6').number();
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test6': ['Must be a number.']
          }));
    });
    test(
        'Endorse finds an error if a null is provided but a number is expected.',
        () async {
      var e = EndorseSchema();
      e.field('test11').number();
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test11': ['Must be a number.']
          }));
    });
  });

  group('string input', () {
    test('Endorse finds no error with an expected string.', () async {
      var e = EndorseSchema();
      e.field('test2').string();
      var r = await e.validate(input);
      expect(r.errorMessages(), equals({}));
    });
    test('Endorse finds an error when an expected string is a number.',
        () async {
      var e = EndorseSchema();
      e.field('test1').string();
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test1': ['Must be a string.']
          }));
    });
    test(
        'Endorse finds no error within a minumum and maximum string length bounds.',
        () async {
      var e = EndorseSchema();
      e.field('test2').string().min(3).max(20);
      var r = await e.validate(input);
      expect(r.errorMessages(), equals({}));
    });
    test(
        'Endorse finds an error outside of minimum and maximum string length bounds.',
        () async {
      var e = EndorseSchema();
      e.field('test2').string().max(2).min(50);
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test2': ['Max length is 2.', 'Min length is 50.']
          }));
    });
    test('Endorse finds no error when a required number is provided.',
        () async {
      var e = EndorseSchema();
      e.field('test3').string().required();
      var r = await e.validate(input);
      expect(r.errorMessages(), equals({}));
    });
    test('Endorse finds no error when a string matches a provided pattern.',
        () async {
      var e = EndorseSchema();
      e.field('test2').string().matches(Patterns.alphaSentence);
      var r = await e.validate(input);
      expect(r.errorMessages(), equals({}));
    });
    test(
        'Endorse finds an error when an string does not match a provided pattern.',
        () async {
      var e = EndorseSchema();
      e.field('test4').string().matches(Patterns.alphaWord);
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test4': ['Does not match pattern.']
          }));
    });
    test(
        'Endorse finds no error when a string provided can be converted to a number.',
        () async {
      var e = EndorseSchema();
      e.field('test8').stringIsNum();
      var r = await e.validate(input);
      expect(r.errorMessages(), equals({}));
    });
    test(
        'Endorse finds an error when a string provided cannot be converted to a number.',
        () async {
      var e = EndorseSchema();
      e.field('test2').stringIsNum();
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test2': ['Cannot cast to number.']
          }));
    });

    test('Endorse allows a custom error message for max.', () async {
      var e = EndorseSchema();
      e.field('test3').string().max(0, msg: 'Error!');
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test3': ['Error!']
          }));
    });
    test('Endorse finds no error for a float value.', () async {
      var e = EndorseSchema();
      e.field('test12').number();
      var r = await e.validate(input);
      expect(r.errorMessages(), equals({}));
    });
    test('Endorse finds various errors with string values.', () async {
      var e = EndorseSchema();
      e.field('test3').string().max(1).min(50).matches(Patterns.integer);
      var r = await e.validate(input);
      expect(r.errorMessages()['test3'].length, equals(3));
    });
    test('Endorse can identify a string integer.', () async {
      var e = EndorseSchema();
      e.field('test8').stringIsNum().integer();
      var r = await e.validate(input);
      expect(r.errorMessages(), equals({}));
    });
    test('Endorse can identify a string double.', () async {
      var e = EndorseSchema();
      e.field('test13').stringIsNum().float();
      var r = await e.validate(input);
      expect(r.errorMessages(), equals({}));
    });
    test(
        'Endorse finds an error if an string int is provided but float is expected.',
        () async {
      var e = EndorseSchema();
      e.field('test8').stringIsNum().float();
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test8': ['Must be a float.']
          }));
    });
    test(
        'Endorse finds an error if a string float is provided but an int is expected.',
        () async {
      var e = EndorseSchema();
      e.field('test13').stringIsNum().integer();
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test13': ['Must be an integer.']
          }));
    });
    test('Endorse finds an error if a [] is provided but a number is expected.',
        () async {
      var e = EndorseSchema();
      e.field('test5').string();
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test5': ['Must be a string.']
          }));
    });
    test('Endorse finds an error if a {} is provided but a number is expected.',
        () async {
      var e = EndorseSchema();
      e.field('test6').string();
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test6': ['Must be a string.']
          }));
    });
    test(
        'Endorse finds an error if a null is provided but a number is expected.',
        () async {
      var e = EndorseSchema();
      e.field('test11').string();
      var r = await e.validate(input);
      expect(
          r.errorMessages(),
          equals({
            'test11': ['Must be a string.']
          }));
    });
  });
}
