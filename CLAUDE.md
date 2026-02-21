# Endorse — AI Instructions

## What This Package Is

Validation library: annotations + code generation (`source_gen`/`build_runner`) → type-safe validators + `toJson` serialization. Validates `Map<String, Object?>` input and returns either an immutable typed instance or structured field errors.

## Package Structure

```
lib/
  endorse.dart              ← barrel export (annotations, result, rules, validator, registry)
  builder.dart              ← build_runner entry point (SharedPartBuilder)
  src/
    annotations.dart        ← @Endorse, @EndorseField, When
    result.dart             ← sealed EndorseResult<T> → ValidResult<T> | InvalidResult<T>
    validator.dart          ← EndorseValidator<T> interface
    registry.dart           ← EndorseRegistry singleton
    rules.dart              ← Rule base + all rules + checkRules()
    builder/
      endorse_generator.dart ← GeneratorForAnnotation<Endorse> (~900 lines)
```

## Request Class Pattern (the one canonical form)

Every validated class MUST follow this exact structure:

```dart
import 'package:endorse/endorse.dart';

part 'my_request.g.dart';

@Endorse()
class MyRequest {
  @EndorseField(rules: [MinLength(1), MaxLength(100)])
  final String name;

  @EndorseField(rules: [Min(0)])
  final int quantity;

  final String? description;  // nullable = optional, no annotation needed

  const MyRequest._({
    required this.name,
    required this.quantity,
    this.description,
  });

  Map<String, dynamic> toJson() => _$MyRequestToJson(this);
  static final $endorse = _$MyRequestValidator();
}
```

**Required elements:**
- `part 'filename.g.dart';`
- `@Endorse()` on class
- All fields `final`
- Private constructor `const ClassName._({...})`
- `Map<String, dynamic> toJson() => _$ClassNameToJson(this);`
- `static final $endorse = _$ClassNameValidator();`

**Inference rules (do NOT add manually):**
- Non-nullable fields → `Required()` added automatically
- Dart type → type rule added automatically (`String` → `IsString`, `int` → `IsInt`, etc.)
- Only add `@EndorseField(rules: [...])` for validation rules beyond type/presence

## Available Rules

All rules accept optional `{message: 'custom error'}` to override defaults.

**String:** `MinLength(n)`, `MaxLength(n)`, `Matches(pattern)`, `Email()`, `Url()`, `Uuid()`, `IpAddress()`, `NoControlChars()`
**Numeric:** `Min(n)`, `Max(n)`
**Collection:** `MinElements(n)`, `MaxElements(n)`, `UniqueElements()`
**Enum:** `OneOf([values])`
**Custom:** `Custom('staticMethodName', message: 'error message')`
**Presence:** `Required()` (rarely needed — inferred from nullability)
**Transform:** `Trim()`, `LowerCase()`, `UpperCase()` (no message needed)
**Date (day granularity):** `IsBeforeDate(date)`, `IsAfterDate(date)`, `IsSameDate(date)` — specs: `'today'`, `'today+N'`, `'today-N'`, ISO 8601
**Datetime (full precision):** `IsFutureDatetime()`, `IsPastDatetime()`, `IsSameDatetime(date)`

## Nested Objects

Any field typed as another `@Endorse()` class is validated recursively. Errors use dot-paths.

```dart
final Address address;           // required nested — errors: 'address.street'
final Address? billingAddress;   // optional nested
```

## Nested Lists

```dart
@EndorseField(rules: [MinElements(1)])
final List<OrderLine> lines;     // errors: 'lines.0.quantity'
```

## Primitive Lists with Item Rules

```dart
@EndorseField(rules: [MinElements(1), UniqueElements()], itemRules: [MinLength(1)])
final List<String> tags;         // errors: 'tags.0', 'tags.1'
```

## Conditional Validation

```dart
@EndorseField(rules: [MinLength(2)], when: When('country', equals: 'US'))
final String? state;  // becomes required when country == 'US'
```

When conditions: `equals`, `isNotNull: true`, `isOneOf: [...]`

## Either Constraint

```dart
@Endorse(either: [['email', 'phone']])
```

At least one field in the group must be non-null.

## Cross-Field Validation

Add a static `crossValidate` method — codegen detects it by name convention:

```dart
static Map<String, List<String>> crossValidate(Map<String, Object?> input) {
  final errors = <String, List<String>>{};
  // validation logic
  return errors;
}
```

## Custom Validation

```dart
@EndorseField(rules: [Custom('isEven', message: 'must be an even number')])
final int value;

static bool isEven(Object? value) => value is int && value.isEven;
```

Method signature: `static bool name(Object? value)` — returns `true` if valid.

## Field Name Mapping

```dart
@EndorseField(name: 'user_role', rules: [OneOf(['admin', 'user', 'guest'])])
final String role;  // reads input['user_role'], writes 'user_role' in toJson
```

## Using the Validator

```dart
// Full validation (server pipeline)
final result = MyRequest.$endorse.validate(inputMap);
switch (result) {
  case ValidResult(:final value): /* value is MyRequest */
  case InvalidResult(:final fieldErrors): /* Map<String, List<String>> */
}

// Single-field validation (frontend forms)
final errors = MyRequest.$endorse.validateField('name', userInput);

// Field introspection
final fields = MyRequest.$endorse.fieldNames; // Set<String>

// Registry (server startup)
EndorseRegistry.instance.register<MyRequest>(MyRequest.$endorse);
final validator = EndorseRegistry.instance.get<MyRequest>();
```

## Auto-Coercion

Built into type rules — no annotations needed:
- `String` → `int`, `double`, `num`, `bool`, `DateTime`
- `double` → `int` (if whole number)
- `int` → `double`, `bool` (1/0)

## Commands

```bash
dart run build_runner build --delete-conflicting-outputs  # generate .g.dart files
dart test --reporter github 2>/dev/null                   # run tests
dart analyze                                              # lint
```

## Build Configuration

`build.yaml` at consumer project root:
```yaml
targets:
  $default:
    builders:
      endorse|endorse:
        generate_for:
          - lib/**
```

Endorse's own `build.yaml` enables generation for `test/samples/**`.

## Test Structure

- `test/rules_test.dart` — unit tests for all rules and `checkRules()`
- `test/result_test.dart` — sealed result type tests
- `test/registry_test.dart` — registry operations
- `test/e2e_test.dart` — end-to-end tests using generated validators
- `test/samples/` — annotated sample classes with generated `.g.dart` files

## Generator Internals (for modifying codegen)

`lib/src/builder/endorse_generator.dart` — `GeneratorForAnnotation<Endorse>`:

1. Reads `@Endorse()` class annotation (requireAll, either)
2. Processes fields: reads `@EndorseField`, infers type/required/nullable
3. Generates `_$ClassNameValidator implements EndorseValidator<ClassName>`:
   - Static rule lists per field
   - Static `_checkFieldName()` methods calling `checkRules()`
   - `validateField()` — switch on field name
   - `validate()` — runs all checks, handles nested/list/when/either/crossValidate
4. Generates `_$ClassNameToJson()` helper

Key internal types: `_FieldInfo`, `_RuleInfo`, `_WhenInfo`, `_TypeKind` enum.

After modifying the generator, regenerate test samples:
```bash
cd /workspaces/dart/endorse
dart run build_runner build --delete-conflicting-outputs
dart test --reporter github 2>/dev/null
```

## Branch

Active: `dev` (submodule in parent workspace)
