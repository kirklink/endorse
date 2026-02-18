# endorse

A Dart validation library with code generation. Define validation rules as annotations on your classes and let the builder generate type-safe validation and entity creation code.

## Quick Start

### 1. Add dependencies

```yaml
# pubspec.yaml
dependencies:
  endorse: ^0.1.0

dev_dependencies:
  build_runner: ^2.0.2
```

### 2. Define an entity

```dart
import 'package:endorse/annotations.dart';
import 'package:endorse/endorse.dart';

part 'user.g.dart';

@EndorseEntity()
class User {
  @EndorseField(validate: [Required(), MaxLength(50)])
  late String name;

  @EndorseField(validate: [Required(), IsGreaterThan(0)])
  late int age;

  @EndorseField(validate: [MaxLength(100)])
  String? email;

  User();

  static final $endorse = _$UserEndorse();
}
```

### 3. Generate code

```bash
dart run build_runner build
```

### 4. Validate input

```dart
final result = User.$endorse.validate({
  'name': 'Kirk',
  'age': 30,
  'email': 'kirk@example.com',
});

if (result.$isValid) {
  final user = result.entity();
  print(user.name); // Kirk
} else {
  print(result.$errors); // List<ValidationError>
}
```

## Annotations

### `@EndorseEntity()`

Marks a class for validation code generation.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `useCase` | `Case` | `Case.none` | Convert field names to a case format (camel, snake, etc.) |
| `requireAll` | `bool` | `false` | Make all fields required |

### `@EndorseField()`

Configures validation for a specific field. Only needed when adding validation rules or overriding defaults.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `validate` | `List<ValidationBase>` | `[]` | Validation rules for the field |
| `itemValidate` | `List<ValidationBase>` | `[]` | Validation rules for items in a list field |
| `ignore` | `bool` | `false` | Exclude field from validation |
| `useCase` | `Case` | `Case.none` | Convert this field's name to a case format |
| `name` | `String` | `''` | Map to a different key name in the input |

## Validation Rules

### Required / Null

| Annotation | Description |
|-----------|-------------|
| `Required()` | Value must not be null |
| `IsNotNull()` | Alias for Required |

### String

| Annotation | Description |
|-----------|-------------|
| `MaxLength(n)` | String length <= n |
| `MinLength(n)` | String length >= n |
| `ExactLength(n)` | String length == n |
| `IsNotEmpty()` | String must not be empty |
| `IsAlpha()` | Letters only |
| `IsAlphanumeric()` | Letters and digits only |
| `Trim()` | Trim whitespace (coercion, not validation) |
| `Matches(value)` | Exact string match |
| `Contains(value)` | String contains substring |
| `StartsWith(value)` | String starts with prefix |
| `EndsWith(value)` | String ends with suffix |
| `MatchesPattern(regex)` | Matches a regex pattern |
| `IsEmail()` | Valid email format |
| `IsUrl()` | Valid URL format |
| `IsUuid()` | Valid UUID format |
| `IsPhoneNumber()` | Valid phone number format |

### Numeric

| Annotation | Description |
|-----------|-------------|
| `IsGreaterThan(n)` | Value > n |
| `IsLessThan(n)` | Value < n |
| `IsGreaterThanOrEqual(n)` | Value >= n |
| `IsLessThanOrEqual(n)` | Value <= n |
| `IsEqualTo(n)` | Value == n |
| `IsNotEqualTo(n)` | Value != n |

### Boolean

| Annotation | Description |
|-----------|-------------|
| `IsTrue()` | Value must be true |
| `IsFalse()` | Value must be false |

### DateTime

| Annotation | Description |
|-----------|-------------|
| `IsBefore(date)` | Before the given date |
| `IsAfter(date)` | After the given date |
| `IsAtMoment(date)` | Exact datetime match |
| `IsSameDateAs(date)` | Same calendar date (ignores time) |

DateTime annotations accept ISO 8601 strings, `'now'`, or `'today'`/`'today+N'`/`'today-N'`.

### Enum / Allowlist

| Annotation | Description |
|-----------|-------------|
| `IsOneOf(['a', 'b', 'c'])` | Value must be one of the allowed values |

### Collection

| Annotation | Description |
|-----------|-------------|
| `MinElements(n)` | List must have at least n elements |
| `MaxElements(n)` | List must have at most n elements |

### Type Coercion

| Annotation | Description |
|-----------|-------------|
| `IntFromString()` | Parse string to int |
| `DoubleFromString()` | Parse string to double |
| `NumFromString()` | Parse string to num |
| `BoolFromString()` | Parse `'true'`/`'false'` to bool |
| `ToStringFromInt()` | Convert int to string |
| `ToStringFromDouble()` | Convert double to string |

## Working with Results

```dart
final result = User.$endorse.validate(input);

result.$isValid;      // bool - all fields passed
result.$isNotValid;   // bool - at least one field failed
result.$errors;       // List<ValidationError> - all errors across fields

if (result.$isValid) {
  final user = result.entity(); // Typed entity with validated values
}
```

## Nested Objects

Fields that are `@EndorseEntity` classes are automatically validated recursively:

```dart
@EndorseEntity()
class Address {
  @EndorseField(validate: [Required(), MaxLength(100)])
  late String street;

  @EndorseField(validate: [Required()])
  late String city;

  Address();
  static final $endorse = _$AddressEndorse();
}

@EndorseEntity()
class User {
  @EndorseField(validate: [Required()])
  late String name;

  @EndorseField(validate: [Required()])
  late Address address;  // Nested entity - validated recursively

  User();
  static final $endorse = _$UserEndorse();
}
```

If the nested field is `null` or not a valid map, validation fails at the field level without attempting to validate the nested fields.

## List Validation

Lists of primitives or objects can be validated with `itemValidate`:

```dart
@EndorseEntity()
class Order {
  @EndorseField(validate: [Required()])
  late String customer;

  @EndorseField(
    validate: [Required()],
    itemValidate: [Required(), IsGreaterThan(0)],
  )
  late List<int> quantities;  // Each item must be > 0

  Order();
  static final $endorse = _$OrderEndorse();
}
```

Lists of `@EndorseEntity` objects are also supported - each item in the list is validated against the entity's rules.

## Custom Error Messages

All annotations accept an optional `message` parameter to override the default error message:

```dart
@EndorseEntity()
class User {
  @EndorseField(validate: [Required(message: 'Please provide your name')])
  late String name;

  @EndorseField(validate: [
    Required(),
    MaxLength(100, message: 'Email must be 100 characters or fewer'),
  ])
  String? email;

  @EndorseField(validate: [
    Required(message: 'Age is required'),
    IsGreaterThan(0, message: 'Age must be positive'),
  ])
  late int age;

  User();
  static final $endorse = _$UserEndorse();
}
```

## Custom Validators

For validation logic that doesn't fit a built-in rule, use `CustomValidation` to reference a static method on the entity class:

```dart
@EndorseEntity()
class Order {
  @EndorseField(validate: [
    Required(),
    CustomValidation('isEven', 'Must be an even number'),
  ])
  late int quantity;

  // Static method: must accept Object? and return bool
  static bool isEven(Object? value) => value is int && value.isEven;

  Order();
  static final $endorse = _$OrderEndorse();
}
```

The builder validates that the referenced static method exists at build time. The generated code calls `..custom('isEven', Order.isEven, 'Must be an even number')`.

`CustomValidation` also supports the `message` parameter for overriding the error message:

```dart
CustomValidation('isEven', 'Must be even', message: 'Custom override message')
```

## Programmatic Validation

You can also use `ValidateValue` directly without code generation:

```dart
final validator = ValidateValue()
  ..isRequired()
  ..isString()
  ..maxLength(50);

final result = validator.from(input, 'fieldName');

if (result.$isValid) {
  print(result.$value); // The validated (and possibly cast) value
}
```

You can also add custom validators and custom error messages programmatically:

```dart
final validator = ValidateValue()
  ..isRequired()
  ..isInt()
  ..custom('isEven', (v) => v is int && v.isEven, 'Must be an even number')
  ..isGreaterThan(0)
  ..withMessage('Must be a positive number');  // overrides previous rule's message
```
