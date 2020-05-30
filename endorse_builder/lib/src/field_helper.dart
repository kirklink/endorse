import 'package:analyzer/dart/element/element.dart';
import 'package:endorse_builder/src/endorse_builder_exception.dart';
import 'package:source_gen/source_gen.dart';
import 'package:endorse/endorse.dart';

final _checkForEndorseField = const TypeChecker.fromRuntime(EndorseField);

StringBuffer processField(FieldElement field) {

  final fieldName = '${field.name}';

  final buf = StringBuffer();
  final valueRule = StringBuffer();
  final listRule = StringBuffer();
  // if (field.type is List) {
  //   buf.write("r['$fieldName'] = ");
  // } else {
  //   buf.write("r['$fieldName'] = ");
  // }
  buf.write("r['$fieldName'] = ");
  

  // Validate the field
  // Handle the annotations
  if (_checkForEndorseField.hasAnnotationOfExact(field)) {
    final reader = ConstantReader(_checkForEndorseField.firstAnnotationOf(field));
    final validations = reader.peek('validate').listValue;
    final listItemValidations = reader.peek('listItemValidate:');
    final isRequired = reader.peek('require')?.boolValue ?? false;
    final fromString = reader.peek('fromString')?.boolValue ?? false;
    
    var isList = false;
    var isCore = false;
    final fieldBuf = StringBuffer();
    final listBuf = StringBuffer();
    var fieldType = '';
    var listType = '';
    var require = '';
    var castFromString = '';

    fieldBuf.write('(ApplyRulesToField()');
    listBuf.write('(ApplyRulesToField()');
    
    if (isRequired) {
      require = '..isRequired()';
    }

    if (fromString) {
      castFromString = 'fromString: true';
    }

    if (field.type.isDartCoreList) {
      isList = true;
      // typeRule = '..isList()';
      fieldType = ('..isList()');
      final listType = field.type.toString().split('<')[1].split('>')[0];
      print(listType);
      switch(listType) {
        case 'String': fieldType = '$fieldType..ofStrings()';
          break;
        case 'int': fieldType = '$fieldType..ofInts()';
          break;
        case 'double': fieldType = '$fieldType..ofDoubles()';
          break;
        case 'bool': fieldType = '$fieldType..ofBools()';
          break;
        default: 
          throw EndorseBuilderException('$listType not implemented');
      }
    } else if (field.type.isDartCoreString) {
      fieldType = '..isString()';
    } else if (field.type.isDartCoreInt) {
      fieldType = '..isInt($castFromString)';
    } else if (field.type.isDartCoreDouble) {
      fieldType = '..isDouble($castFromString)';
    } else if (field.type.isDartCoreBool) {
      fieldType = '..isBoolean($castFromString)';
    } else {
      throw EndorseBuilderException('${field.type.toString()} is not implemented');
    }

    var preRules = '$require$fieldType';

    buf.write(preRules);



    // Handle the validations
    for (final rule in validations) {
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
      final r = '..' + (rule.getField('call').toStringValue()).replaceFirst('@', v);
      buf.write(r);
    }
  }

  if (field.type.isDartCoreList) {
    buf.writeln(');');
  } else {
    buf.writeln(").done(input['$fieldName'], '$fieldName');");
  }
  return buf;
    

}