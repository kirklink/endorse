import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:source_gen/source_gen.dart';

import 'package:endorse/annotations.dart';

import 'package:endorse_builder/src/endorse_builder_exception.dart';
import 'package:endorse_builder/src/recase_helper.dart';
import 'package:endorse_builder/src/field_helper.dart';

final _checkForEndorseEntity = const TypeChecker.fromRuntime(EndorseEntity);
final _checkForEndorseMap = const TypeChecker.fromRuntime(EndorseMap);
final _checkForEndorseField = const TypeChecker.fromRuntime(EndorseField);

Iterable<DartType> _getGenericTypes(DartType type) {
  return type is ParameterizedType ? type.typeArguments : const [];
}

StringBuffer convertToEndorse(ClassElement clazz, int recase, bool globalAllowNull, {String parent = '', bool parentAllowNull = false, int nestLevel = 0, bool inList = false}) {

  final pageBuf = StringBuffer();
  
  final rulesBuf = StringBuffer();
  final rulesClassName = '_\$${clazz.name}ValidationRules'; 
  rulesBuf.writeln('class ${rulesClassName} {');

  
  final resultBuf = StringBuffer();
  final resultClassName = '_\$${clazz.name}ValidationResult';
  resultBuf.writeln('class ${resultClassName} extends ClassResult {');
  // CLOSE
  // resultBuf.writeln('}');
  final resultBufFields = StringBuffer();
  final resultBufConstructor = StringBuffer();
  resultBufConstructor.writeln('${resultClassName}(Map<String, ResultObject> fields, [');
  // CLOSE
  // resultBufConstructor.writeln(']) : super(fields);');

  final valBuf = StringBuffer();
  final validatorClassName = '_\$${clazz.name}Endorse';
  valBuf.writeln('class ${validatorClassName} implements EndorseClassValidator {');
  valBuf.writeln('final rules = ${rulesClassName}();');
  final valBufValidate = StringBuffer();
  valBufValidate.writeln('@override');
  valBufValidate.writeln('${resultClassName} validate(Map<String, Object> input) {');
  valBufValidate.writeln('final r = <String, ResultObject>{');
  // CLOSE
  // valBufValidate.writeln('};');
  final valBufConstructor = StringBuffer();
  valBufConstructor.write('return ${resultClassName}(r, ');
  // CLOSE
  // valBufConstructor.write(']);');
  // CLOSE
  // valBuf.writeln('}');


  final classElements = <ClassElement>[];
  classElements.add(clazz);
  for (final superType in clazz.allSupertypes) {
    if (superType.element is ClassElement) {
      classElements.add(superType.element);
    }
  }

  for (final klass in classElements) {
    for (final field in klass.fields) {
      if (field.isStatic || field.isSynthetic) {
        continue;
      }
      
      final appName = field.name;
      var jsonName = field.name;
      jsonName = recaseFieldName(recase, jsonName);
      var allowNull = globalAllowNull;

      final validations = <DartObject>[];
      final itemValidations = <DartObject>[];

      if (_checkForEndorseField.hasAnnotationOfExact(field)) {
        final reader = ConstantReader(_checkForEndorseField.firstAnnotationOf(field));
      
        final ignore = reader.peek('ignore')?.boolValue ?? false;
        if (ignore) {
          continue;
        }

        if ((reader.peek('ignoreIfNested')?.boolValue ?? false) && nestLevel > 0) {
          continue;
        }
        

        // TODO: Is this needed?
        if ((reader.peek('ignoreInLists')?.boolValue ?? false) && inList) {
          continue;
        }

        final rename = reader.peek('name')?.stringValue ?? '';
        if (rename.isNotEmpty) {
          jsonName = rename;
        }
        
        allowNull = reader.peek('allowNull')?.boolValue ?? false;

        validations.addAll(reader.peek('validate')?.listValue);
        itemValidations.addAll(reader.peek('itemValidate')?.listValue);
            
      }

      // var inheritedName = jsonName;
      // if (parent.isNotEmpty) {
      //   inheritedName = '$parent?.$jsonName';
      // }
      // final inheritedNameDisplay = inheritedName.replaceAll('?', '');
      
      // String mode = '';
      // if (useDefaultValue) {
      //   mode = ', useDefaultValue: true';
      // } else if (allowNull) {
      //   mode = ', allowNull: true';
      // } else if (parentAllowNull) {
      //   mode = ', allowNull: (e?.$parent == null)';
      // }

      final fieldRulesBuf = StringBuffer();
      Type type;
      bool isValue = false;

      if (validations.any((e) => e.type.getDisplayString() == 'Required')) {
        fieldRulesBuf.write('..isRequired()');
      }
      
      if (field.type.isDartCoreString) {
        fieldRulesBuf.write('..isString(#)');
        type = String;
        isValue = true;
      } else if (field.type.isDartCoreInt) {
        fieldRulesBuf.write('..isInt(@)');
        type = int;
        isValue = true;
      } else if (field.type.isDartCoreDouble) {
        fieldRulesBuf.write('..isDouble(@)');
        type = double;
        isValue = true;
      } else if (field.type.isDartCoreNum) {
        fieldRulesBuf.write('..isNum(@)');
        type = num;
        isValue = true;
      } else if (field.type.isDartCoreBool) {
        fieldRulesBuf.write('..isBoolean(@)');
        type = bool;
        isValue = true;
      } else if (field.type.getDisplayString() == 'DateTime') {
        fieldRulesBuf.write('..isDateTime()');
        type = DateTime;
        isValue = true;
      }
      
      if (isValue) {
        
        rulesBuf.write('ValueResult ${appName}(Object value) => (ValidateValue()');
        resultBufFields.writeln('final ValueResult ${appName};');
        resultBufConstructor.write('this.${appName}, ');
        valBufValidate.writeln("'${appName}': rules.${appName}(input['${jsonName}']),");
        valBufConstructor.write("r['${appName}'], ");

        const fromString = 'fromString: true';
        const toString = 'toString: true';
        const fromStringRules = const ['IntFromString', 'DoubleFromString', 'NumFromString', 'BoolFromString'];

        var fieldRules = fieldRulesBuf.toString();
        
        if (validations.any((e) => fromStringRules.contains(e.type.getDisplayString()))) {
          fieldRules.replaceFirst('@', fromString);
        }

        if (validations.any((e) => e.type.getDisplayString().startsWith('ToString'))) {
          fieldRules.replaceFirst('#', toString);
        }
        
        fieldRules = fieldRules.replaceFirst('@', '');
        fieldRules = fieldRules.replaceFirst('#', '');
        
        fieldRulesBuf.clear();
        fieldRulesBuf.writeln(fieldRules);

        if (validations.isNotEmpty) {
          fieldRulesBuf.write(processValidations(validations, type));
        }
        fieldRulesBuf.write(").from(value, '${jsonName}');");
      }
      rulesBuf.writeln(fieldRulesBuf);



      // List
      // if (field.type.isDartCoreList) {
      //   final elementTypes = _getGenericTypes(field.type);
      //   if (elementTypes.isEmpty) {
      //     throw EndorseBuilderException('The element type of ${field.name} should be specified.');
      //   }
      //   if (elementTypes.first.isDartCoreMap) {
      //     throw EndorseBuilderException('Maps within the list ${field.name} must be implemented by using a class annotated with @EndorseMap');
      //   }
      //   final elementType = elementTypes.first;
      //   // final listBuf = StringBuffer();
      //   // listBuf.write("...{'$jsonName' : ToFs.list(e?.$inheritedName?.map((e) => ");
      //   resultBufFields.writeln('final ValueResult ${appName}');
      //   resultBufConstructor.write('this.${appName}');
      //   valBufValidate.writeln("'${appName}': \$rules.${appName}(input['${jsonName}']),");
      //   valBufConstructor.write("r['${appName}'], ");
      //   rulesBuf.write('ListResult ${appName}(Object value) => (ValidateList.');
      //   fieldRulesBuf.write('..isList()');
        
      //   if (elementType.isDartCoreString) {
      //     rulesBuf.write('fromCore(ValidateValue()');
      //     if (validations.isNotEmpty) {
      //       fieldRulesBuf.write(processValidations(validations, List));
      //     }
      //     fieldRulesBuf.write(', ValidateValue()..isString(#)');
      //     if (itemValidations.isNotEmpty) {
      //       fieldRulesBuf.write(processValidations(validations, String));
      //     }
      //     fieldRulesBuf.write('))');

      //   } else if (elementType.isDartCoreInt) {
          
      //   } else if (elementType.isDartCoreDouble) {
          
      //   } else if (elementType.isDartCoreBool) {
          
      //   } else if (elementType.getDisplayString() == 'DateTime') {
          
      //   } else if (elementType.getDisplayString() == 'Reference') {

      //   }
      //   fieldRulesBuf.write(".from(value);");
          
        // } else if (_checkForLooseMap.hasAnnotationOfExact(elementType.element)
        // || _checkForLooseDocument.hasAnnotationOfExact(elementType.element)) {
        // if (elementType.element is! ClassElement) {
        //   throw LooseBuilderException('LooseDocument or LooseMap must only annotate classes. Field elements "${elementType.getDisplayString()}" are not user defined classes.');
        // }
        //   var childAllowNulls = false;
        //   var childUseDefaultValues = false;
        //   if (_checkForLooseDocument.hasAnnotationOfExact(field.type.element)) {
        //     final reader = ConstantReader(_checkForLooseDocument.firstAnnotationOf(field.type.element));
        //     final thisAllowNulls = reader.peek('allowNulls')?.boolValue ?? false;
        //     final thisUseDefaultValue = reader.peek('useDefaultValue')?.boolValue ?? false;
        //     childAllowNulls = thisAllowNulls ? true : allowNull;
        //     childUseDefaultValues = thisUseDefaultValue ? true : allowNull;
        //   }

        //   if (_checkForLooseMap.hasAnnotationOfExact(field.type.element)) {
        //     final reader = ConstantReader(_checkForLooseMap.firstAnnotationOf(field.type.element));
        //     final thisAllowNulls = reader.peek('allowNulls')?.boolValue ?? false;
        //     final thisUseDefaultValue = reader.peek('useDefaultValue')?.boolValue ?? false;
        //     childAllowNulls = thisAllowNulls ? true : allowNull;
        //     childUseDefaultValues = thisUseDefaultValue ? true : allowNull;
        //   }
        //   listBuf.write("ToFs.map(${convertToEndorse(elementType.element, recase, childAllowNulls, childUseDefaultValues, nestLevel: 0, inList: true)}, '$inheritedNameDisplay'$mode)");
        // }
        // listBuf.write(")?.toList(), '$inheritedNameDisplay'$mode)},");
        // classBuffer.writeln(listBuf.toString());
      
      // }
      
      
      // Class
    //   if (_checkForEndorseMap.hasAnnotationOfExact(field.type.element)
    //     || _checkForEndorseEntity.hasAnnotationOfExact(field.type.element)) {
    //     if (field.type.element is! ClassElement) {
    //       throw EndorseBuilderException('EndorseEntity or EndorseField must only annotate classes. Field "${field.name}" is not a class.');
    //     }
        
    //     var childAllowNulls = false;
    //     if (_checkForEndorseEntity.hasAnnotationOfExact(field.type.element)) {
    //       final reader = ConstantReader(_checkForEndorseEntity.firstAnnotationOf(field.type.element));
    //       final thisAllowNulls = reader.peek('allowNulls')?.boolValue ?? false;
    //       childAllowNulls = thisAllowNulls ? true : allowNull;
    //       nestLevel = nestLevel + 1;
    //     }

    //     if (_checkForEndorseMap.hasAnnotationOfExact(field.type.element)) {
    //       final reader = ConstantReader(_checkForEndorseMap.firstAnnotationOf(field.type.element));
    //       final thisAllowNulls = reader.peek('allowNulls')?.boolValue ?? false;
    //       childAllowNulls = thisAllowNulls ? true : allowNull;
    //     }
    //     // if (_checkForEndorseEntity.hasAnnotationOfExact(field.type.element)) {
    //     //   nestLevel = nestLevel + 1;
    //     // }
    //     classBuffer.write("...{'$jsonName' : ToFs.map(${convertToEndorse(field.type.element, recase, childAllowNulls, parent: inheritedName, parentAllowNull: (allowNull || parentAllowNull), nestLevel: nestLevel)}, '$inheritedNameDisplay'$mode)},");
      
    // }
      // classBuffer.writeln('}');
      // print(classBuffer);
      // return classBuffer.toString();
    }

    
  }
  // CLOSE
  rulesBuf.writeln('}');
  // CLOSE
  resultBufConstructor.writeln(']) : super(fields);');
  // CLOSE
  resultBuf.writeln(resultBufFields);
  resultBuf.writeln(resultBufConstructor);
  resultBuf.writeln('}');
  // CLOSE
  valBufValidate.writeln('};');
  // CLOSE
  valBufConstructor.write(');');
  // CLOSE
  valBuf.writeln(valBufValidate);
  valBuf.writeln(valBufConstructor);
  valBuf.writeln('}}');
  pageBuf.writeAll([rulesBuf, resultBuf, valBuf]);
  return pageBuf;
}
