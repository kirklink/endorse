import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:endorse/src/builder/endorse_builder_exception.dart';
import 'package:endorse/src/builder/processed_field_holder.dart';
import 'package:source_gen/source_gen.dart';
import 'package:endorse/annotations.dart';
import 'package:endorse/src/builder/case_helper.dart';

final _checkForEndorseEntity = const TypeChecker.fromRuntime(EndorseEntity);
final _checkForEndorseField = const TypeChecker.fromRuntime(EndorseField);

String processValidations(List<DartObject> validations, Type? type) {
  if (validations.isEmpty) {
    return '';
  }
  var ruleCall = '';

  var typeOverride = '';

  if (validations.any((v) =>
      v.type!.getDisplayString(withNullability: false) == 'ToStringFromInt')) {
    typeOverride = 'int';
    ruleCall = ruleCall + '..isInt()';
  } else if (validations.any((v) =>
      v.type!.getDisplayString(withNullability: false) ==
      'ToStringFromDouble')) {
    typeOverride = 'double';
    ruleCall = ruleCall + '..isDouble()';
  } else if (validations.any((v) =>
      v.type!.getDisplayString(withNullability: false) == 'ToStringFromNum')) {
    typeOverride = 'num';
    ruleCall = ruleCall + '..isNum()';
  } else if (validations.any((v) =>
      v.type!.getDisplayString(withNullability: false) == 'ToStringFromBool')) {
    typeOverride = 'bool';
    ruleCall = ruleCall + '..isBool()';
  }

  for (final rule in validations) {
    if (rule.type!.getDisplayString(withNullability: false) == 'Required') {
      continue;
    }

    if (rule.type!
        .getDisplayString(withNullability: false)
        .startsWith('ToString')) {
      typeOverride = 'String';
    } else if (rule.type!.getDisplayString(withNullability: false) ==
        'IntFromString') {
      typeOverride = 'int';
    } else if (rule.type!.getDisplayString(withNullability: false) ==
        'DoubleFromString') {
      typeOverride = 'double';
    } else if (rule.type!.getDisplayString(withNullability: false) ==
        'NumFromString') {
      typeOverride = 'num';
    } else if (rule.type!.getDisplayString(withNullability: false) ==
        'BoolFromString') {
      typeOverride = 'bool';
    }

    // Get the right type for the test value
    final valueType = rule.getField('value')?.type;
    final validOnList = rule.getField('validOnTypes')?.toListValue();
    final notValidOnList = rule.getField('notValidOnTypes')?.toListValue();

    final typeToCheck =
        typeOverride.isNotEmpty ? typeOverride : type.toString();

    if (validOnList != null && validOnList.isNotEmpty) {
      if (!validOnList
          .map((v) => v.toTypeValue()!.getDisplayString(withNullability: false))
          .contains(typeToCheck)) {
        throw EndorseBuilderException(
            '${rule.type!.getDisplayString(withNullability: false)} cannot be used on a ${type.toString()}');
      }
    }
    ;
    if (notValidOnList != null && notValidOnList.isNotEmpty) {
      if (notValidOnList
          .map((v) => v.toTypeValue()!.getDisplayString(withNullability: false))
          .contains(typeToCheck)) {
        throw EndorseBuilderException(
            '${rule.type!.getDisplayString(withNullability: false)} cannot be used on a ${type.toString()}');
      }
    }
    ;

    var value = '';
    if (valueType == null) {
      value = '';
    } else if (valueType.isDartCoreString) {
      value = "'${rule.getField('value')!.toStringValue().toString()}'";
    } else if (valueType.isDartCoreInt) {
      value = rule.getField('value')!.toIntValue().toString();
    } else if (valueType.isDartCoreDouble) {
      value = rule.getField('value')!.toDoubleValue().toString();
    }
    // Replace the token with a value
    ruleCall = ruleCall +
        '..' +
        (rule.getField('call')!.toStringValue())!.replaceFirst('@', value);
  }
  return ruleCall;
}

ProcessedFieldHolder processField(FieldElement field, String fieldName) {
  final buf = StringBuffer();

  var isCore = true;
  var isEndorseEntity = false;
  final fieldBuf = StringBuffer();
  final itemBuf = StringBuffer();
  var fieldRules = '';
  var itemRules = '';
  Type fieldType;
  Type? itemType;
  var endorseType = '';
  final isList = field.type.isDartCoreList;

  final validations = <DartObject>[];
  final itemValidations = <DartObject>[];

  if (_checkForEndorseField.hasAnnotationOfExact(field)) {
    final reader =
        ConstantReader(_checkForEndorseField.firstAnnotationOf(field));
    validations.addAll(reader.peek('validate')?.listValue ?? const []);
    itemValidations.addAll(reader.peek('itemValidate')?.listValue ?? const []);
    final ignore = reader.peek('ignore')?.boolValue ?? false;
    final nameOverride = reader.peek('name')?.stringValue ?? '';

    if (ignore) {
      return ProcessedFieldHolder('', ignore: true);
    }

    var recase =
        reader.peek('useCase')?.objectValue.getField('none')?.toIntValue() ?? 0;
    recase = reader
            .peek('useCase')
            ?.objectValue
            .getField('camelCase')
            ?.toIntValue() ??
        recase;
    recase = reader
            .peek('useCase')
            ?.objectValue
            .getField('snakeCase')
            ?.toIntValue() ??
        recase;
    recase = reader
            .peek('useCase')
            ?.objectValue
            .getField('pascalCase')
            ?.toIntValue() ??
        recase;
    recase = reader
            .peek('useCase')
            ?.objectValue
            .getField('kebabCase')
            ?.toIntValue() ??
        recase;

    if (nameOverride.isNotEmpty) {
      fieldName = nameOverride;
    } else {
      fieldName = recaseFieldName(recase, fieldName);
    }
  }

  buf.write("r['$fieldName'] = ");

  if (isList) {
    fieldType = List;
    fieldRules = '..isList()';
    final listTypeParts = (field.type
        .toString()
        .split('<')
        .map((p) => p.replaceAll('>', ''))
        .toList()
      ..removeWhere((s) => s == null || s.isEmpty));
    for (final p in listTypeParts.getRange(1, listTypeParts.length)) {
      if (p == 'List') {
        fieldRules = '$fieldRules..ofList()';
      }
    }
    final listTypeStr = listTypeParts.firstWhere((e) => e != 'List');
    switch (listTypeStr) {
      case 'String':
        {
          itemRules = '..isString(#)';
          itemType = String;
        }
        break;
      case 'num':
        {
          itemRules = '..isNum(@)';
          itemType = num;
        }
        break;
      case 'int':
        {
          itemRules = '..isInt(@)';
          itemType = int;
        }
        break;
      case 'double':
        {
          itemRules = '..isDouble(@)';
          itemType = double;
        }
        break;
      case 'bool':
        {
          itemRules = '..isBoolean(@)';
          itemType = bool;
        }
        break;
      case 'DateTime':
        {
          itemRules = '..isDateTime()';
          itemType = DateTime;
        }
        break;
      case 'BigInt':
      case 'Duration':
      case 'Expando':
      case 'Iterable':
      case 'Object':
      case 'Pattern':
      case 'RegExp':
      case 'Runes':
      case 'Set':
      case 'Symbol':
      case 'Uri':
        throw EndorseBuilderException('$listTypeStr not implemented');
      default:
        isCore = false;
        endorseType = listTypeStr;
        break;
    }
  } else {
    if (_checkForEndorseEntity.hasAnnotationOfExact(field.type.element!)) {
      // TODO: or checkForEndorseMap

      fieldRules = '..isMap()';
      isEndorseEntity = true;
      fieldType = Map;
    } else if (field.type.getDisplayString(withNullability: false) ==
        'DateTime') {
      fieldRules = '..isDateTime()';
      fieldType = DateTime;
    } else if (field.type.isDartCoreString) {
      fieldRules = '..isString(#)';
      fieldType = String;
    } else if (field.type.isDartCoreNum) {
      fieldRules = '..isNum(@)';
      fieldType = num;
    } else if (field.type.isDartCoreInt) {
      fieldRules = '..isInt(@)';
      fieldType = int;
    } else if (field.type.isDartCoreDouble) {
      fieldRules = '..isDouble(@)';
      fieldType = double;
    } else if (field.type.isDartCoreBool) {
      fieldRules = '..isBoolean()';
      fieldType = bool;
    } else {
      throw EndorseBuilderException(
          '${field.type.toString()} is not implemented');
    }
  }

  const fromString = 'fromString: true';
  const toString = 'toString: true';
  const fromStringRules = const [
    'IntFromString',
    'DoubleFromString',
    'NumFromString',
    'BoolFromString'
  ];

  if (validations.any(
      (e) => e.type!.getDisplayString(withNullability: false) == 'Required')) {
    fieldRules = '..isRequired()' + fieldRules;
  }

  if (validations.any((e) => fromStringRules
      .contains(e.type!.getDisplayString(withNullability: false)))) {
    fieldRules = fieldRules.replaceFirst('@', fromString);
  }

  if (validations.any((e) => e.type!
      .getDisplayString(withNullability: false)
      .startsWith('ToString'))) {
    fieldRules = fieldRules.replaceFirst('#', toString);
  }
  fieldRules = fieldRules.replaceFirst('@', '');
  fieldRules = fieldRules.replaceFirst('#', '');

  fieldBuf.write(fieldRules);
  if (validations.isNotEmpty) {
    fieldBuf.write(processValidations(validations, fieldType));
  }

  if (isList && isCore) {
    if (itemValidations.any((e) =>
        e.type!.getDisplayString(withNullability: false) == 'Required')) {
      itemRules = '..isRequired()' + itemRules;
    }
    if (itemValidations.any((e) => fromStringRules
        .contains(e.type!.getDisplayString(withNullability: false)))) {
      itemRules = itemRules.replaceFirst('@', fromString);
    }
    if (itemValidations.any((e) => e.type!
        .getDisplayString(withNullability: false)
        .startsWith('ToString'))) {
      itemRules = itemRules.replaceFirst('#', toString);
    }
    itemRules = itemRules.replaceFirst('@', '');
    itemRules = itemRules.replaceFirst('#', '');
  }

  if (isCore) {
    itemBuf.writeln(itemRules);
    if (itemValidations.isNotEmpty) {
      itemBuf.write(processValidations(itemValidations, itemType));
    }
  }

  if (isList && isCore) {
    buf.write('(ValidateList.fromCore(ValidateValue()');
    buf.write(fieldBuf.toString());
    buf.write(', ValidateValue()');
    buf.write(itemBuf.toString());
    buf.write(")).from(input['$fieldName'], '$fieldName');");
  } else if (isList && !isCore) {
    buf.write('(ValidateList.fromEndorse(ValidateValue()');
    buf.write(fieldBuf.toString());
    buf.write(', _\$${endorseType}Endorse()');
    buf.write(")).from(input['$fieldName'], '$fieldName');");
  } else if (isEndorseEntity) {
    final childClass = field.type.getDisplayString(withNullability: false);
    final childResultClass = '${childClass}ValidationResult';
    buf.write("(ValidateMap<_\$${childResultClass}>(ValidateValue()");
    buf.write(fieldBuf.toString());
    buf.write(', _\$${childClass}Endorse()');
    buf.write(")).from(input['$fieldName'], '$fieldName');");
  } else {
    buf.write('(ValidateValue()');
    buf.write(fieldBuf.toString());
    buf.write(").from(input['$fieldName'], '$fieldName');");
  }

  return ProcessedFieldHolder(buf.toString(), fieldName: fieldName);
}
