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
    var $endorse = (element as ClassElement).getField('\$endorse');
    if ($endorse == null || !$endorse.isStatic) {
      var buf = StringBuffer();
      var endorseClass = "${element.name}Endorse";
      buf.writeln(
          '\nThe EndorseEntity subject class "${element.name}" must have a static field "\$endorse".');
      buf.writeln(
          'Add this to ${element.name}: static final \$endorse = \$$endorseClass();');
      throw EndorseBuilderException(buf.toString());
    }
    final endorseBuf = StringBuffer();
    endorseBuf.writeln('class \$${element.name}Endorse {');
    endorseBuf.writeln('static EndorseSchema schema = EndorseSchema()');
    for (var field in (element as ClassElement).fields) {
      if (field.isStatic) {
        continue;
      }
      endorseBuf.write("..field('${field.name}')");

      var prefix = '';
      if (field.type.isDartCoreString) {
        prefix = '.string()';
      } else if (field.type.isDartCoreInt) {
        prefix = '.integer()';
      } else if (field.type.isDartCoreDouble) {
        prefix = '.float()';
      } else if (field.type.isDartCoreBool) {
        prefix = '.boolean()';
      }

      endorseBuf.write(prefix);
      
      if (_checkForEndorseField.hasAnnotationOfExact(field)) {
        final reader =
            ConstantReader(_checkForEndorseField.firstAnnotationOf(field));
        final stringRules = reader.peek('stringRules').listValue;
        final numberRules = reader.peek('numberRules').listValue;
        final booleanRules = reader.peek('boolRules').listValue;
        final dateRules = reader.peek('dateRules').listValue;
        final require = reader.peek('required')?.boolValue ?? false;
        final allRules = [...stringRules, ...numberRules, ...booleanRules, ...dateRules];
        for (final rule in allRules) {
          final t = rule.getField('value')?.type;
          String v;
          if (t == null) {
            v = '';
          } else if (t.isDartCoreString) {
            v = "'${rule.getField('value').toStringValue().toString()}'";
          } else if (t.isDartCoreInt) {
            v = rule.getField('value').toIntValue().toString();
          }
          final r = (rule.getField('part').toStringValue()).replaceFirst('@', v);
          // print(r);
          endorseBuf.write(r);
        }
        if (require) {
          endorseBuf.write('.required()');
        }
      }
    }
    endorseBuf.writeln(';');
    endorseBuf.writeln('');
    endorseBuf.writeln('Future<ValidationSchema> validate(Map<String, dynamic> m) async {');
    endorseBuf.writeln('return await \$${element.name}Endorse.schema.validate(m);');
    endorseBuf.writeln('}');
    endorseBuf.writeln('}');
    return endorseBuf.toString();
  }
}