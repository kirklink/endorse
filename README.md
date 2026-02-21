# Endorse

A validation library for Dart. Annotate your classes, run code generation, and get type-safe validation with immutable result objects. Designed for API request validation and frontend form validation from a single source of truth.

## Quick Start

### 1. Add dependencies

```yaml
# pubspec.yaml
dependencies:
  endorse:
    git:
      url: git@github.com:kirklink/endorse.git
      ref: dev

dev_dependencies:
  build_runner: ^2.11.0
```

### 2. Add build configuration

```yaml
# build.yaml (at your project root)
targets:
  $default:
    builders:
      endorse|endorse:
        generate_for:
          - lib/**
```

### 3. Define a request class

```dart
import 'package:endorse/endorse.dart';

part 'create_item_request.g.dart';

@Endorse()
class CreateItemRequest {
  @EndorseField(rules: [MinLength(1), MaxLength(100)])
  final String name;

  @EndorseField(rules: [Min(0)])
  final int quantity;

  final String? description;

  const CreateItemRequest._({
    required this.name,
    required this.quantity,
    this.description,
  });

  Map<String, dynamic> toJson() => _$CreateItemRequestToJson(this);
  static final $endorse = _$CreateItemRequestValidator();
}
```

Key conventions:
- **`final` fields** — the object is immutable after construction.
- **Private constructor** (`._`) — instances can only be created through validation.
- **Nullable fields** (`String?`) are optional. Non-nullable fields are required automatically.
- **`$endorse`** — static accessor to the generated validator.
- **`toJson()`** — delegates to the generated serialization helper.
- **`part` directive** — required for the generated `.g.dart` file.

### 4. Generate code

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Validate input

```dart
final result = CreateItemRequest.$endorse.validate({
  'name': 'Widget',
  'quantity': 5,
});

switch (result) {
  case ValidResult(:final value):
    print(value.name);     // 'Widget'
    print(value.quantity);  // 5
    print(value.toJson());  // {'name': 'Widget', 'quantity': 5}
  case InvalidResult(:final fieldErrors):
    print(fieldErrors);     // {'name': ['is required'], ...}
}
```

## Result Type

Validation returns a sealed `EndorseResult<T>` — either `ValidResult<T>` or `InvalidResult<T>`. Pattern matching handles both cases exhaustively.

```dart
final result = CreateItemRequest.$endorse.validate(input);

// Pattern matching (preferred)
final message = switch (result) {
  ValidResult(:final value) => 'Created: ${value.name}',
  InvalidResult(:final fieldErrors) => 'Errors: $fieldErrors',
};

// Type checking
if (result is ValidResult<CreateItemRequest>) {
  final item = result.value;
}
```

`InvalidResult.fieldErrors` is a `Map<String, List<String>>` — field names to error messages:

```dart
// {'name': ['is required'], 'quantity': ['must be at least 0']}
```

## Validation Rules

Rules are const-constructable annotations. The codegen infers type rules (IsString, IsInt, etc.) automatically from Dart field types — you only specify validation rules.

All rules accept an optional `message:` parameter to override the default error message:

```dart
@EndorseField(rules: [MinLength(2, message: 'name is too short')])
final String name;
```

### String

| Rule | Description |
|------|-------------|
| `MinLength(n)` | At least n characters (`MinLength(1)` = "must not be empty") |
| `MaxLength(n)` | At most n characters |
| `Matches(pattern)` | Regex match |
| `Email()` | Valid email format |
| `Url()` | Valid URL with scheme and authority |
| `Uuid()` | Valid UUID (v1–v5) |
| `IpAddress()` | Valid IPv4 or IPv6 address |

### Numeric

| Rule | Description |
|------|-------------|
| `Min(n)` | Value >= n |
| `Max(n)` | Value <= n |

### Collection

| Rule | Description |
|------|-------------|
| `MinElements(n)` | List has at least n items (`MinElements(1)` = "must not be empty") |
| `MaxElements(n)` | List has at most n items |
| `UniqueElements()` | All items are distinct |

### Enum / Allowlist

| Rule | Description |
|------|-------------|
| `OneOf([...])` | Value must be in the allowed list |

### Presence

| Rule | Description |
|------|-------------|
| `Required()` | Rarely needed — non-nullable fields are required automatically |

### Transform

Transforms modify the value before subsequent rules run. They never fail.

| Rule | Description |
|------|-------------|
| `Trim()` | Trims whitespace from both ends |
| `LowerCase()` | Converts to lowercase |
| `UpperCase()` | Converts to uppercase |

### DateTime — Date (day granularity)

Date rules compare at day granularity (time component is zeroed out). The `date` parameter accepts: `'today'`, `'today+N'`, `'today-N'`, or an ISO 8601 string.

| Rule | Description |
|------|-------------|
| `IsBeforeDate(date)` | Date must be before the given date |
| `IsAfterDate(date)` | Date must be after the given date |
| `IsSameDate(date)` | Date must be the same day as the given date |

### DateTime — Datetime (full precision)

| Rule | Description |
|------|-------------|
| `IsFutureDatetime()` | DateTime must be in the future |
| `IsPastDatetime()` | DateTime must be in the past |
| `IsSameDatetime(date)` | DateTime must be the same moment (ISO 8601 string) |

## Auto-Coercion

Type coercion happens automatically. No annotations needed.

- `'42'` (String) → `42` (int)
- `7.0` (double) → `7` (int)
- `'3.14'` (String) → `3.14` (double)
- `'true'` / `'1'` (String) → `true` (bool)
- `1` / `0` (int) → `true` / `false` (bool)
- `'2024-01-15T10:30:00Z'` (String) → `DateTime`

## Nested Objects

Fields that are `@Endorse()` classes are validated recursively. Errors use dot-path keys.

```dart
@Endorse()
class Address {
  @EndorseField(rules: [MinLength(1)])
  final String street;

  final String city;

  @EndorseField(rules: [Matches(r'^\d{5}$', message: 'must be a 5-digit zip code')])
  final String zip;

  const Address._({required this.street, required this.city, required this.zip});
  Map<String, dynamic> toJson() => _$AddressToJson(this);
  static final $endorse = _$AddressValidator();
}

@Endorse()
class CreateOrderRequest {
  final Address address;             // required nested object
  final Address? billingAddress;     // optional nested object

  const CreateOrderRequest._({required this.address, this.billingAddress});
  // ...
}
```

Nested errors are reported with dot-paths: `'address.street'`, `'address.zip'`.

## List of Nested Objects

```dart
@Endorse()
class CreateOrderRequest {
  @EndorseField(rules: [MinElements(1)])
  final List<OrderLine> lines;
  // ...
}
```

Item errors use indexed dot-paths: `'lines.0.quantity'`, `'lines.1.productId'`.

## Primitive Lists with Item Rules

Use `itemRules` to validate each item in a primitive list:

```dart
@Endorse()
class TagRequest {
  @EndorseField(rules: [MinElements(1), UniqueElements()], itemRules: [MinLength(1)])
  final List<String> tags;
  // ...
}
```

Item errors: `'tags.0'`, `'tags.2'`.

## Conditional Validation

Use `when` to validate a field only when a sibling field meets a condition. When the condition is met, nullable fields become required.

```dart
@Endorse()
class ShippingForm {
  @EndorseField(rules: [OneOf(['US', 'CA', 'UK'])])
  final String country;

  @EndorseField(
    rules: [MinLength(2)],
    when: When('country', equals: 'US'),
  )
  final String? state;  // required only when country is 'US'

  // ...
}
```

### When Conditions

| Condition | Example |
|-----------|---------|
| `equals` | `When('type', equals: 'business')` |
| `isNotNull` | `When('discount', isNotNull: true)` |
| `isOneOf` | `When('payment', isOneOf: ['credit', 'debit'])` |

## Either Constraint

Require at least one field in a group to be present:

```dart
@Endorse(either: [['email', 'phone']])
class ContactForm {
  @EndorseField(rules: [Email()])
  final String? email;

  @EndorseField(rules: [MinLength(7)])
  final String? phone;
  // ...
}
```

If neither is provided: `{'email': ['at least one of [email, phone] is required'], 'phone': [...]}`.

## Cross-Field Validation

Define a static `crossValidate` method for validation that spans multiple fields. The codegen detects it by convention and calls it after field-level validation passes.

```dart
@Endorse()
class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  const DateRange._({required this.startDate, required this.endDate});

  static Map<String, List<String>> crossValidate(Map<String, Object?> input) {
    final errors = <String, List<String>>{};
    // Add cross-field validation logic here
    return errors;
  }
  // ...
}
```

## Custom Validation

Reference a static method for validation logic that doesn't fit a built-in rule:

```dart
@Endorse()
class NumberForm {
  @EndorseField(rules: [Min(0), Custom('isEven', message: 'must be an even number')])
  final int value;

  const NumberForm._({required this.value});

  static bool isEven(Object? value) => value is int && value.isEven;
  // ...
}
```

The method must have the signature `static bool methodName(Object? value)` and return `true` if valid.

## Field Name Mapping

Map a Dart field name to a different JSON key:

```dart
@EndorseField(name: 'user_role', rules: [OneOf(['admin', 'user', 'guest'])])
final String role;  // reads from input['user_role'], writes 'user_role' in toJson
```

## Frontend Form Validation

The same validator supports single-field validation for forms:

```dart
// Validate one field at a time
final errors = CreateItemRequest.$endorse.validateField('name', userInput);
if (errors.isNotEmpty) {
  showError(errors.first);
}

// Get all field names for form generation
final fields = CreateItemRequest.$endorse.fieldNames;
// {'name', 'quantity', 'description'}
```

Works with Flutter:

```dart
TextFormField(
  decoration: const InputDecoration(labelText: 'Name'),
  validator: (value) {
    final errors = CreateItemRequest.$endorse.validateField('name', value);
    return errors.isEmpty ? null : errors.first;
  },
)
```

## Validator Registry

For server-side use, register validators at startup for lookup by type:

```dart
void main() {
  EndorseRegistry.instance
    ..register<CreateItemRequest>(CreateItemRequest.$endorse)
    ..register<CreateOrderRequest>(CreateOrderRequest.$endorse);

  // Framework looks up validators at request time:
  // EndorseRegistry.instance.get<CreateItemRequest>().validate(body)
}
```

## API Reference

### Annotations

| Annotation | Target | Parameters |
|-----------|--------|------------|
| `@Endorse()` | Class | `requireAll: bool`, `either: List<List<String>>` |
| `@EndorseField()` | Field | `rules: List<Rule>`, `itemRules: List<Rule>`, `name: String`, `ignore: bool`, `when: When` |

### Types

| Type | Description |
|------|-------------|
| `EndorseResult<T>` | Sealed result — `ValidResult<T>` or `InvalidResult<T>` |
| `ValidResult<T>` | Contains `.value` — the immutable validated instance |
| `InvalidResult<T>` | Contains `.fieldErrors` — `Map<String, List<String>>` |
| `EndorseValidator<T>` | Interface: `validate()`, `validateField()`, `fieldNames` |
| `EndorseRegistry` | Singleton registry mapping types to validators |

## Documentation

- **For contributors:** See [CLAUDE.md](CLAUDE.md) — internals, architecture, file map
- **For AI consumers:** See [docs/guide.md](docs/guide.md) — complete self-contained API reference
