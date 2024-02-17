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

class ValidationError {
  final String errorName;
  final List path;
  final String detail;

  ValidationError(this.path, RuleError ruleError)
      : errorName = ruleError.errorName,
        detail = ruleError.errorDetail;
}

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

abstract class Rule {
  // final String call = '';
  // final validOnTypes = const <Type>[];
  const Rule();
  RuleError evaluate(Object? input);
}

abstract class ShortCircuitRule extends Rule {
  const ShortCircuitRule();
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
  RuleError evaluate(Object? input) {
    if (input == null) {
      return RuleError('Required');
    } else {
      return RuleError.empty();
    }
  }
}

class IsString extends ShortCircuitRule {
  const IsString();
  RuleError evaluate(Object? input) {
    if (input is! String) {
      return RuleError('IsString', 'Not a string.');
    } else {
      return RuleError.empty();
    }
  }
}

class MaxLength extends RuleWithNumTest {
  const MaxLength(int test) : super(test);
  RuleError evaluate(Object? input) {
    if (input is! String || input.length > test) {
      return RuleError('MaxLength', 'Max length is ${test}');
    } else {
      return RuleError.empty();
    }
  }
}

class IsLessThan extends RuleWithNumTest {
  const IsLessThan(int test) : super(test);
  RuleError evaluate(Object? input) {
    if (input is! num || input >= test) {
      return RuleError('IsLessThan', 'Must be less than ${test}');
    } else {
      return RuleError.empty();
    }
  }
}

class IsGreaterThan extends RuleWithNumTest {
  const IsGreaterThan(int test) : super(test);
  RuleError evaluate(Object? input) {
    if (input is! num || input <= test) {
      return RuleError('IsGreaterThan', 'Must be greater than ${test}');
    } else {
      return RuleError.empty();
    }
  }
}

class MaxElements extends RuleWithNumTest {
  const MaxElements(int test) : super(test);
  RuleError evaluate(Object? input) {
    if (input is! List || input.length > test) {
      return RuleError('IsLessThan', 'Max element count is ${test}');
    } else {
      return RuleError.empty();
    }
  }
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
      final error = rule.evaluate(input);
      if (!error.isEmpty) {
        errors.add(ValidationError([path], error));
      }
    }
    return errors;
  }
}

class ListValidation implements Validator {
  final List<Rule> listRules;
  final Validator elementValidator;
  ListValidation(this.listRules, this.elementValidator);
  List<RuleError> validate(Object? input) {
    print('ListValidation');
    return <String, Object>{};
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
  List<RuleError> validate(Object? input) {
    final Map<String, Object?> values;
    final Map<String, Object> errors;
    if (input is! Map<String, Object?>) {
      print('Not a map');
      return;
    }
    for (final key in rules.keys) {
      print(key);
      if (rules[key] is ClassValidation) {
        final internal = ClassValidation((rules[key] as ClassValidation).rules);
        final val = internal.validate(input[key]);
      } else {
        final val = rules[key]!.validate(input[key]);
      }
    }
    // for (final rule in rules) {
    //   final error = rule.evaluate(value);
    //   if (!error.isClear) {
    //     errors.add(error);
    //   }
    // }
    print('Validation');
    return;
  }
}
