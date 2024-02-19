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
  final List<String> path;
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
  const Rule();
  // Need to decide if this Object can be null, or if null is handled at Validator level
  RuleError evaluate(Object input);
}

abstract class RuleWithNumTest {
  final num test;
  const RuleWithNumTest(this.test);
}

abstract class ValueRule {
  RuleError evaluate(Object input);
}

abstract class MapRule {
  RuleError evaluate(Object input);
}

abstract class ListRule {
  RuleError evaluate(Object input);
}

// abstract class ShortCircuitRule extends Rule {
//   const ShortCircuitRule();
// }

// abstract class RuleFlowControl {
//   finalResultObjectError bailOnFail = false;
//   const RuleFlowControl();
// }

class Required extends Rule with ValueRule, ListRule, MapRule {
  const Required();
  RuleError evaluate(Object input) {
    if (input == null) {
      return RuleError('Required');
    } else {
      return RuleError.empty();
    }
  }
}

class IsString extends Rule with ValueRule {
  const IsString();
  RuleError evaluate(Object? input) {
    if (input is! String) {
      return RuleError('IsString', 'Not a string.');
    } else {
      return RuleError.empty();
    }
  }
}

class IsMap extends Rule with MapRule {
  const IsMap();
  RuleError evaluate(Object? input) {
    if (input is! Map) {
      return RuleError('IsString', 'Not a string.');
    } else {
      return RuleError.empty();
    }
  }
}

class IsList extends Rule with ListRule {
  const IsList();
  RuleError evaluate(Object input) {
    if (input is! List) {
      return RuleError('IsList', 'Not a list.');
    } else {
      return RuleError.empty();
    }
  }
}

class MaxLength extends RuleWithNumTest with ValueRule {
  const MaxLength(int test) : super(test);
  RuleError evaluate(Object? input) {
    if (input is! String || input.length > test) {
      return RuleError('MaxLength', 'Max length is ${test}');
    } else {
      return RuleError.empty();
    }
  }
}

class IsLessThan extends RuleWithNumTest with ValueRule {
  const IsLessThan(int test) : super(test);
  RuleError evaluate(Object? input) {
    if (input is! num || input >= test) {
      return RuleError('IsLessThan', 'Must be less than ${test}');
    } else {
      return RuleError.empty();
    }
  }
}

class IsGreaterThan extends RuleWithNumTest with ValueRule {
  const IsGreaterThan(int test) : super(test);
  RuleError evaluate(Object? input) {
    if (input is! num || input <= test) {
      return RuleError('IsGreaterThan', 'Must be greater than ${test}');
    } else {
      return RuleError.empty();
    }
  }
}

class MaxElements extends RuleWithNumTest with ListRule, MapRule {
  const MaxElements(int test) : super(test);
  RuleError evaluate(Object? input) {
    if ((input is List || input is Map) && input.length > test) {
      return RuleError('IsLessThan', 'Max element count is ${test}');
    } else {
      return RuleError.empty();
    }
  }
}

class MinElements extends RuleWithNumTest with ListRule, MapRule {
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
  final List<String> path;
  const Validator([this.path = const []]);
  List<ValidationError> validate(Object? input);
}

class ValueValidator implements Validator {
  final List<ValueRule> rules;
  final List<String> path;
  const ValueValidator(this.rules, [this.path = const []]);
  List<ValidationError> validate(Object? input) {
    final errors = <ValidationError>[];
    for (final rule in rules) {
      final error = rule.evaluate(input);
      if (!error.isEmpty) {
        errors.add(ValidationError(path, error));
      }
    }
    return errors;
  }
}

class ListValidator implements Validator {
  final List<ListRule> listRules;
  final Validator elementValidator;
  final List<String> path;
  const ListValidator(this.listRules, this.elementValidator,
      [this.path = const []]);
  List<ValidationError> validate(Object? input) {
    print('ListValidation');
    final errors = <ValidationError>[];
    final isListErrors = IsList().evaluate(input);
    if (!isListErrors.isEmpty) {
      errors.add(ValidationError(path, isListErrors));
      return errors;
    }
    if (input is List) {
      for (var i = 0; i < input.length; i++) {
        final val = elementValidator.validate(input[i]);
        errors.addAll(val);
      }
    }
    print(errors);
    for (var error in errors) {
      print(error.errorName);
    }
    return [];
    // return <String, Object>{};
  }
}

class MapValidator implements Validator {
  final List<MapRule> mapRules;
  final List<String> path;
  const MapValidator(this.mapRules, [this.path = const []]);
  List<ValidationError> validate(Object? input) {
    print('MapValidation');
    return [];
  }
}

class ClassValidator implements Validator {
  final List<String> path;
  final Map<String, Validator> memberValidators;
  const ClassValidator(this.memberValidators, [this.path = const []]);

  List<ValidationError> validate(Object? input) {
    final Map<String, Object?> values;
    final Map<String, Object> errors;
    if (input == null) {
      return [ValidationError([], RuleError('Required'))];
    } else if (input is! Map<String, Object?>) {
      return [ValidationError([], RuleError('IsMap'))];
    }
    final isMapErrors = IsMap().evaluate(input);
    if (!isMapErrors.isEmpty) {
      return [ValidationError([], isMapErrors)];
    }
    for (final key in memberValidators.keys) {
      if (memberValidators[key] is ClassValidator) {
        print('ClassValidation: $key');
        final internal = ClassValidator(
            (memberValidators[key] as ClassValidator).memberValidators);
        // final val = internal.validate(input[key]);
      } else {
        final val = memberValidators[key]!.validate(input[key]);
        print(val);
      }
    }
    return [];
    // for (final key in rules.keys) {
    //   print(key);
    //   if (rules[key] is ClassValidation) {
    //     final internal = ClassValidation((rules[key] as ClassValidation).rules);
    //     final val = internal.validate(input[key]);
    //   } else {
    //     final val = rules[key]!.validate(input[key]);
    //   }
    // }
    // for (final rule in rules) {
    //   final error = rule.evaluate(value);
    //   if (!error.isClear) {
    //     errors.add(error);
    //   }
    // }
    // print('Validation');
    // return;
  }
}
