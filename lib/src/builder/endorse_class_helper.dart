import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart'
    show NullabilitySuffix;
import 'package:source_gen/source_gen.dart';

import 'package:endorse/annotations.dart';

import 'package:endorse/src/builder/endorse_builder_exception.dart';
import 'package:endorse/src/builder/recase_helper.dart';
import 'package:endorse/src/builder/field_helper.dart';
import 'package:endorse/src/builder/build_tracker.dart';

final _checkForEndorseEntity = const TypeChecker.fromRuntime(EndorseEntity);
final _checkForEndorseMap = const TypeChecker.fromRuntime(EndorseMap);
final _checkForEndorseField = const TypeChecker.fromRuntime(EndorseField);

Iterable<DartType> _getGenericTypes(DartType type) {
  return type is ParameterizedType ? type.typeArguments : const [];
}

StringBuffer convertToEndorse(
    ClassElement clazz, int recase, bool globalRequireAll, Tracker tracker,
    {int nestLevel = 0}) {
  final pageBuf = StringBuffer();
  var privatePrefix = '_';
  if (nestLevel > 0) {
    privatePrefix = '__';
  }
  final validatorClassName = '${privatePrefix}\$${clazz.name}Endorse';

  if (tracker.builtClasses.contains(validatorClassName)) {
    return pageBuf;
  } else {
    tracker.builtClasses.add(validatorClassName);
  }

  final rulesBuf = StringBuffer();
  final rulesClassName = '__\$${clazz.name}ValidationRules';
  rulesBuf.writeln('class ${rulesClassName} {');

  final resultBuf = StringBuffer();
  final resultClassName = '__\$${clazz.name}ValidationResult';
  resultBuf.writeln(
      // 'class ${resultClassName} extends ${nestLevel == 0 ? "EndorseResult" : "ClassResult"} {');
      'class ${resultClassName} extends ClassResult {');
  // CLOSE
  // resultBuf.writeln('}');
  final resultBufFields = StringBuffer();
  final resultBufConstructor = StringBuffer();
  resultBufConstructor
      .writeln('${resultClassName}(Map<String, ResultObject> fieldMap, ');
  // CLOSE
  // resultBufConstructor.writeln(']) : super(fields);');

  final valBuf = StringBuffer();
  valBuf.writeln(
      'class ${validatorClassName} implements EndorseClassValidator {');
  valBuf.writeln('final rules = ${rulesClassName}();');
  final valBufValidate = StringBuffer();
  valBufValidate.writeln('@override');
  valBufValidate
      .writeln('${resultClassName} validate(Map<String, Object?> input) {');
  valBufValidate.writeln('final r = <String, ResultObject>{');
  // CLOSE
  // valBufValidate.writeln('};');
  final valBufConstructor = StringBuffer();
  final valBufConstructorMap = StringBuffer();
  final valBufConstructorFields = StringBuffer();
  final entityCreateBuf = StringBuffer();

  valBufConstructor.write('return ${resultClassName}( ');
  valBufConstructorMap.writeln('{');

  entityCreateBuf.writeln("${clazz.name} entity() {");
  entityCreateBuf.writeln("if (\$isValid) {");
  entityCreateBuf.writeln("return ${clazz.name}()");

  // CLOSE
  // valBufConstructor.write(']);');
  // CLOSE
  // valBuf.writeln('}');
  final classElements = <ClassElement>[];
  classElements.add(clazz);
  for (final superType in clazz.allSupertypes) {
    // if (superType.element is ClassElement) {
    //   classElements.add(superType.element);
    // }
    classElements.add(superType.element);
  }

  for (final klass in classElements) {
    for (final field in klass.fields) {
      if (field.isStatic || field.isSynthetic) {
        continue;
      }

      final appName = field.name;
      // var jsonName = field.name;
      var jsonName = recaseFieldName(recase, field.name);

      final validations = <DartObject>[];
      final itemValidations = <DartObject>[];

      final requireAll = globalRequireAll;

      if (_checkForEndorseField.hasAnnotationOfExact(field)) {
        final reader =
            ConstantReader(_checkForEndorseField.firstAnnotationOf(field));

        final ignore = reader.peek('ignore')?.boolValue ?? false;
        if (ignore) {
          continue;
        }

        if ((reader.peek('ignoreIfNested')?.boolValue ?? false) &&
            nestLevel > 0) {
          continue;
        }

        final rename = reader.peek('name')?.stringValue ?? '';
        if (rename.isNotEmpty) {
          jsonName = rename;
        }

        validations.addAll(reader.peek('validate')?.listValue ?? const []);
        itemValidations
            .addAll(reader.peek('itemValidate')?.listValue ?? const []);
      }

      final fieldRulesBuf = StringBuffer();
      final itemRulesBuf = StringBuffer();
      Type? fieldType;
      Type? itemType;
      bool isValue = false;
      bool isList = false;
      bool isClass = false;
      bool canBeNull =
          field.type.nullabilitySuffix == NullabilitySuffix.question;

      if (requireAll ||
          !canBeNull ||
          validations.any((e) =>
              e.type!.getDisplayString(withNullability: false) == 'Required')) {
        fieldRulesBuf.write('..isRequired()');
      }

      if (validations.any((e) =>
          e.type!.getDisplayString(withNullability: false) == 'IsNotNull')) {
        fieldRulesBuf.write('..isNotNull()');
      }

      if (field.type.isDartCoreString) {
        fieldRulesBuf.write('..isString(#)');
        fieldType = String;
        isValue = true;
      } else if (field.type.isDartCoreInt) {
        fieldRulesBuf.write('..isInt(@)');
        fieldType = int;
        isValue = true;
      } else if (field.type.isDartCoreDouble) {
        fieldRulesBuf.write('..isDouble(@)');
        fieldType = double;
        isValue = true;
      } else if (field.type.isDartCoreNum) {
        fieldRulesBuf.write('..isNum(@)');
        fieldType = num;
        isValue = true;
      } else if (field.type.isDartCoreBool) {
        fieldRulesBuf.write('..isBoolean(@)');
        fieldType = bool;
        isValue = true;
      } else if (field.type.getDisplayString(withNullability: false) ==
          'DateTime') {
        fieldRulesBuf.write('..isDateTime()');
        fieldType = DateTime;
        isValue = true;
      }

      if (_checkForEndorseMap.hasAnnotationOfExact(field.type.element!) ||
          _checkForEndorseEntity.hasAnnotationOfExact(field.type.element!)) {
        final mapElement = field.type.element;
        if (mapElement is! ClassElement) {
          throw EndorseBuilderException(
              'EndorseEntity and EdorseMap must only annotate classes. ${field.getDisplayString(withNullability: false)} is not a class.');
        }

        pageBuf.writeln(convertToEndorse(
            mapElement, recase, requireAll, tracker,
            nestLevel: nestLevel + 1));

        itemRulesBuf.write(
            ', __\$${field.type.getDisplayString(withNullability: false)}Endorse()');
        isClass = true;
        fieldRulesBuf.write('..isMap()');
        fieldType = Map;
      }

      if (field.type.isDartCoreList) {
        isList = true;
        fieldType = List;
        final elementTypes = _getGenericTypes(field.type);
        if (elementTypes.isEmpty) {
          throw EndorseBuilderException(
              'The element type of ${field.name} should be specified.');
        }
        if (elementTypes.first.isDartCoreMap) {
          throw EndorseBuilderException(
              'Maps within the list ${field.name} must be implemented by using a class annotated with @EndorseMap');
        }
        final elementType = elementTypes.first;

        fieldRulesBuf.write('..isList()');

        if (elementType.isDartCoreString) {
          itemRulesBuf.write(', ValidateValue()..isString(#)');
          itemType = String;
          isValue = true;
        } else if (elementType.isDartCoreInt) {
          itemRulesBuf.write(', ValidateValue()..isInt(@)');
          itemType = int;
          isValue = true;
        } else if (elementType.isDartCoreDouble) {
          itemRulesBuf.write(', ValidateValue()..isDouble(@)');
          itemType = double;
          isValue = true;
        } else if (elementType.isDartCoreNum) {
          itemRulesBuf.write(', ValidateValue()..isNum(@)');
          itemType = num;
          isValue = true;
        } else if (elementType.isDartCoreBool) {
          itemRulesBuf.write(', ValidateValue()..isBool(@)');
          itemType = bool;
          isValue = true;
        } else if (elementType.getDisplayString(withNullability: false) ==
            'DateTime') {
          itemRulesBuf.write(', ValidateValue()..isDateTime()');
          itemType = DateTime;
          isValue = true;
        } else if (_checkForEndorseEntity
                .hasAnnotationOfExact(elementType.element!) ||
            _checkForEndorseMap.hasAnnotationOfExact(elementType.element!)) {
          isClass = true;
          itemType = Map;
          // itemRulesBuf.write(', ValidateValue()..isMap()');
          itemRulesBuf.write(
              ', __\$${elementType.getDisplayString(withNullability: false)}Endorse()');

          final mapElement = elementType.element;
          if (mapElement is! ClassElement) {
            throw EndorseBuilderException(
                'EndorseEntity and EdorseMap must only annotate classes. ${field.getDisplayString(withNullability: false)} is not a class.');
          }
          pageBuf.writeln(convertToEndorse(
              mapElement, recase, requireAll, tracker,
              nestLevel: nestLevel + 1));
        }
      }

      // var entityFieldType = "";

      if (isValue && !isList) {
        rulesBuf
            .write('ValueResult ${appName}(Object? value) => (ValidateValue()');
        resultBufFields.writeln('final ValueResult ${appName};');
        resultBufConstructor.write('this.${appName}, ');
        valBufValidate
            .writeln("'${appName}': rules.${appName}(input['${jsonName}']),");
        valBufConstructor.write("r['${appName}'] as ValueResult, ");
      }

      if (isList && isValue) {
        rulesBuf.write(
            'ListResult ${appName}(Object? value) => (ValidateList.fromCore(ValidateValue()');
        resultBufFields.writeln('final ListResult ${appName};');
        resultBufConstructor.write('this.${appName}, ');
        valBufValidate
            .writeln("'${appName}': rules.${appName}(input['${jsonName}']),");
        valBufConstructor.write("r['${appName}'] as ListResult, ");
      }

      if (isList && isClass) {
        rulesBuf.write(
            'ListResult ${appName}(Object? value) => (ValidateList.fromEndorse(ValidateValue()');
        resultBufFields.writeln('final ListResult ${appName};');
        resultBufConstructor.write('this.${appName}, ');
        valBufValidate
            .writeln("'${appName}': rules.${appName}(input['${jsonName}']),");
        valBufConstructor.write("r['${appName}'] as ListResult, ");
      }

      if (isClass && !isList) {
        rulesBuf.write(
            'ClassResult ${appName}(Object? value) => (ValidateClass(ValidateValue()');
        final classResultName =
            "__\$${field.type.getDisplayString(withNullability: false)}ValidationResult";
        resultBufFields.writeln('final ${classResultName} ${appName};');
        resultBufConstructor.write('this.${appName}, ');
        valBufValidate
            .writeln("'${appName}': rules.${appName}(input['${jsonName}']),");
        valBufConstructor.write("r['${appName}'] as ${classResultName}, ");
      }

      const fromString = 'fromString: true';
      const toString = 'toString: true';
      const fromStringRules = const [
        'IntFromString',
        'DoubleFromString',
        'NumFromString',
        'BoolFromString'
      ];

      if (isValue && !isList) {
        var fieldRules = fieldRulesBuf.toString();

        if (validations.any((e) => fromStringRules
            .contains(e.type!.getDisplayString(withNullability: false)))) {
          fieldRules = fieldRules.replaceFirst('@', fromString);
        }

        if (validations.any((e) => e.type!
            .getDisplayString(withNullability: false)
            .startsWith('ToString'))) {
          fieldRules = fieldRules.replaceFirst('#', toString);
        }

        fieldRules = fieldRules.replaceFirst('@', '');
        fieldRules = fieldRules.replaceFirst('#', '');

        fieldRulesBuf.clear();
        fieldRulesBuf.writeln(fieldRules);

        if (validations.isNotEmpty) {
          fieldRulesBuf.write(processValidations(validations, fieldType));
        }
      }

      if (isValue && isList) {
        const fromString = 'fromString: true';
        const toString = 'toString: true';
        const fromStringRules = const [
          'IntFromString',
          'DoubleFromString',
          'NumFromString',
          'BoolFromString'
        ];

        var itemRules = itemRulesBuf.toString();

        if (itemValidations.any((e) => fromStringRules
            .contains(e.type!.getDisplayString(withNullability: false)))) {
          itemRules = itemRules.replaceFirst('@', fromString);
        }

        if (itemValidations.any((e) => e.type!
            .getDisplayString(withNullability: false)
            .startsWith('ToString'))) {
          itemRules = itemRules.replaceFirst('#', toString);
        }

        itemRules = itemRules.replaceFirst('@', '');
        itemRules = itemRules.replaceFirst('#', '');

        itemRulesBuf.clear();
        itemRulesBuf.writeln(itemRules);

        if (itemValidations.isNotEmpty) {
          itemRulesBuf.write(processValidations(itemValidations, itemType));
        }
      }

      if (isValue && !isList && !isClass) {
        fieldRulesBuf.write(").from(value, '${jsonName}');");
      }

      if (isList || isClass) {
        itemRulesBuf.write(")).from(value, '${jsonName}');");
        fieldRulesBuf.write(itemRulesBuf);
      }

      rulesBuf.writeln(fieldRulesBuf);
    }
  }
  // CLOSE
  rulesBuf.writeln('}');
  // CLOSE
  resultBufConstructor.writeln(') : super(fieldMap);');
  // CLOSE
  resultBuf.writeln(resultBufFields);
  resultBuf.writeln(resultBufConstructor);
  resultBuf.writeln(entityCreateBuf);
  resultBuf.writeln('}');
  // CLOSE
  // valBufValidate.writeln('};');
  // CLOSE
  valBufConstructorMap.writeln('},');

  valBufConstructor.writeAll([valBufConstructorMap, valBufConstructorFields]);
  valBufConstructor.write(');');
  // CLOSE
  valBuf.writeln(valBufValidate);
  valBuf.writeln(valBufConstructor);
  valBuf.writeln('}}');
  pageBuf.writeAll([rulesBuf, resultBuf, valBuf]);
  return pageBuf;
}
