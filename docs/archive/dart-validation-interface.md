# Validation Interface — API Framework Contract

This document defines the validation interface that the API framework expects. It does not prescribe how the validator is implemented internally — only what it must provide to integrate with the framework's request pipeline.

The validator library is a separate package. The framework depends on a small set of types and conventions described here. Whether those are implemented via codegen, hand-written code, or some other mechanism is up to the validator library.

---

## 1. Core Principle: Valid by Construction

The framework requires that request objects are **immutable and only constructable through validation**. A handler never receives a partially populated or unvalidated object. If validation passes, the handler gets a fully typed, immutable instance. If validation fails, the handler never runs.

This means:
- Request classes have no public constructors.
- The only way to obtain an instance is through the validation pipeline.
- Once constructed, the object cannot be modified.
- There is no state where the object exists but is invalid.

The validation library is also usable on the **frontend** — for form field validation, progressive validation as the user types, and client-side request construction. This means the codegen must produce artifacts that work in both contexts: full-object validation for the server pipeline, and single-field validation for frontend forms.

---

## 2. Types the Framework Depends On

### 2.1 EndorseResult\<T\>

The outcome of validation. A sealed type — either the validated object or structured errors. No exceptions, no nulls, no ambiguity.

```dart
sealed class EndorseResult<T> {
  const EndorseResult();
}

class ValidResult<T> extends EndorseResult<T> {
  final T value;
  const ValidResult(this.value);
}

class InvalidResult<T> extends EndorseResult<T> {
  final Map<String, List<String>> fieldErrors;
  const InvalidResult(this.fieldErrors);
}
```

`fieldErrors` is a map of field name → list of error messages for that field. Example:

```json
{
  "name": ["is required", "must be at least 1 character"],
  "quantity": ["must be greater than 0"]
}
```

The framework maps `InvalidResult` directly to a 400 response:

```json
{
  "error": {
    "type": "BadRequest",
    "message": "Validation failed",
    "fields": {
      "name": ["is required", "must be at least 1 character"],
      "quantity": ["must be greater than 0"]
    }
  }
}
```

### 2.2 EndorseValidator\<T\>

The interface a validator must implement for a given request type. Supports both full-object validation (server pipeline) and single-field validation (frontend forms).

```dart
abstract interface class EndorseValidator<T> {
  /// Validate an entire object from a raw map.
  /// Used by the server pipeline.
  EndorseResult<T> validate(Map<String, Object?> input);
  
  /// Validate a single field by name.
  /// Used by frontend forms for per-field validation as the user types.
  /// Returns a list of error messages, or an empty list if valid.
  List<String> validateField(String fieldName, Object? value);
  
  /// List of all field names this validator knows about.
  /// Useful for form generation and introspection.
  Set<String> get fieldNames;
}
```

The `validateField` method is the key to frontend usability. It allows a form to validate one field at a time without constructing or submitting the full object. This is critical for UX patterns like:
- Real-time validation as the user types
- Showing field-level errors on blur
- Enabling/disabling submit based on field validity
- Progressive form completion

The field-level validators are the **same rules** as the full-object validation — not a separate definition. The codegen produces both paths from the same annotations, so they cannot drift apart.

### 2.3 EndorseRegistry

A registry that maps request types to their validators. Populated at startup.

```dart
class EndorseRegistry {
  static final instance = EndorseRegistry._();
  EndorseRegistry._();
  
  final _validators = <Type, EndorseValidator>{};
  
  void register<T>(EndorseValidator<T> validator) {
    _validators[T] = validator;
  }
  
  EndorseValidator<T> get<T>() {
    final v = _validators[T];
    if (v == null) throw StateError('No validator registered for $T');
    return v as EndorseValidator<T>;
  }
}
```

Registration happens once at startup, alongside role/claim registration:

```dart
void main() async {
  // Register validators (generated or hand-written)
  registerValidators();
  
  // Register roles, claims, start server...
}
```

---

## 3. Request Class Convention

The framework expects validated request classes to follow this shape:

```dart
class CreateItemRequest {
  final String name;
  final int quantity;
  final String? description;
  
  // Private constructor — only the validator produces instances
  const CreateItemRequest._({
    required this.name,
    required this.quantity,
    this.description,
  });
  
  // Static accessor to the validator (used by the registry or directly)
  static final $endorse = _$CreateItemRequestEndorse();
}
```

Key conventions:
- **All fields are `final`**. The object is immutable after construction.
- **Constructor is private** (`._`). Application code cannot bypass validation.
- **`$endorse` static field** provides access to the validator instance. The name is a convention the framework and codegen both know about.
- **Nullable fields** (`String?`) represent optional input. The validator treats them as optional unless explicitly annotated otherwise.

---

## 4. How the Framework Uses It

### 4.1 Route Registration

The framework's route registration carries the request type as a generic:

```dart
server.route<CreateItemRequest, ItemResponse>(
  method: HttpMethod.post,
  path: '/api/items',
  handler: (ctx, body) async {
    // body is CreateItemRequest — immutable, validated
    return ItemResponse(...);
  },
);
```

### 4.2 Request Pipeline

When a request arrives for this route:

```
Raw HTTP body (bytes)
  → JSON parse to Map<String, Object?>
  → EndorseRegistry.get<CreateItemRequest>().validate(map)
  → ValidResult: pass body to handler
  → InvalidResult: return 400 with field errors, handler never called
```

The framework handles the JSON parse step. The validator receives a `Map<String, Object?>` and returns `EndorseResult<T>`. The framework never calls the private constructor directly.

### 4.3 No Body Routes

Routes that don't expect a request body skip validation entirely:

```dart
server.route<Void, ItemListResponse>(
  method: HttpMethod.get,
  path: '/api/items',
  handler: (ctx) async { ... },
);
```

No validator is looked up, no body parsing occurs. The handler signature has no body parameter.

---

## 5. What the Validator Must Handle

The validator is responsible for everything between raw map and valid typed object. This includes:

### 5.1 Type Coercion

JSON numbers might arrive as `int` or `double` depending on the JSON parser. The validator should handle reasonable coercions (e.g., `double` 5.0 → `int` 5) without requiring the caller to pre-process.

### 5.2 Required vs Optional

- A `final String name` field (non-nullable) is required. Missing or null input is a validation error.
- A `final String? description` field (nullable) is optional. Missing or null input is acceptable.

The validator infers this from the class definition (via codegen) or explicit annotation.

### 5.3 Nested Objects

Request bodies may contain nested validated objects:

```dart
class CreateOrderRequest {
  final String customerId;
  final List<OrderLineRequest> lines;
  
  const CreateOrderRequest._({
    required this.customerId,
    required this.lines,
  });
  
  static final $endorse = _$CreateOrderRequestEndorse();
}

class OrderLineRequest {
  final String productId;
  final int quantity;
  
  const OrderLineRequest._({
    required this.productId,
    required this.quantity,
  });
  
  static final $endorse = _$OrderLineRequestEndorse();
}
```

The parent validator calls child validators for nested objects. Errors are reported with dot-path field names:

```json
{
  "lines.0.quantity": ["must be greater than 0"],
  "lines.2.productId": ["is required"]
}
```

### 5.4 Collection Validation

Lists and maps may have both collection-level and item-level rules:

```dart
@EndorseField(
  validate: [Required(), MinElements(1)],     // the list itself
  itemValidate: [MinLength(1)],               // each item in the list
)
final List<String> tags;
```

The validator reports item-level errors with indexed field names: `"tags.0"`, `"tags.3"`.

### 5.5 Cross-Field Validation

Some validation rules depend on multiple fields (e.g., `endDate` must be after `startDate`). The validator should support class-level rules that run after field-level validation passes:

```dart
@EndorseEntity(validate: [DateRangeValid('startDate', 'endDate')])
class CreateEventRequest {
  final DateTime startDate;
  final DateTime endDate;
  // ...
}
```

Cross-field errors may use a synthetic field name (e.g., `"_entity"`) or reference the specific fields involved.

---

## 6. Error Message Convention

Error messages are human-readable strings. They describe *what is wrong*, not what the rule is:

- `"is required"` — not `"Required()"`
- `"must be at least 1 character"` — not `"MinLength(1)"`
- `"must be greater than 0"` — not `"IsGreaterThan(0)"`

The framework passes these through to the API response as-is. They should be suitable for display to end users or consumption by a frontend for field-level error rendering.

The validator library defines the default messages. Applications should be able to override messages per field or per rule if needed.

---

## 7. Built-In Validators the Library Should Provide

The framework does not require a specific set of validators, but the following are expected to exist in any reasonable implementation:

### Presence & Type
- Required — value must be present and non-null
- IsString, IsInt, IsDouble, IsBool, IsDateTime — type checks with coercion where reasonable

### String
- MinLength, MaxLength — character count
- Pattern — regex match
- IsEmail, IsUrl — common format checks (if the library provides them; not required by the framework)

### Numeric
- Min, Max — inclusive bounds
- IsGreaterThan, IsLessThan — exclusive bounds
- IsPositive, IsNegative — sign checks

### Collection
- MinElements, MaxElements — list/map size
- UniqueElements — no duplicates
- AnyElement, EveryElement — apply a rule across items

### Cross-Field
- A mechanism for class-level rules that access multiple validated field values

This list is illustrative, not prescriptive. The framework only cares about the interface (`EndorseValidator<T>` and `EndorseResult<T>`), not the rule vocabulary.

---

## 8. Codegen Expectations

If the validator uses code generation (recommended), the framework expects:

- **Input**: An annotated Dart class with `@EndorseEntity()` and `@EndorseField()` annotations (or equivalent).
- **Output**: A class implementing `EndorseValidator<T>` that validates a `Map<String, Object?>` and returns `EndorseResult<T>`. This class must support both full-object validation and single-field validation from the same rule definitions.
- **Registration function**: A generated function that registers all validators in the project with `EndorseRegistry`:

```dart
// Generated: lib/validators.g.dart
void registerValidators() {
  EndorseRegistry.instance
    ..register<CreateItemRequest>(CreateItemRequest.$endorse)
    ..register<UpdateItemRequest>(UpdateItemRequest.$endorse)
    ..register<CreateOrderRequest>(CreateOrderRequest.$endorse)
    ..register<OrderLineRequest>(OrderLineRequest.$endorse);
}
```

This function is called once at server startup. The framework looks up validators from the registry at request time. On the frontend, the validators are used directly via `$endorse` without the registry.

- **Co-location**: Generated code lives alongside the source class as a `.g.dart` part file, consistent with Dart codegen conventions.
- **Build step**: The codegen runs via `build_runner`, which projects using this framework already require for serialization.

---

## 9. Frontend Usage

The validation library is a shared dependency — it runs on both server and frontend. The same annotated request class, the same generated validator, the same rules. This is one of the primary advantages of Dart on both sides of the wire.

### 9.1 Single-Field Validation in Forms

The most common frontend use case: validate a single field as the user interacts with a form.

```dart
// Flutter form field example
TextFormField(
  decoration: const InputDecoration(labelText: 'Name'),
  validator: (value) {
    final errors = CreateItemRequest.$endorse.validateField('name', value);
    return errors.isEmpty ? null : errors.first;
  },
)
```

Or in a Dart web frontend:

```dart
void onNameInput(String value) {
  final errors = CreateItemRequest.$endorse.validateField('name', value);
  if (errors.isNotEmpty) {
    showFieldError('name', errors);
  } else {
    clearFieldError('name');
  }
}
```

The field name is a string here, which is the one place where stringly-typed access is unavoidable — form fields are inherently identified by name. However, the `fieldNames` set on the validator allows compile-time-adjacent safety:

```dart
// Can assert field names are valid at form construction time
assert(CreateItemRequest.$endorse.fieldNames.contains('name'));
```

### 9.2 Full-Object Validation Before Submit

Before sending a request, the frontend can run full validation and surface all errors at once:

```dart
void onSubmit(Map<String, Object?> formData) {
  final result = CreateItemRequest.$endorse.validate(formData);
  
  switch (result) {
    case ValidResult(:final value):
      // value is an immutable, validated CreateItemRequest
      // Send it to the server (serialize via toJson on the validated instance)
      api.post('/api/items', value.toJson(), ItemResponse.fromJson);
    case InvalidResult(:final fieldErrors):
      // Show field-level errors in the form
      for (final entry in fieldErrors.entries) {
        showFieldError(entry.key, entry.value);
      }
  }
}
```

### 9.3 Client-Side Serialization

The validated request object needs a `toJson()` method for the frontend to serialize it before sending. This means the codegen should produce:

```dart
class CreateItemRequest {
  final String name;
  final int quantity;
  final String? description;
  
  const CreateItemRequest._({
    required this.name,
    required this.quantity,
    this.description,
  });
  
  /// Serialize to JSON for sending to the server.
  /// This is the only public way to get a Map from a validated instance.
  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    if (description != null) 'description': description,
  };
  
  static final $endorse = _$CreateItemRequestEndorse();
}
```

The frontend flow becomes: form data → `validate()` → `ValidResult` with immutable instance → `toJson()` → send to server. The server re-validates on receipt (defense in depth), but the frontend catches errors early for good UX.

### 9.4 Cross-Field Validation in Forms

For cross-field rules (e.g., end date must be after start date), the frontend can run full-object validation on submit, or the codegen can expose entity-level validators separately:

```dart
// Validate the relationship between fields on submit
final result = CreateEventRequest.$endorse.validate({
  'startDate': startDateController.text,
  'endDate': endDateController.text,
  // ... other fields
});
```

Cross-field errors reference specific fields in `fieldErrors`, so the form can highlight the relevant fields.

---

## 10. Package Boundary

The validation library (Endorse) is a separate package from the API framework. Both the server and frontend depend on it.

```
endorse/                  # Validation library package
  lib/
    endorse.dart          # Core exports: annotations, result types, validator interface
    src/
      annotations.dart    # @EndorseEntity, @EndorseField
      result.dart         # EndorseResult, ValidResult, InvalidResult
      validator.dart      # EndorseValidator interface
      registry.dart       # EndorseRegistry (used by server, optional on frontend)
      rules/              # Built-in validation rules
        required.dart
        string_rules.dart
        numeric_rules.dart
        collection_rules.dart
  generator/              # build_runner codegen
```

The API framework depends on `endorse` for `EndorseValidator<T>`, `EndorseResult<T>`, and `EndorseRegistry`. It does not depend on the annotations, rules, or codegen — those are build-time and authoring concerns.

The frontend depends on `endorse` for `EndorseValidator<T>` and `EndorseResult<T>`. It uses the `$endorse` static field on request classes directly, without the registry.

Annotated request classes live in the consuming project's `shared/` directory (or wherever shared types live), and are accessible to both server and frontend via the framework's client export.

---

## 11. Summary: The Contract

The framework and frontend need the following from the validation library:

| What | Type | Used By | Purpose |
|---|---|---|---|
| Full-object validation | `EndorseValidator<T>.validate()` | Server pipeline, frontend submit | Validates `Map<String, Object?>` → `EndorseResult<T>` |
| Single-field validation | `EndorseValidator<T>.validateField()` | Frontend forms | Validates one field by name → list of error messages |
| Field introspection | `EndorseValidator<T>.fieldNames` | Frontend forms | Set of known field names for assertion/generation |
| Validation result | `EndorseResult<T>` | Server, frontend | Sealed: `ValidResult<T>` with immutable instance, or `InvalidResult` with field errors |
| Validator registry | `EndorseRegistry` | Server pipeline | Maps types to validators, populated at startup |
| Serialization | `T.toJson()` | Frontend client | Serialize validated instance for sending to server |

Everything else — annotation syntax, rule vocabulary, codegen strategy, error message formatting — is the validator library's internal concern. The framework and frontend couple only to these types and conventions.
