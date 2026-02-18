# Endorse Changelog

## 0.1.0-nullsafety.3 (Unreleased)

### Stabilization
- Activate and stabilize the full runtime validation engine (Evaluator, ValidateValue, ValidateClass, ValidateList)
- Fix evaluator cast pipeline to properly propagate coerced values between rules
- Fix builder code generation for nested objects to avoid duplicate class definitions
- Fix ValidateClass to always return typed result class (prevents cast errors in generated code)
- Fix ToStringFromX rule ordering so source type check runs before string conversion
- Fix List<bool> code generation to use `isBoolean()` instead of non-existent `isBool()`
- Fix builder integration: correct part file naming, build_to cache, naming conflicts

### Rules
- Implement all 35 validation rules across string, numeric, boolean, DateTime, and pattern categories
- Add IsNotNull, IsMap, IsList, MinElements rules
- Fix short-circuit evaluation in rule pipeline

### Testing
- Add 226 unit tests covering annotations, rules, validation classes, and coverage gaps
- Add 68 comprehensive end-to-end tests in arrow_example exercising all code generation paths
- Test coverage for all 6 value types, nullable fields, nested entities, list validation, field rename/ignore, fromString/toString coercion, requireAll

### Dependencies
- Replace deprecated `pedantic` with `lints` (^5.0.0)
- Update SDK constraint to `>=3.0.0 <4.0.0`
- Fix all lint warnings (dead code, unnecessary null checks, invalid hide directives)

### Documentation
- Full README rewrite with quick start, annotation reference, all validation rules, and programmatic usage
- Add nested object and list validation documentation

## 0.1.0-nullsafety.1
- Add now() constructor to DateTime validation rules
- Merge into single package
- Clean up Dockerfile and VS Code remote config
- Some Dart docs added

## 0.1.0-nullsafety.0
- Null safety
- Build devcontainer with dart 2.16.2
- Fix minor lint errors

## 0.0.28
- Separate validations into sub-library

## 0.0.27
- Add 10 digit phone pattern
- Add basic email validator

## 0.0.26
- Add DateTime validations
- Add RegExp validations
- Clean up built in patterns

## 0.0.25
- Fix error in MaxLength, MinLength

## 0.0.24
- Remove rogue print statement

## 0.0.23
- Fix disappearing build bug

## 0.0.22
- Align analyzer dependency with similar packages

## 0.0.21
- Align analyzer dependency with similar packages

## 0.0.20
- Fix error after dependency upgrades

## 0.0.19
- Fix upload error

## 0.0.18
- Fix failed boolean assertion

## 0.0.17
- Update dependency constraints

## 0.0.16
- Add validation errors as a Dart class ValidationError
- Fix type assigment in code gen of nested classes ClassResult fields

## 0.0.15
- Rework internals to provide rules individually

## 0.0.14
- Better handling of ignored fields

## 0.0.13
- Better handling of ignored fields

## 0.0.12
- Minor oopsie

## 0.0.11
- More improvements to type switching

## 0.0.10
- Fix ToString rule

## 0.0.9
- Fix ToString rule

## 0.0.8
- Better handling of String conversions

## 0.0.7
- Fix handling of String conversions

## 0.0.6
- Change handling of String conversions

## 0.0.5
- Better handling of non-required null values

## 0.0.4
- Validate DateTime strings

## 0.0.3
- Allow override of field names

## 0.0.2
- Added changelog!
- Use code generation to create validations

## 0.0.1
- Legacy version