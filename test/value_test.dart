import 'package:test/test.dart';

import 'package:endorse/src/rule_set.dart';
import 'package:endorse/src/value.dart';

main() {
  group('Value', () {
    test('Value is retrievable after created.', () {
      var v = Value(1);
      expect(v.value, equals(1));
    });
    test('Value.isValid is true if validation passes.', () async {
      var v = Value(1);
      var s = NumRuleSet();
      s.isEqualTo(1);
      await v.validate(s);
      expect(v.isValid, isTrue);
    });
    test('Value.isValid is false if validation fails.', () async {
      var v = Value(1);
      var s = NumRuleSet();
      s.isEqualTo(2);
      await v.validate(s);
      expect(v.isValid, isFalse);
    });
    // test('Value.errors is empty if validation passes.', () async {
    //   var v = Value(1);
    //   var s = NumRuleSet();
    //   s.isEqualTo(1);
    //   await v.validate(s);
    //   expect(v.errors, isEmpty);
    // });
    // test('Value.errors returns an error if a validation rule fails.', () async {
    //   var v = Value(1);
    //   var s = NumRuleSet();
    //   s.isEqualTo(2);
    //   await v.validate(s);
    //   expect(v.errors.length, equals(1));
    // });
    test('Value.errorMessages is empty if validation passes.', () async {
      var v = Value(1);
      var s = NumRuleSet();
      s.isEqualTo(1);
      await v.validate(s);
      expect(v.errorMessages(), isEmpty);
    });
    test('Value.errorMessages returns an error if a validation rule fails.',
        () async {
      var v = Value(1);
      var s = NumRuleSet();
      s.isEqualTo(2);
      await v.validate(s);
      expect(v.errorMessages().length, equals(1));
    });
    test('Value.errorMap is empty if validation passes.', () async {
      var v = Value(1);
      var s = NumRuleSet();
      s.isEqualTo(1);
      await v.validate(s);
      expect(v.errorMap(), isEmpty);
    });
    test('Value.errorMap returns an error if a validation rule fails.',
        () async {
      var v = Value(1);
      var s = NumRuleSet();
      s.isEqualTo(2);
      await v.validate(s);
      expect(v.errorMap().length, equals(1));
    });
    test('All error methods return the name number of errors.', () async {
      var v = Value(1);
      var s = NumRuleSet();
      s.isEqualTo(2).min(2);
      await v.validate(s);
      expect(
          2,
          allOf(
              [equals(v.errorMap().length), equals(v.errorMessages().length)]));
    });
  });
}
