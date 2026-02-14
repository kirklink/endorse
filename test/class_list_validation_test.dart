import 'package:test/test.dart';
import 'package:endorse/endorse.dart';

/// A simple test validator that validates a map with 'name' (required string)
/// and 'age' (required int > 0).
class _TestPersonValidator implements EndorseClassValidator {
  @override
  ClassResult validate(Map<String, Object?> input) {
    final nameVal = ValidateValue()
      ..isRequired()
      ..isString()
      ..maxLength(50);
    final ageVal = ValidateValue()
      ..isRequired()
      ..isInt()
      ..isGreaterThan(0);

    final results = <String, ResultObject>{
      'name': nameVal.from(input['name'], 'name'),
      'age': ageVal.from(input['age'], 'age'),
    };
    return ClassResult(results);
  }
}

void main() {
  // ── ClassResult ───────────────────────────────────────────────────

  group('ClassResult', () {
    test('is valid when all elements are valid', () {
      final nameResult = (ValidateValue()..isRequired()).from('Kirk', 'name');
      final ageResult = (ValidateValue()..isRequired()).from(30, 'age');
      final result = ClassResult({'name': nameResult, 'age': ageResult});
      expect(result.$isValid, isTrue);
      expect(result.$errors, isEmpty);
    });

    test('is invalid when an element fails', () {
      final nameResult = (ValidateValue()..isRequired()).from(null, 'name');
      final ageResult = (ValidateValue()..isRequired()).from(30, 'age');
      final result = ClassResult({'name': nameResult, 'age': ageResult});
      expect(result.$isNotValid, isTrue);
      expect(result.$errors, hasLength(1));
    });

    test('collects errors from multiple elements', () {
      final nameResult = (ValidateValue()..isRequired()).from(null, 'name');
      final ageResult = (ValidateValue()..isRequired()).from(null, 'age');
      final result = ClassResult({'name': nameResult, 'age': ageResult});
      expect(result.$errors, hasLength(2));
    });

    test('with field-level error is invalid even with no elements', () {
      final fieldResult =
          (ValidateValue()..isRequired()).from(null, 'person');
      final result = ClassResult(const {}, 'person', fieldResult);
      expect(result.$isNotValid, isTrue);
      expect(result.$errors, hasLength(1));
    });

    test('\$value throws UnsupportedError', () {
      final result = ClassResult(const {});
      expect(() => result.$value, throwsUnsupportedError);
    });

    test('\$fieldName returns the field name', () {
      final result = ClassResult(const {}, 'myField');
      expect(result.$fieldName, 'myField');
    });
  });

  // ── ValidateClass ─────────────────────────────────────────────────

  group('ValidateClass', () {
    late ValidateClass validateClass;

    setUp(() {
      final fieldRules = ValidateValue()
        ..isRequired()
        ..isMap();
      validateClass = ValidateClass(fieldRules, _TestPersonValidator());
    });

    test('validates a valid map', () {
      final result = validateClass.from(
        {'name': 'Kirk', 'age': 30},
        'person',
      );
      expect(result.$isValid, isTrue);
    });

    test('fails when input is null', () {
      final result = validateClass.from(null, 'person');
      expect(result.$isNotValid, isTrue);
    });

    test('fails when input is not a map', () {
      final result = validateClass.from('not a map', 'person');
      expect(result.$isNotValid, isTrue);
    });

    test('fails when nested field validation fails', () {
      final result = validateClass.from(
        {'name': null, 'age': 30},
        'person',
      );
      expect(result.$isNotValid, isTrue);
    });

    test('returns errors from nested fields', () {
      final result = validateClass.from(
        {'name': null, 'age': -1},
        'person',
      );
      expect(result.$isNotValid, isTrue);
      // name required fails (bail), age > 0 fails
      expect(result.$errors.length, greaterThanOrEqualTo(2));
    });
  });

  // ── ListResult ────────────────────────────────────────────────────

  group('ListResult', () {
    test('is valid when field and all elements valid', () {
      final fieldResult = (ValidateValue()..isRequired()).from([1, 2], 'ids');
      final elem1 = (ValidateValue()..isInt()).from(1, '[0]');
      final elem2 = (ValidateValue()..isInt()).from(2, '[1]');
      final result = ListResult('ids', fieldResult, [elem1, elem2]);
      expect(result.$isValid, isTrue);
      expect(result.$errors, isEmpty);
    });

    test('is invalid when field-level fails', () {
      final fieldResult =
          (ValidateValue()..isRequired()).from(null, 'ids');
      final result = ListResult('ids', fieldResult, const []);
      expect(result.$isNotValid, isTrue);
    });

    test('is invalid when an element fails', () {
      final fieldResult =
          (ValidateValue()..isRequired()).from([1, 'x'], 'ids');
      final elem1 = (ValidateValue()..isInt()).from(1, '[0]');
      final elem2 = (ValidateValue()..isInt()).from('x', '[1]');
      final result = ListResult('ids', fieldResult, [elem1, elem2]);
      expect(result.$isNotValid, isTrue);
      expect(result.$hasElementErrors, isTrue);
    });

    test('\$errors includes ElementErrors summary', () {
      final fieldResult =
          (ValidateValue()..isRequired()).from([1, 'x'], 'ids');
      final elem1 = (ValidateValue()..isInt()).from(1, '[0]');
      final elem2 = (ValidateValue()..isInt()).from('x', '[1]');
      final result = ListResult('ids', fieldResult, [elem1, elem2]);
      final errorNames = result.$errors.map((e) => e.rule).toList();
      expect(errorNames, contains('ElementErrors'));
    });

    test('\$value returns list of element values', () {
      final fieldResult = (ValidateValue()..isRequired()).from([1, 2], 'ids');
      final elem1 = (ValidateValue()..isInt()).from(1, '[0]');
      final elem2 = (ValidateValue()..isInt()).from(2, '[1]');
      final result = ListResult('ids', fieldResult, [elem1, elem2]);
      expect(result.$value, [1, 2]);
    });

    test('\$elements exposes the element results', () {
      final fieldResult = (ValidateValue()..isRequired()).from([1], 'ids');
      final elem1 = (ValidateValue()..isInt()).from(1, '[0]');
      final result = ListResult('ids', fieldResult, [elem1]);
      expect(result.$elements, hasLength(1));
    });
  });

  // ── ValidateList ──────────────────────────────────────────────────

  group('ValidateList (primitive items)', () {
    late ValidateList validateList;

    setUp(() {
      final fieldRules = ValidateValue()
        ..isRequired()
        ..isList();
      final itemRules = ValidateValue()
        ..isRequired()
        ..isInt()
        ..isGreaterThan(0);
      validateList = ValidateList.fromCore(fieldRules, itemRules);
    });

    test('validates a valid list of ints', () {
      final result = validateList.from([1, 2, 3], 'ids');
      expect(result.$isValid, isTrue);
    });

    test('fails when input is null', () {
      final result = validateList.from(null, 'ids');
      expect(result.$isNotValid, isTrue);
    });

    test('fails when input is not a list', () {
      final result = validateList.from('not a list', 'ids');
      expect(result.$isNotValid, isTrue);
    });

    test('fails when an item is invalid', () {
      final result = validateList.from([1, -5, 3], 'ids');
      expect(result.$isNotValid, isTrue);
      expect(result.$hasElementErrors, isTrue);
    });

    test('validates each item independently', () {
      final result = validateList.from([1, null, 'x'], 'ids');
      expect(result.$isNotValid, isTrue);
      // Items at [1] and [2] should fail
      final failedElements =
          result.$elements.where((e) => e.$isNotValid).length;
      expect(failedElements, 2);
    });
  });

  group('ValidateList (object items)', () {
    late ValidateList validateList;

    setUp(() {
      final fieldRules = ValidateValue()
        ..isRequired()
        ..isList();
      validateList =
          ValidateList.fromEndorse(fieldRules, _TestPersonValidator());
    });

    test('validates a list of valid objects', () {
      final result = validateList.from([
        {'name': 'Kirk', 'age': 30},
        {'name': 'Spock', 'age': 35},
      ], 'people');
      expect(result.$isValid, isTrue);
    });

    test('fails when an object item is invalid', () {
      final result = validateList.from([
        {'name': 'Kirk', 'age': 30},
        {'name': null, 'age': -1},
      ], 'people');
      expect(result.$isNotValid, isTrue);
    });

    test('fails when input is null', () {
      final result = validateList.from(null, 'people');
      expect(result.$isNotValid, isTrue);
    });
  });
}
