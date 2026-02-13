# Endorse Package Stabilization Plan

> **Note:** This plan was created based on initial assessment. The commented code sections may be legacy/unused code rather than incomplete work. We'll verify functionality as we implement and adjust scope accordingly.

## Executive Summary

The Endorse package has a solid validation architecture that needs testing, documentation, and integration work. This plan will add comprehensive tests, update dependencies, document the existing functionality, and integrate with the Arrow framework.

**Current State:**
- ✅ Annotations and code generation working
- ❌ Rule execution engine (Evaluator) commented out (CRITICAL)
- ❌ 91% of validation rules commented out (406/448 lines in rules.dart)
- ❌ Class/List validation infrastructure commented out
- ❌ Zero tests
- ⚠️ Outdated dependencies
- ⚠️ Duplicate code and naming conflicts

**Timeline:** Flexible - work will be done as time allows

---

## Phase 1: Core Infrastructure Restoration (Week 1)
**Goal:** Get the validation engine running with basic rules

### Task 1.1: Resolve Naming Conflicts
**Files:**
- `lib/src/endorse/validation_error.dart`
- `lib/src/endorse/rule.dart`

**Problem:** Two different `ValidationError` classes with conflicting structures:
- One in `validation_error.dart` (has: rule, message, got, want)
- One in `rule.dart` (has: errorName, path, detail)

**Solution:**
1. Standardize on the `validation_error.dart` version (better structured)
2. Update `rule.dart` to remove its ValidationError definition
3. Add `path` field to `validation_error.dart` for nested errors
4. Update all imports

**Acceptance Criteria:**
- Only one ValidationError class exists
- All files import from the correct location
- No compilation errors

### Task 1.2: Uncomment and Fix Evaluator
**Files:**
- `lib/src/endorse/evaluator.dart`
- `lib/src/endorse/rule.dart` (update Rule base class)

**Current State:** Entire Evaluator is commented out

**Solution:**
1. Uncomment the Evaluator class
2. Fix Rule base class to support the Evaluator's expectations:
   - Add `check()`, `pass()`, `got()`, `want()`, `errorMsg()`, `cast()` methods
   - Add `skipIfNull`, `causesBail`, `escapesBail` properties
   - Add `name` property
3. Update existing simple rules (Required, IsString, etc.) to full Rule interface
4. Test with basic rule execution

**Acceptance Criteria:**
- Evaluator compiles without errors
- Can execute at least 3 basic rules (Required, IsString, MaxLength)
- Returns proper ValidationError objects
- Supports short-circuit evaluation (causesBail)

### Task 1.3: Write Evaluator Tests
**New File:** `test/evaluator_test.dart`

**Test Coverage:**
- ✓ Evaluator runs single rule
- ✓ Evaluator runs multiple rules
- ✓ Evaluator short-circuits on bail rules
- ✓ Evaluator skips null values when skipIfNull=true
- ✓ Evaluator collects all errors
- ✓ Evaluator returns ValueResult correctly
- ✓ Precondition failures throw EndorseException

**Target:** 80%+ coverage of evaluator.dart

---

## Phase 2: Complete Rule Implementation (Week 2-3)
**Goal:** Uncomment and implement all rules in rules.dart

### Task 2.1: String Rules
**File:** `lib/src/endorse/rules.dart` (lines ~193-251)

**Rules to Implement:**
- MaxLengthRule ✓ (already in rule.dart, move/merge)
- MinLengthRule
- MatchesRule
- ContainsRule
- StartsWithRule
- EndsWithRule
- IsStringRule (already exists, verify)
- CanStringRule
- ToStringRule

**Implementation:**
1. Uncomment each rule class
2. Implement full Rule interface (check, pass, got, want, errorMsg, cast)
3. Write unit test for each rule
4. Verify with integration test

**Acceptance Criteria:**
- All 9 string rules working
- Each rule has 3+ test cases (pass, fail, edge cases)
- Rules integrate with ValidateValue

### Task 2.2: Numeric Rules
**File:** `lib/src/endorse/rules.dart` (lines ~74-99, 264-277)

**Rules to Implement:**
- IsNumRule
- IsIntRule
- IsDoubleRule
- IntFromStringRule
- DoubleFromStringRule
- NumFromStringRule
- CanIntFromStringRule
- CanDoubleFromStringRule
- CanNumFromStringRule
- IsGreaterThanRule ✓ (already in rule.dart)
- IsLessThanRule ✓ (already in rule.dart)
- IsEqualToRule
- IsNotEqualToRule

**Acceptance Criteria:**
- All 13 numeric rules working
- Type coercion rules properly cast values
- Comparison rules handle edge cases (NaN, infinity)

### Task 2.3: Boolean Rules
**File:** `lib/src/endorse/rules.dart` (lines ~101-109, 278-290)

**Rules to Implement:**
- IsBoolRule
- BoolFromStringRule
- CanBoolFromStringRule
- IsTrueRule
- IsFalseRule

**Acceptance Criteria:**
- All 5 boolean rules working
- String coercion handles 'true', 'false', '1', '0'

### Task 2.4: DateTime Rules
**File:** `lib/src/endorse/rules.dart` (lines ~110-117, 292-375)

**Rules to Implement:**
- IsDateTimeRule
- IsBeforeRule
- IsAfterRule
- IsAtMomentRule
- IsSameDateAsRule

**Helper Functions:**
- `_inputDateConverter()` - Parse DateTime from string or DateTime
- `_testDateConverter()` - Handle 'now', 'today', 'today+7', ISO strings

**Acceptance Criteria:**
- All 5 DateTime rules working
- Relative dates work ('now', 'today+7', 'today-3')
- ISO 8601 string parsing works
- DateTime objects pass through correctly

### Task 2.5: Pattern Matching Rules
**File:** `lib/src/endorse/rules.dart` (lines ~376-400)

**Rules to Implement:**
- MatchesPatternRule (regex validation)
- IsEmailRule (extends MatchesPatternRule)

**Acceptance Criteria:**
- Regex patterns compile and match correctly
- Invalid regex patterns throw clear errors
- Email validation uses Patterns.email constant
- Pre-built patterns from patterns.dart work

### Task 2.6: Type Checking Rules
**File:** `lib/src/endorse/rules.dart` (lines ~14-31)

**Rules to Implement:**
- IsRequiredRule ✓ (already as Required in rule.dart)
- IsMapRule
- IsListRule

**Acceptance Criteria:**
- Type checking works for all Dart core types
- IsRequired differentiates null vs empty string

---

## Phase 3: Class and List Validation (Week 3-4)
**Goal:** Enable nested object and array validation

### Task 3.1: Uncomment Result Classes
**Files:**
- `lib/src/endorse/value_result.dart` (already active, verify)
- `lib/src/endorse/class_result.dart`
- `lib/src/endorse/list_result.dart`
- `lib/src/endorse/result_object.dart` (already active, verify)

**Solution:**
1. Uncomment ClassResult and ListResult
2. Verify they implement ResultObject correctly
3. Add `entity()` method to ClassResult for creating validated objects
4. Ensure error aggregation works for nested structures

**Acceptance Criteria:**
- All result classes compile
- ClassResult can aggregate errors from multiple fields
- ListResult can aggregate errors from array elements
- Path tracking works for nested errors (e.g., "user.address.zipCode")

### Task 3.2: Uncomment Validation Classes
**Files:**
- `lib/src/endorse/validate_value.dart` (already active but duplicated)
- `lib/src/endorse/validate_class.dart`
- `lib/src/endorse/validate_list.dart`
- `lib/src/endorse/endorse_class_validator.dart`

**Solution:**
1. Remove duplicate ValidateValue code (lines 168-329)
2. Uncomment ValidateClass
3. Uncomment ValidateList (both variants: fromCore, fromEndorse)
4. Uncomment EndorseClassValidator interface
5. Update exports in `lib/annotations.dart`

**Acceptance Criteria:**
- ValidateClass can validate nested objects
- ValidateList can validate arrays of primitives
- ValidateList can validate arrays of objects
- Type checking happens before nested validation

### Task 3.3: Update Code Generator
**Files:**
- `lib/src/builder/endorse_class_helper.dart`

**Current Issues:**
- Line 47: Uses ClassResult but it's commented
- Lines 273-303: List/class validation code may need updates

**Solution:**
1. Review generated code structure
2. Ensure generated code uses uncommented classes
3. Test with nested class example
4. Test with list field example

**Acceptance Criteria:**
- Generated code compiles without errors
- Nested validation works end-to-end
- List validation works end-to-end

### Task 3.4: Integration Tests
**New Files:**
- `test/class_validation_test.dart`
- `test/list_validation_test.dart`

**Test Scenarios:**
- Flat object with multiple fields
- Nested object (2 levels deep)
- Deeply nested object (3+ levels)
- List of primitives
- List of objects
- Mixed nested structures
- Error path tracking

**Target:** 80%+ coverage of class/list validation code

---

## Phase 4: Testing Infrastructure (Week 4-5)
**Goal:** Comprehensive test coverage

### Task 4.1: Setup Test Infrastructure
**New Files:**
- `test/test_helpers.dart` - Shared test utilities
- `.github/workflows/test.yml` - CI configuration (if using GitHub)

**Setup:**
1. Add `test` dependency to pubspec.yaml
2. Create test directory structure:
   ```
   test/
   ├── unit/
   │   ├── rules/         # Individual rule tests
   │   ├── evaluator_test.dart
   │   └── result_test.dart
   ├── integration/
   │   ├── validation_test.dart
   │   ├── class_validation_test.dart
   │   └── list_validation_test.dart
   ├── builder/
   │   └── code_generation_test.dart
   └── test_helpers.dart
   ```
3. Write helper functions for common test patterns

**Acceptance Criteria:**
- `dart test` command runs successfully
- Tests organized by category
- Helper functions reduce boilerplate

### Task 4.2: Unit Tests for All Rules
**Directory:** `test/unit/rules/`

**Coverage Target:** Every rule in rules.dart

**Test Template (per rule):**
```dart
group('RuleName', () {
  test('passes with valid input', () { /* ... */ });
  test('fails with invalid input', () { /* ... */ });
  test('returns correct error message', () { /* ... */ });
  test('handles null correctly', () { /* ... */ });
  test('handles edge cases', () { /* ... */ });
});
```

**Acceptance Criteria:**
- 5+ test cases per rule
- Edge cases covered (null, empty, boundary values)
- Error messages validated

### Task 4.3: Integration Tests
**File:** `test/integration/validation_test.dart`

**Test Scenarios:**
- End-to-end validation with @EndorseEntity annotation
- Code generation + validation workflow
- Complex nested structures
- Error formatting and JSON serialization
- Case conversion (camelCase, snake_case, etc.)

**Acceptance Criteria:**
- Real-world usage scenarios work
- Generated code functions correctly
- Error messages are user-friendly

### Task 4.4: Code Coverage
**Goal:** Achieve 80%+ test coverage

**Tools:**
- Use `dart test --coverage=coverage`
- Use `genhtml` to generate coverage reports
- Add coverage badge to README

**Acceptance Criteria:**
- Overall coverage ≥80%
- Core files (evaluator, rules, validators) ≥90%
- Coverage report generated in CI

---

## Phase 5: Dependencies & Polish (Week 5-6)
**Goal:** Update dependencies, documentation, and examples

### Task 5.1: Update Dependencies
**File:** `pubspec.yaml`

**Current Issues:**
- `analyzer: ^1.5.0` - Latest is 6.x+ (5+ major versions behind)
- `pedantic: ^1.11.0` - DEPRECATED, replaced by `lints`

**Updates:**
```yaml
dependencies:
  recase: ^4.0.0          # ✓ Current
  source_gen: ^1.5.0      # Update from ^1.0.0
  analyzer: ^6.10.0       # Update from ^1.5.0
  build: ^2.4.0           # Update from ^2.0.1

dev_dependencies:
  build_runner: ^2.4.0    # Update from ^2.0.2
  lints: ^4.0.0           # Replace pedantic
  test: ^1.25.0           # ADD for testing
  coverage: ^1.9.0        # ADD for coverage
```

**Migration Steps:**
1. Update pubspec.yaml
2. Run `dart pub upgrade`
3. Fix any breaking changes from analyzer package
4. Fix any lints from new lints package
5. Test that build_runner still works

**Acceptance Criteria:**
- All dependencies updated
- No deprecation warnings
- All tests pass
- Code generation still works

### Task 5.2: Documentation
**Files to Create/Update:**
- `README.md` - Comprehensive usage guide
- `CHANGELOG.md` - Document all changes
- `example/basic_validation.dart` - Simple example
- `example/nested_objects.dart` - Complex example
- `example/arrow_integration.dart` - Arrow framework usage
- `doc/ARCHITECTURE.md` - System design doc
- Dart doc comments on all public APIs

**README.md Structure:**
1. Overview & Features
2. Installation
3. Quick Start (5-minute example)
4. Core Concepts
   - Annotations
   - Validation Rules
   - Results & Errors
5. Advanced Usage
   - Nested Objects
   - Lists/Arrays
   - Custom Rules
   - Case Conversion
6. API Reference (link to generated docs)
7. Contributing
8. License

**Acceptance Criteria:**
- README has working examples
- All public APIs have doc comments
- Examples compile and run
- Architecture document explains design decisions

### Task 5.3: Example Projects
**Directory:** `example/`

**Examples to Create:**
1. **basic_validation.dart** - Simple field validation
2. **nested_objects.dart** - Nested class validation
3. **list_validation.dart** - Array validation
4. **custom_rules.dart** - Extending with custom rules
5. **arrow_integration.dart** - Using with Arrow framework

**Each Example:**
- Runnable standalone
- Well-commented
- Shows best practices
- Demonstrates error handling

**Acceptance Criteria:**
- All examples run successfully
- Cover 80% of common use cases
- Clear and educational

### Task 5.4: Arrow Integration
**Primary Goal:** Use Arrow example app as playground to test and validate Endorse functionality

**Files:**
- `example/arrow_integration.dart`
- Update `arrow_example/lib/router_config.dart` (parent workspace)

**Integration Points:**
1. Request body validation in POST/PUT handlers
2. Query parameter validation
3. Error response formatting (BadRequestException)
4. Typed request handlers

**Example Usage:**
```dart
// In Arrow handler
router.post('/users', (req, res) async {
  final result = CreateUser.$endorse.validate(req.body);

  if (!result.$isValid) {
    throw BadRequestException(
      'Validation failed',
      result.$errorsJson,
    );
  }

  final user = result.entity(); // Type-safe entity creation
  // ... process user
});
```

**Acceptance Criteria:**
- Arrow example works end-to-end
- Error responses are properly formatted
- Integration feels natural for Arrow users

---

## Phase 6: Release & Communication (Week 6)
**Goal:** Package ready for production use

### Task 6.1: Pre-Release Checklist
- [ ] All tests passing
- [ ] Test coverage ≥80%
- [ ] No deprecation warnings
- [ ] All public APIs documented
- [ ] Examples work
- [ ] README complete
- [ ] CHANGELOG updated
- [ ] Version number updated (0.1.0-nullsafety.2 → 1.0.0)

### Task 6.2: Version 1.0.0 Release
**Updates:**
- `pubspec.yaml` - Bump to 1.0.0
- `CHANGELOG.md` - Document all changes since 0.1.0-nullsafety.2
- Git tag: v1.0.0

**Release Notes:**
```markdown
# Endorse 1.0.0 - Stabilization Release

## ✨ Completed Features
- Full rule execution engine
- 40+ validation rules
- Nested object validation
- List/array validation
- Comprehensive test coverage (85%)
- Updated dependencies (Dart 3.x compatible)

## 🔧 Breaking Changes
- None (first stable release)

## 📚 Documentation
- Complete README with examples
- Architecture documentation
- API documentation

## 🎯 Arrow Framework Integration
- Seamless integration with Arrow web framework
- Request body validation
- Type-safe error handling
```

### Task 6.3: Keep as Git Submodule
**Decision:** Package will remain as git submodule for now

**Actions:**
- Document submodule usage in README
- Ensure proper versioning with git tags
- Add instructions for updating submodule in parent repo
- Note: pub.dev publishing can be considered later after stabilization

---

## Risk Mitigation

### Risk 1: Breaking Changes from Dependency Updates
**Mitigation:**
- Update dependencies incrementally
- Run tests after each dependency update
- Document any required code changes

### Risk 2: Incomplete Rule Implementations
**Mitigation:**
- Implement rules incrementally
- Test each rule immediately after implementation
- Mark incomplete rules as @deprecated until ready

### Risk 3: Generated Code Compatibility
**Mitigation:**
- Test code generation after every significant change
- Keep example classes that trigger all code paths
- Add builder tests

### Risk 4: Performance Issues
**Mitigation:**
- Add benchmark tests for large objects/lists
- Profile validation performance
- Optimize hot paths if needed

---

## Success Metrics

**Completion Criteria:**
1. ✅ All commented code is either active or removed
2. ✅ Test coverage ≥80%
3. ✅ All validation rules implemented and tested
4. ✅ Dependencies up-to-date
5. ✅ Documentation complete
6. ✅ Arrow integration working
7. ✅ Zero compilation warnings
8. ✅ Example projects demonstrate all features

**Quality Gates:**
- Phase 1 → Must have working Evaluator with 3+ rules
- Phase 2 → Must have 30+ rules working with tests
- Phase 3 → Must have nested/list validation working
- Phase 4 → Must have 80% test coverage
- Phase 5 → Must have complete documentation
- Phase 6 → Must pass pre-release checklist

---

## Timeline Summary

| Phase | Duration | Key Deliverable |
|-------|----------|----------------|
| Phase 1 | Week 1 | Working Evaluator + basic rules |
| Phase 2 | Weeks 2-3 | All 40+ rules implemented |
| Phase 3 | Weeks 3-4 | Nested/list validation working |
| Phase 4 | Week 4-5 | 80%+ test coverage |
| Phase 5 | Week 5-6 | Documentation + examples |
| Phase 6 | Week 6 | Release 1.0.0 |

**Total:** 6 weeks (assuming 10-15 hours/week = 60-90 hours total)

---

## Next Steps After Approval

1. Create feature branch: `feature/stabilization`
2. Start with Phase 1, Task 1.1 (resolve naming conflicts)
3. Commit frequently with clear messages
4. Create sub-branches for each phase if desired
5. Merge to `dev` branch when phase complete
6. Final merge `dev` → `main` for 1.0.0 release

---

## Implementation Notes

**Decisions made:**
1. **Scope:** Plan approved as-is, with understanding that commented code may be legacy/unused
2. **Timeline:** Flexible - work as time allows
3. **Publishing:** Keep as git submodule for now, pub.dev later
4. **Arrow Integration:** Yes - arrow_example app is the playground
5. **Approach:** Verify functionality first, adjust plan based on what actually needs work

---

## Implementation Strategy

Given the flexible timeline, we'll:
1. **Verify first:** Test current functionality before assuming code needs uncommenting
2. **Test-driven:** Write tests to understand what actually works
3. **Incremental:** Implement and test one component at a time
4. **Document as we go:** Update docs with actual behavior discovered
5. **Arrow-validated:** Use arrow_example to validate real-world usage
