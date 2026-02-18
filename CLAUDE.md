# Endorse - Dart Validation Library

Validation library: annotations + code generation (source_gen/build_runner) + runtime rules/evaluator.

## Project Structure

- `lib/src/endorse/` - Runtime: rules, evaluator, result types, patterns
- `lib/src/builder/` - Code generation: source_gen builder, field/class helpers
- `lib/annotations.dart` - Public annotation exports
- `lib/endorse.dart` - Public runtime exports
- `test/` - Unit tests (291 total)
- `docs/stabilization-plan.md` - Stabilization roadmap (Phases 1-5 done)

## Architecture

Three-layer system:

1. **Annotations** (`validations.dart`) - Const classes with a `call` string (e.g. `'isNotEmpty()'`) and optional `value` field
2. **Code Generation** (`endorse_class_helper.dart`, `field_helper.dart`) - source_gen builder reads annotations, generates validator classes. The `call` string's `@` token gets replaced with the annotation's `value`.
3. **Runtime** (`rule.dart`, `validate_value.dart`, `evaluator.dart`) - Rule classes implement `pass()`, ValidateValue provides fluent API, Evaluator runs rules and produces results

## Key Files

- `lib/src/endorse/validations.dart` - All annotation classes (48+)
- `lib/src/endorse/rule.dart` - All runtime rule classes
- `lib/src/endorse/validate_value.dart` - Fluent validation API (methods map 1:1 with rules)
- `lib/src/endorse/evaluator.dart` - Runs rules, produces ValueResult
- `lib/src/builder/endorse_class_helper.dart` - Main codegen: generates validator/result/entity classes
- `lib/src/builder/field_helper.dart` - `processValidations()` handles annotation value substitution

## Adding a New Validation Rule

1. Add annotation class to `validations.dart` (extend `ValidationBase`, set `call` string)
2. Add runtime rule class to `rule.dart` (extend `Rule` or `RuleWithNumTest`)
3. Add method to `validate_value.dart` (creates `RuleHolder` wrapping the rule)
4. If the rule has a non-standard value type (not String/int/double), update `processValidations()` in `field_helper.dart`
5. Add unit tests to `test/rule_test.dart` and `test/annotations_test.dart`
6. Test codegen e2e in `arrow_example/`

## Commands

```bash
# Run tests
dart test

# Analyze
dart analyze

# Get dependencies
dart pub get
```

## Build Configuration

- `build.yaml`: `build_to: cache`, builder name `endorse`, applies `combining_builder`
- Builder entry point: `lib/builder.dart`

## Branch

- Current stabilization branch: `feature/initial-stabilization`
- Major dep upgrade branch: `feature/major-dep-upgrade`

## Using Endorse

### Setup

**pubspec.yaml:**
```yaml
dependencies:
  endorse:
    git:
      url: git@github.com:kirklink/endorse.git
      ref: feature/major-dep-upgrade

dev_dependencies:
  build_runner: ^2.11.0
```

**build.yaml** (at project root):
```yaml
targets:
  $default:
    builders:
      endorse|endorse:
        generate_for:
          - lib/**
```

### Defining an Entity

```dart
import 'package:endorse/annotations.dart';
import 'package:endorse/endorse.dart';

part 'my_entity.g.dart';

@EndorseEntity()
class MyEntity {
  @EndorseField(validate: [Required(), MaxLength(100)])
  late String name;

  @EndorseField(validate: [Required(), IsGreaterThan(0)])
  late int age;

  // Nullable fields are optional by default (no Required needed)
  @EndorseField(validate: [IsEmail()])
  String? email;

  MyEntity();

  // This line is required - connects to generated code
  // ignore: non_constant_identifier_names
  static final $endorse = _$MyEntityEndorse();
}
```

### Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates `my_entity.g.dart` with the validator class.

### Using the Validator

```dart
// Validate a map (e.g. from JSON body)
final result = MyEntity.$endorse.validate({
  'name': 'Alice',
  'age': 30,
  'email': 'alice@example.com',
});

// Check validity
if (result.$isValid) {
  // Access individual field values
  print(result.name.$value);  // 'Alice'
  print(result.age.$value);   // 30

  // Or hydrate the full entity
  final entity = result.entity();
  print(entity.name);  // 'Alice'
}

// Handle errors
if (result.$isNotValid) {
  // All errors across all fields
  for (final error in result.$errors) {
    print('${error.rule}: ${error.message}');
  }

  // Per-field errors
  if (result.name.$isNotValid) {
    print(result.name.$errors);
  }
}
```

### Available Validation Annotations

**Type coercion (place before other rules):**
- `IntFromString()` - parse string to int
- `DoubleFromString()`, `NumFromString()`, `BoolFromString()`
- `ToStringFromInt()`, `ToStringFromDouble()`, `ToStringFromNum()`, `ToStringFromBool()`

**Requirement:**
- `Required()` - field must not be null

**String rules:**
- `MaxLength(n)`, `MinLength(n)`, `ExactLength(n)`
- `Matches(string)`, `Contains(string)`, `StartsWith(string)`, `EndsWith(string)`
- `IsNotEmpty()`, `IsAlpha()`, `IsAlphanumeric()`, `Trim()`
- `IsEmail()`, `IsUrl()`, `IsUuid()`, `IsPhoneNumber()`
- `MatchesPattern(r'regex')`, `MatchesRawPattern(r'regex')`

**Numeric rules:**
- `IsGreaterThan(n)`, `IsLessThan(n)`
- `IsGreaterThanOrEqual(n)`, `IsLessThanOrEqual(n)`
- `IsEqualTo(n)`, `IsNotEqualTo(n)`

**Boolean rules:**
- `IsTrue()`, `IsFalse()`

**DateTime rules:**
- `IsBefore(dateString)`, `IsAfter(dateString)` - supports `'now'`, `'today'`, `'today+N'`, `'today-N'`
- `IsAtMoment(dateString)`, `IsSameDateAs(dateString)`

**Enum/allowlist:**
- `IsOneOf(['value1', 'value2', 'value3'])`

**Collection rules (for List fields):**
- `MinElements(n)`, `MaxElements(n)`

### Advanced Patterns

**Nested entities:**
```dart
@EndorseEntity()
class Address {
  @EndorseField(validate: [Required()])
  late String street;
  // ...
  static final $endorse = _$AddressEndorse();
}

@EndorseEntity()
class User {
  @EndorseField(validate: [Required()])
  late Address address;  // validates as nested map
  // ...
}
```

**Lists of primitives with item validation:**
```dart
@EndorseField(
  validate: [Required()],
  itemValidate: [MinLength(1)],  // each item must be non-empty
)
late List<String> tags;
```

**Lists of entities:**
```dart
@EndorseField(validate: [Required()])
late List<Address> addresses;  // each element validated as Address
```

**Field renaming (map key differs from Dart field name):**
```dart
@EndorseField(name: 'email_address', validate: [Required(), IsEmail()])
late String email;  // reads from input['email_address']
```

**Ignoring fields:**
```dart
@EndorseField(ignore: true)
late String internalOnly;  // skipped in validation entirely
```

**Require all fields:**
```dart
@EndorseEntity(requireAll: true)
class StrictEntity {
  late String name;        // auto-required
  String? description;     // also required despite being nullable
}
```

### Supported Field Types

`String`, `int`, `double`, `num`, `bool`, `DateTime`, `List<T>` (where T is any of these or another `@EndorseEntity`), and nested `@EndorseEntity` classes (validated as maps).

### Key Things to Know

- The `part 'filename.g.dart';` directive and `static final $endorse = _$EntityEndorse();` line are both required
- Nullable fields (`String?`) are optional by default - validation rules are skipped when null
- Non-nullable fields (`late String`) automatically get `Required()` unless you explicitly omit it
- `Trim()` is a transform rule, not a validation - it modifies the value before subsequent rules run
- `entity()` on a valid result hydrates the entity object; it throws on invalid results
- After changing annotations, always re-run `dart run build_runner build --delete-conflicting-outputs`
