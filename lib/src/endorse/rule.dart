import 'package:endorse/src/endorse/validation_error.dart';

// typedef String PreCondition(Object? input, Object? test);
// typedefResultObjectError PassFuntion(Object? input, Object? test);
// typedef String GotFunction(Object? input, Object? test);
// typedef Object? CastFunction(Object? input);
// typedef String ErrorMessage(Object? input, Object? test);

// abstract class Rule {
//   final String name = '';
//   finalResultObjectError skipIfNull = true;
//   finalResultObjectError causesBail = false;
//   finalResultObjectError escapesBail = false;
//   final PreCondition check = (input, test) => '';
// typedef String WantFunction(Object? input, Object? test);
//   final PassFuntion pass = (input, test) => true;
//   final GotFunction got = (input, test) => '';
//   final WantFunction want = (input, test) => '';
//   final CastFunction cast = (input) => input;
//   final ErrorMessage errorMsg = (input, test) => '';
// }

class RuleError {
  final String errorName;
  final String errorDetail;

  const RuleError(this.errorName, [this.errorDetail = '']);
  const RuleError.empty()
      : errorName = '',
        errorDetail = '';

  bool get isEmpty => errorDetail.isEmpty && errorName.isEmpty;
}

// Note: ValidationError is also defined in validation_error.dart
// The one in validation_error.dart is the preferred implementation
// This one is kept for backwards compatibility but should not be used

// class ValidationResult {
//   final Map<String, Object?> value;
//   final Map<String, Object> errors;

//   ValidationResult(this.value, this.errors);
// }

// abstract class ValidationBase {
//   final String call = '';
//   final validOnTypes = const <Type>[];
//   const ValidationBase();
// }

// Base Rule class with full interface for Evaluator
abstract class Rule {
  const Rule();

  // Rule metadata
  String get name => '';
  bool get skipIfNull => true;
  bool get causesBail => false;
  bool get escapesBail => false;

  // Validation methods
  String check(Object? input, Object? test) => '';
  bool pass(Object? input, Object? test);
  String got(Object? input, Object? test) => '';
  String want(Object? input, Object? test) => '';
  String errorMsg(Object? input, Object? test);
  Object? cast(Object? input) => input;

  // Legacy method for backwards compatibility
  RuleError evaluate(Object? input) {
    if (!pass(input, null)) {
      return RuleError(name, errorMsg(input, null));
    }
    return RuleError.empty();
  }
}

abstract class ShortCircuitRule extends Rule {
  const ShortCircuitRule();

  @override
  bool get causesBail => true;
}

abstract class RuleWithNumTest extends Rule {
  final num test;
  const RuleWithNumTest(this.test);
}

// abstract class RuleFlowControl {
//   finalResultObjectError bailOnFail = false;
//   const RuleFlowControl();
// }

class Required extends Rule {
  const Required();

  @override
  String get name => 'Required';

  @override
  bool get skipIfNull => false;

  @override
  bool get causesBail => true;

  @override
  bool pass(Object? input, Object? test) => input != null;

  @override
  String errorMsg(Object? input, Object? test) => 'Required.';
}

class IsString extends ShortCircuitRule {
  const IsString();

  @override
  String get name => 'IsString';

  @override
  bool pass(Object? input, Object? test) => input is String;

  @override
  String errorMsg(Object? input, Object? test) => 'Must be a String';

  @override
  String got(Object? input, Object? test) => input.runtimeType.toString();

  @override
  String want(Object? input, Object? test) => 'String';
}

class MaxLength extends RuleWithNumTest {
  const MaxLength(int test) : super(test);

  @override
  String get name => 'MaxLength';

  @override
  bool pass(Object? input, Object? testParam) =>
      input is String && input.length <= test;

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Length must be less than or equal to $test.';

  @override
  String got(Object? input, Object? testParam) =>
      input is String ? input.length.toString() : 'not a string';

  @override
  String want(Object? input, Object? testParam) => '<= $test';
}

class IsLessThan extends RuleWithNumTest {
  const IsLessThan(int test) : super(test);

  @override
  String get name => 'IsLessThan';

  @override
  bool pass(Object? input, Object? testParam) =>
      input is num && input < test;

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Must be less than $test.';

  @override
  String want(Object? input, Object? testParam) => '< $test';
}

class IsGreaterThan extends RuleWithNumTest {
  const IsGreaterThan(int test) : super(test);

  @override
  String get name => 'IsGreaterThan';

  @override
  bool pass(Object? input, Object? testParam) =>
      input is num && input > test;

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Must be greater than $test.';

  @override
  String want(Object? input, Object? testParam) => '> $test';
}

class MaxElements extends RuleWithNumTest {
  const MaxElements(int test) : super(test);

  @override
  String get name => 'MaxElements';

  @override
  bool pass(Object? input, Object? testParam) =>
      input is List && input.length <= test;

  @override
  String errorMsg(Object? input, Object? testParam) =>
      'Max element count is $test';

  @override
  String want(Object? input, Object? testParam) => '<= $test elements';
}

abstract class Validator {
  List<ValidationError> validate(Object? input);
}

// class ValidateMap implements Validator {
//   final Map<String, Object?> map;

//   ValidateMap(this.map);

//   ResultObject validate() {}
// }

class ValueValidation implements Validator {
  final List<Rule> rules;
  final List path;
  ValueValidation(this.rules, [this.path = const []]);
  List<ValidationError> validate(Object? input) {
    final errors = <ValidationError>[];
    for (final rule in rules) {
      final ruleError = rule.evaluate(input);
      if (!ruleError.isEmpty) {
        errors.add(ValidationError(
          ruleError.errorName,
          ruleError.errorDetail,
          input?.toString() ?? 'null',
          '', // want - not available in RuleError
        ));
      }
    }
    return errors;
  }
}

class ListValidation implements Validator {
  final List<Rule> listRules;
  final Validator elementValidator;
  ListValidation(this.listRules, this.elementValidator);
  List<ValidationError> validate(Object? input) {
    print('ListValidation - not yet implemented');
    return [];
  }
}

// class MapValidation implements Validator {
//   final Map<String, Validator> mapRules;
//   MapValidation(this.mapRules);
//   List<ValidationError> validate(Object? input) {
//     print('MapValidation');
//     return <String, Object>{};
//   }
// }

class ClassValidation implements Validator {
  final Map<String, Validator> rules;
  ClassValidation(this.rules);
  List<ValidationError> validate(Object? input) {
    print('ClassValidation - not yet implemented');
    if (input is! Map<String, Object?>) {
      return [];
    }
    for (final key in rules.keys) {
      if (rules[key] is ClassValidation) {
        final internal = ClassValidation((rules[key] as ClassValidation).rules);
        final val = internal.validate(input[key]);
      } else {
        final val = rules[key]!.validate(input[key]);
      }
    }
    return [];
  }
}
