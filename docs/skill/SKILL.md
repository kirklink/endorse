---
name: endorse
description: "Endorse consumer API reference — validation library with code generation. TRIGGER when: adding validation to a Dart application, using @Endorse/@EndorseField annotations, defining validation rules (StringMust, NumMust, When), working with EndorseResult/Valid/Invalid types, configuring the Endorse registry, or integrating endorse with Swoop request validation."
---

# Endorse — Consumer Guide

Annotation-driven validation with code generation. Define rules declaratively, validate at runtime with typed results.

**Import:** `package:endorse/endorse.dart`

## When to use this skill

Use when writing code that **uses** Endorse for validation — annotating models, running validators, handling results. For editing Endorse internals, the contributor guide loads automatically.

## Guide contents

Full reference in [guide.md](guide.md). Key sections:

- **Setup** — pubspec dependencies, build_runner configuration
- **Quick Start** — annotate, generate, validate in 3 steps
- **Annotations** — @Endorse, @EndorseField, rule composition
- **Validation Rules** — StringMust, NumMust, ListMust, DateTimeMust, When (conditional)
- **Result Types** — EndorseResult, Valid, Invalid, field-level errors
- **Validator Interface** — generated validator API, unchecked construction, manual usage
- **Registry** — global validator lookup by type
- **Patterns** — nested validation, cross-field rules, custom rules
- **Framework Integration** — Swoop middleware, request validation hook
