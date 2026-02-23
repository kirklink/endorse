import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../annotations.dart';

/// Code generator for `@Endorse()` annotated classes.
///
/// For each annotated class, generates:
/// - `_$<ClassName>Validator` implementing `EndorseValidator<ClassName>`
/// - `_$<ClassName>ToJson` helper function
class EndorseGenerator extends GeneratorForAnnotation<Endorse> {
  static const _endorseChecker =
      TypeChecker.fromUrl('package:endorse/src/annotations.dart#Endorse');
  static const _fieldChecker =
      TypeChecker.fromUrl('package:endorse/src/annotations.dart#EndorseField');

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@Endorse can only be applied to classes.',
        element: element,
      );
    }

    final classEl = element;
    final className = classEl.name!;
    final requireAll = annotation.read('requireAll').boolValue;
    final eitherGroups = _readEither(annotation);
    final fields = _processFields(classEl, requireAll);

    // Check for crossValidate static method
    final hasCrossValidate = classEl.methods.any(
      (m) => m.isStatic && m.name == 'crossValidate',
    );

    final buffer = StringBuffer();
    buffer.writeln(
        '// ignore_for_file: unnecessary_cast, prefer_is_empty, '
        'curly_braces_in_flow_control_structures');
    buffer.writeln();
    _generateValidator(
        buffer, className, fields, eitherGroups, hasCrossValidate);
    _generateToJson(buffer, className, fields);
    return buffer.toString();
  }

  // ---------------------------------------------------------------------------
  // Annotation reading
  // ---------------------------------------------------------------------------

  List<List<String>> _readEither(ConstantReader annotation) {
    final eitherReader = annotation.read('either');
    if (eitherReader.isNull) return [];
    final groups = <List<String>>[];
    for (final groupObj in eitherReader.listValue) {
      final reader = ConstantReader(groupObj);
      if (reader.isList) {
        groups.add(
          reader.listValue.map((f) => ConstantReader(f).stringValue).toList(),
        );
      }
    }
    return groups;
  }

  List<_FieldInfo> _processFields(ClassElement classEl, bool requireAll) {
    final fields = <_FieldInfo>[];
    for (final field in classEl.fields) {
      // ignore: deprecated_member_use
      if (field.isStatic || field.isSynthetic) continue;

      // Read @EndorseField annotation if present
      final fieldAnnotation = _readFieldAnnotation(field);
      if (fieldAnnotation?.ignore == true) continue;

      final dartName = field.name!;
      final jsonKey = fieldAnnotation?.jsonKey ?? dartName;
      final type = field.type;
      final isNullable = type.nullabilitySuffix == NullabilitySuffix.question;
      final isRequired = requireAll || !isNullable;
      final typeKind = _getTypeKind(type);
      final rules = fieldAnnotation?.rules ?? [];
      final itemRules = fieldAnnotation?.itemRules ?? [];
      final when = fieldAnnotation?.when;

      // For List<T>, determine the item type
      String? listItemType;
      bool isNestedList = false;
      if (typeKind == _TypeKind.list && type is InterfaceType) {
        final typeArgs = type.typeArguments;
        if (typeArgs.isNotEmpty) {
          final itemType = typeArgs.first;
          listItemType = _typeToString(itemType);
          isNestedList = _hasEndorseAnnotation(itemType);
        }
      }

      // For nested objects
      final isNested = typeKind == _TypeKind.nested;
      final dartTypeName = _typeToString(type);

      fields.add(_FieldInfo(
        dartName: dartName,
        jsonKey: jsonKey,
        dartType: dartTypeName,
        isRequired: isRequired,
        isNullable: isNullable,
        typeKind: typeKind,
        rules: rules,
        itemRules: itemRules,
        when: when,
        isNested: isNested,
        isList: typeKind == _TypeKind.list,
        listItemType: listItemType,
        isNestedList: isNestedList,
      ));
    }
    return fields;
  }

  _FieldAnnotation? _readFieldAnnotation(FieldElement field) {
    final annotation = _fieldChecker.firstAnnotationOf(field);
    if (annotation == null) return null;
    final reader = ConstantReader(annotation);

    return _FieldAnnotation(
      rules: _readRuleList(reader.read('rules')),
      itemRules: _readRuleList(reader.read('itemRules')),
      jsonKey: _readNullableString(reader.read('name')),
      ignore: reader.read('ignore').boolValue,
      when: _readWhen(reader.read('when')),
    );
  }

  List<_RuleInfo> _readRuleList(ConstantReader reader) {
    if (reader.isNull) return [];
    final rules = <_RuleInfo>[];
    for (final ruleObj in reader.listValue) {
      final rule = _readRule(ruleObj);
      if (rule != null) rules.add(rule);
    }
    return rules;
  }

  _RuleInfo? _readRule(DartObject ruleObj) {
    final typeName = ruleObj.type?.element?.name;
    if (typeName == null) return null;

    switch (typeName) {
      case 'Required':
        return _RuleInfo('Required', {
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'MinLength':
        return _RuleInfo('MinLength', {
          'min': ruleObj.getField('min')?.toIntValue(),
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'MaxLength':
        return _RuleInfo('MaxLength', {
          'max': ruleObj.getField('max')?.toIntValue(),
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'Matches':
        return _RuleInfo('Matches', {
          'pattern': ruleObj.getField('pattern')?.toStringValue(),
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'Email':
        return _RuleInfo('Email', {
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'Url':
        return _RuleInfo('Url', {
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'Uuid':
        return _RuleInfo('Uuid', {
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'Min':
        return _RuleInfo('Min', {
          'min': _readNum(ruleObj.getField('min')),
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'Max':
        return _RuleInfo('Max', {
          'max': _readNum(ruleObj.getField('max')),
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'MinElements':
        return _RuleInfo('MinElements', {
          'min': ruleObj.getField('min')?.toIntValue(),
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'MaxElements':
        return _RuleInfo('MaxElements', {
          'max': ruleObj.getField('max')?.toIntValue(),
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'UniqueElements':
        return _RuleInfo('UniqueElements', {
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'OneOf':
        return _RuleInfo('OneOf', {
          'allowed': _readObjectList(ruleObj.getField('allowed')),
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'Custom':
        return _RuleInfo('Custom', {
          'methodName': ruleObj.getField('methodName')?.toStringValue(),
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'Trim':
        return _RuleInfo('Trim');
      case 'LowerCase':
        return _RuleInfo('LowerCase');
      case 'UpperCase':
        return _RuleInfo('UpperCase');
      case 'StripHtml':
        return _RuleInfo('StripHtml');
      case 'CollapseWhitespace':
        return _RuleInfo('CollapseWhitespace');
      case 'NormalizeNewlines':
        return _RuleInfo('NormalizeNewlines');
      case 'Truncate':
        return _RuleInfo('Truncate', {
          'max': ruleObj.getField('max')?.toIntValue(),
        });
      case 'Transform':
        return _RuleInfo('Transform', {
          'methodName': ruleObj.getField('methodName')?.toStringValue(),
        });
      case 'IsBeforeDate':
        return _RuleInfo('IsBeforeDate', {
          'date': ruleObj.getField('date')?.toStringValue(),
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'IsAfterDate':
        return _RuleInfo('IsAfterDate', {
          'date': ruleObj.getField('date')?.toStringValue(),
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'IsSameDate':
        return _RuleInfo('IsSameDate', {
          'date': ruleObj.getField('date')?.toStringValue(),
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'IsFutureDatetime':
        return _RuleInfo('IsFutureDatetime', {
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'IsPastDatetime':
        return _RuleInfo('IsPastDatetime', {
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'IsSameDatetime':
        return _RuleInfo('IsSameDatetime', {
          'date': ruleObj.getField('date')?.toStringValue(),
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'IpAddress':
        return _RuleInfo('IpAddress', {
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      case 'NoControlChars':
        return _RuleInfo('NoControlChars', {
          'message': ruleObj.getField('message')?.toStringValue(),
        });
      default:
        return null;
    }
  }

  String? _readNullableString(ConstantReader reader) {
    if (reader.isNull) return null;
    final value = reader.stringValue;
    return value.isEmpty ? null : value;
  }

  _WhenInfo? _readWhen(ConstantReader reader) {
    if (reader.isNull) return null;
    final obj = reader.objectValue;
    final field = obj.getField('field')?.toStringValue();
    if (field == null) return null;

    final equalsField = obj.getField('equals');
    final isNotNull = obj.getField('isNotNull')?.toBoolValue() ?? false;
    final isOneOfField = obj.getField('isOneOf');

    String? equalsValue;
    if (equalsField != null && !equalsField.isNull) {
      equalsValue = _dartObjectToLiteral(equalsField);
    }

    String? isOneOfValue;
    if (isOneOfField != null && !isOneOfField.isNull) {
      final items = isOneOfField.toListValue();
      if (items != null) {
        isOneOfValue =
            '[${items.map(_dartObjectToLiteral).join(', ')}]';
      }
    }

    return _WhenInfo(
      field: field,
      equalsValue: equalsValue,
      isNotNull: isNotNull,
      isOneOfValue: isOneOfValue,
    );
  }

  String _dartObjectToLiteral(DartObject obj) {
    if (obj.toIntValue() != null) return obj.toIntValue().toString();
    if (obj.toDoubleValue() != null) return obj.toDoubleValue().toString();
    if (obj.toBoolValue() != null) return obj.toBoolValue().toString();
    if (obj.toStringValue() != null) return "'${obj.toStringValue()}'";
    return 'null';
  }

  String? _readNum(DartObject? obj) {
    if (obj == null) return null;
    final intVal = obj.toIntValue();
    if (intVal != null) return intVal.toString();
    final doubleVal = obj.toDoubleValue();
    if (doubleVal != null) return doubleVal.toString();
    return null;
  }

  String? _readObjectList(DartObject? obj) {
    if (obj == null || obj.isNull) return null;
    final list = obj.toListValue();
    if (list == null) return null;
    return '[${list.map(_dartObjectToLiteral).join(', ')}]';
  }

  // ---------------------------------------------------------------------------
  // Type helpers
  // ---------------------------------------------------------------------------

  _TypeKind _getTypeKind(DartType type) {
    if (type.isDartCoreString) return _TypeKind.string;
    if (type.isDartCoreInt) return _TypeKind.int_;
    if (type.isDartCoreDouble) return _TypeKind.double_;
    if (type.isDartCoreBool) return _TypeKind.bool_;
    if (type.isDartCoreList) return _TypeKind.list;

    final element = type.element;
    if (element != null) {
      if (element.name == 'num') return _TypeKind.num_;
      if (element.name == 'DateTime') return _TypeKind.dateTime;
    }

    if (_hasEndorseAnnotation(type)) return _TypeKind.nested;
    return _TypeKind.other;
  }

  bool _hasEndorseAnnotation(DartType type) {
    final element = type.element;
    if (element == null) return false;
    return _endorseChecker.hasAnnotationOf(element);
  }

  String _typeToString(DartType type) {
    // Strip nullability suffix for the base type name
    final display = type.getDisplayString();
    if (display.endsWith('?')) return display.substring(0, display.length - 1);
    return display;
  }

  // ---------------------------------------------------------------------------
  // Type rule source generation
  // ---------------------------------------------------------------------------

  String? _typeRuleSource(_TypeKind kind) {
    return switch (kind) {
      _TypeKind.string => 'const IsString()',
      _TypeKind.int_ => 'const IsInt()',
      _TypeKind.double_ => 'const IsDouble()',
      _TypeKind.num_ => 'const IsNum()',
      _TypeKind.bool_ => 'const IsBool()',
      _TypeKind.dateTime => 'const IsDateTime()',
      _TypeKind.list => 'const IsList()',
      _TypeKind.nested => 'const IsMap()',
      _TypeKind.other => null,
    };
  }

  String _ruleToSource(_RuleInfo rule) {
    String msgArg(Object? msg) => msg != null ? ", message: '$msg'" : '';

    return switch (rule.name) {
      'Required' => () {
          final msg = rule.params['message'];
          return msg != null
              ? "const Required(message: '$msg')"
              : 'const Required()';
        }(),
      'MinLength' => () {
          final msg = rule.params['message'];
          return 'const MinLength(${rule.params['min']}${msgArg(msg)})';
        }(),
      'MaxLength' => () {
          final msg = rule.params['message'];
          return 'const MaxLength(${rule.params['max']}${msgArg(msg)})';
        }(),
      'Matches' => () {
          final msg = rule.params['message'];
          return "const Matches(r'${rule.params['pattern']}'${msgArg(msg)})";
        }(),
      'Email' => () {
          final msg = rule.params['message'];
          return msg != null
              ? "const Email(message: '$msg')"
              : 'const Email()';
        }(),
      'Url' => () {
          final msg = rule.params['message'];
          return msg != null
              ? "const Url(message: '$msg')"
              : 'const Url()';
        }(),
      'Uuid' => () {
          final msg = rule.params['message'];
          return msg != null
              ? "const Uuid(message: '$msg')"
              : 'const Uuid()';
        }(),
      'Min' => () {
          final msg = rule.params['message'];
          return 'const Min(${rule.params['min']}${msgArg(msg)})';
        }(),
      'Max' => () {
          final msg = rule.params['message'];
          return 'const Max(${rule.params['max']}${msgArg(msg)})';
        }(),
      'MinElements' => () {
          final msg = rule.params['message'];
          return 'const MinElements(${rule.params['min']}${msgArg(msg)})';
        }(),
      'MaxElements' => () {
          final msg = rule.params['message'];
          return 'const MaxElements(${rule.params['max']}${msgArg(msg)})';
        }(),
      'UniqueElements' => () {
          final msg = rule.params['message'];
          return msg != null
              ? "const UniqueElements(message: '$msg')"
              : 'const UniqueElements()';
        }(),
      'OneOf' => () {
          final msg = rule.params['message'];
          return 'const OneOf(${rule.params['allowed']}${msgArg(msg)})';
        }(),
      'Trim' => 'const Trim()',
      'LowerCase' => 'const LowerCase()',
      'UpperCase' => 'const UpperCase()',
      'StripHtml' => 'const StripHtml()',
      'CollapseWhitespace' => 'const CollapseWhitespace()',
      'NormalizeNewlines' => 'const NormalizeNewlines()',
      'Truncate' => 'const Truncate(${rule.params['max']})',
      'IsBeforeDate' => () {
          final msg = rule.params['message'];
          return "const IsBeforeDate('${rule.params['date']}'${msgArg(msg)})";
        }(),
      'IsAfterDate' => () {
          final msg = rule.params['message'];
          return "const IsAfterDate('${rule.params['date']}'${msgArg(msg)})";
        }(),
      'IsSameDate' => () {
          final msg = rule.params['message'];
          return "const IsSameDate('${rule.params['date']}'${msgArg(msg)})";
        }(),
      'IsFutureDatetime' => () {
          final msg = rule.params['message'];
          return msg != null
              ? "const IsFutureDatetime(message: '$msg')"
              : 'const IsFutureDatetime()';
        }(),
      'IsPastDatetime' => () {
          final msg = rule.params['message'];
          return msg != null
              ? "const IsPastDatetime(message: '$msg')"
              : 'const IsPastDatetime()';
        }(),
      'IsSameDatetime' => () {
          final msg = rule.params['message'];
          return "const IsSameDatetime('${rule.params['date']}'${msgArg(msg)})";
        }(),
      'IpAddress' => () {
          final msg = rule.params['message'];
          return msg != null
              ? "const IpAddress(message: '$msg')"
              : 'const IpAddress()';
        }(),
      'NoControlChars' => () {
          final msg = rule.params['message'];
          return msg != null
              ? "const NoControlChars(message: '$msg')"
              : 'const NoControlChars()';
        }(),
      _ => throw ArgumentError('Unknown rule: ${rule.name}'),
    };
  }

  // ---------------------------------------------------------------------------
  // Validator class generation
  // ---------------------------------------------------------------------------

  void _generateValidator(
    StringBuffer buf,
    String className,
    List<_FieldInfo> fields,
    List<List<String>> eitherGroups,
    bool hasCrossValidate,
  ) {
    buf.writeln(
        'class _\$${className}Validator implements EndorseValidator<$className> {');
    buf.writeln('  const _\$${className}Validator();');
    buf.writeln();

    // fieldNames
    final names = fields.map((f) => "'${f.dartName}'").join(', ');
    buf.writeln('  @override');
    buf.writeln('  Set<String> get fieldNames => const {$names};');
    buf.writeln();

    // Per-field rule lists and check methods
    for (final field in fields) {
      if (field.isNested || field.isNestedList) continue;
      _generateFieldRules(buf, className, field);
    }

    // validateField
    _generateValidateField(buf, fields);

    // validate
    _generateValidate(
        buf, className, fields, eitherGroups, hasCrossValidate);

    buf.writeln('}');
  }

  void _generateFieldRules(
      StringBuffer buf, String className, _FieldInfo field) {
    final rules = <String>[];

    // Required: add if non-nullable OR user explicitly specified it
    final hasExplicitRequired = field.rules.any((r) => r.name == 'Required');
    if (field.isRequired || hasExplicitRequired) {
      rules.add('const Required()');
    }

    // Type rule
    final typeRule = _typeRuleSource(field.typeKind);
    if (typeRule != null) rules.add(typeRule);

    // User rules (skip Required — already handled above;
    // skip Custom — handled below; Transform — inline as TransformRule)
    for (final rule in field.rules) {
      if (rule.name == 'Required' || rule.name == 'Custom') continue;
      if (rule.name == 'Transform') {
        rules.add('TransformRule($className.${rule.params['methodName']})');
        continue;
      }
      rules.add(_ruleToSource(rule));
    }

    final customRules =
        field.rules.where((r) => r.name == 'Custom').toList();
    final hasCustom = customRules.isNotEmpty;

    // static final with const elements — works for both pure-const and Custom lists
    buf.writeln(
        '  static final _${field.dartName}Rules = <Rule>[${rules.join(', ')}];');

    // Generate check method
    if (hasCustom) {
      buf.writeln(
          '  static (List<String>, Object?) _check${_capitalize(field.dartName)}(Object? value) {');
      buf.writeln(
          '    var (errors, coerced) = checkRules(value, _${field.dartName}Rules);');
      buf.writeln('    if (errors.isNotEmpty) return (errors, coerced);');
      for (final custom in customRules) {
        final method = custom.params['methodName'];
        final message = custom.params['message'] ?? 'is invalid';
        buf.writeln(
            "    if (!$className.$method(coerced)) errors = [...errors, '$message'];");
      }
      buf.writeln('    return (errors, coerced);');
      buf.writeln('  }');
    } else {
      buf.writeln(
          '  static (List<String>, Object?) _check${_capitalize(field.dartName)}(Object? value) =>');
      buf.writeln('      checkRules(value, _${field.dartName}Rules);');
    }
    buf.writeln();
  }

  void _generateValidateField(StringBuffer buf, List<_FieldInfo> fields) {
    buf.writeln('  @override');
    buf.writeln(
        '  List<String> validateField(String fieldName, Object? value) {');
    buf.writeln('    return switch (fieldName) {');
    for (final field in fields) {
      if (field.isNested) {
        // For nested fields, validate presence + type only
        buf.writeln("      '${field.dartName}' => _checkNested(value, "
            'isRequired: ${field.isRequired}),');
      } else if (field.isNestedList) {
        buf.writeln("      '${field.dartName}' => _checkNestedList(value, "
            'isRequired: ${field.isRequired}),');
      } else {
        buf.writeln(
            "      '${field.dartName}' => _check${_capitalize(field.dartName)}(value).\$1,");
      }
    }
    buf.writeln(
        "      _ => throw ArgumentError('Unknown field: \$fieldName'),");
    buf.writeln('    };');
    buf.writeln('  }');
    buf.writeln();

    // Helper for nested field-level validation (presence check only)
    final hasNested = fields.any((f) => f.isNested);
    final hasNestedList = fields.any((f) => f.isNestedList);

    if (hasNested) {
      buf.writeln(
          '  static List<String> _checkNested(Object? value, {required bool isRequired}) {');
      buf.writeln(
          '    if (value == null) return isRequired ? [\'is required\'] : [];');
      buf.writeln(
          '    if (value is! Map) return [\'must be an object\'];');
      buf.writeln('    return [];');
      buf.writeln('  }');
      buf.writeln();
    }

    if (hasNestedList) {
      buf.writeln(
          '  static List<String> _checkNestedList(Object? value, {required bool isRequired}) {');
      buf.writeln(
          '    if (value == null) return isRequired ? [\'is required\'] : [];');
      buf.writeln('    if (value is! List) return [\'must be a list\'];');
      buf.writeln('    return [];');
      buf.writeln('  }');
      buf.writeln();
    }
  }

  void _generateValidate(
    StringBuffer buf,
    String className,
    List<_FieldInfo> fields,
    List<List<String>> eitherGroups,
    bool hasCrossValidate,
  ) {
    buf.writeln('  @override');
    buf.writeln(
        '  EndorseResult<$className> validate(Map<String, Object?> input) {');
    buf.writeln('    final errors = <String, List<String>>{};');
    buf.writeln('    final values = <String, Object?>{};');
    buf.writeln();

    for (final field in fields) {
      if (field.when != null) {
        _generateWhenCondition(buf, field);
      }

      if (field.isNested) {
        _generateNestedValidation(buf, field);
      } else if (field.isNestedList) {
        _generateNestedListValidation(buf, field);
      } else if (field.isList && !field.isNestedList) {
        _generatePrimitiveListValidation(buf, className, field);
      } else {
        // When condition on a nullable field: prepend Required to make it
        // conditionally required when the condition is met.
        final whenRequired = field.when != null && field.isNullable;
        _generateSimpleValidation(buf, field, whenRequired: whenRequired);
      }

      if (field.when != null) {
        // Close the when condition block
        buf.writeln('    }');
      }
      buf.writeln();
    }

    // Either constraints
    for (final group in eitherGroups) {
      final checks = group.map((f) => "input['$f'] == null").join(' && ');
      final fieldList = group.join(', ');
      buf.writeln('    if ($checks) {');
      for (final f in group) {
        buf.writeln(
            "      errors.putIfAbsent('$f', () => []).add("
            "'at least one of [$fieldList] is required');");
      }
      buf.writeln('    }');
      buf.writeln();
    }

    // Cross-field validation
    if (hasCrossValidate) {
      buf.writeln('    if (errors.isEmpty) {');
      buf.writeln(
          '      final crossErrors = $className.crossValidate(input);');
      buf.writeln('      for (final entry in crossErrors.entries) {');
      buf.writeln(
          '        errors.putIfAbsent(entry.key, () => []).addAll(entry.value);');
      buf.writeln('      }');
      buf.writeln('    }');
      buf.writeln();
    }

    buf.writeln('    if (errors.isNotEmpty) return InvalidResult(errors);');
    buf.writeln();

    // Construct the validated instance
    buf.writeln('    return ValidResult($className._(');
    for (final field in fields) {
      if (field.isNested || field.isNestedList) {
        buf.writeln(
            "      ${field.dartName}: values['${field.dartName}'] as ${field.dartType}${field.isNullable ? '?' : ''},");
      } else if (field.isList) {
        final castType =
            field.isNullable ? '${field.dartType}?' : field.dartType;
        buf.writeln(
            "      ${field.dartName}: values['${field.dartName}'] as $castType,");
      } else {
        final cast = _castExpression(field);
        buf.writeln("      ${field.dartName}: $cast,");
      }
    }
    buf.writeln('    ));');
    buf.writeln('  }');
  }

  void _generateSimpleValidation(StringBuffer buf, _FieldInfo field,
      {bool whenRequired = false}) {
    final input = field.jsonKey == field.dartName
        ? "input['${field.dartName}']"
        : "input['${field.jsonKey}']";
    if (whenRequired) {
      // Nullable field inside a When block: prepend Required() to make it
      // conditionally required, calling checkRules directly.
      buf.writeln(
          '    final (${field.dartName}Errors, ${field.dartName}Val) = '
          'checkRules($input, [const Required(), ..._${field.dartName}Rules]);');
    } else {
      buf.writeln(
          "    final (${field.dartName}Errors, ${field.dartName}Val) = _check${_capitalize(field.dartName)}($input);");
    }
    buf.writeln(
        "    if (${field.dartName}Errors.isNotEmpty) errors['${field.dartName}'] = ${field.dartName}Errors;");
    buf.writeln("    values['${field.dartName}'] = ${field.dartName}Val;");
  }

  void _generateNestedValidation(StringBuffer buf, _FieldInfo field) {
    final input = "input['${field.jsonKey}']";
    buf.writeln('    final ${field.dartName}Raw = $input;');
    if (field.isRequired) {
      buf.writeln('    if (${field.dartName}Raw == null) {');
      buf.writeln("      errors['${field.dartName}'] = ['is required'];");
      buf.writeln(
          '    } else if (${field.dartName}Raw is! Map<String, Object?>) {');
      buf.writeln(
          "      errors['${field.dartName}'] = ['must be an object'];");
      buf.writeln('    } else {');
    } else {
      buf.writeln('    if (${field.dartName}Raw != null) {');
      buf.writeln(
          '      if (${field.dartName}Raw is! Map<String, Object?>) {');
      buf.writeln(
          "        errors['${field.dartName}'] = ['must be an object'];");
      buf.writeln('      } else {');
    }
    buf.writeln(
        '      final ${field.dartName}Result = ${field.dartType}.\$endorse.validate(${field.dartName}Raw${field.isRequired ? '' : ' as Map<String, Object?>'});');
    buf.writeln('      switch (${field.dartName}Result) {');
    buf.writeln('        case ValidResult(:final value):');
    buf.writeln("          values['${field.dartName}'] = value;");
    buf.writeln('        case InvalidResult(:final fieldErrors):');
    buf.writeln('          for (final entry in fieldErrors.entries) {');
    buf.writeln(
        "            errors['${field.dartName}.\${entry.key}'] = entry.value;");
    buf.writeln('      }');
    buf.writeln('      }');
    if (field.isRequired) {
      buf.writeln('    }');
    } else {
      buf.writeln('      }');
      buf.writeln('    }');
    }
  }

  void _generateNestedListValidation(StringBuffer buf, _FieldInfo field) {
    final input = "input['${field.jsonKey}']";
    buf.writeln('    final ${field.dartName}Raw = $input;');
    if (field.isRequired) {
      buf.writeln('    if (${field.dartName}Raw == null) {');
      buf.writeln("      errors['${field.dartName}'] = ['is required'];");
      buf.writeln('    } else if (${field.dartName}Raw is! List) {');
      buf.writeln("      errors['${field.dartName}'] = ['must be a list'];");
      buf.writeln('    } else {');
    } else {
      buf.writeln('    if (${field.dartName}Raw != null) {');
      buf.writeln('      if (${field.dartName}Raw is! List) {');
      buf.writeln("        errors['${field.dartName}'] = ['must be a list'];");
      buf.writeln('      } else {');
    }

    // List-level rules
    final listRules = field.rules.where((r) =>
        r.name == 'MinElements' ||
        r.name == 'MaxElements' ||
        r.name == 'UniqueElements');
    if (listRules.isNotEmpty) {
      buf.writeln(
          '      final ${field.dartName}List = ${field.dartName}Raw as List;');
      buf.writeln(
          '      final ${field.dartName}ListErrors = <String>[];');
      for (final rule in listRules) {
        switch (rule.name) {
          case 'MinElements':
            final min = rule.params['min'];
            final msg = min == 1
                ? 'must not be empty'
                : 'must have at least $min elements';
            buf.writeln(
                "      if (${field.dartName}List.length < $min) ${field.dartName}ListErrors.add('$msg');");
          case 'MaxElements':
            buf.writeln(
                "      if (${field.dartName}List.length > ${rule.params['max']}) ${field.dartName}ListErrors.add('must have at most ${rule.params['max']} elements');");
          case 'UniqueElements':
            buf.writeln(
                "      if (${field.dartName}List.length != ${field.dartName}List.toSet().length) ${field.dartName}ListErrors.add('must contain unique elements');");
        }
      }
      buf.writeln(
          "      if (${field.dartName}ListErrors.isNotEmpty) errors['${field.dartName}'] = ${field.dartName}ListErrors;");
    }

    // Item-level validation
    final itemType = field.listItemType!;
    buf.writeln(
        '      final ${field.dartName}Items = <$itemType>[];');
    buf.writeln(
        '      for (var i = 0; i < (${field.dartName}Raw as List).length; i++) {');
    buf.writeln(
        '        final item = (${field.dartName}Raw as List)[i];');
    buf.writeln('        if (item is! Map<String, Object?>) {');
    buf.writeln(
        "          errors['${field.dartName}.\$i'] = ['must be an object'];");
    buf.writeln('        } else {');
    buf.writeln(
        '          final itemResult = $itemType.\$endorse.validate(item);');
    buf.writeln('          switch (itemResult) {');
    buf.writeln('            case ValidResult(:final value):');
    buf.writeln('              ${field.dartName}Items.add(value);');
    buf.writeln('            case InvalidResult(:final fieldErrors):');
    buf.writeln(
        '              for (final entry in fieldErrors.entries) {');
    buf.writeln(
        "                errors['${field.dartName}.\$i.\${entry.key}'] = entry.value;");
    buf.writeln('              }');
    buf.writeln('          }');
    buf.writeln('        }');
    buf.writeln('      }');
    buf.writeln(
        "      if (!errors.keys.any((k) => k.startsWith('${field.dartName}'))) {");
    buf.writeln(
        "        values['${field.dartName}'] = ${field.dartName}Items;");
    buf.writeln('      }');

    if (field.isRequired) {
      buf.writeln('    }');
    } else {
      buf.writeln('      }');
      buf.writeln('    }');
    }
  }

  void _generatePrimitiveListValidation(
      StringBuffer buf, String className, _FieldInfo field) {
    final input = "input['${field.jsonKey}']";

    // Validate the list itself with checkRules
    buf.writeln(
        "    final (${field.dartName}Errors, ${field.dartName}Val) = _check${_capitalize(field.dartName)}($input);");
    buf.writeln(
        "    if (${field.dartName}Errors.isNotEmpty) errors['${field.dartName}'] = ${field.dartName}Errors;");

    // Item-level validation if itemRules exist
    if (field.itemRules.isNotEmpty) {
      final itemRuleSources = <String>[];
      for (final rule in field.itemRules) {
        if (rule.name != 'Custom') {
          itemRuleSources.add(_ruleToSource(rule));
        }
      }
      buf.writeln(
          "    if (${field.dartName}Errors.isEmpty && ${field.dartName}Val is List) {");
      buf.writeln(
          '      final itemRules = <Rule>[${itemRuleSources.join(', ')}];');
      buf.writeln(
          '      for (var i = 0; i < (${field.dartName}Val as List).length; i++) {');
      buf.writeln(
          '        final (itemErrors, _) = checkRules((${field.dartName}Val as List)[i], itemRules);');
      buf.writeln(
          "        if (itemErrors.isNotEmpty) errors['${field.dartName}.\$i'] = itemErrors;");
      buf.writeln('      }');
      buf.writeln('    }');
    }

    buf.writeln("    values['${field.dartName}'] = ${field.dartName}Val;");
  }

  void _generateWhenCondition(StringBuffer buf, _FieldInfo field) {
    final when = field.when!;
    final condition = when.equalsValue != null
        ? "input['${when.field}'] == ${when.equalsValue}"
        : when.isNotNull
            ? "input['${when.field}'] != null"
            : when.isOneOfValue != null
                ? "${when.isOneOfValue}.contains(input['${when.field}'])"
                : 'true';
    buf.writeln('    if ($condition) {');
  }

  String _castExpression(_FieldInfo field) {
    final accessor = "values['${field.dartName}']";
    final baseType = switch (field.typeKind) {
      _TypeKind.string => 'String',
      _TypeKind.int_ => 'int',
      _TypeKind.double_ => 'double',
      _TypeKind.num_ => 'num',
      _TypeKind.bool_ => 'bool',
      _TypeKind.dateTime => 'DateTime',
      _ => field.dartType,
    };
    return field.isNullable ? '$accessor as $baseType?' : '$accessor as $baseType';
  }

  // ---------------------------------------------------------------------------
  // toJson generation
  // ---------------------------------------------------------------------------

  void _generateToJson(
      StringBuffer buf, String className, List<_FieldInfo> fields) {
    buf.writeln();
    buf.writeln(
        'Map<String, dynamic> _\$${className}ToJson($className instance) => {');
    for (final field in fields) {
      final key = field.jsonKey;
      final accessor = 'instance.${field.dartName}';

      if (field.isNullable) {
        if (field.isNested) {
          buf.writeln(
              "      if ($accessor != null) '$key': _\$${field.dartType}ToJson($accessor!),");
        } else if (field.isNestedList) {
          buf.writeln(
              "      if ($accessor != null) '$key': $accessor!.map((e) => _\$${field.listItemType}ToJson(e)).toList(),");
        } else {
          buf.writeln("      if ($accessor != null) '$key': $accessor,");
        }
      } else {
        if (field.isNested) {
          buf.writeln(
              "      '$key': _\$${field.dartType}ToJson($accessor),");
        } else if (field.isNestedList) {
          buf.writeln(
              "      '$key': $accessor.map((e) => _\$${field.listItemType}ToJson(e)).toList(),");
        } else if (field.typeKind == _TypeKind.dateTime) {
          buf.writeln("      '$key': $accessor.toIso8601String(),");
        } else {
          buf.writeln("      '$key': $accessor,");
        }
      }
    }
    buf.writeln('    };');
  }

  // ---------------------------------------------------------------------------
  // Utilities
  // ---------------------------------------------------------------------------

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

// ---------------------------------------------------------------------------
// Internal data classes
// ---------------------------------------------------------------------------

enum _TypeKind { string, int_, double_, num_, bool_, dateTime, list, nested, other }

class _FieldInfo {
  final String dartName;
  final String jsonKey;
  final String dartType;
  final bool isRequired;
  final bool isNullable;
  final _TypeKind typeKind;
  final List<_RuleInfo> rules;
  final List<_RuleInfo> itemRules;
  final _WhenInfo? when;
  final bool isNested;
  final bool isList;
  final String? listItemType;
  final bool isNestedList;

  _FieldInfo({
    required this.dartName,
    required this.jsonKey,
    required this.dartType,
    required this.isRequired,
    required this.isNullable,
    required this.typeKind,
    required this.rules,
    required this.itemRules,
    required this.when,
    required this.isNested,
    required this.isList,
    required this.listItemType,
    required this.isNestedList,
  });
}

class _RuleInfo {
  final String name;
  final Map<String, Object?> params;
  _RuleInfo(this.name, [this.params = const {}]);
}

class _FieldAnnotation {
  final List<_RuleInfo> rules;
  final List<_RuleInfo> itemRules;
  final String? jsonKey;
  final bool ignore;
  final _WhenInfo? when;
  _FieldAnnotation({
    required this.rules,
    required this.itemRules,
    required this.jsonKey,
    required this.ignore,
    required this.when,
  });
}

class _WhenInfo {
  final String field;
  final String? equalsValue;
  final bool isNotNull;
  final String? isOneOfValue;
  _WhenInfo({
    required this.field,
    this.equalsValue,
    this.isNotNull = false,
    this.isOneOfValue,
  });
}
