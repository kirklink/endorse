# Endorse Modernization Plan

**Goal:** Evolve endorse from a functional validation library into a competitive, production-grade package on par with class-validator (TypeScript), FluentValidation (.NET), and Zod (TypeScript).

**Prerequisite:** Stabilization plan (Phases 1-5) complete. 48+ annotations, 48+ runtime rules, 400 tests passing.

**Current Status:** Phases 4, 1, 2, 3, 5, and 9 complete

---

## Key Principles

1. **Backwards-compatible** — Existing annotations and generated code must continue to work
2. **Incremental** — Each phase is independently valuable; no phase depends on all prior phases
3. **Codegen-first** — Maximize what the builder handles; minimize runtime boilerplate
4. **Test-driven** — Every feature ships with unit tests, annotation tests, and e2e codegen tests

---

## Critical Assessment

### Strengths to Preserve
- Map-first validation (validate before object construction)
- Declarative annotation-driven API
- Code generation eliminates boilerplate
- Clean three-layer separation (annotations → codegen → runtime)
- Typed result objects with entity hydration

### Gaps to Address (Priority Order)
1. **No custom error messages** — Messages are hardcoded in rule classes
2. **No custom validation escape hatch** — Every rule requires annotation + rule class + method + builder
3. **No conditional/cross-field validation** — Can't express field dependencies
4. **`call` string mechanism is fragile** — String template DSL with no compile-time safety
5. **No async validation** — Can't validate against external state (DB uniqueness, API checks)
6. **No validation groups** — Can't validate subsets of fields (wizard steps, partial updates)
7. **`$` prefix is unconventional** — Works but feels foreign to Dart developers
8. **`entity()` throws on invalid** — Runtime error where type system could help

### Competitive Landscape

| Feature | Endorse | class-validator (TS) | Zod (TS) | FluentValidation (.NET) |
|---------|---------|---------------------|----------|------------------------|
| Declarative rules | Yes | Yes | Yes (schema) | Yes (fluent) |
| Custom error messages | Yes | Yes | Yes | Yes |
| Custom validators | Yes | Yes | Yes (.refine) | Yes |
| Conditional validation | Yes | Yes (@ValidateIf) | Yes | Yes (.When) |
| Cross-field validation | Yes | Yes | Yes (.superRefine) | Yes |
| Async validation | No | Yes | Yes | Yes |
| Validation groups | No | Yes | No | Yes |
| Type coercion | Yes | Yes (transform) | Yes (.coerce) | No |
| Nested objects | Yes | Yes | Yes | Yes |
| Code generation | Yes | Reflect/transform | No (runtime) | No (runtime) |
| Typed results | Yes | No (throws) | Yes (inferred) | Yes |

---

## Phase 1: Custom Error Messages

**Goal:** Let users override default error messages per annotation instance

### 1.1 Add `message` Parameter to ValidationBase

**Files:** `lib/src/endorse/validations.dart`

Add an optional `message` parameter to `ValidationBase` and all annotation constructors:

```dart
class Required extends ValidationBase {
  const Required({String? message})
      : super('required()', null, const [String, int, double, num, bool, DateTime],
            message: message);
}

// Usage:
@EndorseField(validate: [Required(message: 'Name is required')])
late String name;
```

**Implementation:**
1. Add `final String? message` to `ValidationBase`
2. Update all 48+ annotation constructors to accept optional `message`
3. No breaking changes — parameter is optional with null default

### 1.2 Propagate Message Through Code Generation

**Files:** `lib/src/builder/field_helper.dart`, `lib/src/builder/endorse_class_helper.dart`

The builder must read the `message` annotation field and pass it to the generated `ValidateValue` call.

**Implementation:**
1. In `processValidations()`, read the `message` field from each annotation
2. Generate a `.withMessage('...')` call after the rule method when message is present
3. Add `withMessage(String)` method to `ValidateValue` that sets message on the last `RuleHolder`

### 1.3 Use Custom Message in Rule Evaluation

**Files:** `lib/src/endorse/evaluator.dart`, `lib/src/endorse/rule.dart`

**Implementation:**
1. Add optional `customMessage` field to `RuleHolder`
2. In `Evaluator`, when building `ValidationError`, prefer `customMessage` over `rule.errorMsg()`
3. Default behavior unchanged when no custom message provided

### 1.4 Tests

- Unit tests: custom message flows through RuleHolder → Evaluator → ValidationError
- Annotation tests: `message` field is readable on all annotations
- E2E test: generated code uses custom message in error output

---

## Phase 2: Custom Validators

**Goal:** Allow inline or referenced custom validation logic without creating full annotation + rule classes

### 2.1 `CustomRule` Runtime Class

**Files:** `lib/src/endorse/rule.dart`

```dart
class CustomRule extends Rule {
  final String _name;
  final bool Function(Object?) _test;
  final String _errorMessage;

  const CustomRule(this._name, this._test, this._errorMessage);

  @override String get name => _name;
  @override bool pass(Object? input, Object? testParam) => _test(input);
  @override String errorMsg(Object? input, Object? testParam) => _errorMessage;
  // ...
}
```

### 2.2 Programmatic Validation API

**Files:** `lib/src/endorse/validate_value.dart`

Add method for ad-hoc rules:

```dart
void custom(String name, bool Function(Object?) test, String errorMessage) {
  rules.add(RuleHolder(CustomRule(name, test, errorMessage)));
}
```

This works for programmatic (non-codegen) usage immediately.

### 2.3 Static Custom Validator Registration (Codegen Path)

**Files:** `lib/src/endorse/validations.dart`, `lib/src/builder/field_helper.dart`

For codegen, custom validators must be const-constructible. Approach: a `CustomValidation` annotation that references a static function by name.

```dart
@EndorseField(validate: [
  Required(),
  CustomValidation('isEvenNumber', 'Must be an even number'),
])
late int count;

// In the entity class or a referenced class:
static bool isEvenNumber(Object? value) => value is int && value % 2 == 0;
```

**Implementation:**
1. Add `CustomValidation` annotation class with `functionName` and `errorMessage`
2. Builder generates: `..custom('isEvenNumber', EntityClass.isEvenNumber, 'Must be an even number')`
3. Builder validates that the referenced static method exists at build time

### 2.4 Tests

- Unit tests: CustomRule pass/fail/error message
- Programmatic API test: `ValidateValue.custom()` works without codegen
- E2E test: `CustomValidation` annotation generates working code

---

## Phase 3: Conditional and Cross-Field Validation

**Goal:** Express field dependencies and cross-field constraints

### 3.1 `When` Conditional Annotation

**Files:** `lib/src/endorse/validations.dart`, `lib/src/builder/endorse_class_helper.dart`

```dart
@EndorseField(
  validate: [Required()],
  when: When('country', isEqualTo: 'US'),
)
late String state;
```

**Implementation:**
1. Add `When` class with `fieldName`, `isEqualTo`, `isNotNull`, `isOneOf` conditions
2. Add optional `when` parameter to `@EndorseField`
3. Builder generates conditional wrapper: `if (inputMap['country'] == 'US') { validate state }`
4. When condition not met, field is treated as optional (skipped)

### 3.2 Cross-Field Validation Method

**Files:** `lib/src/endorse/endorse_class_validator.dart`, `lib/src/builder/endorse_class_helper.dart`

```dart
@EndorseEntity()
class DateRange {
  @EndorseField(validate: [Required()])
  late DateTime startDate;

  @EndorseField(validate: [Required()])
  late DateTime endDate;

  // Cross-field validation — runs after all individual field validations
  static List<ValidationError> crossValidate(Map<String, dynamic> input) {
    final start = DateTime.tryParse(input['startDate']?.toString() ?? '');
    final end = DateTime.tryParse(input['endDate']?.toString() ?? '');
    if (start != null && end != null && end.isBefore(start)) {
      return [ValidationError('DateOrder', 'endDate must be after startDate', ...)];
    }
    return [];
  }
}
```

**Implementation:**
1. Builder detects `static List<ValidationError> crossValidate(Map<String, dynamic>)` method
2. Generated validator calls it after field-level validation
3. Cross-validation errors added to the `ClassResult.$errors` list
4. Individual field results remain unchanged

### 3.3 `Either` Constraint

```dart
@EndorseEntity(either: [['email', 'phone']])
class ContactInfo {
  String? email;
  String? phone;
}
```

At least one field in each group must be non-null. Builder generates the check.

### 3.4 Tests

- Unit tests: When condition evaluation
- E2E test: conditional field skipped/enforced based on sibling field value
- E2E test: crossValidate errors appear in result
- E2E test: either constraint with various combinations

---

## Phase 4: Refactor `call` String to `method` Name

**Goal:** Replace the fragile `call` string template mechanism with clean method name + value separation

### The Problem

Annotations currently embed a code template in the `call` field:
```dart
class MaxLength extends ValidationBase {
  final String call = 'maxLength(@)';    // method name + argument template
  final int value;
}
class MatchesPattern extends ValidationBase {
  final String call = 'matchesPattern(r@)';  // 'r@' hack encodes raw string syntax
}
```

The builder does `call.replaceFirst('@', serializedValue)` to produce `..maxLength(100)`. This is a micro-template DSL with no compile-time safety — typos in method names silently generate broken Dart code.

### 4.1 Split `call` into `method` Field

**Files:** `lib/src/endorse/validations.dart`

Rename `call` to `method` on `ValidationBase`. Store only the method name, not a code template:

```dart
abstract class ValidationBase {
  final String method;
  final List<Type> validOnTypes;
  const ValidationBase(this.method, this.validOnTypes);
}

class MaxLength extends ValidationBase {
  final int value;
  const MaxLength(this.value) : super('maxLength', const [String]);
}

class MatchesPattern extends ValidationBase {
  final String value;
  final bool rawString = true;
  const MatchesPattern(this.value) : super('matchesPattern', const [String]);
}
```

The `@` token, `r@` hack, and `()` suffix all disappear. Annotations become pure data.

### 4.2 Update Builder to Construct Calls

**Files:** `lib/src/builder/field_helper.dart`

`processValidations` reads the method name and constructs the call:

```dart
final method = rule.getField('method')!.toStringValue()!;
final serialized = serializeValue(rule);
ruleCall += serialized.isEmpty ? '..$method()' : '..$method($serialized)';
```

Value serialization (strings get quotes, ints are bare, lists get brackets, raw strings get `r` prefix) stays in one place. The `replaceFirst('@', value)` line is removed.

### 4.3 Build-Time Method Validation

With method names as plain strings, add validation:

1. Maintain a `Set<String>` of valid `ValidateValue` method names
2. At build time, check each annotation's `method` against the set
3. Emit `log.severe()` with annotation name, field name, and valid methods on mismatch

### 4.4 Tests

- All existing tests continue to pass (generated code is identical)
- Annotation tests: verify `method` field on all annotations
- Builder test: unknown method name produces clear build error

---

## Phase 5: Result API Improvements — DONE

**Goal:** Make results more ergonomic for API error responses and safer for entity access

### 5.1 `$errorsJson` on All Result Types

**Files:** `result_object.dart`, `class_result.dart`, `list_result.dart`, `value_result.dart`

`ValueResult.$errorsJson` already existed but `ClassResult` and `ListResult` were missing it, and `ResultObject` had it commented out. Finished the implementation so `result.$errorsJson` produces structured error output ready for API responses.

**Design:**
- `ValueResult.$errorsJson` → `List<Map>` — list of `{ruleName: {message, got}}` maps
- `ClassResult.$errorsJson` → `Map<String, Object>` — keys are field names, values are that field's `$errorsJson`. Only includes invalid fields. Cross-errors under `_cross` key, field-level pre-validation errors under `_self` key
- `ListResult.$errorsJson` → `Map<String, Object>` — list-level errors under `_self`, element errors under indexed string keys (`'0'`, `'1'`, etc.)
- `ResultObject.$errorsJson` uncommented — now part of the abstract interface

```dart
final result = MyEntity.$endorse.validate(input);
if (result.$isNotValid) {
  return Response.json(result.$errorsJson);
  // {"name": [{"required": {"message": "Field is required", "got": "null"}}],
  //  "address": {"street": [...]},
  //  "_cross": [{"DateOrder": {"message": "end must be after start", "got": "..."}}]}
}
```

### 5.2 Safe Entity Access (`entityOrNull()`)

**Files:** `lib/src/builder/endorse_class_helper.dart`

Builder now generates `entityOrNull()` alongside `entity()`:

```dart
// Generated:
MyEntity? entityOrNull() {
  if ($isNotValid) return null;
  return entity();
}
```

Delegates to `entity()` rather than duplicating the body. Safe — the throw path in `entity()` is never reached since we check `$isNotValid` first.

### 5.3 Typed Field Getters — Dropped

Typed `$value` getters were dropped. `entity()` is the canonical typed-access path; `$value` is the low-level escape hatch.

### 5.4 Tests

- 17 unit tests in `test/result_api_test.dart`: ValueResult, ClassResult, ListResult `$errorsJson` structure, nesting, cross-errors, `_self`
- 9 e2e tests in `arrow_example/test/comprehensive_entity_test.dart`: `entityOrNull()` (valid/invalid/nested) + `$errorsJson` (valid/invalid/nested/cross-errors/list)

---

## Phase 6: Async Validation (Future Consideration)

**Goal:** Support validation rules that require async operations (DB lookups, API calls)

**Note:** This is the most architecturally significant change. It ripples through the entire stack: `Rule.pass()` becomes `Future<bool>`, `Evaluator.evaluate()` becomes async, `ValidateValue.from()` returns `Future<ValueResult>`, generated `validate()` returns `Future<ClassResult>`. This should only be attempted after Phases 1-5 are stable.

### 6.1 Design Decision: Separate Async Pipeline

Rather than making the entire validation pipeline async, consider a separate `validateAsync()` method:

```dart
// Sync (existing, unchanged):
final result = MyEntity.$endorse.validate(input);

// Async (new, for rules that need it):
final result = await MyEntity.$endorse.validateAsync(input);
```

**Implementation sketch:**
1. Add `AsyncRule` base class with `Future<bool> passAsync()`
2. Add `AsyncEvaluator` that awaits each rule
3. Builder generates `validateAsync()` alongside `validate()` when async rules are present
4. Async rules: `IsUnique(table, column)`, `Exists(table, column)`, custom async

### 6.2 Tests

- Unit tests: AsyncEvaluator runs async rules
- Integration test: mixed sync and async rules
- E2E test: generated validateAsync() works

---

## Phase 7: Validation Groups (Future Consideration)

**Goal:** Validate subsets of fields for different contexts (create vs update, wizard steps)

```dart
@EndorseEntity()
class User {
  @EndorseField(validate: [Required()], groups: ['create', 'update'])
  late String name;

  @EndorseField(validate: [Required(), IsEmail()], groups: ['create'])
  late String email;

  @EndorseField(validate: [MinLength(8)], groups: ['update'])
  String? newPassword;
}

// Usage:
final result = User.$endorse.validate(input, group: 'create');  // validates name + email
final result = User.$endorse.validate(input, group: 'update');  // validates name + newPassword
```

---

## Phase 8: Transformation Pipeline (Future Consideration)

**Goal:** Generalize the `Trim()` pattern into a first-class transformation system

Currently `Trim()` is the only transform rule — it modifies the value before subsequent rules run. But there's no general mechanism for transforms. Users can't lowercase, strip HTML, normalize unicode, parse dates from custom formats, etc.

### 8.1 `Transform` Annotation

```dart
@EndorseField(validate: [
  Required(),
  Transform('normalizeEmail'),  // references a static method
  IsEmail(),
])
late String email;

static String normalizeEmail(Object? value) =>
    (value as String).toLowerCase().trim();
```

### 8.2 Built-in Transforms

Add common transforms alongside `Trim()`:
- `ToLowerCase()` — lowercase the value
- `ToUpperCase()` — uppercase the value
- `DefaultValue(value)` — use default when null (before Required check)

### 8.3 Implementation

Transforms use the same `causesBail: false` + cast mechanism as `Trim()`. The evaluator already supports rules that modify the value via `cast()`. The infrastructure exists — it just needs more rules and the custom transform annotation.

---

## Phase 9: Advanced Collection Validation — DONE

**Goal:** Deeper validation of list contents beyond element-level rules

### 9.1 Bug Fix: List Field-Level Validation Processing

`processValidations(validations, fieldType)` was never called for list field-level annotations in `endorse_class_helper.dart`. The `isValue && !isList` guard meant annotations like `MinElements(2)` in the `validate:` list didn't generate code. Fixed by adding list field-level processing after item-level processing, including `CustomValidation` and `AnyElement` handling.

### 9.2 UniqueElements

```dart
@EndorseField(
  validate: [Required(), UniqueElements()],
  itemValidate: [MinLength(1)],
)
late List<String> tags;
```

Runtime rule checks `input.length == input.toSet().length`. Error message reports which elements are duplicated.

### 9.3 AnyElement

```dart
@EndorseField(
  validate: [Required(), AnyElement([IsGreaterThan(100)])],
)
late List<int> scores;
```

Takes nested `List<ValidationBase>` annotations. Builder processes nested rules via `processValidations` with the element type for type checking. Runtime uses a closure-based rule to avoid circular dependency between `rule.dart` and `validate_value.dart`.

### 9.4 Tests

- 19 unit tests: uniqueElements (8) + anyElement (7) + annotation tests (4)
- 16 e2e tests in `arrow_example/test/collection_entity_test.dart`: MinElements, UniqueElements, AnyElement, MaxElements on nullable, combined field+item validation, entity hydration

---

## Priority and Dependencies

```
Phase 4 (call → method)       ← Foundation cleanup, do first
  ↓
Phase 1 (Custom Messages)     ← Highest value, lowest effort
  ↓
Phase 2 (Custom Validators)   ← Unblocks most user needs
  ↓
Phase 3 (Conditional)         ← High value, moderate effort
  ↓
Phase 5 (Result API)          ← Polish and ergonomics
  ↓
Phase 8 (Transforms)          ← Generalizes existing pattern
  ↓
Phase 9 (Collections)         ← Fills out collection support
  ↓
Phase 6 (Async)               ← High effort, evaluate need
  ↓
Phase 7 (Groups)              ← Niche use case, lowest priority
```

Phase 4 should come first — it cleans up the annotation/builder contract before new features build on top of it. Phases 1-3 close the biggest competitive gaps. Phase 5 is polish. Phases 8-9 fill out the rule library. Phases 6-7 are stretch goals.

---

## Out of Scope

1. **Flutter form integration** — Endorse is server-side / map-first. Flutter form bindings are a separate package.
2. **OpenAPI schema generation** — Better handled by arrow_openapi reading the annotations
3. **i18n / localization of error messages** — Custom messages (Phase 1) covers the 80% case
4. **Dropping code generation entirely** — Codegen is the core value proposition
5. **Renaming the `$` prefix** — Too much churn for cosmetic benefit at this stage

---

## Success Metrics

| Metric | Target |
|--------|--------|
| `call` string eliminated, `method` field on all annotations | Phase 4 done |
| Build-time validation catches invalid method names | Phase 4 done |
| Custom messages working e2e | Phase 1 done |
| Custom validators working e2e | Phase 2 done |
| Conditional validation working e2e | Phase 3 done |
| `$errorsJson` on all result types + `entityOrNull()` | Phase 5 done |
| General-purpose transforms working | Phase 8 done |
| UniqueElements + AnyElement collection constraints | Phase 9 done |
| Feature parity with class-validator (core features) | Phases 1-3 done |

---

**Last Updated:** 2026-02-19
**Status:** Phases 4, 1, 2, 3, 5, and 9 complete. 385 endorse tests + 223 e2e tests passing.
