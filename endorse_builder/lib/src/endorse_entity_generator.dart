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
          'Add this to $endorseClassName: static final \$endorse = _\$$endorseClassName();');
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
    validatorBuf.writeln('@override');
    validatorBuf.writeln('_\$${classNamePrefix}ValidationResult validate(Map<String, Object> input) {');
    validatorBuf.writeln('final r = <String, ResultObject>{};');

    // For each field
    for (var field in (element as ClassElement).fields) {
      if (field.isStatic) {
        continue;
      }
      final reader = ConstantReader(_checkForEndorseField.firstAnnotationOf(field));
      final ignore = reader.peek('ignore')?.boolValue ?? false;
      if (ignore) {
        continue;
      }

      // var fieldInfo = ProcessedFieldHolder('', fieldName: field.name);
      var fieldName = recaseFieldName(recase, '${field.name}');
      
      fieldInfo = processField(field, fieldName);
      fieldName = '${fieldInfo.fieldName}';
      
      validatorReturnBuf.write(", r['$fieldName']");
      if (resultContructorBuf.toString().isNotEmpty) {
        resultContructorBuf.write(', ');
      }
      
      // If the field is an EndorseEntity, set the type as it's result
      if (_checkForEndorseEntity.hasAnnotationOfExact(field.type.element)) {
        final childClass = field.type.getDisplayString();
        final childResultClass = '${childClass}ValidationResult';
        resultBuf.writeln('final _\$$childResultClass _$fieldName;');
        resultBuf.writeln('_\$$childResultClass get $fieldName => _$fieldName;');
        validatorBuf.writeln(fieldInfo.fieldOutput.toString());
        resultContructorBuf.write('this._$fieldName');
      // Otherwise, the type is the result for an instance field
      } else {

        if (field.type.isDartCoreList) {
          resultBuf.writeln('final ListResult _$fieldName;');
          resultBuf.writeln('ListResult get $fieldName => _$fieldName;');
        } else {
          resultBuf.writeln('final ValueResult _$fieldName;');
          resultBuf.writeln('ValueResult get $fieldName => _$fieldName;');
        }
        resultContructorBuf.write('this._$fieldName');

        validatorBuf.writeln(fieldInfo.fieldOutput.toString());
      
      
      }
    }
    resultBuf.writeln('_\$${classNamePrefix}ValidationResult(Map<String, ResultObject> fields, ValueResult mapResult, [${resultContructorBuf.toString()}]) : super(fields, mapResult);');
    resultBuf.writeln('}');
    validatorBuf.writeln('return _\$${classNamePrefix}ValidationResult(r, null${validatorReturnBuf.toString()});');
    validatorBuf.writeln('}');
    validatorBuf.writeln('');
    validatorBuf.writeln('@override');
    validatorBuf.writeln('_\$${classNamePrefix}ValidationResult invalid(ValueResult mapResult) {');
    validatorBuf.writeln('return _\$${classNamePrefix}ValidationResult(null, mapResult);');
    validatorBuf.writeln('}');
    validatorBuf.writeln('}');
    pageBuf.writeAll([resultBuf, validatorBuf]);
    return pageBuf.toString();
  }
}