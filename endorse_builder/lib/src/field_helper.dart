import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:endorse/annotations.dart';

final _checkForEndorseField = const TypeChecker.fromRuntime(EndorseField);

StringBuffer processField(FieldElement field) {

  final fieldName = '${field.name}';

  final buf = StringBuffer();
  final valueRule = StringBuffer();
  final listRule = StringBuffer();
  buf.write("r['$fieldName'] = (ApplyRulesToField()");

  // Validate the field
  // Handle the annotations
  if (_checkForEndorseField.hasAnnotationOfExact(field)) {
    final reader = ConstantReader(_checkForEndorseField.firstAnnotationOf(field));
    final validations = reader.peek('validate').listValue;
    final require = reader.peek('require')?.boolValue ?? false;
    final fromString = reader.peek('fromString')?.boolValue ?? false;
    
    
    
    var typeRule = '';
    var castFromString = '';
    var isList = false;
    if (fromString) {
      castFromString = 'fromString: true';
    }
    if (field.type.isDartCoreString) {
      typeRule = '..isString()';
    } else if (field.type.isDartCoreInt) {
      typeRule = '..isInt($castFromString)';
    } else if (field.type.isDartCoreDouble) {
      typeRule = '..isDouble($castFromString)';
    } else if (field.type.isDartCoreBool) {
      typeRule = '..isBoolean($castFromString)';
    } else if (field.type.isDartCoreList) {
      isList = true;
      typeRule = '..isList()';
      final listType = field.type.toString().split('<')[1].split('>')[0];
      print(listType);
      switch(listType) {
        case 'String': typeRule = '$typeRule..ofStrings()';
        break;
      }
    }

    var preRules = '';
    if (require) {
      preRules = '..isRequired()$typeRule';
    } else {
      preRules = '$typeRule';
    }

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