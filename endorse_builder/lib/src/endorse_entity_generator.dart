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
    return '';
  }
}