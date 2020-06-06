import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

import 'package:endorse/annotations.dart';
import 'package:endorse_builder/src/processed_field_holder.dart';
import 'package:endorse_builder/src/endorse_builder_exception.dart';
import 'package:endorse_builder/src/field_helper.dart';
import 'package:endorse_builder/src/case_helper.dart';


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

    var recase = annotation.peek('useCase')?.objectValue?.getField('none')?.toIntValue() ?? 0;
    recase = annotation.peek('useCase')?.objectValue?.getField('camelCase')?.toIntValue() ?? recase;
    recase = annotation.peek('useCase')?.objectValue?.getField('snakeCase')?.toIntValue() ?? recase;
    recase = annotation.peek('useCase')?.objectValue?.getField('pascalCase')?.toIntValue() ?? recase;
    recase = annotation.peek('useCase')?.objectValue?.getField('kebabCase')?.toIntValue() ?? recase;

    final pageBuf = StringBuffer();
    final resultBuf = StringBuffer();
    final resultContructorBuf = StringBuffer();
    final validatorBuf = StringBuffer();
    final validatorReturnBuf = StringBuffer();
    ProcessedFieldHolder fieldInfo;

    // Set up the result class
    resultBuf.writeln('class _\$${classNamePrefix}ValidationResult extends ClassResult {');
    
    // Set up the validator class
    validatorBuf.writeln('class _\$Endorse${classNamePrefix} implements EndorseClassValidator {');
    validatorBuf.writeln('');
    validatorBuf.writeln('_\$${classNamePrefix}ValidationResult validate(Map<String, Object> input) {');
    validatorBuf.writeln('final r = <String, ResultObject>{};');

    // For each field
    for (var field in (element as ClassElement).fields) {
      if (field.isStatic) {
        continue;
      }

      // var fieldInfo = ProcessedFieldHolder('', fieldName: field.name);
      var fieldName = recaseFieldName(recase, '${field.name}');
      
      if (!_checkForEndorseEntity.hasAnnotationOfExact(field.type.element)) {
        fieldInfo = processField(field, fieldName);
        if (fieldInfo.ignore) {
          continue;
        }
        fieldName = '${fieldInfo.fieldName}';
      }
      
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

        if (field.type.isDartCoreList) {
          resultBuf.writeln('final ListResult $fieldName;');
        } else {
          resultBuf.writeln('final ValueResult $fieldName;');
        } 
        

        validatorBuf.writeln(fieldInfo.fieldOutput.toString());
      
      
      }
    }
    resultBuf.writeln('_\$${classNamePrefix}ValidationResult(Map<String, ResultObject> fields${resultContructorBuf.toString()}) : super(fields);');
    resultBuf.writeln('}');
    validatorBuf.writeln('return _\$${classNamePrefix}ValidationResult(r${validatorReturnBuf.toString()});');
    validatorBuf.writeln('}');
    // validatorBuf.writeln('List<_\$${classNamePrefix}ValidationResult> validateList(List<Object> list) {');
    // validatorBuf.writeln('final result = <_\$${classNamePrefix}ValidationResult>[];');
    // validatorBuf.writeln('list.asMap().forEach((index, value) {');
    // validatorBuf.writeln('final r = validate({index.toString(): value});');
    // validatorBuf.writeln('result.add(r);');
    // validatorBuf.writeln('});');
    // validatorBuf.writeln('return result;');
    // validatorBuf.writeln('}');
    validatorBuf.writeln('}');
    pageBuf.writeAll([resultBuf, validatorBuf]);
    return pageBuf.toString();
  }
}