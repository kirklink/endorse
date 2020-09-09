import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:endorse_builder/src/endorse_class_helper.dart';
import 'package:source_gen/source_gen.dart';

import 'package:endorse/annotations.dart';
import 'package:endorse_builder/src/endorse_builder_exception.dart';


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

    final endorse = convertToEndorse(element, recase);
    return endorse.toString();
  }
}