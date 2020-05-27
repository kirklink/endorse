import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:recase/recase.dart';

import 'package:endorse/annotations.dart';
import 'package:endorse_builder/src/endorse_builder_exception.dart';

final _checkForEndorseField = const TypeChecker.fromRuntime(EndorseField);

class EndorseEntityGenerator extends GeneratorForAnnotation<EndorseEntity> {
  @override
  FutureOr<String> generateForAnnotatedElement(
  Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw ('EndorseEntity must only annotate a class.');
    }
    
    final classNamePrefix = '${element.name}';

    final endorseClassName = '${classNamePrefix}Endorse';
    final $endorse = (element as ClassElement).getField('\$endorse');
    if ($endorse == null || !$endorse.isStatic) {
      final notReadyBuf = StringBuffer();
      notReadyBuf.writeln(
          '\nThe EndorseEntity subject class "$endorseClassName" must have a static field "\$endorse".');
      notReadyBuf.writeln(
          'Add this to $endorseClassName: static final \$endorse = \$$endorseClassName;');
      throw EndorseBuilderException(notReadyBuf.toString());
    }

    final pageBuf = StringBuffer();
    
    final resultBuf = StringBuffer();
    final resultContructorBuf = StringBuffer();
    final validatorBuf = StringBuffer();
    final validatorReturnBuf = StringBuffer();

    // Set up the result class
    resultBuf.writeln('class \$${classNamePrefix}ValidationResult implements ValidationResult {');
    resultBuf.writeln('@override');
    resultBuf.writeln('final Map<String, Object> values;');
    resultBuf.writeln('@override');
    resultBuf.writeln('final bool isValid;');
    
    // Set up the validator class
    validatorBuf.writeln('class \$${classNamePrefix}Validator implements Validator {');
    validatorBuf.writeln('');
    validatorBuf.writeln('\$${classNamePrefix}ValidationResult validate(Map<String, Object> input) {');
    validatorBuf.writeln('final r = <String, ValueResult>{};');
    validatorBuf.writeln('final v = <String, Object>{};');
    validatorBuf.writeln('var isValid = true;');

    
    
    // For each field
    for (var field in (element as ClassElement).fields) {
      if (field.isStatic) {
        continue;
      }
      final fieldName = '${field.name}';

      resultBuf.writeln('final ValueResult $fieldName;');
      resultContructorBuf.write(', this.$fieldName');
      validatorBuf.write("r['$fieldName'] = (ValidationRules('$fieldName', input['$fieldName'])");
      validatorReturnBuf.write(", r['$fieldName']");

      

      
      
      // Handle the annotations
      if (_checkForEndorseField.hasAnnotationOfExact(field)) {
        final reader = ConstantReader(_checkForEndorseField.firstAnnotationOf(field));
        final validations = reader.peek('validations').listValue;
        final require = reader.peek('require')?.boolValue ?? false;
        final fromString = reader.peek('fromString')?.boolValue ?? false;
        
        
        
        var typeRule = '';
        var castFromString = '';
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
        }

        var preRules = '';
        if (require) {
          preRules = '..isRequired()$typeRule';
        } else {
          preRules = '$typeRule';
        }

        validatorBuf.write(preRules);



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
          final r = '..' + (rule.getField('part').toStringValue()).replaceFirst('@', v);
          validatorBuf.write(r);
        }
      }
      validatorBuf.writeln(').done();');
      validatorBuf.writeln("v['$fieldName'] = List.from(r['$fieldName'].errors.map((i) => i.map()));");
      validatorBuf.writeln("isValid = isValid == false ? false : r['$fieldName'].isValid;");
    }
    resultBuf.writeln('\$${classNamePrefix}ValidationResult(this.isValid, this.values${resultContructorBuf.toString()});');
    resultBuf.writeln('}');
    validatorBuf.writeln('return \$${classNamePrefix}ValidationResult(isValid, v${validatorReturnBuf.toString()});');
    validatorBuf.writeln('}');
    validatorBuf.writeln('}');
    pageBuf.writeAll([resultBuf, validatorBuf]);
    return pageBuf.toString();
  }
}