# Endorse — Consumer Guide

Complete API reference for AI consumers. Load this one file — never read source code.

## Import

```dart
import 'package:endorse/endorse.dart';
```

This single import provides all annotations, rules, result types, the validator interface, and the registry.

## Setup

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

```yaml
# build.yaml (project root)
targets:
  $default:
    builders:
      endorse|endorse:
        generate_for:
          - lib/**
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Quick Start

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

```dart
final result = CreateItemRequest.$endorse.validate({
  'name': 'Widget',
  'quantity': 5,
});

switch (result) {
  case ValidResult(:final value):
    print(value.name);     // 'Widget'
    print(value.quantity);  // 5
  case InvalidResult(:final fieldErrors):
    print(fieldErrors);     // {'name': ['is required'], ...}
}
```

---

## Annotations

### `@Endorse()`

Applied to a class. Marks it for code generation.

```dart
const Endorse({
  bool requireAll = false,
  List<List<String>> either = const [],
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `requireAll` | `bool` | `false` | Make all fields required regardless of nullability |
| `either` | `List<List<String>>` | `const []` | Groups where at least one field must be present |

### `@EndorseField()`

Applied to fields within an `@Endorse()` class.

```dart
const EndorseField({
  List<Rule> rules = const [],
  List<Rule> itemRules = const [],
  String? name,
  bool ignore = false,
  When? when,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `rules` | `List<Rule>` | `const []` | Validation rules for this field |
| `itemRules` | `List<Rule>` | `const []` | Rules for each item in a `List<T>` field |
| `name` | `String?` | `null` | Override the JSON key name |
| `ignore` | `bool` | `false` | Skip validation for this field |
| `when` | `When?` | `null` | Conditional validation |

### `When`

Conditional validation — field is only validated when a sibling field meets a condition.

```dart
const When(
  String field, {
  Object? equals,
  bool isNotNull = false,
  List<Object>? isOneOf,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `field` | `String` | required | Name of the sibling field to check |
| `equals` | `Object?` | `null` | Sibling must equal this value |
| `isNotNull` | `bool` | `false` | Sibling must not be null |
| `isOneOf` | `List<Object>?` | `null` | Sibling must be one of these values |

Provide exactly one condition (`equals`, `isNotNull`, or `isOneOf`).

```dart
@EndorseField(
  rules: [MinLength(2)],
  when: When('country', equals: 'US'),
)
final String? state;
```

---

## Result Types

### `EndorseResult<T>` (sealed)

Returned by `validate()`. Pattern match to handle both cases.

### `ValidResult<T>`

```dart
const ValidResult(T value)
```

| Field | Type | Description |
|-------|------|-------------|
| `value` | `T` | The immutable, fully validated instance |

### `InvalidResult<T>`

```dart
const InvalidResult(Map<String, List<String>> fieldErrors)
```

| Field | Type | Description |
|-------|------|-------------|
| `fieldErrors` | `Map<String, List<String>>` | Per-field error messages |

Keys are field names. Nested objects use dot-paths (`'address.street'`). List items use indexed dot-paths (`'items.0.name'`).

```dart
switch (result) {
  case ValidResult(:final value):
    // value is fully typed
  case InvalidResult(:final fieldErrors):
    // fieldErrors: {'name': ['is required'], 'quantity': ['must be at least 0']}
}
```

---

## Validator Interface

### `EndorseValidator<T>`

Generated for each `@Endorse()` class. Access via `ClassName.$endorse`.

#### `EndorseResult<T> validate(Map<String, Object?> input)`

Validate an entire object from a raw map.

```dart
final result = CreateItemRequest.$endorse.validate({
  'name': 'Widget',
  'quantity': 5,
});
```

#### `List<String> validateField(String fieldName, Object? value)`

Validate a single field by name. Returns error messages, or empty list if valid.

```dart
final errors = CreateItemRequest.$endorse.validateField('name', userInput);
if (errors.isNotEmpty) {
  showError(errors.first);
}
```

#### `Set<String> get fieldNames`

All field names this validator knows about (including remapped names).

```dart
final fields = CreateItemRequest.$endorse.fieldNames;
// {'name', 'quantity', 'description'}
```

---

## Registry

### `EndorseRegistry`

Singleton for mapping request types to validators. Useful for framework integration.

#### `static final EndorseRegistry instance`

#### `void register<T extends Object>(EndorseValidator<T> validator)`

```dart
EndorseRegistry.instance
  ..register<CreateItemRequest>(CreateItemRequest.$endorse)
  ..register<UpdateItemRequest>(UpdateItemRequest.$endorse);
```

#### `EndorseValidator<T> get<T extends Object>()`

Retrieve validator by type. Throws `StateError` if not registered.

```dart
final validator = EndorseRegistry.instance.get<CreateItemRequest>();
```

#### `bool has<T extends Object>()`

Check if a validator is registered.

#### `EndorseValidator<Object>? getForType(Type type)`

Runtime type lookup. Returns `null` if not registered.

```dart
final validator = EndorseRegistry.instance.getForType(MyRequest);
```

#### `void clear()`

Remove all registered validators. Useful for testing.

---

## Validation Rules

All rules are const-constructable. Most accept an optional `message:` parameter to override the default error message. Codegen auto-infers type rules (`IsString`, `IsInt`, etc.) and `Required()` — you only add validation rules.

### Presence

| Rule | Default Message |
|------|-----------------|
| `Required({String? message})` | `'is required'` |

Bails on failure. Auto-inferred for non-nullable fields — rarely needed manually.

### Type Rules (auto-inferred, auto-coercing)

These are added automatically by codegen based on Dart field types. Listed here for completeness.

| Rule | Coercion |
|------|----------|
| `IsString()` | None |
| `IsInt()` | `double` (if whole) and `String` via `int.tryParse()` |
| `IsDouble()` | `int` and `String` via `double.tryParse()` |
| `IsNum()` | `String` via `num.tryParse()` |
| `IsBool()` | `String` (`'true'`/`'false'`/`'1'`/`'0'`), `int` (`1`/`0`) |
| `IsDateTime()` | `String` via `DateTime.tryParse()` |
| `IsMap()` | None |
| `IsList()` | None |

All type rules bail on failure.

### String Rules

| Rule | Constructor | Default Message |
|------|-------------|-----------------|
| `MinLength` | `MinLength(int min, {String? message})` | `'must not be empty'` (min=1) or `'must be at least N characters'` |
| `MaxLength` | `MaxLength(int max, {String? message})` | `'must be at most N characters'` |
| `Matches` | `Matches(String pattern, {String? message})` | `'must match pattern ...'` |
| `Email` | `Email({String? message})` | `'must be a valid email address'` |
| `Url` | `Url({String? message})` | `'must be a valid URL'` |
| `Uuid` | `Uuid({String? message})` | `'must be a valid UUID'` |
| `IpAddress` | `IpAddress({String? message})` | `'must be a valid IP address'` |

### Numeric Rules

| Rule | Constructor | Default Message |
|------|-------------|-----------------|
| `Min` | `Min(num min, {String? message})` | `'must be at least N'` |
| `Max` | `Max(num max, {String? message})` | `'must be at most N'` |

### Collection Rules

| Rule | Constructor | Default Message |
|------|-------------|-----------------|
| `MinElements` | `MinElements(int min, {String? message})` | `'must not be empty'` (min=1) or `'must have at least N elements'` |
| `MaxElements` | `MaxElements(int max, {String? message})` | `'must have at most N elements'` |
| `UniqueElements` | `UniqueElements({String? message})` | `'must contain unique elements'` |

### Allowlist

| Rule | Constructor | Default Message |
|------|-------------|-----------------|
| `OneOf` | `OneOf(List<Object> allowed, {String? message})` | `'must be one of: ...'` |

### Transform Rules

Transforms modify the value before subsequent rules. They never fail.

| Rule | Effect |
|------|--------|
| `Trim()` | Trims whitespace from both ends |
| `LowerCase()` | Converts to lowercase |
| `UpperCase()` | Converts to uppercase |

```dart
@EndorseField(rules: [Trim(), LowerCase(), Email()])
final String email;  // '  USER@EXAMPLE.COM  ' → 'user@example.com'
```

### DateTime Rules — Day Granularity

Compare at day granularity (time zeroed). Date specs: `'today'`, `'today+N'`, `'today-N'`, or ISO 8601 string.

| Rule | Constructor | Default Message |
|------|-------------|-----------------|
| `IsBeforeDate` | `IsBeforeDate(String date, {String? message})` | `'must be before ...'` |
| `IsAfterDate` | `IsAfterDate(String date, {String? message})` | `'must be after ...'` |
| `IsSameDate` | `IsSameDate(String date, {String? message})` | `'must be the same date as ...'` |

### DateTime Rules — Full Precision

| Rule | Constructor | Default Message |
|------|-------------|-----------------|
| `IsFutureDatetime` | `IsFutureDatetime({String? message})` | `'must be in the future'` |
| `IsPastDatetime` | `IsPastDatetime({String? message})` | `'must be in the past'` |
| `IsSameDatetime` | `IsSameDatetime(String date, {String? message})` | `'must be the same moment as ...'` |

### Custom Validation

#### `Custom(String methodName, {String? message})`

References a static method on the annotated class. The method must have signature `static bool methodName(Object? value)` — returns `true` if valid.

```dart
@Endorse()
class NumberForm {
  @EndorseField(rules: [Custom('isEven', message: 'must be even')])
  final int value;

  const NumberForm._({required this.value});

  static bool isEven(Object? value) => value is int && value.isEven;

  Map<String, dynamic> toJson() => _$NumberFormToJson(this);
  static final $endorse = _$NumberFormValidator();
}
```

---

## Patterns

### Required Class Structure

Every `@Endorse()` class must follow this pattern:

```dart
import 'package:endorse/endorse.dart';

part 'my_request.g.dart';

@Endorse()
class MyRequest {
  // All fields must be final
  final String name;
  final int quantity;
  final String? optional;  // nullable = optional

  // Private constructor
  const MyRequest._({
    required this.name,
    required this.quantity,
    this.optional,
  });

  // Serialization helper (generated)
  Map<String, dynamic> toJson() => _$MyRequestToJson(this);

  // Validator accessor (generated)
  static final $endorse = _$MyRequestValidator();
}
```

Key conventions:
- `final` fields — immutable after construction
- Private constructor (`._`) — instances only created through validation
- Nullable fields (`String?`) are optional; non-nullable are required automatically
- `part` directive required for the `.g.dart` file

### Auto-Inferred Rules

Codegen infers these automatically — don't add them manually:
- `Required()` — for non-nullable fields
- Type rules (`IsString`, `IsInt`, etc.) — from Dart field type

Only add `@EndorseField(rules: [...])` for validation beyond type and presence.

### Nested Objects

Fields typed as other `@Endorse()` classes are validated recursively:

```dart
@Endorse()
class Order {
  final Address shippingAddress;   // required nested
  final Address? billingAddress;   // optional nested

  const Order._({required this.shippingAddress, this.billingAddress});
  Map<String, dynamic> toJson() => _$OrderToJson(this);
  static final $endorse = _$OrderValidator();
}
```

Errors use dot-paths: `'shippingAddress.street'`, `'billingAddress.zip'`.

### Lists of Nested Objects

```dart
@Endorse()
class OrderRequest {
  @EndorseField(rules: [MinElements(1)])
  final List<OrderLine> lines;

  const OrderRequest._({required this.lines});
  Map<String, dynamic> toJson() => _$OrderRequestToJson(this);
  static final $endorse = _$OrderRequestValidator();
}
```

Item errors: `'lines.0.quantity'`, `'lines.1.productId'`.

### Primitive Lists with Item Rules

```dart
@EndorseField(
  rules: [MinElements(1), UniqueElements()],
  itemRules: [MinLength(1), MaxLength(50)],
)
final List<String> tags;
```

Item errors: `'tags.0'`, `'tags.2'`.

### Conditional Validation

```dart
@EndorseField(
  rules: [MinLength(2)],
  when: When('country', equals: 'US'),
)
final String? state;  // required only when country == 'US'
```

When the condition is NOT met, the field is treated as optional.

### Either Constraint

```dart
@Endorse(either: [['email', 'phone']])
class ContactForm {
  @EndorseField(rules: [Email()])
  final String? email;

  @EndorseField(rules: [MinLength(7)])
  final String? phone;

  const ContactForm._({this.email, this.phone});
  Map<String, dynamic> toJson() => _$ContactFormToJson(this);
  static final $endorse = _$ContactFormValidator();
}
```

Error if neither provided: `{'email': ['at least one of [email, phone] is required'], 'phone': [...]}`.

### Cross-Field Validation

Add a static `crossValidate` method. Codegen detects it by name and calls it after field-level validation passes.

```dart
@Endorse()
class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  const DateRange._({required this.startDate, required this.endDate});

  static Map<String, List<String>> crossValidate(Map<String, Object?> input) {
    final errors = <String, List<String>>{};
    final start = input['startDate'];
    final end = input['endDate'];
    if (start is DateTime && end is DateTime && start.isAfter(end)) {
      errors['startDate'] = ['must be before endDate'];
    }
    return errors;
  }

  Map<String, dynamic> toJson() => _$DateRangeToJson(this);
  static final $endorse = _$DateRangeValidator();
}
```

### Field Name Mapping

```dart
@EndorseField(name: 'user_role', rules: [OneOf(['admin', 'user', 'guest'])])
final String role;  // reads from input['user_role'], writes 'user_role' in toJson
```

### Ignoring Fields

```dart
@EndorseField(ignore: true)
final String? internalNote;  // skipped during validation
```

### Frontend Form Validation

```dart
TextFormField(
  decoration: const InputDecoration(labelText: 'Name'),
  validator: (value) {
    final errors = CreateItemRequest.$endorse.validateField('name', value);
    return errors.isEmpty ? null : errors.first;
  },
)
```

### Registry-Based Lookup

```dart
void main() {
  EndorseRegistry.instance
    ..register<CreateItemRequest>(CreateItemRequest.$endorse)
    ..register<UpdateItemRequest>(UpdateItemRequest.$endorse);
}

// Framework looks up at request time:
final validator = EndorseRegistry.instance.get<CreateItemRequest>();
final result = validator.validate(body);
```

---

## Complete Working Example

```dart
import 'package:endorse/endorse.dart';

part 'order_request.g.dart';

// --- Nested type ---

@Endorse()
class OrderLine {
  @EndorseField(rules: [MinLength(1)])
  final String productId;

  @EndorseField(rules: [Min(1), Max(100)])
  final int quantity;

  const OrderLine._({required this.productId, required this.quantity});
  Map<String, dynamic> toJson() => _$OrderLineToJson(this);
  static final $endorse = _$OrderLineValidator();
}

// --- Main request ---

@Endorse(either: [['email', 'phone']])
class OrderRequest {
  @EndorseField(rules: [Trim(), MinLength(1), MaxLength(200)])
  final String customerName;

  @EndorseField(rules: [Trim(), LowerCase(), Email()])
  final String? email;

  @EndorseField(rules: [MinLength(7)])
  final String? phone;

  @EndorseField(rules: [OneOf(['standard', 'express', 'overnight'])])
  final String shippingMethod;

  @EndorseField(
    rules: [Matches(r'^\d{5}$', message: 'must be a 5-digit zip code')],
    when: When('shippingMethod', isOneOf: ['express', 'overnight']),
  )
  final String? priorityZip;

  @EndorseField(rules: [MinElements(1)])
  final List<OrderLine> lines;

  @EndorseField(
    rules: [MinElements(1), UniqueElements()],
    itemRules: [MinLength(1), MaxLength(30)],
  )
  final List<String>? tags;

  @EndorseField(rules: [IsFutureDatetime()])
  final DateTime? deliverBy;

  const OrderRequest._({
    required this.customerName,
    this.email,
    this.phone,
    required this.shippingMethod,
    this.priorityZip,
    required this.lines,
    this.tags,
    this.deliverBy,
  });

  static Map<String, List<String>> crossValidate(Map<String, Object?> input) {
    final errors = <String, List<String>>{};
    final lines = input['lines'];
    if (lines is List && lines.length > 50) {
      errors['lines'] = ['orders are limited to 50 line items'];
    }
    return errors;
  }

  Map<String, dynamic> toJson() => _$OrderRequestToJson(this);
  static final $endorse = _$OrderRequestValidator();
}

// --- Usage ---

void handleOrder(Map<String, Object?> body) {
  final result = OrderRequest.$endorse.validate(body);

  switch (result) {
    case ValidResult(:final value):
      print('Order for ${value.customerName}');
      print('${value.lines.length} line items');
      print('Ship via ${value.shippingMethod}');
      if (value.deliverBy != null) {
        print('Deliver by ${value.deliverBy}');
      }
      print(value.toJson());

    case InvalidResult(:final fieldErrors):
      for (final entry in fieldErrors.entries) {
        print('${entry.key}: ${entry.value.join(', ')}');
      }
  }
}
```

---

## Framework Integration

Endorse is the validation foundation for the framework. For how Swoop uses it for automatic request validation and how Trellis uses it for client-side form validation, see `docs/integration-guide.md` in the workspace root.
