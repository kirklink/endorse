import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:endorse_builder/src/endorse_builder_exception.dart';
import 'package:source_gen/source_gen.dart';
import 'package:endorse/endorse.dart';


final _checkForEndorseField = const TypeChecker.fromRuntime(EndorseField);

String _processValidations(List<DartObject> validations) {
   
   if (validations == null) {
     return '';
   }
   var r = '';
   for (final rule in validations) {
    if (rule.type.getDisplayString() == 'Required' 
        || rule.type.getDisplayString() == 'FromString') {
      continue;
    }
    // Get the right type for the test value
    final t = rule.getField('value')?.type;
    String v;
    if (t == null) {
      v = '';
    } else if (t.isDartCoreString) {
      v = "'${rule.getField('value').toStringValue().toString()}'";
    } else if (t.isDartCoreInt) {
      v = rule.getField('value').toIntValue().toString();
    } else if (t.isDartCoreDouble) {
      v = rule.getField('value').toDoubleValue().toString();
    }
    // Replace the token with a value
    r = r + '..' + (rule.getField('call').toStringValue()).replaceFirst('@', v);
  }
  return r;
}




StringBuffer processField(FieldElement field) {

  final fieldName = '${field.name}';

  final buf = StringBuffer();
  
  var isCore = false;
  final fieldBuf = StringBuffer();
  final itemBuf = StringBuffer();
  var fieldType = '';
  var itemType = '';
  var fieldCastFromString = '';
  var itemCastFromString = '';

  buf.write("r['$fieldName'] = ");

  final isList = field.type.isDartCoreList;

  if (isList) {
    fieldType = '..isList()';
    final listTypeParts = (field.type.toString()
      .split('<').map((p) => p.replaceAll('>', ''))
      .toList()
        ..removeWhere((s) => s == null || s.isEmpty));
    for (final p in listTypeParts.getRange(1, listTypeParts.length)) {
      if (p == 'List') {
        fieldType = '$fieldType..ofList()';
      }
    }
    final listTypeStr = listTypeParts.firstWhere((e) => e != 'List');
    switch(listTypeStr) {
      case 'String': itemType = '..isString()';
        break;
      case 'int': itemType = '..isInt(@)';
        break;
      case 'double': itemType = '..isDouble(@)';
        break;
      case 'bool': itemType = '..isBoolean(@)';
        break;
      default: 
        throw EndorseBuilderException('$listTypeStr not implemented');
    }
  } else {
    if (field.type.isDartCoreString) {
    fieldType = '..isString()';
    } else if (field.type.isDartCoreInt) {
      fieldType = '..isInt(@)';
    } else if (field.type.isDartCoreDouble) {
      fieldType = '..isDouble(@)';
    } else if (field.type.isDartCoreBool) {
      fieldType = '..isBoolean(@)';
    } else {
      throw EndorseBuilderException('${field.type.toString()} is not implemented');
    }
  }
  // Validate the field
  // Handle the annotations

  final validations = <DartObject>[];
  final itemValidations = <DartObject>[];

  if (_checkForEndorseField.hasAnnotationOfExact(field)) {
    final reader = ConstantReader(_checkForEndorseField.firstAnnotationOf(field));
    validations.addAll(reader.peek('validate').listValue);
    itemValidations.addAll(reader.peek('itemValidate').listValue);

    final fromString = 'fromString: true';  
    
    if (validations.any((e) => e.type.getDisplayString() == 'Required')) {
      fieldType = '..isRequired()' + fieldType;
    }

    if (validations.any((e) => e.type.getDisplayString() == 'FromString')) {
      fieldCastFromString = fromString;
    }
    
    
    if (isList) {
      if (itemValidations.any((e) => e.type.getDisplayString() == 'Required')) {
        itemType = '..isRequired()' + itemType;
      }
      
      if (itemValidations.any((e) => e.type.getDisplayString() == 'FromString')) {
        itemCastFromString = fromString;
      }  
    }
    
  }

  fieldType = fieldType.replaceFirst('@', fieldCastFromString);

  fieldBuf.write(fieldType);
  if (validations.isNotEmpty) {
    fieldBuf.write(_processValidations(validations));
  }
  
  itemType = itemType.replaceFirst('@', itemCastFromString);
  itemBuf.writeln(itemType);
  if (itemValidations.isNotEmpty) {
    itemBuf.write(_processValidations(itemValidations));
  }
  
 
  if (isList) {
    buf.write('(ApplyRulesToList.fromCore(ApplyRulesToValue()');
    buf.write(fieldBuf.toString());
    buf.write(', ApplyRulesToValue()');
    buf.write(itemBuf.toString());
    buf.write(")).done(input['$fieldName'], '$fieldName');");
  } else {
    buf.write('(ApplyRulesToValue()');
    buf.write(fieldBuf.toString());
    buf.write(").done(input['$fieldName'], '$fieldName');");
  }

  return buf;
}