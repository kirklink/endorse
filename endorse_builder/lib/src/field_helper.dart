import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:endorse_builder/src/endorse_builder_exception.dart';
import 'package:endorse_builder/src/processed_field_holder.dart';
import 'package:source_gen/source_gen.dart';
import 'package:endorse/annotations.dart';
import 'package:recase/recase.dart';


final _checkForEndorseField = const TypeChecker.fromRuntime(EndorseField);

String _processValidations(List<DartObject> validations, Type type) {
   
   if (validations == null) {
     return '';
   }
   var ruleCall = '';
   for (final rule in validations) {
    if (rule.type.getDisplayString() == 'Required' 
        || rule.type.getDisplayString() == 'FromString') {
      continue;
    }
    // Get the right type for the test value
    final valueType = rule.getField('value')?.type;
    final validOnList = rule.getField('validOnTypes')?.toListValue();
    final notValidOnList = rule.getField('notValidOnTypes')?.toListValue();
    if (validOnList != null && validOnList.isNotEmpty) {
      if (!validOnList.map((v) => v.toTypeValue().getDisplayString()).contains(type.toString())) {
        throw EndorseBuilderException('${rule.type.getDisplayString()} cannot be used on a ${type.toString()}');
      }
    };
    if (notValidOnList != null && notValidOnList.isNotEmpty) {
      if (validOnList.map((v) => v.toTypeValue().getDisplayString()).contains(type.toString())) {
        throw EndorseBuilderException('${rule.type.getDisplayString()} cannot be used on a ${type.toString()}');
      }
    };
    String value;
    if (valueType == null) {
      value = '';
    } else if (valueType.isDartCoreString) {
      value = "'${rule.getField('value').toStringValue().toString()}'";
    } else if (valueType.isDartCoreInt) {
      value = rule.getField('value').toIntValue().toString();
    } else if (valueType.isDartCoreDouble) {
      value = rule.getField('value').toDoubleValue().toString();
    }
    // Replace the token with a value
    ruleCall = ruleCall + '..' + (rule.getField('call').toStringValue()).replaceFirst('@', value);
  }
  return ruleCall;
}




ProcessedFieldHolder processField(FieldElement field, int entityRecase) {

  

  final buf = StringBuffer();
  
  var isCore = true;
  final fieldBuf = StringBuffer();
  final itemBuf = StringBuffer();
  var fieldRules = '';
  var itemRules = '';
  Type fieldType;
  Type itemType;
  var endorseType = '';
  var fieldCastFromString = '';
  var itemCastFromString = '';
  final isList = field.type.isDartCoreList;
  final validations = <DartObject>[];
  final itemValidations = <DartObject>[];

  var fieldName = '${field.name}';
  
  if (_checkForEndorseField.hasAnnotationOfExact(field)) {
    final reader = ConstantReader(_checkForEndorseField.firstAnnotationOf(field));
    validations.addAll(reader.peek('validate').listValue);
    itemValidations.addAll(reader.peek('itemValidate').listValue);
    final ignore = reader.peek('ignore')?.boolValue ?? false;

    var recase = reader.peek('useCase')?.objectValue?.getField('none')?.toIntValue() ?? 0;
    recase = reader.peek('useCase')?.objectValue?.getField('camelCase')?.toIntValue() ?? recase;
    recase = reader.peek('useCase')?.objectValue?.getField('snakeCase')?.toIntValue() ?? recase;
    recase = reader.peek('useCase')?.objectValue?.getField('pascalCase')?.toIntValue() ?? recase;
    recase = reader.peek('useCase')?.objectValue?.getField('kebabCase')?.toIntValue() ?? recase;

    if (ignore) {
      return ProcessedFieldHolder('', ignore: true);
    }

    final useCase = recase > 0 ? recase : entityRecase;
    
    print(useCase);
    if (useCase > 0) {
      final rc = ReCase('$fieldName');
      switch (useCase) {
        case 1: fieldName = rc.camelCase;
        break;
        case 2: fieldName = rc.snakeCase;
        break;
        case 3: fieldName = rc.pascalCase;
        break;
        case 4: fieldName = rc.paramCase;
        break;
        default:
        break;
      }
    }
    
  }

  
  buf.write("r['$fieldName'] = ");

  

  if (isList) {
    fieldType = List;
    fieldRules = '..isList()';
    final listTypeParts = (field.type.toString()
      .split('<').map((p) => p.replaceAll('>', ''))
      .toList()
        ..removeWhere((s) => s == null || s.isEmpty));
    for (final p in listTypeParts.getRange(1, listTypeParts.length)) {
      if (p == 'List') {
        fieldRules = '$fieldRules..ofList()';
      }
    }
    final listTypeStr = listTypeParts.firstWhere((e) => e != 'List');
    switch(listTypeStr) {
      case 'String': {
        itemRules = '..isString()';
        itemType = String;
      }
        break;
      case 'num': {
        itemRules = '..isNum(@)';
        itemType = num;
      }
        break;
      case 'int': {
        itemRules = '..isInt(@)';
        itemType = int;
      }
        break;
      case 'double': {
        itemRules = '..isDouble(@)';
        itemType = double;
      }
        break;
      case 'bool': {
        itemRules = '..isBoolean(@)';
        itemType = bool;
        }
        break;
      case 'DateTime':
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
      break;
      default: 
        isCore = false;
        endorseType = listTypeStr;
      break;
    }
  } else {
    if (field.type.isDartCoreString) {
      fieldRules = '..isString()';
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
      fieldRules = '..isBoolean(@)';
      fieldType = bool;
    } else {
      throw EndorseBuilderException('${field.type.toString()} is not implemented');
    }
  }
  // Validate the field
  // Handle the annotations



  final fromString = 'fromString: true';  
  
  if (validations.any((e) => e.type.getDisplayString() == 'Required')) {
    fieldRules = '..isRequired()' + fieldRules;
  }

  if (validations.any((e) => e.type.getDisplayString() == 'FromString')) {
    fieldCastFromString = fromString;
  }
  
  
  if (isList && isCore) {
    if (itemValidations.any((e) => e.type.getDisplayString() == 'Required')) {
      itemRules = '..isRequired()' + itemRules;
    }
    
    if (itemValidations.any((e) => e.type.getDisplayString() == 'FromString')) {
      itemCastFromString = fromString;
    }  
  }
    


  fieldRules = fieldRules.replaceFirst('@', fieldCastFromString);

  fieldBuf.write(fieldRules);
  if (validations.isNotEmpty) {
    fieldBuf.write(_processValidations(validations, fieldType));
  }
  
  if (isCore) {
    itemRules = itemRules.replaceFirst('@', itemCastFromString);
    itemBuf.writeln(itemRules);
    if (itemValidations.isNotEmpty) {
      itemBuf.write(_processValidations(itemValidations, itemType));
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
    buf.write(', _\$Endorse$endorseType()');
    buf.write(")).from(input['$fieldName'], '$fieldName');");
  } else {
    buf.write('(ValidateValue()');
    buf.write(fieldBuf.toString());
    buf.write(").from(input['$fieldName'], '$fieldName');");
  }

  return ProcessedFieldHolder(buf.toString(), fieldName: fieldName);
}