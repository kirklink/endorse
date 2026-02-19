# Phase 8: Transformation Pipeline

## Context

Phases 4, 1, 2, 3, 5, and 9 are complete (385 endorse + 223 e2e = 608 tests). Phase 8 generalizes the existing `Trim()` pattern into a first-class transformation system with built-in and custom transforms.

The infrastructure already exists: `Rule.cast()` in the Evaluator pipeline modifies `_inputCast` after each rule. `TrimRule` demonstrates the pattern: `pass()=>true` (always passes), `cast()` modifies the value. No new evaluator changes needed.

## Scope

1. **ToLowerCase()** — lowercase string transform
2. **ToUpperCase()** — uppercase string transform
3. **DefaultValue(value)** — substitute default when null (placed before Required)
4. **Transform('functionName')** — custom transform referencing a static method (like CustomValidation pattern)

## Implementation Steps

### Step 1: ToLowerCase and ToUpperCase annotations

**File:** `endorse/lib/src/endorse/validations.dart` — after Trim class (~line 446)

```dart
class ToLowerCase extends ValidationBase {
  @override final String method = 'toLowerCase';
  @override final List<Type> validOnTypes = const [String];
  @override final String? message;
  const ToLowerCase({this.message});
}

class ToUpperCase extends ValidationBase {
  @override final String method = 'toUpperCase';
  @override final List<Type> validOnTypes = const [String];
  @override final String? message;
  const ToUpperCase({this.message});
}
```

### Step 2: ToLowerCase and ToUpperCase runtime rules

**File:** `endorse/lib/src/endorse/rule.dart` — after TrimRule (~line 966)

Follow TrimRule pattern exactly: `pass()=>true`, `cast()` transforms.

```dart
class ToLowerCaseRule extends Rule {
  const ToLowerCaseRule();
  @override String get name => 'ToLowerCase';
  @override bool pass(Object? input, Object? test) => true;
  @override String errorMsg(Object? input, Object? test) => '';
  @override Object? cast(Object? input) => input is String ? input.toLowerCase() : input;
}

class ToUpperCaseRule extends Rule {
  const ToUpperCaseRule();
  @override String get name => 'ToUpperCase';
  @override bool pass(Object? input, Object? test) => true;
  @override String errorMsg(Object? input, Object? test) => '';
  @override Object? cast(Object? input) => input is String ? input.toUpperCase() : input;
}
```

### Step 3: ToLowerCase and ToUpperCase ValidateValue methods

**File:** `endorse/lib/src/endorse/validate_value.dart` — after trim() (~line 214)

```dart
void toLowerCase() {
  rules.add(RuleHolder(ToLowerCaseRule()));
}

void toUpperCase() {
  rules.add(RuleHolder(ToUpperCaseRule()));
}
```

### Step 4: DefaultValue annotation

**File:** `endorse/lib/src/endorse/validations.dart`

```dart
class DefaultValue extends ValidationBase {
  @override final String method = 'defaultValue';
  @override final String? message;
  final Object value;
  const DefaultValue(this.value, {this.message});
}
```

Uses `Object` for the value field since defaults can be any type. The `validOnTypes` is left empty (default) — works on all types.

### Step 5: DefaultValue runtime rule

**File:** `endorse/lib/src/endorse/rule.dart`

```dart
class DefaultValueRule extends Rule {
  final Object _defaultValue;
  const DefaultValueRule(this._defaultValue);

  @override String get name => 'DefaultValue';
  @override bool get skipIfNull => false;  // Must run when null to apply default
  @override bool pass(Object? input, Object? test) => true;
  @override String errorMsg(Object? input, Object? test) => '';
  @override Object? cast(Object? input) => input ?? _defaultValue;
}
```

Key: `skipIfNull => false` — the rule must execute when input is null so it can substitute the default.

### Step 6: DefaultValue ValidateValue method

**File:** `endorse/lib/src/endorse/validate_value.dart`

```dart
void defaultValue(Object value) {
  rules.add(RuleHolder(DefaultValueRule(value)));
}
```

### Step 7: DefaultValue builder special case

**File:** `endorse/lib/src/builder/field_helper.dart`

DefaultValue uses `Object value` which isn't handled by the standard value serialization in `processValidations` (it only handles String, int, double, List<String>). Add special handling at the top of the for-loop (before the standard value serialization), using `continue` to skip the normal path:

```dart
if (rule.type!.getDisplayString(withNullability: false) == 'DefaultValue') {
  final valueField = rule.getField('value')!;
  String serialized;
  if (valueField.type!.isDartCoreString) {
    serialized = "'${valueField.toStringValue()}'";
  } else if (valueField.type!.isDartCoreInt) {
    serialized = valueField.toIntValue().toString();
  } else if (valueField.type!.isDartCoreDouble) {
    serialized = valueField.toDoubleValue().toString();
  } else if (valueField.type!.isDartCoreBool) {
    serialized = valueField.toBoolValue().toString();
  } else {
    throw EndorseBuilderException('DefaultValue only supports String, int, double, bool');
  }
  ruleCall += '..defaultValue($serialized)';
  final customMessage = rule.getField('message')?.toStringValue();
  if (customMessage != null) {
    ruleCall += "..withMessage('$customMessage')";
  }
  continue;
}
```

### Step 8: Transform annotation

**File:** `endorse/lib/src/endorse/validations.dart`

```dart
class Transform extends ValidationBase {
  @override final String method = 'transform';
  @override final String? message;
  final String functionName;
  const Transform(this.functionName, {this.message});
}
```

Follows the CustomValidation pattern: `functionName` references a static method on the entity class.

### Step 9: TransformRule runtime rule

**File:** `endorse/lib/src/endorse/rule.dart`

```dart
class TransformRule extends Rule {
  final String _name;
  final Object? Function(Object?) _transform;
  TransformRule(this._name, this._transform);

  @override String get name => _name;
  @override bool get skipIfNull => false;  // Transform may handle null
  @override bool pass(Object? input, Object? test) => true;
  @override String errorMsg(Object? input, Object? test) => '';
  @override Object? cast(Object? input) => _transform(input);
}
```

### Step 10: Transform ValidateValue method

**File:** `endorse/lib/src/endorse/validate_value.dart`

```dart
void transform(String name, Object? Function(Object?) fn) {
  rules.add(RuleHolder(TransformRule(name, fn)));
}
```

### Step 11: Transform builder handling

**File:** `endorse/lib/src/builder/field_helper.dart` — skip Transform in processValidations:

```dart
if (rule.type!.getDisplayString(withNullability: false) == 'Transform') {
  continue;
}
```

**File:** `endorse/lib/src/builder/endorse_class_helper.dart` — handle Transform alongside CustomValidation in all three loops (non-list ~line 430, item-level ~line 492, list field-level ~line 526):

```dart
if (rule.type!.getDisplayString(withNullability: false) == 'Transform') {
  final functionName = rule.getField('functionName')!.toStringValue()!;
  final hasMethod = clazz.methods.any((m) => m.isStatic && m.name == functionName);
  if (!hasMethod) {
    throw EndorseBuilderException(
        "Transform references '$functionName' but no static "
        "method with that name was found on ${clazz.name}");
  }
  fieldRulesBuf.write("..transform('$functionName', ${clazz.name}.$functionName)");
  final customMessage = rule.getField('message')?.toStringValue();
  if (customMessage != null) {
    fieldRulesBuf.write("..withMessage('$customMessage')");
  }
}
```

### Step 12: Unit tests

**File:** `endorse/test/rule_test.dart` — add groups:

- **toLowerCase**: transforms string, passes through non-string, pass always true
- **toUpperCase**: transforms string, passes through non-string, pass always true
- **defaultValue**: substitutes when null, passes through when not null, works with int/string/bool, skipIfNull is false
- **transform**: applies custom function, pass always true, skipIfNull is false

**File:** `endorse/test/annotations_test.dart` — add:

- ToLowerCase, ToUpperCase, DefaultValue, Transform annotation field tests

### Step 13: E2e entity + tests

**File:** `arrow_example/lib/src/transform_entity.dart` — NEW

```dart
@EndorseEntity()
class TransformEntity {
  @EndorseField(validate: [Required(), Trim(), ToLowerCase(), IsEmail()])
  late String email;

  @EndorseField(validate: [Required(), ToUpperCase()])
  late String code;

  @EndorseField(validate: [DefaultValue('guest'), IsNotEmpty()])
  String? role;

  @EndorseField(validate: [Required(), Transform('normalizePhone')])
  late String phone;

  static Object? normalizePhone(Object? value) {
    if (value is! String) return value;
    return value.replaceAll(RegExp(r'[^\d+]'), '');
  }

  TransformEntity();
  static final $endorse = _$TransformEntityEndorse();
}
```

**File:** `arrow_example/test/transform_entity_test.dart` — NEW

Tests:
- ToLowerCase transforms email before validation
- ToUpperCase transforms code to uppercase
- DefaultValue substitutes when null, passes through when provided
- Transform calls static normalizePhone method
- Entity hydration preserves transformed values
- Combination: Trim + ToLowerCase + IsEmail works end-to-end

### Step 14: Regenerate + run all tests

1. `dart test` in endorse/ — all 385 + new unit tests pass
2. `dart run build_runner build --delete-conflicting-outputs` in arrow_example/
3. Verify generated code includes `..toLowerCase()`, `..toUpperCase()`, `..defaultValue('guest')`, `..transform('normalizePhone', TransformEntity.normalizePhone)`
4. `dart test` in arrow_example/ — all 223 + new e2e tests pass

### Step 15: Update docs and commit

- Update modernization-plan.md Phase 8 section to DONE
- Update CLAUDE.md with new annotations
- Update README.md with Transform section
- Update stabilization-plan.md test counts
- Commit in endorse submodule, push
- Commit in parent repo, push

## Files to Modify

| File | Change |
|------|--------|
| `endorse/lib/src/endorse/validations.dart` | Add ToLowerCase, ToUpperCase, DefaultValue, Transform annotations |
| `endorse/lib/src/endorse/rule.dart` | Add ToLowerCaseRule, ToUpperCaseRule, DefaultValueRule, TransformRule |
| `endorse/lib/src/endorse/validate_value.dart` | Add toLowerCase(), toUpperCase(), defaultValue(), transform() methods |
| `endorse/lib/src/builder/field_helper.dart` | Skip Transform + DefaultValue special handling in processValidations |
| `endorse/lib/src/builder/endorse_class_helper.dart` | Handle Transform in CustomValidation loops (non-list, list field-level, item-level) |
| `endorse/test/rule_test.dart` | Unit tests for 4 new rules |
| `endorse/test/annotations_test.dart` | Annotation field tests |
| `arrow_example/lib/src/transform_entity.dart` | **New** — entity with transform annotations |
| `arrow_example/test/transform_entity_test.dart` | **New** — e2e tests |

## Verification

1. `dart test` in endorse/ — all existing + new tests pass
2. `dart run build_runner build --delete-conflicting-outputs` in arrow_example/
3. Inspect `transform_entity.g.dart` — verify `..toLowerCase()`, `..toUpperCase()`, `..defaultValue('guest')`, `..transform('normalizePhone', TransformEntity.normalizePhone)` appear
4. `dart test` in arrow_example/ — all existing + new tests pass
