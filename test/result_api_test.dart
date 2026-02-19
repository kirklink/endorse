import 'package:test/test.dart';
import 'package:endorse/endorse.dart';

void main() {
  // ── Helpers ───────────────────────────────────────────────────────

  ValueResult validValue(String name, [Object? value = 'ok']) =>
      ValueResult(name, value, const []);

  ValueResult invalidValue(String name) =>
      (ValidateValue()..isRequired()).from(null, name);

  // ── ValueResult.$errorsJson ──────────────────────────────────────

  group('ValueResult.\$errorsJson', () {
    test('returns empty list when valid', () {
      final r = validValue('name');
      expect(r.$errorsJson, isList);
      expect(r.$errorsJson as List, isEmpty);
    });

    test('returns list of error maps when invalid', () {
      final r = invalidValue('name');
      final json = r.$errorsJson as List;
      expect(json, hasLength(1));
      expect(json[0], isA<Map>());
      // Each error is keyed by rule name
      final error = json[0] as Map;
      expect(error.keys.first, isA<String>());
    });

    test('error map contains message and got', () {
      final r = invalidValue('name');
      final json = r.$errorsJson as List;
      final error = json[0] as Map;
      final details = error.values.first as Map;
      expect(details, containsPair('message', isA<String>()));
      expect(details, containsPair('got', isA<String>()));
    });
  });

  // ── ClassResult.$errorsJson ──────────────────────────────────────

  group('ClassResult.\$errorsJson', () {
    test('returns empty map when all fields valid', () {
      final r = ClassResult({
        'name': validValue('name'),
        'age': validValue('age', 25),
      });
      final json = r.$errorsJson as Map;
      expect(json, isEmpty);
    });

    test('includes only invalid fields', () {
      final r = ClassResult({
        'name': invalidValue('name'),
        'age': validValue('age', 25),
      });
      final json = r.$errorsJson as Map;
      expect(json, hasLength(1));
      expect(json.containsKey('name'), isTrue);
      expect(json.containsKey('age'), isFalse);
    });

    test('field errors are lists of error maps', () {
      final r = ClassResult({
        'name': invalidValue('name'),
      });
      final json = r.$errorsJson as Map;
      final nameErrors = json['name'] as List;
      expect(nameErrors, hasLength(1));
      expect(nameErrors[0], isA<Map>());
    });

    test('includes cross-errors under _cross key', () {
      final crossError =
          ValidationError('CrossField', 'fields conflict', null, '');
      final r = ClassResult(
          {'name': validValue('name')}, '', null, [crossError]);
      final json = r.$errorsJson as Map;
      expect(json.containsKey('_cross'), isTrue);
      final crossErrors = json['_cross'] as List;
      expect(crossErrors, hasLength(1));
      expect(crossErrors[0], isA<Map>());
      expect((crossErrors[0] as Map).containsKey('CrossField'), isTrue);
    });

    test('no _cross key when no cross-errors', () {
      final r = ClassResult({
        'name': invalidValue('name'),
      });
      final json = r.$errorsJson as Map;
      expect(json.containsKey('_cross'), isFalse);
    });

    test('includes _self when field-level result is invalid', () {
      final fieldResult = invalidValue('person');
      final r = ClassResult(const {}, 'person', fieldResult);
      final json = r.$errorsJson as Map;
      expect(json.containsKey('_self'), isTrue);
      expect(json['_self'], isList);
    });

    test('handles nested ClassResult', () {
      final address = ClassResult({
        'street': invalidValue('street'),
        'city': validValue('city'),
      });
      final r = ClassResult({
        'name': validValue('name'),
        'address': address,
      });
      final json = r.$errorsJson as Map;
      expect(json, hasLength(1));
      expect(json.containsKey('address'), isTrue);
      final addressJson = json['address'] as Map;
      expect(addressJson.containsKey('street'), isTrue);
      expect(addressJson.containsKey('city'), isFalse);
    });

    test('handles multiple invalid fields', () {
      final r = ClassResult({
        'name': invalidValue('name'),
        'age': invalidValue('age'),
        'email': validValue('email'),
      });
      final json = r.$errorsJson as Map;
      expect(json, hasLength(2));
      expect(json.containsKey('name'), isTrue);
      expect(json.containsKey('age'), isTrue);
    });

    test('combined field errors and cross-errors', () {
      final crossError =
          ValidationError('Either', 'need email or phone', null, '');
      final r = ClassResult(
          {'name': invalidValue('name')}, '', null, [crossError]);
      final json = r.$errorsJson as Map;
      expect(json, hasLength(2));
      expect(json.containsKey('name'), isTrue);
      expect(json.containsKey('_cross'), isTrue);
    });
  });

  // ── ListResult.$errorsJson ───────────────────────────────────────

  group('ListResult.\$errorsJson', () {
    test('returns empty map when valid', () {
      final listField = (ValidateValue()..isList()).from([1, 2, 3], 'items');
      final elements = [
        validValue('0', 1),
        validValue('1', 2),
        validValue('2', 3),
      ];
      final r = ListResult('items', listField, elements);
      final json = r.$errorsJson as Map;
      expect(json, isEmpty);
    });

    test('includes _self when list-level validation fails', () {
      final listField =
          (ValidateValue()..isRequired()).from(null, 'items');
      final r = ListResult('items', listField, const []);
      final json = r.$errorsJson as Map;
      expect(json.containsKey('_self'), isTrue);
      expect(json['_self'], isList);
    });

    test('includes element errors at correct indices', () {
      final listField = (ValidateValue()..isList()).from(['a', '', 'c'], 'items');
      final elements = [
        validValue('0', 'a'),
        invalidValue('1'),
        validValue('2', 'c'),
      ];
      final r = ListResult('items', listField, elements);
      final json = r.$errorsJson as Map;
      expect(json.containsKey('0'), isFalse);
      expect(json.containsKey('1'), isTrue);
      expect(json.containsKey('2'), isFalse);
    });

    test('multiple invalid elements', () {
      final listField = (ValidateValue()..isList()).from([null, null], 'items');
      final elements = [
        invalidValue('0'),
        invalidValue('1'),
      ];
      final r = ListResult('items', listField, elements);
      final json = r.$errorsJson as Map;
      expect(json.containsKey('0'), isTrue);
      expect(json.containsKey('1'), isTrue);
    });
  });

  // ── ClassResult with nested ListResult ───────────────────────────

  group('ClassResult with nested ListResult', () {
    test('errorsJson includes nested list errors', () {
      final listField = (ValidateValue()..isList()).from(['a', ''], 'tags');
      final elements = [
        validValue('0', 'a'),
        invalidValue('1'),
      ];
      final tags = ListResult('tags', listField, elements);
      final r = ClassResult({
        'name': validValue('name'),
        'tags': tags,
      });
      final json = r.$errorsJson as Map;
      expect(json, hasLength(1));
      expect(json.containsKey('tags'), isTrue);
      final tagsJson = json['tags'] as Map;
      expect(tagsJson.containsKey('1'), isTrue);
    });
  });
}
