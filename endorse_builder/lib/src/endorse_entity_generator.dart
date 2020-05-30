import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:recase/recase.dart';

import 'package:endorse/annotations.dart';
import 'package:endorse_builder/src/endorse_builder_exception.dart';
import 'package:endorse_builder/src/field_helper.dart';


final _checkForEndorseEntity = const TypeChecker.fromRuntime(EndorseEntity);

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
    resultBuf.writeln('class _\$${classNamePrefix}ValidationResult implements ResultObject {');
    resultBuf.writeln('@override');
    resultBuf.writeln('final bool isValid;');
    resultBuf.writeln('@override');
    resultBuf.writeln('final Object value;');
    resultBuf.writeln('@override');
    resultBuf.writeln('final Object errors;\n');
    // resultBuf.writeln('');
    
    
    // Set up the validator class
    validatorBuf.writeln('class _\$${classNamePrefix}Validator implements Validator {');
    validatorBuf.writeln('');
    validatorBuf.writeln('_\$${classNamePrefix}ValidationResult validate(Map<String, Object> input) {');
    validatorBuf.writeln('final r = <String, ResultObject>{};');
    validatorBuf.writeln('final v = <String, Object>{};');
    validatorBuf.writeln('final e = <String, Object>{};');
    validatorBuf.writeln('var isValid = true;');

    
    
    // For each field
    for (var field in (element as ClassElement).fields) {
      if (field.isStatic) {
        continue;
      }


      
      final fieldName = '${field.name}';
      resultContructorBuf.write(', this.$fieldName');
      validatorReturnBuf.write(", r['$fieldName']");
      
      // If the field is an EndorseEntity, set the type as it's result
      if (_checkForEndorseEntity.hasAnnotationOfExact(field.type.element)) {
        final childClass = field.type.getDisplayString();
        final childResultClass = '${childClass}ValidationResult';
        resultBuf.writeln('final _\$$childResultClass $fieldName;');
        validatorBuf.writeln("r['$fieldName'] = ${childClass}.\$endorse.validate(input['$fieldName']);");
      // Otherwise, the type is the result for an instance field
      } else {
        
      resultBuf.writeln('final ValueResult $fieldName;');
      final fieldBuf = processField(field);
      validatorBuf.writeln(fieldBuf.toString());
      

      

      
      
      }
      validatorBuf.writeln("v['$fieldName'] = r['$fieldName'].value;");
      validatorBuf.writeln("if (!r['$fieldName'].isValid) e['$fieldName'] = r['$fieldName'].errors;");
      validatorBuf.writeln("isValid = isValid == false ? false : r['$fieldName'].isValid;");
    }
    resultBuf.writeln('_\$${classNamePrefix}ValidationResult(this.isValid, this.value, this.errors${resultContructorBuf.toString()});');
    resultBuf.writeln('}');
    validatorBuf.writeln('return _\$${classNamePrefix}ValidationResult(isValid, v, e${validatorReturnBuf.toString()});');
    validatorBuf.writeln('}');
    validatorBuf.writeln('List<_\$${classNamePrefix}ValidationResult> validateList(List<Object> list) {');
    validatorBuf.writeln('final result = <_\$${classNamePrefix}ValidationResult>[];');
    validatorBuf.writeln('list.asMap().forEach((index, value) {');
    validatorBuf.writeln('final r = validate({index.toString(): value});');
    validatorBuf.writeln('result.add(r);');
    validatorBuf.writeln('});');
    validatorBuf.writeln('return result;');
    validatorBuf.writeln('}');
    validatorBuf.writeln('}');
    pageBuf.writeAll([resultBuf, validatorBuf]);
    return pageBuf.toString();
  }
}